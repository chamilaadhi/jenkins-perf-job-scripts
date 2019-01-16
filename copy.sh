#!/bin/bash -xe

git="git@github.com:chrishantha/performance-common.git"
if [[ ! $git =~ ^git@github\.com:.*\.git$ ]]; then
    echo "Invalid repository!"
    exit 1
fi

scp common.sh wso2-product-performance-test:/build/jenkins-home/workspace/product-performance-test
scp run_apim_tests.sh wso2-product-performance-test:/build/jenkins-home/workspace/product-performance-test/apim-performance-execution
scp run_ei_tests.sh wso2-product-performance-test:/build/jenkins-home/workspace/product-performance-test/ei-performance-execution
