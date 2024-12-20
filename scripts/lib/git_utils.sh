#!/bin/bash

# Set strict error handling
set -euo pipefail

# Initialise git repository with basic configuration
init_git_repo() {
    local project_name="$1"
    local git_user_name
    local git_user_email

    echo "Initialising Git repository..."

    # Initialise repository if not already initialised
    if [[ ! -d ".git" ]]; then
        git init

        # Try to get git config values, use defaults if not set
        git_user_name=$(git config --global user.name || echo "")
        git_user_email=$(git config --global user.email || echo "")

        # Configure git if values are not already set
        if [[ -z "$git_user_name" ]]; then
            echo "Warning: Git user.name not set. Please configure it manually."
        fi

        if [[ -z "$git_user_email" ]]; then
            echo "Warning: Git user.email not set. Please configure it manually."
        fi
    else
        echo "Git repository already initialised"
    fi
}

# Create .gitignore file based on project type
create_gitignore() {
    local project_type="$1"
    local gitignore_file=".gitignore"

    # Only create the .gitignore file if it doesn't exist
    if [[ -f "$gitignore_file" ]]; then
        echo "Using existing .gitignore file"
        return
    fi

    echo "Creating root .gitignore file..."

    # Only include common/root-level ignores
    cat > "$gitignore_file" << EOF
# General
.DS_Store
*.log
logs/
.env
.env.*
!.env.example

# Editor directories and files
.idea/
.vscode/
*.swp
*.swo
*~

# Project generator logs
generator-logs/
EOF
}

# Initialise main branch and create initial commit
create_initial_commit() {
    local project_name="$1"

    echo "Creating initial commit..."

    # Stage all files
    git add .

    # Create initial commit
    git commit -m "Initial commit: Setup $project_name project structure" || {
        echo "Warning: Could not create initial commit. Please configure git user.name and user.email"
        return 1
    }
}

# Configure common git hooks
# In this case, we just want to prevent commits of sensitive data
setup_git_hooks() {
    local hooks_dir=".git/hooks"

    echo "Setting up Git hooks for security checks..."

    # Create pre-commit hook
    cat > "$hooks_dir/pre-commit" << 'EOF'
#!/bin/bash

echo "Running security checks..."

# Check for potential sensitive files
SENSITIVE_PATTERNS=(
    '\.env$'
    '\.pem$'
    '\.key$'
    '\.pfx$'
    '\.p12$'
    '\.pkcs12$'
    'id_rsa'
    'id_dsa'
    'private.*\.key'
    '\.env\.local$'
    '\.env\.development$'
    '\.env\.production$'
    'credentials\.json$'
    'secrets\.yaml$'
    'secrets\.yml$'
    'secrets\.properties$'
    'application\.properties$'
    'application\.yml$'
    'application\.yaml$'
)

# Files to be committed
FILES_CHANGED=$(git diff --cached --name-only)

# Flag to track if any sensitive files are found
SENSITIVE_FILES_FOUND=0

# Check each changed file against sensitive patterns
for file in $FILES_CHANGED; do
    for pattern in "${SENSITIVE_PATTERNS[@]}"; do
        if echo "$file" | grep -Eq "$pattern"; then
            echo "⚠️  Warning: Potentially sensitive file detected: $file"
            SENSITIVE_FILES_FOUND=1
        fi
    done
    
    # Additional check for files containing potential secrets
    if [ -f "$file" ]; then
        # Check for potential API keys, tokens, and passwords
        if git diff --cached "$file" | grep -Ei 'api[_-]key|api[_-]secret|access[_-]key|secret[_-]key|password|token|credential' > /dev/null; then
            echo "⚠️  Warning: File '$file' may contain sensitive data (API keys, tokens, or credentials)"
            SENSITIVE_FILES_FOUND=1
        fi
    fi
done

if [ $SENSITIVE_FILES_FOUND -eq 1 ]; then
    echo "❌ Commit blocked: Sensitive data detected in staged files"
    echo "Please review the warnings above and:"
    echo "1. Remove sensitive files from git tracking"
    echo "2. Add them to .gitignore if needed"
    echo "3. Move sensitive data to environment variables"
    echo ""
    echo "To proceed anyway (NOT RECOMMENDED), use --no-verify:"
    echo "git commit --no-verify"
    exit 1
fi

echo "✅ Security checks passed"
exit 0
EOF

    # Make hooks executable
    chmod +x "$hooks_dir/pre-commit"

    echo "Git security hooks installed successfully"
}

# Main git setup function that orchestrates all git-related operations
setup_git() {
    local project_name="$1"
    local project_type="$2"

    # Initialise repository
    init_git_repo "$project_name"

    # Create appropriate .gitignore
    create_gitignore "$project_type"

    # Setup git hooks
    setup_git_hooks

    # Create initial commit (if git is configured)
    create_initial_commit "$project_name" || true

    echo "Git setup completed successfully!"
}
