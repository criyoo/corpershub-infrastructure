SHELL = /bin/bash
TF = terraform

WORKSPACE_VARS = "-var-file=envs/$(WORKSPACE).tfvars"
DECRYPTED_ENV_FILE = envs/secrets/.env.$(WORKSPACE)
ENCRYPTED_ENV_FILE = $(DECRYPTED_ENV_FILE).age
LOCK_FILE = s3://corpershub-statefile/envs/$(WORKSPACE)/corpershub.tfstate.tflock
STATE_FILE = s3://corpershub-statefile/envs/$(WORKSPACE)/corpershub.tfstate
LOAD_ENV = set -a && . $(DECRYPTED_ENV_FILE) && set +a


.PHONY: setup encrypt decrypt load-env fmt init reconfig workspace validate plan plan-nolock apply refresh destroy console list unlock down migrate admin seed new-build build up prune

# SECRETS INITIALIZATION
setup:
	@bash ../scripts/secrets/setup.sh

decrypt: setup
	@bash ../scripts/secrets/decrypt.sh $(WORKSPACE)

encrypt: setup
	@bash ../scripts/secrets/encrypt.sh $(WORKSPACE)

encrypt-all:
	@bash ../scripts/secrets/encrypt.sh dev
	@bash ../scripts/secrets/encrypt.sh prod

# LOAD ENVIRONMENT SECRETS
load-env:
	@if [ ! -f $(DECRYPTED_ENV_FILE) ]; then \
		echo "Error: $(DECRYPTED_ENV_FILE) not found, Run 'make setup' to initialize secrets"; \
		exit 1; \
	fi
	@bash ../scripts/secrets/secrets.sh "$(DECRYPTED_ENV_FILE)"


# TERRAFORM COMMANDS
fmt:
	@$(TF) fmt -recursive

init: fmt
	@$(TF) init -input=false -upgrade

reconfig: fmt
	@$(TF) init -reconfigure

workspace: init
	@bash ../scripts/workspace.sh $(WORKSPACE)

validate: load-env workspace
	@$(TF) fmt -diff -check -recursive
	@$(LOAD_ENV) && $(TF) validate

plan: validate
	@$(LOAD_ENV) && $(TF) plan $(WORKSPACE_VARS) -out=tfplan

plan-nolock: validate
	@$(LOAD_ENV) && $(TF) plan $(WORKSPACE_VARS) -lock=false

apply: plan
	@$(LOAD_ENV) && $(TF) apply tfplan

refresh: validate
	@$(LOAD_ENV) && $(TF) refresh

destroy: validate
	@$(LOAD_ENV) && $(TF) destroy $(WORKSPACE_VARS)

console: validate
	@$(LOAD_ENV) && $(TF) console $(WORKSPACE_VARS)

list: workspace
	@$(TF) state list

unlock:
	@if pgrep -x terraform-ls >/dev/null; then \
		pkill -x terraform-ls; \
		sleep 2; \
	fi
	@if aws s3 ls $(LOCK_FILE) --profile $(AWS_PROFILE) >/dev/null 2>&1; then \
		echo "Lock file found, removing..."; \
		aws s3 rm $(LOCK_FILE) --profile $(AWS_PROFILE); \
	else \
		echo "No lock file found"; \
	fi
