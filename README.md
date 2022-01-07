# terraform-aws-eks-issue-1707

## Run locally

```bash
export AWS_PROFILE=terraform-issue-1707
export AWS_DEFAULT_REGION=us-west-2
export TF_BIN=terraform-1.1.3

${TF_BIN} init 
${TF_BIN} validate
${TF_BIN} fmt -check -diff
${TF_BIN} plan -out plan.tfplan 
${TF_BIN} apply plan.tfplan
```
