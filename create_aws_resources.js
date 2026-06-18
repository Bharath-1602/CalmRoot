const { DynamoDBClient, CreateTableCommand, DescribeTableCommand } = require('@aws-sdk/client-dynamodb');
const { S3Client, CreateBucketCommand, HeadBucketCommand } = require('@aws-sdk/client-s3');

const REGION = process.env.AWS_REGION || 'us-east-1';

const ddb = new DynamoDBClient({ region: REGION });
const s3 = new S3Client({ region: REGION });

const tablesSpec = [
  {
    TableName: 'calmroot-users',
    KeySchema: [
      { AttributeName: 'userId', KeyType: 'HASH' },
      { AttributeName: 'SK', KeyType: 'RANGE' }
    ],
    AttributeDefinitions: [
      { AttributeName: 'userId', AttributeType: 'S' },
      { AttributeName: 'SK', AttributeType: 'S' },
      { AttributeName: 'email', AttributeType: 'S' }
    ],
    GlobalSecondaryIndexes: [
      {
        IndexName: 'email-index',
        KeySchema: [{ AttributeName: 'email', KeyType: 'HASH' }],
        Projection: { ProjectionType: 'ALL' }
      }
    ],
    BillingMode: 'PAY_PER_REQUEST'
  },
  {
    TableName: 'calmroot-sessions',
    KeySchema: [
      { AttributeName: 'sessionId', KeyType: 'HASH' },
      { AttributeName: 'SK', KeyType: 'RANGE' }
    ],
    AttributeDefinitions: [
      { AttributeName: 'sessionId', AttributeType: 'S' },
      { AttributeName: 'SK', AttributeType: 'S' },
      { AttributeName: 'therapistId', AttributeType: 'S' },
      { AttributeName: 'userId', AttributeType: 'S' }
    ],
    GlobalSecondaryIndexes: [
      {
        IndexName: 'therapist-index',
        KeySchema: [{ AttributeName: 'therapistId', KeyType: 'HASH' }],
        Projection: { ProjectionType: 'ALL' }
      },
      {
        IndexName: 'patient-index',
        KeySchema: [{ AttributeName: 'userId', KeyType: 'HASH' }],
        Projection: { ProjectionType: 'ALL' }
      }
    ],
    BillingMode: 'PAY_PER_REQUEST'
  },
  {
    TableName: 'calmroot-assessment-templates',
    KeySchema: [
      { AttributeName: 'type', KeyType: 'HASH' },
      { AttributeName: 'SK', KeyType: 'RANGE' }
    ],
    AttributeDefinitions: [
      { AttributeName: 'type', AttributeType: 'S' },
      { AttributeName: 'SK', AttributeType: 'S' }
    ],
    BillingMode: 'PAY_PER_REQUEST'
  },
  {
    TableName: 'calmroot-assessments',
    KeySchema: [
      { AttributeName: 'userId', KeyType: 'HASH' },
      { AttributeName: 'SK', KeyType: 'RANGE' }
    ],
    AttributeDefinitions: [
      { AttributeName: 'userId', AttributeType: 'S' },
      { AttributeName: 'SK', AttributeType: 'S' }
    ],
    BillingMode: 'PAY_PER_REQUEST'
  },
  {
    TableName: 'calmroot-mood-logs',
    KeySchema: [
      { AttributeName: 'userId', KeyType: 'HASH' },
      { AttributeName: 'SK', KeyType: 'RANGE' }
    ],
    AttributeDefinitions: [
      { AttributeName: 'userId', AttributeType: 'S' },
      { AttributeName: 'SK', AttributeType: 'S' }
    ],
    BillingMode: 'PAY_PER_REQUEST'
  },
  {
    TableName: 'calmroot-therapist-patients',
    KeySchema: [
      { AttributeName: 'therapistId', KeyType: 'HASH' },
      { AttributeName: 'SK', KeyType: 'RANGE' }
    ],
    AttributeDefinitions: [
      { AttributeName: 'therapistId', AttributeType: 'S' },
      { AttributeName: 'SK', AttributeType: 'S' }
    ],
    BillingMode: 'PAY_PER_REQUEST'
  }
];

const bucketName = 'calmroot-clinical-notes-006805625766';

async function setupDynamoDB() {
  console.log('--- Setting up DynamoDB Tables ---');
  for (const spec of tablesSpec) {
    try {
      // Check if table exists
      await ddb.send(new DescribeTableCommand({ TableName: spec.TableName }));
      console.log(`Table "${spec.TableName}" already exists. Skipping.`);
    } catch (error) {
      if (error.name === 'ResourceNotFoundException') {
        console.log(`Table "${spec.TableName}" not found. Creating...`);
        try {
          await ddb.send(new CreateTableCommand(spec));
          console.log(`✅ Table "${spec.TableName}" created successfully!`);
        } catch (createErr) {
          console.error(`❌ Failed to create table "${spec.TableName}":`, createErr.message);
        }
      } else {
        console.error(`Error describing table "${spec.TableName}":`, error.message);
      }
    }
  }
}

async function setupS3() {
  console.log('\n--- Setting up S3 Buckets ---');
  try {
    await s3.send(new HeadBucketCommand({ Bucket: bucketName }));
    console.log(`S3 Bucket "${bucketName}" already exists. Skipping.`);
  } catch (error) {
    console.log(`S3 Bucket "${bucketName}" not found. Creating...`);
    try {
      const config = { Bucket: bucketName };
      // us-east-1 cannot specify LocationConstraint
      if (REGION !== 'us-east-1') {
        config.CreateBucketConfiguration = { LocationConstraint: REGION };
      }
      await s3.send(new CreateBucketCommand(config));
      console.log(`✅ S3 Bucket "${bucketName}" created successfully!`);
    } catch (createErr) {
      console.error(`❌ Failed to create S3 bucket "${bucketName}":`, createErr.message);
    }
  }
}

async function run() {
  try {
    await setupDynamoDB();
    await setupS3();
    console.log('\n🌿 AWS Resource initialization sequence completed.');
  } catch (err) {
    console.error('Initialization failed:', err.message);
  }
}

run();
