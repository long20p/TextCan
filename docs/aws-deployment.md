# AWS Deployment Documentation

This document describes the AWS CloudFormation deployment setup for the TextCan project.

## Overview

TextCan has an alternative deployment option on AWS using CloudFormation templates. The AWS deployment consists of EC2 instances hosting the various components of the application, along with a DynamoDB table for data storage.

## Architecture

The AWS deployment of TextCan includes the following resources:

- **Amazon DynamoDB**: Stores content data in a table named "Content"
- **EC2 Instances**: Three instances for different components:
  - Website Instance: Hosts the Angular frontend
  - API Server Instance: Hosts the Content API
  - Key Service Instance: Hosts the Key Generation Service
- **Security Groups**: Configures network access for each instance
- **IAM Role**: Provides access to DynamoDB for the API server

## Deployment Structure

The AWS deployment is defined in the `AWS` directory:

- `textcan.template.yaml`: CloudFormation template defining all resources

## Deployment Parameters

The CloudFormation template accepts the following parameters:

- `ImageId`: AMI ID for the EC2 instances (Default: ami-09d2e79e17aeef8cd)
- `ApiImageId`: AMI ID for the API server (Default: ami-09d9ce8f22d7bd8bb)
- `KeyPair`: EC2 key pair name for SSH access
- `InstanceType`: EC2 instance type (Default: t2.micro)

## Instance Configuration

### Website Instance
- Runs the Angular frontend on port 4200
- Uses http-server to serve the application
- Configured with the API server's IP address at runtime

### API Server Instance
- Runs the ASP.NET Core API on port 80
- Configured with DynamoDB endpoint and key service URL at runtime
- Has IAM permissions to access DynamoDB

### Key Service Instance
- Runs the Python-based Key Generation Service on port 8083
- Uses Django's runserver for development/simple deployments

## Security Configuration

Each component has its own security group with the following access rules:

### Website Instance Security Group
- SSH (port 22) from anywhere
- HTTP (port 4200) from anywhere

### API Server Security Group
- SSH (port 22) from anywhere
- HTTP (port 80) from anywhere

### Key Service Security Group
- SSH (port 22) from anywhere
- HTTP (port 8083) from anywhere

## Database Configuration

The DynamoDB table has the following configuration:

- Table Name: Content
- Partition Key: Key (String)
- Provisioned Capacity: 5 read/write capacity units

## Integration Points

The components are integrated at runtime using EC2 instance public IPs:

1. The API server is configured with the DynamoDB endpoint URL and Key Service URL
2. The frontend is configured with the API server's public IP address

## Deployment Outputs

The CloudFormation stack provides the following outputs:

- Public DNS name of the Website instance
- Public IP address of the Website instance

## Deployment Instructions

To deploy the TextCan application on AWS:

1. Run the `RunEverything-AWS.ps1` script
2. The script will create or update the CloudFormation stack
3. Access the application using the public IP address of the Website instance
