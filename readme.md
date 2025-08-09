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
│  │  │  - Cohere Vector                       │  │  │
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

## Components Created by This Project

### AWS Infrastructure:
- **EC2 Instance**: Configurable instance type (default: m5.large) running Amazon Linux 2
- **EBS Volume**: High-performance gp3 volume (default: 100GB) mounted to `/home/rally`
- **Security Group**: Allows SSH access on port 22
- **SSH Key Pair**: Uses your local public key for secure access

### Software Installation:
- **Elasticsearch Rally**: Performance testing framework
- **Python 3**: Runtime environment
- **Rally Benchmark Scripts**: Pre-configured test scenarios

### External Dependencies (Not Created):
- **Elasticsearch Cluster**: Target cluster for benchmarking
- **Elastic API Key**: Authentication credentials

## Prerequisites

1. **AWS CLI** installed and configured
2. **Terraform** >= 1.0.0
3. **SSH key pair** at `~/.ssh/id_rsa.pub`
4. **Elasticsearch cluster** (e.g., Elastic Cloud deployment)
5. **Elastic API key** for authentication

## Quick Start

1. **Clone and configure**:
   ```bash
   git clone <repository-url>
   cd <repository-directory>
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your values
   ```

2. **Deploy infrastructure**:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

3. **Connect and test**:
   ```bash
   ssh rally@$(terraform output -raw instance_public_ip)
   # Default password: rally
   ```

## Configuration

### Required Variables

Create a `terraform.tfvars` file with:

```hcl
aws_region = "ap-northeast-1"
aws_profile = "default"
prefix = "my-rally"

elasticsearch_url = "https://your-elasticsearch-endpoint:9200"
elastic_api_key = "your-elastic-api-key"

default_tags = {
  Project     = "ES-Rally-Benchmark"
  Environment = "Test"
}
```

### Optional Variables

```hcl
ec2_instance_type = "m5.large"          # Instance size
ec2_ami_id = "ami-0599b6e53ca798bb2"    # Amazon Linux 2 AMI
ssh_public_key_path = "~/.ssh/id_rsa.pub"
ebs_volume_size = 100                   # Volume size in GB
```

## Available Benchmark Scripts

The following Rally benchmark scripts are pre-installed:

| Script | Description |
|--------|-------------|
| `run-rally-httplogs.sh` | HTTP access logs benchmark |
| `run-rally-eslogs-ingest.sh` | Elastic logs ingestion test |
| `run-rally-eslogs-query.sh` | Elastic logs query test |
| `run-rally-geonames.sh` | Geographic data benchmark |
| `run-rally-sql.sh` | SQL workload simulation |
| `run-rally-k8_metrics.sh` | Kubernetes metrics benchmark |
| `run-rally-cohere-vector.sh` | Vector search benchmark |

### Running Benchmarks

```bash
cd /home/rally
./run-rally-httplogs.sh  # Or any other benchmark script
```

## CI/CD Pipeline

This project includes GitHub Actions workflow for automated testing:

### Required Secrets

Configure these secrets in your GitHub repository:

- `AWS_ACCESS_KEY_ID`: AWS access key
- `AWS_SECRET_ACCESS_KEY`: AWS secret key
- `SSH_PRIVATE_KEY`: Private SSH key content
- `SSH_PUBLIC_KEY`: Public SSH key content
- `ELASTICSEARCH_URL`: Target Elasticsearch endpoint
- `ELASTIC_API_KEY`: Elasticsearch API key

### Workflow Features

- **Infrastructure validation**: Terraform format, validate, plan
- **Deployment testing**: Automated apply and destroy
- **Component verification**: SSH connectivity, Rally installation, script permissions
- **Cleanup**: Automatic resource cleanup on completion

## Security Considerations

⚠️ **Important Security Notes**:

- The security group allows SSH from any IP (`0.0.0.0/0`) for testing purposes
- Default credentials are set for the rally user (username: rally, password: rally)
- For production use:
  - Restrict SSH access to specific IP ranges
  - Change default passwords immediately
  - Use IAM roles instead of API keys where possible

## Cost Optimization

- Uses spot instances where appropriate
- Automatic cleanup in CI/CD pipeline
- Configurable instance sizes for different use cases
- EBS volume is optimized for performance vs. cost

## Troubleshooting

### Common Issues

#### SSH Connection Issues
```bash
# Test SSH connectivity
ssh -v rally@<instance-ip>

# Check security group rules
aws ec2 describe-security-groups --group-ids <sg-id>
```

#### Rally Installation Issues
```bash
# Check Rally installation
ssh rally@<instance-ip> "esrally --version"

# Check Python installation
ssh rally@<instance-ip> "python3 --version && pip3 --version"
```

#### EBS Volume Issues
```bash
# Check volume mount
ssh rally@<instance-ip> "df -h /home/rally"

# Check filesystem
ssh rally@<instance-ip> "lsblk"
```

#### Elasticsearch Connection Issues
```bash
# Test Elasticsearch connectivity
ssh rally@<instance-ip> "curl -H 'Authorization: ApiKey YOUR_API_KEY' https://your-es-endpoint:9200/_cluster/health"
```

### Logs and Debugging

- **User data logs**: `/var/log/cloud-init-output.log`
- **Rally logs**: `/home/rally/.rally/logs/`
- **System logs**: `/var/log/messages`

## Testing

The project includes automated tests via Python script:

### Local Testing
```bash
pip install -r requirements.txt
python test_rally_deployment.py --instance-ip <instance-ip>
```

### Test Coverage
- SSH connectivity
- Python and Rally installation
- EBS volume mounting
- Script existence and permissions
- Rally configuration
- Basic functionality test

## Cleanup

To destroy all resources:

```bash
terraform destroy
```

**Note**: EBS volumes are created with `force_destroy = true` for easy cleanup.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with the CI/CD pipeline
5. Submit a pull request

## Resources

- [Elasticsearch Rally Documentation](https://esrally.readthedocs.io/)
- [AWS EC2 Documentation](https://docs.aws.amazon.com/ec2/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Elastic Cloud](https://cloud.elastic.co/)

## License

This project is licensed under the MIT License - see the LICENSE file for details.