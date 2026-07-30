# Project 3 — CI/CD Pipeline — Status Notes

_Last updated: 29 July 2026_

## Status: WORKING ✅

Pushing to GitHub automatically builds, tests, and deploys the site to EC2.
Verified end to end: commit `ee6f2a9` (Version 2.0) deployed with no manual steps.

## Resources created (all in us-east-1 / N. Virginia)

| Resource | Name / ID |
|---|---|
| GitHub repo | `Smalap/cicd-pipeline` |
| EC2 instance | `CICD-WebServer` — i-0e02ff620640c3b27 |
| EC2 IAM role | `EC2-CodeDeploy-Role` (S3ReadOnly + SSMManagedInstanceCore) |
| S3 staging bucket | `cicd-pipeline-deploy-shivam-2026` |
| CodeBuild project | `CICD-Build` |
| CodeBuild role | `codebuild-CICD-Build-service-role` + inline policy `CICD-Deploy-Permissions` |
| Pipeline | `CICD-Pipeline` |
| Unused roles | `CodeDeploy-Service-Role` (CodeDeploy blocked on Free plan) |

CodeBuild env vars: `DEPLOY_BUCKET=cicd-pipeline-deploy-shivam-2026`, `EC2_TAG_NAME=CICD-WebServer`

## Architecture

Developer → GitHub → CodePipeline → CodeBuild (test → S3 upload → SSM Run Command) → EC2 (Apache) → Live site

CodeDeploy is not available on the AWS Free account plan, so deployment is done by
CodeBuild issuing an SSM Run Command that makes EC2 pull the site from S3.

## Remaining work

- [ ] CloudWatch alarm on CodeBuild `FailedBuilds` metric → SNS email (confirm the subscription email)
- [ ] Portfolio write-up (README polish, LinkedIn post, resume bullet)

## To resume tomorrow

1. Start the EC2 instance (EC2 → Instance state → Start)
2. Get the NEW public IP — it changes on every stop/start
3. Open `http://<new-ip>` (must be **http**, not https)

## Problems solved along the way (good interview material)

| Problem | Cause | Fix |
|---|---|---|
| Site unreachable | Browser forced `https://`; Apache serves port 80 only | Use `http://` explicitly |
| CodeDeploy console redirected to signup | CodeDeploy is blocked on the AWS Free account plan | Redesigned deploy stage to use SSM Run Command |
| `Unknown options: bucket,name/site/` | `DEPLOY_BUCKET` was set to placeholder text containing spaces | Set the real bucket name |
| `AccessDenied` on `s3:PutObject` | CodeBuild service role had no S3 write permission | Added inline policy `CICD-Deploy-Permissions` |
| Pipeline succeeded but site showed old version | `aws s3 sync` skips files of identical size; "Version 1.0" and "Version 2.0" are the same length | Added `--exact-timestamps` to the EC2-side sync |

## Cleanup when finished with the project

Terminate EC2, delete the S3 bucket, delete the pipeline and CodeBuild project,
delete the IAM roles, and remove the GitHub connection.
