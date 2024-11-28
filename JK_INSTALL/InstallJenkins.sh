#!/bin/bash

# Function to handle errors
error_exit() {
    echo "$1" 1>&2
    exit 1
}

# Input validation
if [ -z "$1" ]; then
    error_exit "Error: Please provide the Jenkins version as an argument (e.g., 2.361.1)."
fi

if [ -z "$2" ]; then
    error_exit "Error: Please provide the OS type (e.g., ubuntu, centos, macos)."
fi

JENKINS_VERSION=$1
OS_TYPE=$2
JENKINS_INSTALL_DIR="/usr/local/bin"
JENKINS_WAR_FILE="jenkins.war"

# Check if Java is installed
check_java() {
    if ! command -v java &>/dev/null; then
        echo "Java not found. Installing Java..."
        install_java
    else
        echo "Java is already installed."
    fi
}

# Function to install Java (OpenJDK 11)
install_java() {
    if [ "$OS_TYPE" == "ubuntu" ] || [ "$OS_TYPE" == "debian" ]; then
        sudo apt update && sudo apt install -y openjdk-11-jdk || error_exit "Error: Failed to install Java on Ubuntu/Debian."
    elif [ "$OS_TYPE" == "centos" ] || [ "$OS_TYPE" == "rhel" ]; then
        sudo yum install -y java-11-openjdk-devel || error_exit "Error: Failed to install Java on CentOS/RHEL."
    elif [ "$OS_TYPE" == "macos" ]; then
        brew install openjdk@11 || error_exit "Error: Failed to install Java on macOS. Please ensure Homebrew is installed."
        # Link OpenJDK to the default java path
        sudo ln -sfn /usr/local/opt/openjdk@11/bin/java /usr/local/bin/java
    else
        error_exit "Error: Unsupported OS type. Please provide either 'ubuntu', 'centos', or 'macos'."
    fi
}

# Download Jenkins WAR file
download_jenkins() {
    echo "Downloading Jenkins version $JENKINS_VERSION..."
    wget https://get.jenkins.io/war-stable/$JENKINS_VERSION/jenkins.war -O $JENKINS_INSTALL_DIR/$JENKINS_WAR_FILE || error_exit "Error: Failed to download Jenkins WAR file."
}

# Start Jenkins using the downloaded WAR file
start_jenkins() {
    echo "Starting Jenkins..."
    java -jar $JENKINS_INSTALL_DIR/$JENKINS_WAR_FILE --httpPort=8080 || error_exit "Error: Failed to start Jenkins."
}

# Main script execution
echo "Starting Jenkins installation process..."

# Step 1: Check and Install Java if necessary
check_java

# Step 2: Download Jenkins WAR file
download_jenkins

# Step 3: Start Jenkins
start_jenkins

echo "Jenkins installation completed successfully."
echo "Jenkins is running at http://localhost:8080"
