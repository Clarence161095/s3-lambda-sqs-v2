#!/bin/bash
aws apigateway get-rest-apis | jq -r '.items[] | .id' | while read x; do aws apigateway delete-rest-api --rest-api-id $x; done
# aws s3 ls | awk '{print $3}' | while read x; do aws s3 rb s3://$x --force; done
aws lambda list-functions | jq -r '.Functions[] | .FunctionName' | while read x; do aws lambda delete-function --function-name $x; done
aws sqs list-queues | jq -r '.QueueUrls[]' | while read x; do aws sqs delete-queue --queue-url $x; done
aws dynamodb list-tables | jq -r '.TableNames[]' | while read x; do aws dynamodb delete-table --table-name $x; done
aws logs describe-log-groups | jq -r '.logGroups[] | .logGroupName' | while read x; do aws logs delete-log-group --log-group-name $x; done
aws codebuild list-projects | jq -r '.projects[]' | while read x; do aws codebuild delete-project --name $x; done
aws codepipeline list-pipelines | jq -r '.pipelines[] | .name' | while read x; do aws codepipeline delete-pipeline --name $x; done
aws cloudformation list-stacks | jq -r '.StackSummaries[] | .StackName' | while read x; do aws cloudformation delete-stack --stack-name $x; done
aws rds describe-db-instances | jq -r '.DBInstances[] | .DBInstanceIdentifier' | while read x; do aws rds delete-db-instance --db-instance-identifier $x --skip-final-snapshot; done
aws elasticache describe-cache-clusters | jq -r '.CacheClusters[] | .CacheClusterId' | while read x; do aws elasticache delete-cache-cluster --cache-cluster-id $x; done
aws ec2 describe-instances | jq -r '.Reservations[] | .Instances[] | .InstanceId' | while read x; do aws ec2 terminate-instances --instance-ids $x; done
sh remove-all-s3.sh