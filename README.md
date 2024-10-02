# s3-lambda-sqs-v2

## CloudFormation

### Create stack

```bash
aws cloudformation create-stack \
  --stack-name s3-lambda-sqs-v2 \
  --template-body file://cloudformation.yaml \
  --parameters file://parameters.json \
  --capabilities CAPABILITY_NAMED_IAM
```

### Update stack

```bash
aws cloudformation update-stack \
  --stack-name s3-lambda-sqs-v2 \
  --template-body file://cloudformation.yaml \
  --parameters file://parameters.json \
  --capabilities CAPABILITY_NAMED_IAM
```

### Create change set

```bash
aws cloudformation create-change-set \
  --stack-name s3-lambda-sqs-v2 \
  --change-set-name s3-lambda-sqs-v2-change-set \
  --template-body file://cloudformation.yaml \
  --parameters file://parameters.json \
  --capabilities CAPABILITY_NAMED_IAM
```

### Describe change set

```bash
aws cloudformation describe-change-set \
  --change-set-name s3-lambda-sqs-v2-change-set \
  --stack-name s3-lambda-sqs-v2
```

### Execute change set

```bash
aws cloudformation execute-change-set \
  --change-set-name s3-lambda-sqs-v2-change-set \
  --stack-name s3-lambda-sqs-v2
```

### Delete stack

```bash
aws cloudformation delete-stack \
  --stack-name s3-lambda-sqs-v2
```
