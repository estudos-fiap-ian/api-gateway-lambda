# GitHub Actions Deployment Setup

This repository includes a GitHub Actions workflow that automatically deploys your serverless infrastructure to AWS using Terraform.

## Required GitHub Secrets

Before the deployment can work, you need to configure the following secrets in your GitHub repository:

### AWS Credentials
1. Go to your GitHub repository
2. Click on **Settings** → **Secrets and variables** → **Actions**
3. Add the following repository secrets:

| Secret Name | Description | Example |
|-------------|-------------|---------|
| `AWS_ACCESS_KEY_ID` | Your AWS Access Key ID | `AKIAIOSFODNN7EXAMPLE` |
| `AWS_SECRET_ACCESS_KEY` | Your AWS Secret Access Key | `wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY` |
| `JWT_SECRET_KEY` | Secret key for JWT token signing | `your-super-secret-jwt-key-here` |

### How to Get AWS Credentials

1. **AWS Console Method:**
   - Log into AWS Console
   - Go to IAM → Users → Your User → Security Credentials
   - Create Access Key → Command Line Interface (CLI)
   - Copy the Access Key ID and Secret Access Key

2. **Required AWS Permissions:**
   Your AWS user needs the following permissions:
   - `AmazonAPIGatewayAdministrator`
   - `AWSLambda_FullAccess`
   - `AmazonCognitoPowerUser`
   - `IAMReadOnlyAccess`
   - `CloudWatchLogsFullAccess`
   - `AmazonS3FullAccess` (for Terraform state)

## Deployment Workflow

The GitHub Action workflow (`deploy.yml`) will:

1. **Trigger on:**
   - Push to `main` branch (deploys automatically)
   - Pull requests to `main` branch (runs plan only)

2. **Deployment Steps:**
   - Checkout code
   - Setup Terraform
   - Configure AWS credentials
   - Setup Node.js and install Lambda dependencies
   - Create Lambda deployment packages (.zip files)
   - Run `terraform init`
   - Run `terraform fmt -check`
   - Run `terraform plan`
   - Run `terraform apply` (only on main branch pushes)
   - Output the API Gateway URL

## Environment Configuration

The workflow uses the following environment variables:
- `AWS_REGION`: us-east-1 (default)
- `TF_VERSION`: 1.2.0

## Manual Deployment

If you prefer to deploy manually:

```bash
# Install Lambda dependencies
cd auth
npm install
cd ..

# Create deployment packages
cd auth
zip -r ../register.zip register.js node_modules/
zip -r ../login.zip login.js node_modules/
zip -r ../anonymous.zip anonymous.js node_modules/
cd ..

# Deploy with Terraform
terraform init
terraform plan -var="jwt_secret_key=your-secret-key"
terraform apply -var="jwt_secret_key=your-secret-key"
```

## Troubleshooting

1. **403 Forbidden errors**: Check AWS credentials and permissions
2. **Terraform state conflicts**: Ensure S3 bucket permissions are correct
3. **Lambda packaging errors**: Ensure Node.js dependencies are installed correctly
4. **JWT Secret Key**: Make sure the secret is set and matches between deployments