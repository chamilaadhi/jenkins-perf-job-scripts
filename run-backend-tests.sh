#!/bin/bash -xe
. ../common.sh

declare -a repositories
repositories+=("git@github.com:chrishantha/performance-common.git")

clone_and_build "${repositories[@]}"

echo "Extracting scripts..."
cd performance-common/distribution/target
tar -xf *.tar.gz

./cloudformation/run-backend-tests.sh -f *.tar.gz \
    -d ${RESULTS_DIR} \
    -k ~/keys/apim-perf-test.pem -n 'apim-perf-test' \
    -j ~/apache-jmeter-4.0.tgz -o ~/jdk-8u192-linux-x64.tar.gz \
    -g ~/gcviewer-1.36-SNAPSHOT.jar -s 'backend-test-' \
    -b backendperformancetest -r 'us-east-1' \
    -J "${JMETER_CLIENT_EC2_INSTANCE_TYPE}" \
    -S "${JMETER_SERVER_EC2_INSTANCE_TYPE}" \
    -N "${BACKEND_EC2_INSTANCE_TYPE}" \
    -t ${NUMBER_OF_STACKS} \
    -p ${PARALLEL_PARAMETER_OPTION} \
    -- ${RUN_PERF_OPTS} | tee ${CURRENT_DIR}/performance_test_run.log
