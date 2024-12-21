#!/bin/bash

# Set strict error handling
set -euo pipefail

# Setup frontend project using Vite + React + Typescript + Tailwind
setup_frontend_project() {
    local project_name="$1"

    echo "Setting up frontend project with Vite + React + Typescript + Tailwind..."

    # Check if npm is installed
    if ! command -v npm &> /dev/null; then
        echo "Error: npm is not installed. Please install Node.js and npm first."
        exit 1
    fi

    # Create React + Typescript project using Vite
    echo "Creating Vite project..."
    npm create vite@laest . -- --template react-ts # To compare with the commands we normally use

    # To continue adding here

}

# Setup backend project using Spring Boot
setup_backend_project() {
    local project_name="$1"

    echo "Setting up backend project with Spring Boot..."

    # Check if curl is installed
    if ! command -v curl &> /dev/null; then
        echo "Error: curl is not installed. Please install curl first."
        exit 1
    fi

    # Spring Boot project variables
    local boot_version="3.2.0"
    local java-version="17" # might want to change this
    local group_id="com.example"
    local artifact_id="$project_name"
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

    echo "Backend project setup completed successfully!"
}

# Setup fullstack project
setup_fullstack_project() {
    
}

# Select and setup project based on template
setup_project_template() {

}
