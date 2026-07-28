# Project 3 — CI/CD Pipeline on AWS

Automated build, test, and deployment using AWS CI/CD services.

**Flow:** Developer → GitHub → CodePipeline → CodeBuild (build & test) → CodeDeploy → EC2 → Live app. Monitoring via CloudWatch.

## Files

| File | Purpose |
|---|---|
| `index.html` | The website deployed to EC2 |
| `buildspec.yml` | CodeBuild instructions (build + test + package artifact) |
| `appspec.yml` | CodeDeploy instructions (file destinations + lifecycle hooks) |
| `scripts/install_dependencies.sh` | Installs Apache (BeforeInstall) |
| `scripts/start_server.sh` | Starts Apache (ApplicationStart) |
| `scripts/stop_server.sh` | Stops Apache (ApplicationStop) |
| `scripts/validate_service.sh` | Health check (ValidateService) |

## Test the pipeline

Change `Version 1.0` in `index.html`, commit, push — the pipeline redeploys automatically.
