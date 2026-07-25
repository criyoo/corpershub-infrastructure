# Corpershub Terraform

This directory is a single Terraform root module for the Corpershub AWS environment stack.

## Local secret workflow

Local runs use the same pattern as `corpershub/infra`:

- `envs/secrets/.env.dev` and `envs/secrets/.env.prod` hold local-only secrets.
- `envs/secrets/.env.<env>.age` can be committed if you want encrypted copies in git.
- `make plan`, `make apply`, `make destroy`, and `make console` source the matching `.env` file before running Terraform.
- CI can inject the same `TF_VAR_api_secure_parameters` value from GitHub Actions secrets instead of using local files.

Terraform writes secure values into AWS SSM Parameter Store through the `storage` module. The local `.env` files only control how those values reach Terraform during a local run.

## Setup

Run from `infrastructure/`.

```bash
make setup
cp envs/secrets/.env.dev.example envs/secrets/.env.dev
cp envs/secrets/.env.prod.example envs/secrets/.env.prod
```

Fill in the placeholder secret values in the local `.env` files, then optionally encrypt them:

```bash
make encrypt WORKSPACE=dev
make encrypt WORKSPACE=prod
```

## Commands

```bash
make dev
make plan WORKSPACE=dev
make apply WORKSPACE=dev
make api WORKSPACE=dev
make web WORKSPACE=dev

make prod
make plan WORKSPACE=prod
make apply WORKSPACE=prod
make api WORKSPACE=prod
make web WORKSPACE=prod
```

Deployment target aliases:

```bash
make deploy WORKSPACE=dev
make deploy-web WORKSPACE=dev
```

- `make api` is the primary api image build and ECS rollout command.
- `make web` is the primary static web build, S3 sync, and CloudFront invalidation command.
- `make deploy` is an alias for `make api`.
- `make deploy-web` is an alias for `make web`.

## Notes

- Non-secret Terraform inputs stay in `envs/dev.tfvars` and `envs/prod.tfvars`.
- Sensitive application parameters are passed through `TF_VAR_api_secure_parameters`.
- `TF_VAR_api_secure_parameters` must include a preauthorized `TAILSCALE_AUTHKEY` when `tailscale.enabled = true`. Leave `tailscale.tags = []` unless your tailnet ACL explicitly permits the advertised tags for that key.
- The current api uses Terraform workspaces, so `dev` and `prod` should be selected before planning or applying.
- Terraform uses the `root` AWS SSO profile by default because the shared state bucket and root Route 53 zone live in the root account, and the workload providers assume into `dev` or `prod`.
- Override `AWS_PROFILE` only if that base profile can access the shared Terraform state and root DNS resources.
- Local commands refresh the underlying AWS SSO access token, not just cached role credentials, before Terraform or deployment commands run.
