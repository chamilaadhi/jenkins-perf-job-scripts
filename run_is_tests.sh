#!/bin/bash -xe
. ../common.sh

export PRODUCT_REPO="git@github.com:wso2/product-is.git"

declare -a repositories
repositories+=("git@github.com:chrishantha/performance-common.git")
repositories+=("git@github.com:chrishantha/performance-is.git")

clone_and_build "${repositories[@]}"

cd performance-is/cloudformation

./init-performance-tests.sh -f ../distribution/target/*.tar.gz \
    -d ${RESULTS_DIR} \
    -k ~/keys/is-perf-test.pem \
    -a "${IS_AWS_ACCESS_KEY_ID}" \
    -s "${IS_AWS_SECRET_ACCESS_KEY}" \
    -c "is-perf-cert" \
    -j ~/apache-jmeter-4.0.tgz -o ~/jdk-8u192-linux-x64.tar.gz \
    -g ~/gcviewer-1.36-SNAPSHOT.jar \
    -n "${WUM_USERNAME}" \
    -e "${WUM_PASSWORD}" \
    -i "${WSO2_IDENTITY_SERVER_EC2_INSTANCE_TYPE}" \
    -b "${JMETER_CLIENT_EC2_INSTANCE_TYPE}" \
    -- ${RUN_PERF_OPTS} | tee ${CURRENT_DIR}/performance_test_run.log
