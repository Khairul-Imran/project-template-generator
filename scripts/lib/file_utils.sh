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

    # Create main README.md
    cat > "README.md" << EOF
# ${project_name^}

## Overview
${project_name^} is a ${project_type} project.

## Project Structure
$(case "$project_type" in
    "frontend")
        echo "- \`${project_name}-frontend/\` - Frontend application (React + TypeScript)
  - See frontend README for specific setup and development instructions"
        ;;
    "backend")
        echo "- \`${project_name}-backend/\` - Backend application (Spring Boot)
  - See backend README for specific setup and development instructions"
        ;;
    "fullstack")
        echo "- \`${project_name}-frontend/\` - Frontend application (React + TypeScript)
  - See frontend README for specific setup and development instructions
- \`${project_name}-backend/\` - Backend application (Spring Boot)
  - See backend README for specific setup and development instructions"
        ;;
esac)

## Getting Started

### Prerequisites
$(case "$project_type" in
    "frontend")
        echo "- Node.js (LTS version recommended)
- npm"
        ;;
    "backend")
        echo "- Java 17 or higher
- Maven"
        ;;
    "fullstack")
        echo "- Node.js (LTS version recommended)
- npm
- Java 17 or higher
- Maven"
        ;;
esac)

### Installation and setup
1. Clone the repository
\`\`\`bash
git clone <repository-url>
cd ${project_name}
\`\`\`

$(case "$project_type" in
    "frontend")
        echo "2. Install dependencies
\`\`\`bash
npm install
\`\`\`"
        ;;
    "backend")
        echo "2. Build the project
\`\`\`bash
./mvnw clean install
\`\`\`"
        ;;
    "fullstack")
        echo "2. Install and build projects
\`\`\`bash
# Frontend
cd frontend
npm install

# Backend
cd ../backend
./mvnw clean install
\`\`\`"
        ;;
esac)

### Development
$(case "$project_type" in
    "frontend")
        echo "Run the development server:
\`\`\`bash
npm run dev
\`\`\`"
        ;;
    "backend")
        echo "Run the application:
\`\`\`bash
./mvnw spring-boot:run
\`\`\`"
        ;;
    "fullstack")
        echo "1. Start the backend server:
\`\`\`bash
cd backend
./mvnw spring-boot:run
\`\`\`

2. In a new terminal, start the frontend development server:
\`\`\`bash
cd frontend
npm run dev
\`\`\`"
        ;;
esac)

## Project Structure
$(case "$project_type" in
    "frontend")
        echo "- \`src/\` - Source files
- \`public/\` - Static assets
- \`docs/\` - Documentation
- \`scripts/\` - Utility scripts"
        ;;
    "backend")
        echo "- \`src/\` - Source files
- \`config/\` - Configuration files
- \`docs/\` - Documentation
- \`scripts/\` - Utility scripts"
        ;;
    "fullstack")
        echo "- \`frontend/\` - Frontend application
- \`backend/\` - Backend application
- \`docs/\` - Documentation
- \`scripts/\` - Utility scripts
- \`config/\` - Configuration files"
        ;;
esac)

## Available Commands
$(case "$project_type" in
    "frontend")
        echo "- \`npm run dev\` - Start development server
- \`npm run build\` - Build for production
- \`npm run test\` - Run tests"
        ;;
    "backend")
        echo "- \`./mvnw spring-boot:run\` - Start the application
- \`./mvnw test\` - Run tests
- \`./mvnw package\` - Create production build"
        ;;
    "fullstack")
        echo "Frontend:
- \`npm run dev\` - Start development server
- \`npm run build\` - Build for production
- \`npm run test\` - Run tests

Backend:
- \`./mvnw spring-boot:run\` - Start the application
- \`./mvnw test\` - Run tests
- \`./mvnw package\` - Create production build"
        ;;
esac)

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
# Contributing to ${project_name^}

## Getting started
1. Fork the repository
2. Create a new branch (\`git checkout -b feature/amazing-feature\`)
3. Commit your changes (\`git commit -m 'Add some amazing feature'\`)
4. Push to the branch (\`git push origin feature/amazing-feature\`)
5. Open a Pull Request

## Development Guidelines
$(case "$project_type" in
    "frontend")
        echo "- Follow the existing code style
- Write meaningful commit messages
- Update documentation as needed
- Add appropriate tests"
        ;;
    "backend")
        echo "- Follow Java coding conventions
- Write meaningful commit messages
- Include appropriate unit tests
- Update documentation as needed"
        ;;
    "fullstack")
        echo "### Frontend
- Follow the existing code style
- Write meaningful commit messages
- Update documentation as needed
- Add appropriate tests

### Backend
- Follow Java coding conventions
- Write meaningful commit messages
- Include appropriate unit tests
- Update documentation as needed"
        ;;
esac)
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
