#!/usr/bin/env bash

set -euo pipefail

ENVIRONMENT=${1:-dev}
PROJECT="corpershub"

CLUSTER_NAME="${PROJECT}-${ENVIRONMENT}-cluster"
if [ -z "$CLUSTER_NAME" ]; then
    echo "Error: Could not get cluster name. Ensure terraform is initialized and outputs are available."
    echo "Run 'terraform init' and select the correct workspace first."
    exit 1
fi

SERVICE_PREFIX="${PROJECT}-${ENVIRONMENT}"
SERVICE_NAME="api"

echo "fetching task arn..."
TASK_ARN=$(aws ecs list-tasks \
    --cluster "$CLUSTER_NAME" \
    --service "${SERVICE_PREFIX}-${SERVICE_NAME}" \
    --desired-status RUNNING \
    --profile "${ENVIRONMENT}-${PROJECT}" \
    --region "eu-west-1" \
    --query 'taskArns[0]' \
    --output text)

if [ "$TASK_ARN" = "None" ] || [ -z "$TASK_ARN" ]; then
    echo "Error: No running tasks found for service ${CLUSTER_NAME}-${SERVICE_NAME}"
    exit 1
fi

echo "Connecting to task: $TASK_ARN"
echo "Container: ${SERVICE_NAME}"
echo ""

aws ecs execute-command \
    --cluster "$CLUSTER_NAME" \
    --task "$TASK_ARN" \
    --container "${SERVICE_NAME}" \
    --interactive \
    --command "/bin/sh" \
    --profile "${ENVIRONMENT}-${PROJECT}" \
    --region "eu-west-1"

# ============================================================================
# To connect to the PostgreSQL RDS database from within the container:
# ============================================================================
#
# 1. Once inside the container, use the psql client:
#
# PGPASSWORD="$POSTGRES_PASSWORD" psql -h "$POSTGRES_HOST" -U "$POSTGRES_USER" -d "$POSTGRES_DB" -p "$POSTGRES_PORT"
#
# 2. Or with explicit values (get them from environment first):
#
#    export DB_ENDPOINT=$(terraform output -raw database_endpoint)
#    export DB_PASSWORD=$(terraform output -raw database_password)
#    export DB_USER="postgres"  # or var.database.username
#    export DB_NAME="corpershub" # or var.database.name
#
#    Then inside the container:
#    PGPASSWORD="$DB_PASSWORD" psql -h "$DB_ENDPOINT" -U "$DB_USER" -d "$DB_NAME"
#
# 3. If psql is not installed in the container, install it first (Alpine/Debian):
#
#    Alpine: apk add --no-cache postgresql-client
#    Debian: apt-get update && apt-get install -y postgresql-client
#
# 4. Alternative: Connect via the database endpoint directly from your machine
#    if you have VPC access (via VPN/tailscale) or the RDS is publicly accessible:
#
#    terraform output -raw database_endpoint
#    terraform output -raw database_password
#
# ============================================================================
# 
# PGPASSWORD="$POSTGRES_PASSWORD" \
# psql \
#   -h "$POSTGRES_HOST" \
#   -p "${POSTGRES_PORT:-5432}" \
#   -U "$POSTGRES_USER" \
#   -d "$POSTGRES_DB" \
#   -v ON_ERROR_STOP=1 \
#   -f update.sql