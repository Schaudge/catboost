package ai.catboost.spark

//import org.apache.spark.ml.{Model,Predictor}

import collection.mutable
import collection.mutable.HashMap

import java.net._
import java.nio.file._
import java.util.concurrent.{ExecutorCompletionService,Executors}

import org.json4s._
import org.json4s.jackson.JsonMethods._
import org.json4s.JsonDSL._

import org.apache.spark.ml.linalg.Vector
import org.apache.spark.ml.param._
import org.apache.spark.sql.{DataFrame,Dataset,Row}
import org.apache.spark.TaskContext

import ru.yandex.catboost.spark.catboost4j_spark.core.src.native_impl
import ru.yandex.catboost.spark.catboost4j_spark.core.src.native_impl.QuantizedFeaturesInfoPtr

/**
 * Base trait with common functionality for both [[CatBoostClassifier]] and [[CatBoostRegressor]]
 */
trait CatBoostPredictorTrait[
  Learner <: org.apache.spark.ml.Predictor[Vector, Learner, Model],
  Model <: org.apache.spark.ml.PredictionModel[Vector, Model]]
    extends org.apache.spark.ml.Predictor[Vector, Learner, Model]
      with params.DatasetParamsTrait
{
  this: params.TrainingParamsTrait =>

  private def saveDatasetsForMaster(
    quantizedTrainPool: Pool,
    quantizedEvalPools: Array[Pool],
    threadCount: Int
  ) : (Path, Array[Path]) = {
    val trainPoolAsFile = DataHelpers.downloadQuantizedPoolToTempFile(
      quantizedTrainPool,
      includeFeatures=false,
      threadCount
    )
    val evalPoolsAsFiles = quantizedEvalPools.map {
      evalPool => DataHelpers.downloadQuantizedPoolToTempFile(
        evalPool,
        includeFeatures=true,
        threadCount
      )
    }.toArray
    (trainPoolAsFile, evalPoolsAsFiles)
  }

  // override in descendants if necessary
  protected def preprocessBeforeTraining(
    quantizedTrainPool: Pool,
    quantizedEvalPools: Array[Pool]
  ) : (Pool, Array[Pool]) = {
    (quantizedTrainPool, quantizedEvalPools)
  }

  protected def createModel(fullModel: native_impl.TFullModel) : Model;

  protected override def train(dataset: Dataset[_]): Model = {
    val pool = new Pool(dataset.asInstanceOf[DataFrame])
      .setLabelCol(getLabelCol)
      .setFeaturesCol(getFeaturesCol)
      .setWeightCol(getWeightCol)

    fit(pool)
  }

  /**
   * Additional variant of `fit` method that accepts CatBoost's [[Pool]] s and allows to specify additional
   * datasets for computing evaluation metrics and overfitting detection similarily to CatBoost's other APIs.
   *
   * @param trainPool The input training dataset.
   * @param evalPools The validation datasets used for the following processes:
   *  - overfitting detector
   *  - best iteration selection
   *  - monitoring metrics' changes
   * @return trained model
   */
  def fit(trainPool: Pool, evalPools: Array[Pool] = Array[Pool]()): Model = {
    val spark = trainPool.data.sparkSession

    val partitionCount = get(sparkPartitionCount).getOrElse(SparkHelpers.getWorkerCount(spark))

    val quantizedTrainPool = if (trainPool.isQuantized) {
      trainPool
    } else {
      trainPool.quantize(this) // this as QuantizationParamsTrait
    }.repartition(partitionCount)

    // TODO(akhropov): eval pools are not distributed for now, so they are not repartitioned
    val quantizedEvalPools = evalPools.map {
      evalPool => {
        if (evalPool.isQuantized) {
          evalPool
        } else {
          evalPool.quantize(quantizedTrainPool.quantizedFeaturesInfo)
        }
      }
    }
    val (preprocessedTrainPool, preprocessedEvalPools) = preprocessBeforeTraining(
      quantizedTrainPool,
      quantizedEvalPools
    )

    val catBoostJsonParams = ai.catboost.spark.params.Helpers.sparkMlParamsToCatBoostJsonParams(this)

    val master = impl.Master(preprocessedTrainPool, preprocessedEvalPools, compact(catBoostJsonParams))

    val trainingDriver : TrainingDriver = new TrainingDriver(
      listeningPort = 0,
      workerCount = partitionCount,
      startMasterCallback = master.trainCallback,
      workerInitializationTimeout = getOrDefault(workerInitializationTimeout)
    )

    val listeningPort = trainingDriver.getListeningPort

    val ecs = new ExecutorCompletionService[Unit](Executors.newFixedThreadPool(2))

    val trainingDriverFuture = ecs.submit(trainingDriver, ())

    val workers = new impl.Workers(spark, listeningPort, preprocessedTrainPool, catBoostJsonParams)

    val workersFuture = ecs.submit(workers, ())

    val firstCompletedFuture = ecs.take()

    if (firstCompletedFuture == workersFuture) {
      impl.Helpers.checkOneFutureAndWaitForOther(workersFuture, trainingDriverFuture, "workers")
    } else { // firstCompletedFuture == trainingDriverFuture
      impl.Helpers.checkOneFutureAndWaitForOther(trainingDriverFuture, workersFuture, "master")
    }

    createModel(master.nativeModelResult)
  }
}
