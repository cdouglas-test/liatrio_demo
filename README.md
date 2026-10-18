# Liatrio Demo

A small Flask API deployed to AWS EKS, with the infrastructure in Terraform and the build/deploy steps in GitHub Actions.

## API

| Path       | Response                                                       |
|------------|----------------------------------------------------------------|
| `/`        | Welcome message and list of endpoints                          |
| `/api`     | `{"message": "Automate all the things!", "timestamp": <epoch>}` |
| `/health`  | Health status, used by the Kubernetes probes                   |
| `/version` | Deployed version (the short commit SHA) and environment        |

## Repository layout

```text
app/                    Flask app, tests, Dockerfile
infrastructure/         Terraform for the VPC, EKS cluster and ECR repository
infrastructure/bootstrap/   Terraform for the S3 bucket that holds the main stack's state
k8s/deployment.yaml     Deployment and LoadBalancer service
.github/workflows/      CI, deploy and teardown pipelines
```

## Running locally

```bash
cd app
python -m venv .venv && source .venv/bin/activate
pip install -r requirements-dev.txt
pytest
python app.py            # http://localhost:8080
```

With Docker:

```bash
docker build -t liatrio-demo-api app
docker run -p 8080:8080 liatrio-demo-api
```

## Pipelines

All workflows are manual and run only from the Actions tab. Nothing runs on push or pull request.

- **CI**: runs the tests and a dependency audit, builds the image and smoke-tests it, and runs `terraform fmt`, `validate` and `tflint`. Needs no AWS access.
- **Deploy**: builds the image, pushes it to ECR tagged with the short commit SHA, applies `k8s/deployment.yaml`, waits for the rollout, and checks the API through the load balancer.
- **Teardown**: deletes the Kubernetes resources, then runs `terraform destroy`. Type `DESTROY` to confirm.

Deploy and Teardown need a GitHub environment named `dev` with two variables:

- `AWS_ROLE_ARN`: an IAM role that GitHub Actions can assume through OIDC
- `TF_STATE_BUCKET`: the bucket created by the bootstrap stack

## Provisioning the infrastructure

Requires the AWS CLI, Terraform 1.10 or newer, and kubectl. Running the stack costs roughly $100 per month, mostly for the EKS control plane and the NAT gateway.

1. Create the state bucket. Its own state stays local in `infrastructure/bootstrap/terraform.tfstate`, so keep that file.

   ```bash
   cd infrastructure/bootstrap
   terraform init
   terraform apply -var="bucket_name=<globally unique name>"
   ```

2. Create the cluster, network and registry (about 15 to 20 minutes):

   ```bash
   cd ..
   cp terraform.tfvars.example terraform.tfvars   # set github_actions_role_arn
   terraform init -backend-config="bucket=<bucket name>"
   terraform apply
   ```

3. Set `AWS_ROLE_ARN` and `TF_STATE_BUCKET` on the `dev` environment, then run the Deploy workflow.

## Tearing down

Run the Teardown workflow, or locally:

```bash
kubectl delete -f k8s/deployment.yaml --wait
cd infrastructure && terraform destroy
cd bootstrap && terraform destroy -var="bucket_name=<bucket name>"
```

Delete the Kubernetes service before destroying the stack. Its AWS load balancer isn't managed by Terraform, and the VPC can't be removed while the load balancer exists.

## License

MIT
