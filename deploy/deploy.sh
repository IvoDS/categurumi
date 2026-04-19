#!/bin/bash

# Deployment script for Initializer System [IDS_CYBER_INDUSTRIAL]

# Load environment variables
if [ -f deploy.env ]; then
    export $(grep -v '^#' deploy.env | xargs)
else
    echo "Error: deploy.env file not found."
    exit 1
fi

# Check for required variables
if [ -z "$DEPLOY_USER" ] || [ -z "$DEPLOY_HOST" ] || [ -z "$DEPLOY_PATH" ]; then
    echo "Error: Missing deployment variables in deploy.env."
    exit 1
fi

echo "--- Starting Deployment [INITIALIZER_BOOT_SEQUENCE] ---"

# Step 1: Build Frontend
echo "Step 1: Building Frontend..."
cd ../initializer-fe
npm run build

if [ $? -ne 0 ]; then
    echo "Frontend build failed. Aborting."
    exit 1
fi

# Step 2: Prepare Backend 'public' folder
echo "Step 2: Preparing Backend public folder..."
rm -rf ../initializer-be/public
mkdir -p ../initializer-be/public
cp -r dist/* ../initializer-be/public/

# Step 3: Upload Backend to server
echo "Step 3: Uploading Backend to $DEPLOY_HOST..."
cd ../initializer-be
# Exclude node_modules, logs, and local sqlite database to keep upload clean
rsync -avz --delete \
    --exclude 'node_modules' \
    --exclude 'logs' \
    --exclude '*.sqlite' \
    --exclude '.env' \
    ./ $DEPLOY_USER@$DEPLOY_HOST:$DEPLOY_PATH

if [ $? -ne 0 ]; then
    echo "Transfer failed."
    exit 1
fi

# Step 4: Remote Setup (Install dependencies & Restart PM2)
echo "Step 4: Running remote setup..."
ssh $DEPLOY_USER@$DEPLOY_HOST << EOF
    # Load NVM path explicitly for non-interactive shell
    export PATH="\$PATH:/root/.nvm/versions/node/v24.13.0/bin"
    
    cd $DEPLOY_PATH
    
    # Create production .env if it doesn't exist
    if [ ! -f .env ]; then
        echo "Creating production .env..."
        echo "PORT=3001" > .env
        echo "DB_NAME=database.sqlite" >> .env
        echo "JWT_SECRET=ids-cyber-secret-999" >> .env
        echo "ADMIN_USER=admin" >> .env
        echo "ADMIN_PASS=admin123" >> .env
        echo "NODE_ENV=production" >> .env
    fi

    npm install --production
    # Ensure PM2 is running or start it
    pm2 delete $PM2_NAME || true
    pm2 start src/index.js --name $PM2_NAME
    pm2 save
EOF

if [ $? -eq 0 ]; then
    echo "--- Deployment Successful [SYSTEM_ONLINE] ---"
    echo "Accessible at: https://initializer.ivandestefani.it"
else
    echo "Remote setup failed."
    exit 1
fi
