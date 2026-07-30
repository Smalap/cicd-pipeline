# Portfolio content — CI/CD Pipeline project

---

## Resume bullets

Pick two or three depending on how much space you have. The first one is the strongest.

**Full version (3 bullets):**

- Built an automated CI/CD pipeline on AWS using CodePipeline, CodeBuild, S3, and
  Systems Manager, reducing deployment from a manual process to a single `git push`
  that ships to a live EC2 web server in under 60 seconds.
- Redesigned the deployment stage around SSM Run Command after identifying that
  CodeDeploy was unavailable on the account plan, preserving automated, tag-targeted,
  failure-aware deployment without additional cost.
- Configured scoped IAM roles, CloudWatch build logging, and an SNS-backed alarm on
  build failures; debugged pipeline issues including IAM permission gaps and a silent
  deployment failure caused by `aws s3 sync` size-based change detection.

**Condensed version (1 bullet, if space is tight):**

- Built an automated CI/CD pipeline (CodePipeline, CodeBuild, S3, SSM, EC2) deploying
  to a live web server on every `git push`, with scoped IAM roles, CloudWatch logging,
  and SNS failure alerts.

**Skills line to add:**

`AWS (EC2, S3, IAM, CodePipeline, CodeBuild, Systems Manager, CloudWatch, SNS) · CI/CD · Git · Linux · Bash`

---

## LinkedIn post

> Just finished my third AWS project: a fully automated CI/CD pipeline.
>
> The goal was simple — push code to GitHub, and have it live on a web server
> without touching anything else. The build is:
>
> GitHub → CodePipeline → CodeBuild → EC2, with CloudWatch handling logs and alerts.
>
> The interesting part wasn't the happy path. It was the two problems I didn't plan for.
>
> First, CodeDeploy turned out to be unavailable on my account plan — and instead of a
> permissions error, the console just redirected me to a billing page, which took a
> while to work out. Rather than pay to unlock one service, I rebuilt the deployment
> stage around AWS Systems Manager Run Command: CodeBuild stages the site in S3, then
> instructs the EC2 instance to pull it down and restart Apache. Same outcome, still
> automated, still fails the pipeline if the deploy fails.
>
> Second, and more subtle: a deployment that reported success but served the old page.
> The cause was that `aws s3 sync` compares file size and timestamp rather than
> content — and "Version 1.0" and "Version 2.0" happen to be exactly the same number
> of bytes, so the file looked unchanged. A green pipeline is not the same thing as a
> correct deployment.
>
> Both were better learning than the parts that worked first time.
>
> Next: adding a load balancer and moving the infrastructure into Terraform.
>
> #AWS #DevOps #CICD #CloudComputing #Terraform

---

## Interview talking points

Questions this project lets you answer well:

**"Tell me about a technical problem you solved."**
Use the `aws s3 sync` bug. It shows you don't trust a green checkmark, you verify the
actual outcome, and you understood the tool's change-detection behaviour well enough
to fix it properly rather than working around it.

**"Tell me about a time you had to change your approach."**
Use the CodeDeploy substitution. Emphasise that you identified what CodeDeploy was
actually providing (automation, targeting, failure detection), then found a different
service that provided those same properties within the constraint.

**"How do you debug something you've never seen before?"**
Walk through the IAM `AccessDenied` — the error named the exact role, action, and
resource, and you read it rather than guessing. Contrast with the CodeDeploy redirect,
where the error message was actively misleading and you had to reason about what the
platform was doing.

**"How do you know your deployment worked?"**
CloudWatch logs for every build, an SNS alarm on failure, and a health check in the
deploy step that fails the pipeline if the service doesn't come back up.

---

## Honest framing note

Describe this as a personal learning project, not production infrastructure. It runs a
single EC2 instance with no load balancer, no HTTPS, and console-created infrastructure
rather than IaC — and you should say so if asked. Knowing the limitations of what you
built is itself a signal of competence, and the "possible extensions" section of the
README gives you a natural way to demonstrate that.
