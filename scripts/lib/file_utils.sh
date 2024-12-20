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
    # Stopped here



}




# TODO:
# - Double check the directory structures that you want to create.


# Comments:

# DIRECTORY STRUCTURE
# For the fullstack directories (frontend and backend) I want the respective directories to start with "project_name-"
# E.g. ats-optimiser-frontend
