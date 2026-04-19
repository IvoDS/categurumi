#!/bin/bash

# Deployment script for CateGurumi (Laravel + React)

# Load environment variables
if [ -f deploy.env ]; then
    export $(grep -v '^#' deploy.env | xargs)
else
    echo "Warning: deploy.env file not found. Please ensure DEPLOY_USER, DEPLOY_HOST, and DEPLOY_PATH are set."
    exit 1
fi

echo "--- Starting Deployment [CATEGURUMI_SYNC] ---"

# Step 1: Build Frontend Assets locally
echo "Step 1: Building Frontend Assets..."
npm install
npm run build

if [ $? -ne 0 ]; then
    echo "Frontend build failed. Aborting."
    exit 1
fi

# Step 2: Sync files to server
echo "Step 2: Uploading to $DEPLOY_HOST..."
# Syncing all files while excluding local dev files and storage contents
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
    ./ $DEPLOY_USER@$DEPLOY_HOST:$DEPLOY_PATH

if [ $? -ne 0 ]; then
    echo "Transfer failed."
    exit 1
fi

# Step 3: Remote Post-Deployment Tasks
echo "Step 3: Running remote setup..."
ssh $DEPLOY_USER@$DEPLOY_HOST << EOF
    cd $DEPLOY_PATH
    
    # Install PHP dependencies
    composer install --no-dev --optimize-autoloader
    
    # Run migrations
    php artisan migrate --force
    
    # Ensure storage link exists
    php artisan storage:link
    
    # Clear and cache configuration for performance
    php artisan config:cache
    php artisan route:cache
    php artisan view:cache
    
    # Fix permissions (adjust according to your server user, e.g., www-data)
    # sudo chown -R www-data:www-data storage bootstrap/cache
    # sudo chmod -R 775 storage bootstrap/cache
EOF

if [ $? -eq 0 ]; then
    echo "--- Deployment Successful ---"
else
    echo "Remote setup failed."
    exit 1
fi
