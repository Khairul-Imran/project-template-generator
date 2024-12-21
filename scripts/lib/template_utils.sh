#!/bin/bash

# Set strict error handling
set -euo pipefail

# Update the frontend README
update_frontend_readme() {
    local project_name="$1"
    local frontend_dir="${project_name}-frontend"
    
    echo "Updating frontend README..."
    
    cat > "${frontend_dir}/README.md" << EOF
# ${project_name^} Frontend

## Tech Stack
- React
- TypeScript
- Tailwind CSS
- Vite

## Getting Started

### Prerequisites
- Node.js (LTS version)
- npm

### Installation
1. Install dependencies
   \`\`\`bash
   npm install
   \`\`\`

### Development
1. Start the development server
   \`\`\`bash
   npm run dev
   \`\`\`
   This will start the server at http://localhost:5173

### Building for Production
1. Create a production build
   \`\`\`bash
   npm run build
   \`\`\`
   The build output will be in the \`dist\` directory

### Project Structure
\`\`\`
src/
├── assets/        # Static assets
├── components/    # Reusable components
├── pages/         # Route components
├── services/      # API services
└── types/         # TypeScript type definitions
\`\`\`

### Available Scripts
- \`npm run dev\` - Start development server
- \`npm run build\` - Build for production
- \`npm run preview\` - Preview production build
EOF
}

# Create the backend README
create_backend_readme() {
    local project_name="$1"
    local backend_dir="${project_name}-backend"
    
    echo "Creating backend README..."
    
    cat > "${backend_dir}/README.md" << EOF
# ${project_name^} Backend

## Tech Stack
- Java 17
- Spring Boot
- Spring Data JPA
- Spring Security
- Maven

## Getting Started

### Prerequisites
- Java 17 or higher
- Maven

### Development
1. Run the application
   \`\`\`bash
   ./mvnw spring-boot:run
   \`\`\`
   The server will start at http://localhost:8080

### Building for Production
1. Create a production build
   \`\`\`bash
   ./mvnw clean package
   \`\`\`
   The build output will be in the \`target\` directory

### Project Structure
\`\`\`
src/
├── main/
│   ├── java/
│   │   └── com/example/${backend_dir}/
│   │       ├── config/      # Configuration classes
│   │       ├── controller/  # REST controllers
│   │       ├── model/       # Entity classes
│   │       ├── repository/  # Data repositories
│   │       └── service/     # Business logic
│   └── resources/
│       └── application.properties  # Application configuration
├── test/                          # Test files
└── pom.xml                        # Maven configuration
\`\`\`

### Available Commands
- \`./mvnw spring-boot:run\` - Run the application
- \`./mvnw test\` - Run tests
- \`./mvnw clean package\` - Create production build
- \`./mvnw clean install\` - Install dependencies
EOF
}

# Setup frontend project using Vite + React + Typescript + Tailwind
setup_frontend_project() {
    local project_name="$1"
    local frontend_dir="${project_name}-frontend"

    echo "Setting up frontend project with Vite + React + Typescript + Tailwind..."

    # Check if npm is installed
    if ! command -v npm &> /dev/null; then
        echo "Error: npm is not installed. Please install Node.js and npm first."
        exit 1
    fi

    # Create React + Typescript project using Vite
    echo "Creating Vite project..."
    npm create vite@latest "$frontend_dir" -- --template react-ts

    # Navigate to frontend directory
    cd "$frontend_dir"

    # Install dependencies
    echo "Installing dependencies..."
    npm install

    # Add Tailwind CSS and its dependencies
    echo "Adding Tailwind CSS..."
    npm install -D tailwindcss postcss autoprefixer

    # Initialise Tailwind CSS
    echo "Initialising Tailwind CSS.."
    npx tailwindcss init -p

    # Update tailwind.config.js
    cat > "tailwind.config.js" << EOF
/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {},
  },
  plugins: [],
}
EOF

    # Update index.css to include Tailwind directives, and global styles
    cat > "src/index.css" << EOF
@tailwind base;
@tailwind components;
@tailwind utilities;

/* Add some global styles */
@layer base {
    body {
      @apply bg-gray-50 min-h-screen;
    }
}
EOF

    # Update TypeScript configurations
    echo "Updating TypeScript configurations..."
    
    # Update tsconfig.node.json
    cat > "tsconfig.node.json" << EOF
{
  "compilerOptions": {
    "composite": true,
    "tsBuildInfoFile": "./node_modules/.tmp/tsconfig.node.tsbuildinfo",
    "target": "ES2022",
    "lib": ["ES2023"],
    "module": "ESNext",
    "skipLibCheck": true,

    /* Bundler mode */
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "isolatedModules": true,
    "moduleDetection": "force",
    "noEmit": true,

    /* Linting */
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noFallthroughCasesInSwitch": true
  },
  "include": ["vite.config.ts"]
}
EOF

    # Update tsconfig.app.json
    cat > "tsconfig.app.json" << EOF
{
  "compilerOptions": {
    "composite": true,
    "tsBuildInfoFile": "./node_modules/.tmp/tsconfig.app.tsbuildinfo",
    "target": "ES2020",
    "useDefineForClassFields": true,
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "skipLibCheck": true,

    /* Bundler mode */
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "isolatedModules": true,
    "moduleDetection": "force",
    "noEmit": true,
    "jsx": "react-jsx",

    /* Linting */
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noFallthroughCasesInSwitch": true
  },
  "include": ["src"]
}
EOF

    # Update vite.config.ts with proxy configuration
    cat > "vite.config.ts" << EOF
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vite.dev/config/
export default defineConfig({
  plugins: [react()],
  build: {
    outDir: 'dist'
  },
  server: {
    proxy: {
      '/api': {
        target: 'http://localhost:8080',
        changeOrigin: true,
        secure: false,
      },
    },
  },
});
EOF

    # Update frontend README
    update_frontend_readme "$project_name"

    # Navigate back to parent directory
    cd ..

    echo "Frontend project setup completed successfully!"
}

# Setup backend project using Spring Boot
setup_backend_project() {
    local project_name="$1"
    local backend_dir="${project_name}-backend"

    echo "Setting up backend project with Spring Boot..."

    # Check if curl is installed
    if ! command -v curl &> /dev/null; then
        echo "Error: curl is not installed. Please install curl first."
        exit 1
    fi

    # Spring Boot project variables
    local boot_version="3.4.0" # Changed to 3.4.0
    local java-version="21" # Changed to 21
    local group_id="com.example"
    local artifact_id="$backend_dir"
    local deps="web,data-jpa,security,validation,lombok,devtools"

    # Create temp directory for zip file
    local temp_dir=$(mktemp -d)
    local zip_file="$temp_dir/spring-boot-project.zip"

    # Download the Spring Boot project from Spring Initializr
    echo "Downloading Spring Boot project template..."
    curl -L "https://start.spring.io/starter.zip?\
type=maven-project&\
language=java&\
bootVersion=${boot_version}&\
baseDir=${artifact_id}&\
groupId=${group_id}&\
artifactId=${artifact_id}&\
name=${artifact_id}&\
description=Demo+project+for+Spring+Boot&\
packageName=${group_id}.${artifact_id}&\
packaging=jar&\
javaVersion=${java_version}&\
dependencies=${deps}" -o "$zip_file"

    # Unzip the project
    echo "Extracting project files..."
    unzip -q "$zip_file" -d .

    # Cleanup
    rm -rf "$temp_dir"

    # Create backend README
    create_backend_readme "$project_name"

    echo "Backend project setup completed successfully!"
}


# Setup fullstack project
setup_fullstack_project() {
    local project_name="$1"

    echo "Setting up fullstack project..."

    # Setup backend project first
    setup_backend_project "$project_name"

    # Setup frontend project
    setup_frontend_project "$project_name"

    echo "Fullstack project setup completed successfully!"
}

# Select and setup project based on template
setup_project_template() {
    local project_type="$1"
    local project_name="$2"
    local template="${3:-}" # Optional template parameter -> what is this?

    case "$project_type" in
        "frontend")
            setup_frontend_project "$project_name"
            ;;
        "backend")
            setup_backend_project "$project_name"
            ;;
        "fullstack")
            setup_fullstack_project "$project_name"
            ;;
        *)
            echo "Error: Unknown project type $project_type"
            return 1
            ;;
    esac
}
