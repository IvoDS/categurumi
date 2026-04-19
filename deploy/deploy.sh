#!/bin/bash

# Deployment script for CateGurumi (Laravel + React)
set -e # Stop on any error

# 1. Determine directories
# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# The project root is one level up from the deploy folder
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"

cd "$PROJECT_ROOT"

# 2. Load environment variables
if [ -f "$SCRIPT_DIR/deploy.env" ]; then
    export $(grep -v '^#' "$SCRIPT_DIR/deploy.env" | xargs)
elif [ -f "$PROJECT_ROOT/deploy.env" ]; then
    export $(grep -v '^#' "$PROJECT_ROOT/deploy.env" | xargs)
else
    echo "Error: deploy.env file not found in $SCRIPT_DIR or $PROJECT_ROOT"
    exit 1
fi

# Check for required variables
if [ -z "$DEPLOY_USER" ] || [ -z "$DEPLOY_HOST" ] || [ -z "$DEPLOY_PATH" ]; then
    echo "Error: Missing deployment variables in deploy.env."
    exit 1
fi

echo "--- Starting Deployment [CATEGURUMI_SYNC] ---"
echo "Project Root: $PROJECT_ROOT"

# Step 1: Build Frontend Assets locally
echo "Step 1: Building Frontend Assets..."
npm install
npm run build

# Step 2: Sync files to server
echo "Step 2: Uploading to $DEPLOY_HOST..."
# Sync from PROJECT_ROOT to ensure everything is uploaded
rsync -avz --delete \
    --exclude 'node_modules' \
    --exclude 'storage/framework/cache/data/*' \
    --exclude 'storage/framework/sessions/*' \
    --exclude 'storage/framework/views/*' \
    --exclude 'storage/logs/*' \
    --exclude 'storage/app/public/*' \
    --exclude '.env' \
    --exclude '.git' \
    --exclude '.idea' \
    --exclude 'database/*.sqlite' \
    --exclude 'deploy/deploy.env' \
    ./ $DEPLOY_USER@$DEPLOY_HOST:$DEPLOY_PATH/

# Step 3: Remote Post-Deployment Tasks
echo "Step 3: Running remote setup..."
ssh $DEPLOY_USER@$DEPLOY_HOST "bash -s" << EOF
    set -e
    cd $DEPLOY_PATH
    
    # Verify artisan exists
    if [ ! -f "artisan" ]; then
        echo "Error: artisan file not found in \$(pwd). Files might not have been uploaded correctly."
        ls -la
        exit 1
    fi

    echo "Installing PHP dependencies..."
    composer install --no-dev --optimize-autoloader
    
    echo "Running migrations..."
    php artisan migrate --force
    
    echo "Linking storage..."
    # Storage link might already exist, so we use || true
    php artisan storage:link || true
    
    echo "Caching optimization..."
    php artisan config:cache
    php artisan route:cache
    php artisan view:cache
EOF

echo "--- Deployment Successful ---"
echo "REMINDER: Ensure your .env file is present on the server at $DEPLOY_PATH/.env"
echo "REMINDER: If you changed the Caddyfile, run: sudo systemctl reload caddy"
