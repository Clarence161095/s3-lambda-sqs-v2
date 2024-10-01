const { SQS } = require("@aws-sdk/client-sqs");

const sqs = new SQS({ region: process.env.AWS_REGION });

exports.handler = async (event) => {
  const record = event.Records[0];
  console.log("event :>> ", event);
  console.log("record :>> ", record);
  const bucketName = record.s3.bucket.name;
  const fileName = decodeURIComponent(record.s3.object.key.replace(/\+/g, " "));

  const message = {
    bucket: bucketName,
    file: fileName,
    type: "rc",
  };

  const params = {
    MessageBody: JSON.stringify(message),
    QueueUrl: process.env.SQS_QUEUE_URL,
  };

  try {
    await sqs.sendMessage(params);
    console.log("Message sent to SQS");
    return { statusCode: 200, body: "Message sent to SQS" };
  } catch (error) {
    console.error("Error sending message to SQS:", error);
    return { statusCode: 500, body: "Error sending message to SQS" };
  }
};
