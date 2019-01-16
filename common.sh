#!/bin/bash -xe
# Check for errors. Piping to tee might hide the exit code of the script
set -o pipefail
eval "$(ssh-agent -s)"
ssh-add ~/wso2-product-performance-test-key.pem

export PATH=$PATH:/usr/local/wum/bin
export PATH=$PATH:/usr/local/apache-maven/bin
export JAVA_HOME=/usr/lib/jvm/jdk1.8.0_192
export CURRENT_DIR="$(realpath .)"
export TEST_ID="${BUILD_NUMBER:-TEST}-$(date +%Y-%m-%d_%H-%M-%S)"
export RESULTS_DIR="$(realpath "results-${TEST_ID}")"

function clone_and_build() {
    for repository in "$@"; do
        echo "Getting files from $repository repository..."
        if [[ ! $repository =~ ^git@github\.com:.*\.git$ ]]; then
            echo "Invalid repository!"
            return 1
        fi
        repo_dir=$(basename "$repository" .git)
        if [[ ! -d $repo_dir ]]; then
            git clone --depth 1 "${repository}"
        else
            pushd $repo_dir
            git status
            # git pull
            git status
            popd
        fi
        echo "Running Maven Build on $repo_dir"
        mvn clean install -V -B -f $repo_dir
    done
}

function exit_handler() {
    rv=$?
    if [[ -f ${CURRENT_DIR}/performance_test_run.log ]] && [[ -d $RESULTS_DIR ]]; then
        mv ${CURRENT_DIR}/performance_test_run.log $RESULTS_DIR
    fi
    ARCHIVE_DIR="${CURRENT_DIR}/archive"
    if [[ $rv -eq 0 ]]; then
        echo "Build is successful."
        mkdir -p ${ARCHIVE_DIR}/successful
        if [[ -d $RESULTS_DIR ]]; then
            mv $RESULTS_DIR ${ARCHIVE_DIR}/successful
            if [[ ! -z $PRODUCT_REPO ]]; then
                # Commit results:
                # Must clone with SSH
                git clone --depth 1 git@github.com:chrishantha/product-apim.git
                pushd product-apim
                git checkout -b performance-test-${test_id}
                mkdir -p performance/benchmarks
                cp $RESULTS_DIR/summary.{csv,md} performance/benchmarks
                git add performance/benchmarks/summary.{csv,md}
                git commit -m "Update performance test results"
                git push -u origin performance-test-${test_id}
                popd
            else
                echo "WARNING: The 'PRODUCT_REPO' environment variable is not set."
            fi
        fi
    else
        echo "Build failed!"
        mkdir -p ${ARCHIVE_DIR}/failed
        if [[ -d $RESULTS_DIR ]]; then
            mv $RESULTS_DIR ${ARCHIVE_DIR}/failed
        fi
    fi
    exit $rv
}

trap exit_handler EXIT
