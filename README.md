# CI/CD Pipeline on AWS

An automated build, test, and deployment pipeline. Pushing to `main` on GitHub
builds and tests the application, then deploys it to a live EC2 web server with
no manual intervention.

**Live flow:** `git push` → GitHub → CodePipeline → CodeBuild → Amazon EC2 → site updated in ~60 seconds

---

## Architecture

```
Developer
   │  git push
   ▼
GitHub (source of truth)
   │  webhook
   ▼
AWS CodePipeline  ──────────────────────────► Amazon CloudWatch
   │  orchestrates                              (build logs + failure alarm → SNS email)
   ▼
AWS CodeBuild
   ├─ test    verify required files exist
   ├─ build   upload site to S3 staging bucket
   └─ deploy  SSM Run Command → EC2 pulls from S3, restarts Apache
                │
                ▼
        Amazon EC2 (Apache) — application live
```

### Why SSM instead of CodeDeploy

The original design used AWS CodeDeploy. During implementation I found that
CodeDeploy is not available on the AWS Free account plan — the console redirects
to the billing signup page rather than returning a permissions error, which took
some diagnosis to identify.

Rather than pay to unlock a single service, I redesigned the deployment stage
around **AWS Systems Manager Run Command**, which is available on the free plan:

- CodeBuild stages the built site in an S3 bucket
- CodeBuild issues an SSM Run Command targeting the EC2 instance by tag
- The instance pulls from S3, writes to the Apache web root, and restarts the service
- CodeBuild polls the command status and **fails the pipeline** if the deployment fails

This preserves the properties that matter — automated, repeatable, tag-targeted,
and failure-aware deployment — while removing a hard dependency on a service the
account could not use.

---

## AWS services used

| Service | Role in the pipeline |
|---|---|
| **CodePipeline** | Orchestrates the workflow, triggered by GitHub webhook |
| **CodeBuild** | Runs tests, packages the site, executes the deployment |
| **Systems Manager (SSM)** | Delivers and runs the deploy command on EC2 |
| **S3** | Staging bucket for build output |
| **EC2** | Amazon Linux 2023 host running Apache |
| **IAM** | Scoped roles for EC2 and CodeBuild |
| **CloudWatch** | Build logs, plus an alarm on failed builds → SNS email |

---

## Repository contents

| File | Purpose |
|---|---|
| `index.html` | The deployed website |
| `buildspec.yml` | CodeBuild definition: test → build → deploy → verify |
| `codebuild-deploy-policy.json` | IAM policy attached to the CodeBuild service role |
| `ec2-user-data.txt` | EC2 bootstrap script (Apache + SSM prerequisites) |
| `PROJECT-NOTES.md` | Build log, resource inventory, and troubleshooting record |

---

## Setup

**Prerequisites:** an AWS account, a GitHub account, and an S3 bucket name.

1. **EC2** — launch Amazon Linux 2023 (t3.micro), tag it `Name=CICD-WebServer`,
   open ports 22 and 80, and attach the user data from `ec2-user-data.txt`.
2. **IAM (EC2 role)** — attach `AmazonS3ReadOnlyAccess` and
   `AmazonSSMManagedInstanceCore`, then assign the role to the instance.
3. **S3** — create a private bucket for staging build output.
4. **CodePipeline** — create a pipeline with a GitHub (App) source stage and a
   CodeBuild build stage. Skip the deploy stage; CodeBuild handles deployment.
5. **CodeBuild environment variables:**

   | Name | Value |
   |---|---|
   | `DEPLOY_BUCKET` | your S3 bucket name |
   | `EC2_TAG_NAME` | `CICD-WebServer` |

6. **IAM (CodeBuild role)** — attach `codebuild-deploy-policy.json` as an inline
   policy, substituting your bucket name in both ARNs.
7. **CloudWatch** — create an alarm on the CodeBuild `FailedBuilds` metric
   (Sum ≥ 1 over 5 minutes) with an SNS email subscription.

---

## Verifying the pipeline

Edit the version string in `index.html`, then:

```bash
git add .
git commit -m "Update version"
git push
```

CodePipeline starts within seconds. When both stages pass, the change is live on
the EC2 public IP.

---

## Problems solved during implementation

| Symptom | Root cause | Resolution |
|---|---|---|
| CodeDeploy console redirected to the billing signup page | CodeDeploy is not available on the AWS Free account plan | Redesigned the deploy stage around SSM Run Command |
| Build failed: `Unknown options: bucket,name/site/` | `DEPLOY_BUCKET` contained a value with spaces, so the shell split the S3 URI into three arguments | Corrected the environment variable |
| Build failed: `AccessDenied` on `s3:PutObject` | The CodeBuild service role had no write permission on the staging bucket | Added a scoped inline IAM policy |
| Pipeline reported success but the site served the previous version | `aws s3 sync` compares file size and timestamp, not content — `Version 1.0` and `Version 2.0` are byte-identical in length, so the file was treated as unchanged | Added `--exact-timestamps` to the EC2-side sync |
| Site unreachable in the browser | The browser upgraded the request to HTTPS; Apache was serving port 80 only | Requested `http://` explicitly |

---

## Possible extensions

- Application Load Balancer with an Auto Scaling group for high availability
- HTTPS via ACM and a custom domain in Route 53
- Blue/green deployment with automated rollback
- Infrastructure defined in Terraform or CloudFormation rather than the console

---

**Author:** Shivam Malap
