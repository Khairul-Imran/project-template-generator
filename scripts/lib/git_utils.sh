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
        git_user_email=$(git config -global user.email || echo "")

        # Configure git if values are not already set
        if [[ -z "$git_user_name" ]]; then
            echo "Warning: Git user.name not set. Please configure it manually."
        fi

        if [[ -z "$git_user_email" ]]; then
            echo "Warning: Git uesr.email not set. Please configure it manually."
        fi
    else
        echo "Git repository already initialised"
    fi
}

# Create .gitignore file based on project type
create_gitignore() {
    local project_type="$1"
    local gitignore_file=".gitignore"

    echo "Creating .gitignore file..."

    # Common ignores for all projects
    cat > "$gitignore_file" << EOF
# General
.DS_Store
*.log
logs/
*.env
.env.*
!.env.example

# Editor directories and files
.idea/
.vscode/
*.swp
*.swo
*~

# Dependencies
node_modules/
EOF
    
    # Add project-specific ignores based on type
    case "$project_type" in
        "frontend")
            cat >> "$gitignore_file" << EOF
# Frontend specific
/build/
/dist/
/.next/
/out/
/coverage/
.cache/
*.tsbuildinfo

# Environment files
.env.local
.env.development.local
.env.test.local
.env.production.local

# Debug logs
npm-debug.log*
yarn-debug.log*
yarn-error.log*
EOF
            ;;
            
        "backend")
            cat >> "$gitignore_file" << EOF
# Backend specific
/target/
*.class
*.jar
*.war
*.ear
*.iml

# Spring Boot
HELP.md
.gradle/
build/
!gradle/wrapper/gradle-wrapper.jar
!**/src/main/**/build/
!**/src/test/**/build/

# STS/Eclipse
.apt_generated
.classpath
.factorypath
.project
.settings
.springBeans
.sts4-cache

# Database
*.db
*.sqlite
EOF
            ;;
            
        "fullstack")
            # Call both frontend and backend gitignore creation
            create_gitignore "frontend"
            create_gitignore "backend"
            ;;
    esac
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
setup_git_hooks() {
    local hooks_dir=".git/hooks"

    echo "Setting up Git hooks..."

    # Create pre-commit hook
    cat > "$hooks_dir/pre-commit" << 'EOF'
#!/bin/bash

echo "Running pre-commit checks..."

# Check for large files
large_files=$(find . -type f -size +5M -not -path "./.git/*")
if [[ -n "$large_files" ]]; then
    echo "Error: Large files detected:"
    echo "$large_files"
    echo "Please remove large files before committing."
    exit 1
fi

# To add more pre-commit checks here in the future as needed
exit 0
EOF

    # Make hooks executable
    chmod +x "$hooks_dir/pre-commit"
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
