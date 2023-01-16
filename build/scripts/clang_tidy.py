import argparse
import contextlib
import json
import os
import re
import shutil
import tempfile

import subprocess
import yaml


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("--testing-src", required=True)
    parser.add_argument("--clang-tidy-bin", required=True)
    parser.add_argument("--config-validation-script", required=True)
    parser.add_argument("--ymake-python", required=True)
    parser.add_argument("--tidy-json", required=True)
    parser.add_argument("--source-root", required=True)
    parser.add_argument("--build-root", required=True)
    parser.add_argument("--default-config-file", required=True)
    parser.add_argument("--project-config-file", required=True)
    parser.add_argument("--export-fixes", required=True)
    parser.add_argument("--checks", required=False, default="")
    parser.add_argument("--header-filter", required=False, default=None)
    return parser.parse_known_args()


def generate_compilation_database(clang_cmd, source_root, filename, path):
    compile_database = [
        {
            "file": filename,
            "command": subprocess.list2cmdline(clang_cmd),
            "directory": source_root,
        }
    ]
    compilation_database_json = os.path.join(path, "compile_commands.json")
    with open(compilation_database_json, "w") as afile:
        json.dump(compile_database, afile)
    return compilation_database_json


@contextlib.contextmanager
def gen_tmpdir():
    path = tempfile.mkdtemp()
    yield path
    shutil.rmtree(path)


@contextlib.contextmanager
def gen_tmpfile():
    _, path = tempfile.mkstemp()
    yield path
    os.remove(path)


def load_profile(path):
    if os.path.exists(path):
        files = os.listdir(path)
        if len(files) == 1:
            with open(os.path.join(path, files[0])) as afile:
                return json.load(afile)["profile"]
        elif len(files) > 1:
            return {
                "error": "found several profile files: {}".format(files),
            }
    return {
        "error": "profile file is missing",
    }


def load_fixes(path):
    if os.path.exists(path):
        with open(path, 'r') as afile:
            return afile.read()
    else:
        return ""


def is_generated(testing_src, build_root):
    return testing_src.startswith(build_root)


def generate_outputs(output_json):
    output_obj = os.path.splitext(output_json)[0] + ".o"
    open(output_obj, "w").close()
    open(output_json, "w").close()


def split_strip(s):
    return [x.strip() for x in s.split(',')]


def merge_tidy_configs(base_config_path, additional_config_path, result_config_path):
    """
    config has next format:
    {
        "Checks": "check1, check2, ...",
        "CheckOptions": [{"key": "option1_name", "value": "option1_value"}, {"key": "option2_name", "value": "option2_value"}, ...]
    }
    """
    def merge_checks(base_checks, additional_checks):
        base_checks = base_checks.strip(",\n")
        additional_checks = additional_checks.strip(",\n")
        base_checks = split_strip(base_checks)
        additional_checks = split_strip(additional_checks)
        result_checks = base_checks
        for check in additional_checks:
            if check not in result_checks:
                result_checks.append(check)
        return ", ".join(result_checks)

    def merge_options(base_options, additional_options):
        result_options = {}
        for opt in base_options:
            result_options[opt["key"]] = opt["value"]
        for opt in additional_options:
            result_options[opt["key"]] = opt["value"]
        result_opions_list = []
        for k, v in result_options.items():
            result_opions_list.append({"key": k, "value": v})
        return result_opions_list

    with open(base_config_path, 'r') as afile:
        base_config = yaml.safe_load(afile)
    with open(additional_config_path, 'r') as afile:
        additional_config = yaml.safe_load(afile)

    result_config = {
        "Checks": merge_checks(base_config["Checks"], additional_config["Checks"]),
        "CheckOptions": merge_options(base_config["CheckOptions"], additional_config["CheckOptions"])
    }
    with open(result_config_path, 'w') as afile:
        yaml.safe_dump(result_config, afile)
    return result_config_path


def main():
    args, clang_cmd = parse_args()
    clang_tidy_bin = args.clang_tidy_bin
    output_json = args.tidy_json
    generate_outputs(output_json)
    if is_generated(args.testing_src, args.build_root):
        return
    if args.header_filter is None:
        header_filter = r"^" + re.escape(os.path.dirname(args.testing_src)) + r".*"  # .pb.h files will be excluded because they are not in source_root
    else:
        header_filter = r"^(" + args.header_filter + r").*"

    with gen_tmpdir() as profile_tmpdir, gen_tmpdir() as db_tmpdir, gen_tmpfile() as fixes_file, gen_tmpdir() as config_dir:
        result_config_file = args.default_config_file
        if args.project_config_file != args.default_config_file:
            result_config = os.path.join(config_dir, "result_tidy_config.yaml")
            filtered_config = os.path.join(config_dir, "filtered_tidy_config.yaml")
            subprocess.check_call([args.ymake_python, args.config_validation_script, "--input-config-path", args.project_config_file, "--result-config-path", filtered_config])
            result_config_file = merge_tidy_configs(base_config_path=args.default_config_file, additional_config_path=filtered_config, result_config_path=result_config)
        compile_command_path = generate_compilation_database(clang_cmd, args.source_root, args.testing_src, db_tmpdir)
        cmd = [
            clang_tidy_bin,
            args.testing_src,
            "-p",
            compile_command_path,
            "--warnings-as-errors",
            "*",
            "--config-file",
            result_config_file,
            "--header-filter",
            header_filter,
            "--use-color",
            "--enable-check-profile",
            "--store-check-profile={}".format(profile_tmpdir),
        ]
        if args.export_fixes == "yes":
            cmd += ["--export-fixes", fixes_file]

        if args.checks:
            cmd += ["--checks", args.checks]
        res = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        out, err = res.communicate()
        exit_code = res.returncode
        profile = load_profile(profile_tmpdir)
        testing_src = os.path.relpath(args.testing_src, args.source_root)
        tidy_fixes = load_fixes(fixes_file)

    with open(output_json, "wb") as afile:
        json.dump(
            {
                "file": testing_src,
                "exit_code": exit_code,
                "profile": profile,
                "stderr": err,
                "stdout": out,
                "fixes": tidy_fixes,
            },
            afile,
        )


if __name__ == "__main__":
    main()
