# Navigate to directory
cd $FORGE_SITE_PATH

# Enable maintenance mode only if not already enabled
$FORGE_PHP artisan down || true

# Pull latest changes from GitHub
git pull origin $FORGE_SITE_BRANCH

( flock -w 10 9 || exit 1
    echo 'Reloading PHP FPM...'; sudo -S service $FORGE_PHP_FPM reload ) 9>/tmp/fpmlock

# Install composer assets
$FORGE_COMPOSER install --no-interaction --prefer-dist --optimize-autoloader --no-dev

# Run migrations
$FORGE_PHP artisan migrate --force

# Install NPM dependencies and build frontend assets
npm ci
npm run build

# Cache Assets
$FORGE_PHP artisan view:cache
$FORGE_PHP artisan optimize

# Disable maintenance mode
$FORGE_PHP artisan up