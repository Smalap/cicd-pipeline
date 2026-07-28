# Project 3 — CI/CD Pipeline on AWS

Automated build, test, and deployment of a website to EC2 using AWS CI/CD services.

**Flow:** Developer → GitHub → CodePipeline → CodeBuild (test → build → deploy via SSM) → EC2 → Live site
Monitoring and build logs via CloudWatch.

CodeDeploy is unavailable on the AWS Free account plan, so deployment is handled by
CodeBuild using **AWS Systems Manager Run Command**: the site is staged in S3, then
EC2 is instructed to pull it into the Apache web root and restart the service.

## Files

| File | Purpose |
|---|---|
| `index.html` | The website deployed to EC2 |
| `buildspec.yml` | CodeBuild: test → upload to S3 → SSM deploy → wait for result |
| `codebuild-deploy-policy.json` | IAM policy attached to the CodeBuild service role |
| `ec2-user-data.txt` | Bootstrap script used when launching the EC2 instance |
| `appspec.yml`, `scripts/` | Unused — kept from the original CodeDeploy design |

## Required CodeBuild environment variables

| Name | Value |
|---|---|
| `DEPLOY_BUCKET` | your S3 staging bucket name |
| `EC2_TAG_NAME` | `CICD-WebServer` |

## Test the pipeline

Change `Version 1.0` in `index.html`, commit, push — the pipeline runs automatically
and the live site updates.
