LIBRARY()

LICENSE(
    MIT AND
    NCSA
)

VERSION(1.3.0)

LICENSE_TEXTS(.yandex_meta/licenses.list.txt)



CFLAGS(
    -DONNX_ML=1
    -DONNX_NAMESPACE=onnx
)

PEERDIR(
    contrib/libs/onnx/proto
    contrib/libs/protobuf
)

ADDINCL(
    contrib/libs/onnx
)

SRCDIR(contrib/libs/onnx/onnx)

SRCS(
    common/interned_strings.cc
    common/graph_node_list.h
    common/status.h
    common/stl_backports.h
    common/array_ref.h
    common/ir.h
    common/tensor.h
    common/status.cc
    common/ir_pb_converter.cc
    common/model_helpers.h
    common/constants.h
    common/assertions.cc
    common/model_helpers.cc
    common/assertions.h
    common/ir_pb_converter.h
    proto_utils.h
    onnxifi_loader.h
    string_utils.h
    optimizer/pass.h
    optimizer/pass_manager.cc
    optimizer/pass_registry.h
    optimizer/optimize.cc
    optimizer/pass_registry.cc
    optimizer/passes/extract_constant_to_initializer.h
    optimizer/passes/fuse_matmul_add_bias_into_gemm.h
    optimizer/passes/fuse_pad_into_conv.h
    optimizer/passes/fuse_add_bias_into_conv.h
    optimizer/passes/eliminate_unused_initializer.h
    optimizer/passes/fuse_consecutive_transposes.h
    optimizer/passes/fuse_consecutive_concats.h
    optimizer/passes/eliminate_nop_transpose.h
    optimizer/passes/fuse_transpose_into_gemm.h
    optimizer/passes/fuse_bn_into_conv.h
    optimizer/passes/fuse_consecutive_log_softmax.h
    optimizer/passes/eliminate_nop_dropout.h
    optimizer/passes/eliminate_nop_monotone_argmax.h
    optimizer/passes/lift_lexical_references.h
    optimizer/passes/eliminate_identity.h
    optimizer/passes/eliminate_deadend.h
    optimizer/passes/split.h
    optimizer/passes/eliminate_nop_pad.h
    optimizer/passes/fuse_consecutive_reduce_unsqueeze.h
    optimizer/passes/nop.h
    optimizer/passes/fuse_consecutive_squeezes.h
    optimizer/pass.cc
    optimizer/pass_manager.h
    onnx-operators_pb.h
    checker.h
    checker.cc
    onnx_pb.h
    version_converter/adapters/maxpool_8_7.h
    version_converter/adapters/averagepool_7_6.h
    version_converter/adapters/set_is_test.h
    version_converter/adapters/broadcast_forward_compatibility.h
    version_converter/adapters/gemm_7_6.h
    version_converter/adapters/type_restriction.h
    version_converter/adapters/remove_consumed_inputs.h
    version_converter/adapters/no_previous_version.h
    version_converter/adapters/reshape_4_5.h
    version_converter/adapters/sum_8_7.h
    version_converter/adapters/broadcast_backward_compatibility.h
    version_converter/adapters/reshape_5_4.h
    version_converter/adapters/adapter.h
    version_converter/adapters/compatible.h
    version_converter/adapters/gemm_6_7.h
    version_converter/adapters/batch_normalization_6_5.h
    version_converter/adapters/dropout_6_7.h
    version_converter/adapters/concat_3_4.h
    version_converter/adapters/batch_normalization_6_7.h
    version_converter/BaseConverter.h
    version_converter/convert.cc
    version_converter/helper.cc
    onnxifi.h
    onnxifi_utils.h
    shape_inference/implementation.cc
    defs/experiments/defs.cc
    defs/experiments/experiments_functions.cc
    defs/schema.h
    defs/logical/old.cc
    defs/logical/defs.cc
    defs/tensor/old.cc
    defs/tensor/defs.cc
    defs/operator_sets-ml.h
    defs/data_type_utils.h
    defs/function.cc
    defs/operator_sets.h
    defs/function.h
    defs/data_type_utils.cc
    defs/nn/old.cc
    defs/nn/defs.cc
    defs/schema.cc
    defs/math/old.cc
    defs/math/defs.cc
    defs/controlflow/old.cc
    defs/controlflow/defs.cc
    defs/generator/old.cc
    defs/generator/defs.cc
    defs/shape_inference.h
    defs/traditionalml/old.cc
    defs/traditionalml/defs.cc
    defs/rnn/old.cc
    defs/rnn/defs.cc
    defs/reduction/defs.cc
    onnxifi_utils.cc
)

END()

RECURSE(
    proto
)
