#!/bin/bash

# Fix Homebrew Permissions and Install PostgreSQL
# This script will fix permissions and install PostgreSQL

echo "🔧 Fixing Homebrew permissions..."
echo "You may be prompted for your password (for sudo)"

# Fix permissions for Homebrew directories
sudo chown -R $(whoami) /usr/local/Cellar /usr/local/var/homebrew
sudo chown -R $(whoami) /usr/local/Frameworks /usr/local/Homebrew
sudo chown -R $(whoami) /usr/local/bin /usr/local/etc /usr/local/include
sudo chown -R $(whoami) /usr/local/lib /usr/local/opt /usr/local/sbin
sudo chown -R $(whoami) /usr/local/share
sudo chown -R $(whoami) /Users/$(whoami)/Library/Caches/Homebrew
sudo chown -R $(whoami) /Users/$(whoami)/Library/Logs/Homebrew

echo ""
echo "🧹 Cleaning up Homebrew..."
brew cleanup

echo ""
echo "📦 Installing PostgreSQL (latest version)..."
brew install postgresql

echo ""
echo "🚀 Starting PostgreSQL service..."
brew services start postgresql

echo ""
echo "✅ Checking PostgreSQL installation..."
if command -v psql &> /dev/null; then
    echo "PostgreSQL version:"
    psql --version
    echo ""
    echo "✅ PostgreSQL is installed and ready!"
    echo ""
    echo "Next steps:"
    echo "1. Run: createdb retail_sales_db"
    echo "2. Run: ./setup_database.sh"
else
    echo "❌ PostgreSQL installation may have failed. Please check the output above."
fi
