const { DynamoDBClient } = require('@aws-sdk/client-dynamodb');
const { DynamoDBDocumentClient } = require('@aws-sdk/lib-dynamodb');

const region = process.env.AWS_REGION || 'us-east-1';

// DynamoDB Client will automatically use IAM roles (EC2 instance profile, ECS task role) 
// or local AWS credentials from environment/credentials file.
const ddbClient = new DynamoDBClient({
  region
});

const marshallOptions = {
  convertEmptyValues: false,
  removeUndefinedValues: true,
  convertClassInstanceToMap: false
};

const unmarshallOptions = {
  wrapNumbers: false
};

const ddbDocClient = DynamoDBDocumentClient.from(ddbClient, {
  marshallOptions,
  unmarshallOptions
});

module.exports = {
  ddbClient,
  ddbDocClient
};
