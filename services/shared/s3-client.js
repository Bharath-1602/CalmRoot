const { S3Client } = require('@aws-sdk/client-s3');

const region = process.env.AWS_REGION || 'us-east-1';

// S3Client will automatically use IAM roles (EC2 instance profile, ECS task role)
// or local AWS credentials from environment/credentials file.
const s3Client = new S3Client({
  region
});

const CLINICAL_NOTES_BUCKET = process.env.CLINICAL_NOTES_BUCKET || 'calmroot-clinical-notes-006805625766';

module.exports = {
  s3Client,
  CLINICAL_NOTES_BUCKET
};
