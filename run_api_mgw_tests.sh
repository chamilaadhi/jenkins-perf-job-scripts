#!/bin/bash -xe
. ../common.sh

declare -a repositories
repositories+=("git@github.com:chrishantha/performance-common.git")
repositories+=("git@github.com:chrishantha/performance-apim.git")

clone_and_build "${repositories[@]}"

echo "Extracting scripts..."
cd performance-apim/distribution/target
tar -xf *.tar.gz

./cloudformation/get_wum_updated_wso2_product.sh -p wso2am -v ${PRODUCT_VERSION} -l ${PWD}
./cloudformation/get_wum_updated_wso2_product.sh -p wso2am-micro-gw -v ${PRODUCT_VERSION} -l ${PWD}

./cloudformation/run-micro-gw-performance-tests.sh -f *.tar.gz \
    -d ${RESULTS_DIR} \
    -k ~/keys/apim-perf-test.pem -n 'apim-perf-test' \
    -j ~/apache-jmeter-4.0.tgz -o ~/jdk-8u192-linux-x64.tar.gz \
    -g ~/gcviewer-1.36-SNAPSHOT.jar -s 'wso2-api-mgw-test-' \
    -b apimgwperformancetest -r 'us-east-1' \
    -J "${JMETER_CLIENT_EC2_INSTANCE_TYPE}" \
    -S "${JMETER_SERVER_EC2_INSTANCE_TYPE}" \
    -N "${BACKEND_EC2_INSTANCE_TYPE}" \
    -a ${PWD}/wso2am.zip \
    -c ${PWD}/wso2am-micro-gw.zip \
    -A ${WSO2_API_MANAGER_EC2_INSTANCE_TYPE} \
    -t ${NUMBER_OF_STACKS} \
    -p ${PARALLEL_PARAMETER_OPTION} \
    -- ${RUN_PERF_OPTS} | tee ${CURRENT_DIR}/performance_test_run.log
