#!/bin/bash

# Deployment script for CateGurumi (Laravel + React)
set -e # Stop on any error

# 1. Determine directories
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"

cd "$PROJECT_ROOT"

# 2. Load environment variables
if [ -f "$SCRIPT_DIR/deploy.env" ]; then
    export $(grep -v '^#' "$SCRIPT_DIR/deploy.env" | xargs)
elif [ -f "$PROJECT_ROOT/deploy.env" ]; then
    export $(grep -v '^#' "$PROJECT_ROOT/deploy.env" | xargs)
else
    echo "Error: deploy.env file not found."
    exit 1
fi

# Check for required variables
if [ -z "$DEPLOY_USER" ] || [ -z "$DEPLOY_HOST" ] || [ -z "$DEPLOY_PATH" ]; then
    echo "Error: Missing deployment variables in deploy.env."
    exit 1
fi

echo "--- Starting Deployment [CATEGURUMI_SYNC] ---"

# Step 1: Build Frontend Assets locally
echo "Step 1: Building Frontend Assets..."
npm install
npm run build

# Step 2: Sync files to server
echo "Step 2: Uploading to $DEPLOY_HOST..."
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
    
    # 3.1 Force create all required directories
    echo "Ensuring directory structure..."
    mkdir -p storage/framework/{sessions,views,cache}
    mkdir -p storage/app/public/creations
    mkdir -p storage/app/livewire-tmp
    mkdir -p bootstrap/cache

    # 3.2 Install PHP dependencies
    echo "Installing PHP dependencies..."
    composer install --no-dev --optimize-autoloader
    
    # 3.3 Database and Storage
    echo "Running migrations and linking storage..."
    php artisan migrate --force
    php artisan storage:link --force || true
    
    # 3.4 Definitive Permission Reset (The "Once and For All" Fix)
    echo "Applying definitive permission fix..."
    # Set ownership to web server user
    chown -R www-data:www-data $DEPLOY_PATH
    # Folders: 775 (owner/group can write)
    find $DEPLOY_PATH -type d -exec chmod 775 {} \;
    # Files: 664 (owner/group can write)
    find $DEPLOY_PATH -type f -exec chmod 664 {} \;
    # Ensure Caddy/PHP-FPM can enter all folders
    chmod -R 775 storage bootstrap/cache database
    
    # 3.5 Optimize Laravel
    echo "Optimizing Laravel..."
    sudo -u www-data php artisan config:cache
    sudo -u www-data php artisan route:cache
    sudo -u www-data php artisan view:cache
    
    # 3.6 Restart PHP-FPM to clear any stale file handles
    echo "Restarting PHP service..."
    systemctl restart php8.4-fpm
EOF

echo "--- Deployment Successful ---"
echo "REMINDER: Ensure your .env file is present on the server at $DEPLOY_PATH/.env"
echo "REMINDER: If you changed the Caddyfile, run: sudo cp $DEPLOY_PATH/deploy/Caddyfile /etc/caddy/Caddyfile && sudo systemctl reload caddy"
