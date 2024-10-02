#!/bin/bash

PREFIX="lab-practice-101-"

# API Gateway
aws apigateway get-rest-apis | jq -r '.items[] | select(.name | startswith("'"$PREFIX"'")) | .id' | while read x; do
    aws apigateway delete-rest-api --rest-api-id $x
done

# Lambda
aws lambda list-functions | jq -r '.Functions[] | select(.FunctionName | startswith("'"$PREFIX"'")) | .FunctionName' | while read x; do
    aws lambda delete-function --function-name $x
done

# SQS
aws sqs list-queues --queue-name-prefix $PREFIX | jq -r '.QueueUrls[]' | while read x; do
    aws sqs delete-queue --queue-url $x
done

# DynamoDB
aws dynamodb list-tables | jq -r '.TableNames[] | select(startswith("'"$PREFIX"'"))' | while read x; do
    aws dynamodb delete-table --table-name $x
done

# CloudWatch Logs
aws logs describe-log-groups --log-group-name-prefix "/aws/lambda/$PREFIX" | jq -r '.logGroups[] | .logGroupName' | while read x; do
    aws logs delete-log-group --log-group-name $x
done

# CodeBuild
aws codebuild list-projects | jq -r '.projects[] | select(startswith("'"$PREFIX"'"))' | while read x; do
    aws codebuild delete-project --name $x
done

# CodePipeline
aws codepipeline list-pipelines | jq -r '.pipelines[] | select(.name | startswith("'"$PREFIX"'")) | .name' | while read x; do
    aws codepipeline delete-pipeline --name $x
done

# CloudFormation
aws cloudformation list-stacks | jq -r '.StackSummaries[] | select(.StackName | startswith("'"$PREFIX"'")) | .StackName' | while read x; do
    aws cloudformation delete-stack --stack-name $x
done

# RDS
aws rds describe-db-instances | jq -r '.DBInstances[] | select(.DBInstanceIdentifier | startswith("'"$PREFIX"'")) | .DBInstanceIdentifier' | while read x; do
    aws rds delete-db-instance --db-instance-identifier $x --skip-final-snapshot
done

# ElastiCache
aws elasticache describe-cache-clusters | jq -r '.CacheClusters[] | select(.CacheClusterId | startswith("'"$PREFIX"'")) | .CacheClusterId' | while read x; do
    aws elasticache delete-cache-cluster --cache-cluster-id $x
done

# EC2
aws ec2 describe-instances --filters "Name=tag:Name,Values=$PREFIX*" | jq -r '.Reservations[] | .Instances[] | .InstanceId' | while read x; do
    aws ec2 terminate-instances --instance-ids $x
done

# Roles
aws iam list-roles | jq -r '.Roles[] | select(.RoleName | startswith("'"$PREFIX"'")) | .RoleName' | while read role; do
    # Detach all managed policies
    aws iam list-attached-role-policies --role-name $role | jq -r '.AttachedPolicies[].PolicyArn' | while read policy_arn; do
        aws iam detach-role-policy --role-name $role --policy-arn $policy_arn
    done
    
    # Delete all inline policies
    aws iam list-role-policies --role-name $role | jq -r '.PolicyNames[]' | while read policy_name; do
        aws iam delete-role-policy --role-name $role --policy-name $policy_name
    done
    
    # Delete the role
    aws iam delete-role --role-name $role
done

# Policies
aws iam list-policies --scope Local | jq -r '.Policies[] | select(.PolicyName | startswith("'"$PREFIX"'")) | .Arn' | while read policy_arn; do
    # Detach policy from all entities
    aws iam list-entities-for-policy --policy-arn $policy_arn | jq -r '.PolicyRoles[].RoleName' | while read role; do
        aws iam detach-role-policy --role-name $role --policy-arn $policy_arn
    done
    
    # Delete all versions except the default version
    aws iam list-policy-versions --policy-arn $policy_arn | jq -r '.Versions[] | select(.IsDefaultVersion==false) | .VersionId' | while read version; do
        aws iam delete-policy-version --policy-arn $policy_arn --version-id $version
    done
    
    # Delete the policy
    aws iam delete-policy --policy-arn $policy_arn
done

# S3 - Remember alway remove S3 after all
aws s3api list-buckets --query "Buckets[?starts_with(Name, '$PREFIX')].Name" --output text | tr '\t' '\n' | while read bucket; do
  # Delete all objects from the bucket
  aws s3api delete-objects --bucket "$bucket" --delete "$(aws s3api list-object-versions --bucket "$bucket" --output=json --query='{Objects: Versions[].{Key:Key,VersionId:VersionId}}')"
  
  # Delete all object delete markers from the bucket
  aws s3api delete-objects --bucket "$bucket" --delete "$(aws s3api list-object-versions --bucket "$bucket" --output=json --query='{Objects: DeleteMarkers[].{Key:Key,VersionId:VersionId}}')"
  
  # Delete the bucket
  aws s3 rb "s3://$bucket" --force
done