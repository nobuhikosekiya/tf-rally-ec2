# Elasticsearch Rally Benchmark Environment

This project automates the setup of an EC2 environment for running Elasticsearch Rally benchmarks. Rally is a performance testing tool that allows you to measure and analyze the performance of your Elasticsearch cluster under various workloads.

## Architecture

```
                                            ┌───────────────────────┐
                                            │                       │
                                            │  External Elastic     │
                                            │  Cloud Deployment     │
                                            │  (Not created by      │
                                            │   this project)       │
                                            │                       │
                                            └───────────┬───────────┘
                                                        │
                                                        │ HTTPS
                                                        │
┌────────────────────────────────────────────────────┐  │
│                                                    │  │
│  AWS Resources (Created by this project)           │  │
│                                                    │  │
│  ┌──────────────────────────────────────────────┐  │  │
│  │                                              │  │  │
│  │  EC2 Instance (m5.large)                     │  │  │
│  │                                              │  │  │
│  │  ┌────────────────────────────────────────┐  │  │  │
│  │  │                                        │  │  │  │
│  │  │  Rally Benchmark Scripts               ├──┼──┼──►
│  │  │  - HTTP Logs                           │  │  │
│  │  │  - Elastic Logs                        │  │  │
│  │  │  - Geonames                            │  │  │
│  │  │  - SQL                                 │  │  │
│  │  │  - K8s Metrics                         │  │  │
│  │  │                                        │  │  │
│  │  └────────────────────────────────────────┘  │  │
│  │                                              │  │
│  └──────────────────────────────────────────────┘  │
│                                                    │
│  ┌───────────────────┐                             │
│  │                   │                             │
│  │  EBS Volume       │                             │
│  │  (100GB, gp3)     │                             │
│  │                   │                             │
│  └───────────────────┘                             │
│                                                    │
│  ┌───────────────────┐                             │
│  │                   │                             │
│  │  Security Group   │                             │
│  │  (SSH Ingress)    │                             │
│  │                   │                             │
│  └───────────────────┘                             │
│                                                    │
│  ┌───────────────────┐                             │
│  │                   │                             │
│  │  SSH Key Pair     │                             │
│  │                   │                             │
│  └───────────────────┘                             │
│                                                    │
└────────────────────────────────────────────────────┘
```

## Components

### Created by this project:
- **EC2 Instance**: m5.large running Amazon Linux 2
- **EBS Volume**: 100GB gp3 volume mounted to /home/rally
- **Security Group**: Allows SSH access (port 22)
- **SSH Key Pair**: Uses your local public key for SSH access

### External components (referenced but not created):
- **Elasticsearch Cluster**: An external Elasticsearch deployment (likely on Elastic Cloud)
- **Elastic API Key**: For authentication to the Elasticsearch cluster

## Prerequisites

1. AWS CLI installed and configured
2. Terraform installed (version >= 1.0.0)
3. SSH key pair generated on your local machine
4. Access to an Elasticsearch cluster (e.g., Elastic Cloud deployment)
5. Elastic API key for authentication

## Setup Instructions

1. Clone this repository:
   ```bash
   git clone <repository-url>
   cd <repository-directory>
   ```

2. Create a `terraform.tfvars` file with your specific variables:
   ```hcl
   aws_region        = "ap-northeast-1"  # Or your preferred region
   aws_profile       = "default"         # Your AWS CLI profile
   prefix            = "my-rally"        # Prefix for resource names
   elastic_api_key   = "your-api-key"    # Elastic Cloud API key
   elasticsearch_url = "https://your-elasticsearch-endpoint:9200"  # Elasticsearch endpoint
   default_tags      = {
     Project     = "ES-Rally-Benchmark"
     Environment = "Test"
   }
   ```

3. Initialize Terraform:
   ```bash
   terraform init
   ```

4. Apply the Terraform configuration:
   ```bash
   terraform apply
   ```

5. After successful deployment, SSH into the instance:
   ```bash
   ssh rally@$(terraform output -raw instance_public_ip)
   # Default password: rally
   ```

## Running Benchmarks

Several Rally benchmark scripts are pre-configured on the instance:

- `/home/rally/run-rally-httplogs.sh` - HTTP Logs benchmark
- `/home/rally/run-rally-eslogs-ingest.sh` - Elastic Logs ingest benchmark
- `/home/rally/run-rally-eslogs-query.sh` - Elastic Logs query benchmark
- `/home/rally/run-rally-geonames.sh` - Geonames benchmark
- `/home/rally/run-rally-sql.sh` - SQL benchmark
- `/home/rally/run-rally-k8_metrics.sh` - Kubernetes metrics benchmark

To run a benchmark:
```bash
cd /home/rally
./run-rally-httplogs.sh  # Or any other benchmark script
```

## Security Notes

- The security group allows SSH access from any IP (`0.0.0.0/0`). For production use, restrict this to your specific IP range.
- Default credentials are set for the rally user (username: rally, password: rally). Change these after first login.

## Cleanup

To destroy all resources created by this project:
```bash
terraform destroy
```

## Resources

- [Elasticsearch Rally Documentation](https://esrally.readthedocs.io/)
- [AWS EC2 Documentation](https://docs.aws.amazon.com/ec2/)
- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)