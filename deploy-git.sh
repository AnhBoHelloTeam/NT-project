#!/bin/bash

# NT Project - Git Deploy Script
# This script commits and pushes changes to GitHub

set -e

echo "📤 Deploying NT Project to GitHub..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[GIT]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Check if git is initialized
if [ ! -d ".git" ]; then
    print_error "Git repository not initialized. Please run 'git init' first."
    exit 1
fi

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    print_error "Not in a git repository. Please navigate to the project directory."
    exit 1
fi

# Get current branch
current_branch=$(git branch --show-current)
print_status "Current branch: $current_branch"

# Check for uncommitted changes
if git diff --quiet && git diff --cached --quiet; then
    print_warning "No changes to commit."
    exit 0
fi

# Show status
print_status "Git status:"
git status --short

# Add all changes
print_status "Adding all changes..."
git add .

# Get commit message
if [ -z "$1" ]; then
    read -p "Enter commit message: " commit_message
else
    commit_message="$1"
fi

# If no commit message provided, use default
if [ -z "$commit_message" ]; then
    commit_message="Update NT Project - Full Stack with MongoDB"
fi

# Commit changes
print_status "Committing changes..."
git commit -m "$commit_message"

# Check if remote origin exists
if ! git remote get-url origin > /dev/null 2>&1; then
    print_warning "No remote origin found. Please add remote origin first:"
    echo "git remote add origin https://github.com/your-username/your-repo.git"
    exit 1
fi

# Get remote URL
remote_url=$(git remote get-url origin)
print_status "Remote origin: $remote_url"

# Push to remote
print_status "Pushing to remote repository..."
if git push origin "$current_branch"; then
    print_success "Successfully pushed to GitHub!"
else
    print_error "Failed to push to GitHub. Please check your credentials and network connection."
    exit 1
fi

# Show GitHub Actions status
print_status "GitHub Actions will now run the CI/CD pipeline..."
echo ""
echo "🔗 GitHub Actions:"
echo "   Repository: $remote_url"
echo "   Actions: $remote_url/actions"
echo ""

# Check if this is main branch
if [ "$current_branch" = "main" ] || [ "$current_branch" = "master" ]; then
    print_success "🚀 Deployment triggered! GitHub Actions will deploy to Ubuntu VM."
    echo ""
    echo "📋 Next steps:"
    echo "1. Check GitHub Actions: $remote_url/actions"
    echo "2. Monitor deployment progress"
    echo "3. Verify application is running on your VM"
    echo ""
    echo "🌐 Access URLs (after deployment):"
    echo "   Frontend: http://your-vm-ip:3001"
    echo "   Backend API: http://your-vm-ip:3000"
    echo "   API Health: http://your-vm-ip:3000/health"
else
    print_warning "This is not the main branch. CI/CD will only run tests."
    echo "To deploy, merge this branch to main or push directly to main branch."
fi

echo ""
print_success "Git deployment completed! 🎉"
