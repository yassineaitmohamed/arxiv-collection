#!/bin/bash
# Automatic deployment script for GitHub Pages
# By Yassine Ait Mohamed

echo "=================================="
echo "📦 arXiv Collection Pro Deployer"
echo "=================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if git is initialized
if [ ! -d .git ]; then
    echo -e "${YELLOW}⚠️  Git not initialized. Initializing...${NC}"
    git init
    echo -e "${GREEN}✅ Git initialized${NC}"
fi

# Check for remote
if ! git remote | grep -q origin; then
    echo -e "${YELLOW}⚠️  No remote repository found.${NC}"
    echo "Please enter your GitHub repository URL (e.g., https://github.com/username/repo.git):"
    read repo_url
    git remote add origin "$repo_url"
    echo -e "${GREEN}✅ Remote added${NC}"
fi

# Export database if it exists
if [ -f "arxiv_collection.db" ]; then
    echo -e "${YELLOW}📊 Found database. Exporting to JSON...${NC}"
    python3 export_to_json.py arxiv_collection.db articles.json
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Database exported${NC}"
    else
        echo -e "${RED}❌ Export failed${NC}"
        exit 1
    fi
else
    echo -e "${YELLOW}ℹ️  No database found. Using existing articles.json${NC}"
fi

# Check file sizes
json_size=$(du -h articles.json 2>/dev/null | cut -f1)
if [ ! -z "$json_size" ]; then
    echo -e "${GREEN}📦 articles.json size: $json_size${NC}"
    
    # Warn if file is large
    json_bytes=$(stat -f%z articles.json 2>/dev/null || stat -c%s articles.json 2>/dev/null)
    if [ "$json_bytes" -gt 100000000 ]; then  # 100 MB
        echo -e "${YELLOW}⚠️  Warning: articles.json is very large (>100MB)${NC}"
        echo -e "${YELLOW}   Consider splitting or compressing the data${NC}"
    fi
fi

# Add files
echo ""
echo -e "${YELLOW}📝 Adding files to git...${NC}"
git add .

# Commit
echo ""
echo "Enter commit message (or press Enter for default):"
read commit_msg
if [ -z "$commit_msg" ]; then
    commit_msg="Update arXiv collection $(date +%Y-%m-%d)"
fi

git commit -m "$commit_msg"

# Push
echo ""
echo -e "${YELLOW}🚀 Pushing to GitHub...${NC}"
git push -u origin main

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}=================================="
    echo -e "✅ Deployment successful!"
    echo -e "==================================${NC}"
    echo ""
    echo "Your site will be live at:"
    
    # Try to extract username and repo from remote URL
    remote_url=$(git remote get-url origin)
    if [[ $remote_url =~ github\.com[:/]([^/]+)/([^/.]+) ]]; then
        username="${BASH_REMATCH[1]}"
        repo="${BASH_REMATCH[2]}"
        echo -e "${GREEN}https://${username}.github.io/${repo}/${NC}"
    else
        echo "https://YOUR_USERNAME.github.io/YOUR_REPO/"
    fi
    
    echo ""
    echo "Note: It may take 1-2 minutes for changes to appear."
    echo ""
    echo "Next steps:"
    echo "1. Go to your repository settings on GitHub"
    echo "2. Navigate to 'Pages' section"
    echo "3. Make sure source is set to 'main' branch"
    echo ""
else
    echo ""
    echo -e "${RED}=================================="
    echo -e "❌ Deployment failed"
    echo -e "==================================${NC}"
    echo ""
    echo "Please check:"
    echo "1. You have push access to the repository"
    echo "2. You're authenticated with GitHub"
    echo "3. The remote URL is correct"
    echo ""
    exit 1
fi
