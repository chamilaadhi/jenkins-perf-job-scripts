#!/bin/bash -xe

scp common.sh wso2-product-performance-test:/build/jenkins-home/workspace/product-performance-test
scp run-apim-tests.sh wso2-product-performance-test:/build/jenkins-home/workspace/product-performance-test/apim-performance-execution
scp run-api-mgw-tests.sh wso2-product-performance-test:/build/jenkins-home/workspace/product-performance-test/apim-microgw-performance-execution
scp run-ei-tests.sh wso2-product-performance-test:/build/jenkins-home/workspace/product-performance-test/ei-performance-execution
scp run-is-tests.sh wso2-product-performance-test:/build/jenkins-home/workspace/product-performance-test/is-performance-execution
scp run-backend-tests.sh wso2-product-performance-test:/build/jenkins-home/workspace/product-performance-test/backend-performance-execution
