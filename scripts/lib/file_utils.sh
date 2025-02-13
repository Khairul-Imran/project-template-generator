#!/bin/bash

# Set strict error handling
set -euo pipefail

# Create necessary directory structure based on project type
create_directory_structure() {
    local project_type="$1"
    local project_name="$2"

    log_info "Creating directory structure for $project_type project..."
    log_verbose "Creating docs directory..."

    # Create docs directory for additional documentation if needed
    mkdir -p docs
}

# Create basic documentation files
create_documentation() {
    local project_type="$1"
    local project_name="$2"

    log_info "Creating documentation files..."
    log_verbose "Generating README.md..."

    # Create project title with first letter capitalized
    project_title=$(echo "$project_name" | tr '[:lower:]' '[:upper:]' | sed 's/\(.\)\(.*\)/\1\L\2/')

    # Pre-generate content based on project type
    local project_structure=""
    local prerequisites=""
    local installation=""
    local development=""
    local project_files=""
    local available_commands=""
    local contributing_guidelines=""

    # Set content based on project type
    case "$project_type" in
        "frontend")
            project_structure="- \`${project_name}-frontend/\` - Frontend application (React + TypeScript)\n  - See frontend README for specific setup and development instructions"
            prerequisites="- Node.js (LTS version recommended)\n- npm"
            installation="2. Install dependencies\n\`\`\`bash\nnpm install\n\`\`\`"
            development="Run the development server:\n\`\`\`bash\nnpm run dev\n\`\`\`"
            project_files="- \`src/\` - Source files\n- \`public/\` - Static assets\n- \`docs/\` - Documentation\n- \`scripts/\` - Utility scripts"
            available_commands="- \`npm run dev\` - Start development server\n- \`npm run build\` - Build for production\n- \`npm run test\` - Run tests"
            contributing_guidelines="- Follow the existing code style\n- Write meaningful commit messages\n- Update documentation as needed\n- Add appropriate tests"
            ;;
        "backend")
            project_structure="- \`${project_name}-backend/\` - Backend application (Spring Boot)\n  - See backend README for specific setup and development instructions"
            prerequisites="- Java 17 or higher\n- Maven"
            installation="2. Build the project\n\`\`\`bash\n./mvnw clean install\n\`\`\`"
            development="Run the application:\n\`\`\`bash\n./mvnw spring-boot:run\n\`\`\`"
            project_files="- \`src/\` - Source files\n- \`config/\` - Configuration files\n- \`docs/\` - Documentation\n- \`scripts/\` - Utility scripts"
            available_commands="- \`./mvnw spring-boot:run\` - Start the application\n- \`./mvnw test\` - Run tests\n- \`./mvnw package\` - Create production build"
            contributing_guidelines="- Follow Java coding conventions\n- Write meaningful commit messages\n- Include appropriate unit tests\n- Update documentation as needed"
            ;;
        "fullstack")
            project_structure="- \`${project_name}-frontend/\` - Frontend application (React + TypeScript)\n  - See frontend README for specific setup and development instructions\n- \`${project_name}-backend/\` - Backend application (Spring Boot)\n  - See backend README for specific setup and development instructions"
            prerequisites="- Node.js (LTS version recommended)\n- npm\n- Java 17 or higher\n- Maven"
            installation="2. Install and build projects\n\`\`\`bash\n# Frontend\ncd frontend\nnpm install\n\n# Backend\ncd ../backend\n./mvnw clean install\n\`\`\`"
            development="1. Start the backend server:\n\`\`\`bash\ncd backend\n./mvnw spring-boot:run\n\`\`\`\n\n2. In a new terminal, start the frontend development server:\n\`\`\`bash\ncd frontend\nnpm run dev\n\`\`\`"
            project_files="- \`frontend/\` - Frontend application\n- \`backend/\` - Backend application\n- \`docs/\` - Documentation\n- \`scripts/\` - Utility scripts\n- \`config/\` - Configuration files"
            available_commands="Frontend:\n- \`npm run dev\` - Start development server\n- \`npm run build\` - Build for production\n- \`npm run test\` - Run tests\n\nBackend:\n- \`./mvnw spring-boot:run\` - Start the application\n- \`./mvnw test\` - Run tests\n- \`./mvnw package\` - Create production build"
            contributing_guidelines="### Frontend\n- Follow the existing code style\n- Write meaningful commit messages\n- Update documentation as needed\n- Add appropriate tests\n\n### Backend\n- Follow Java coding conventions\n- Write meaningful commit messages\n- Include appropriate unit tests\n- Update documentation as needed"
            ;;
    esac

    # Create main README.md
    cat > "README.md" << EOF
# $project_title

## Overview
$project_title is a ${project_type} project.

## Project Structure
$project_structure

## Getting Started

### Prerequisites
$prerequisites

### Installation and setup
1. Clone the repository
\`\`\`bash
git clone <repository-url>
cd ${project_name}
\`\`\`

$installation

### Development
$development

## Project Structure
$project_files

## Available Commands
$available_commands

## Git Hooks
This project includes a pre-commit hook that checks for sensitive data in your commits. This helps prevent accidental commits of sensitive information.

To bypass this check (NOT RECOMMENDED), use:
\`\`\`bash
git commit --no-verify
\`\`\`
EOF

    log_verbose "Generating CONTRIBUTING.md..."
    # Create docs/CONTRIBUTING.md
    mkdir -p docs
    cat > "docs/CONTRIBUTING.md" << EOF
# Contributing to $project_title

## Getting started
1. Fork the repository
2. Create a new branch (\`git checkout -b feature/amazing-feature\`)
3. Commit your changes (\`git commit -m 'Added some amazing feature'\`)
4. Push to the branch (\`git push origin feature/amazing-feature\`)
5. Open a Pull Request

## Development Guidelines
$contributing_guidelines
EOF
}

# Main file setup function that orchestrates all file operations
setup_project_files() {
    local project_type="$1"
    local project_name="$2"

    log_verbose "Starting project files setup..."
    create_directory_structure "$project_type" "$project_name"
    create_documentation "$project_type" "$project_name"

    log_success "Project files setup completed successfully!!"
}
