#!/bin/bash

# Set strict error handling
set -euo pipefail

# Create necessary directory structure based on project type
create_directory_structure() {
    local project_type="$1"
    local project_name="$2"

    echo "Creating directory structure for $project_type project..."

    case "$project_type" in
        "frontend")
            # Note: Most directories will be created by the frontend template generator
            # These are just additional directories we might need
            mkdir -p docs
            mkdir -p scripts/utils
            ;;
        "backend")
            # Note: Most directories will be created by Spring Initializr
            # These are just additional directories we might need
            mkdir -p docs
            mkdir -p scripts/utils
            mkdir -p config
            ;;
        "fullstack")
            # Create both frontend and backend structures
            mkdir -p frontend
            mkdir -p backend
            mkdir -p docs
            mkdir -p scripts/utils
            mkdir -p config
            ;;

        *)
            echo "Error: Unknown project type $project_type"
            return 1
            ;;
    esac
}

# Create basic documentation files
create_documentation() {
    local project_type="$1"
    local project_name="$2"

    echo "Creating documentation files..."

    # Create main README.md
    cat > "README.md" << EOF
# ${project_name^}

## Overview
${project_name^} is a ${project_type} project.

## Getting Started

### Prerequisites
$(case "$project_type" in
    "frontend")
        echo "- Node.js (LTS version recommended)
- npm or yarn"
        ;;
    "backend")
        echo "- Java 17 or higher
- Maven or Gradle"
        ;;
    "fullstack")
        echo "- Node.js (LTS version recommended)
- npm or yarn
- Java 17 or higher
- Maven or Gradle"
        ;;
esac)

### Installation
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
# or
yarn install
\`\`\`"
        ;;
    "backend")
        echo "2. Build the project
\`\`\`bash
./mvnw clean install
# or
./gradlew build
\`\`\`"
        ;;
    "fullstack")
        echo "2. Install and build projects
\`\`\`bash
# Frontend
cd frontend
npm install
# or
yarn install

# Backend
cd ../backend
./mvnw clean install
# or
./gradlew build
\`\`\`"
        ;;
esac)

### Development
$(case "$project_type" in
    "frontend")
        echo "Run the development server:
\`\`\`bash
npm run dev
# or
yarn dev
\`\`\`"
        ;;
    "backend")
        echo "Run the application:
\`\`\`bash
./mvnw spring-boot:run
# or
./gradlew bootRun
\`\`\`"
        ;;
    "fullstack")
        echo "1. Start the backend server:
\`\`\`bash
cd backend
./mvnw spring-boot:run
# or
./gradlew bootRun
\`\`\`

2. In a new terminal, start the frontend development server:
\`\`\`bash
cd frontend
npm run dev
# or
yarn dev
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

## License
This project is licensed under the MIT License - see the LICENSE file for details.
EOF

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

# Copy or create any necessary config files
setup_config_files() {
    local project_type="$1"

    echo "Setting up configuration files..."

    # Create config directory if it doesn't exist
    # Might not need this, as the templates generated might already have generated config files for us
    # mkdir -p config

    # I need to see how the respective templates are generated first before deciding how these config files could work
    case "$project_type" in 
        # For now, not doing anything at the frontend
        "frontend")
            ;;
        # Same for the backend
        "backend")
            ;;
        "fullstack")
            setup_config_files "frontend"
            setup_config_files "backend"
            ;;
    esac
}

# Main file setup function that orchestrates all file operations
setup_project_files() {
    local project_type="$1"
    local project_name="$2"

    create_directory_structure "$project_type" "$project_name"
    create_documentation "$project_type" "$project_name"
    setup_config_files "$project_type"

    echo "Project files setup completed successfully!!"
}


# TODO:
# - Double check the directory structures that you want to create for each type of project.


# Comments:

# DIRECTORY STRUCTURE
# For the fullstack directories (frontend and backend) I want the respective directories to start with "project_name-"
# E.g. ats-optimiser-frontend
