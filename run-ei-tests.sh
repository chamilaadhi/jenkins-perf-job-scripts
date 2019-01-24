#!/bin/bash -xe
. ../common.sh

declare -a repositories
repositories+=("git@github.com:chrishantha/performance-common.git")
repositories+=("git@github.com:chrishantha/performance-ei.git")

clone_and_build "${repositories[@]}"

echo "Extracting scripts..."
cd performance-ei/distribution/target
tar -xf *.tar.gz

./cloudformation/get-wum-updated-wso2-product.sh -p wso2ei -v ${PRODUCT_VERSION} -l ${PWD}

./cloudformation/run-performance-tests.sh -f *.tar.gz \
    -d ${RESULTS_DIR} \
    -k ~/keys/ei-perf-test.pem -n 'ei-perf-test' \
    -j ~/apache-jmeter-4.0.tgz -o ~/jdk-8u192-linux-x64.tar.gz \
    -g ~/gcviewer-1.36-SNAPSHOT.jar -s 'wso2-ei-test-' \
    -b ei-performance-test -r 'us-east-1' \
    -J "${JMETER_CLIENT_EC2_INSTANCE_TYPE}" \
    -S "${JMETER_SERVER_EC2_INSTANCE_TYPE}" \
    -N "${BACKEND_EC2_INSTANCE_TYPE}" \
    -e ${PWD}/wso2ei.zip \
    -E ${WSO2_ENTERPISE_INTEGRATOR_EC2_INSTANCE_TYPE} \
    -t ${NUMBER_OF_STACKS} \
    -p ${PARALLEL_PARAMETER_OPTION} \
    -- ${RUN_PERF_OPTS} | tee ${CURRENT_DIR}/performance_test_run.log
