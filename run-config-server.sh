#!/bin/bash

# Source environment variables from docker_dev/.env
ENV_FILE="$(dirname "$0")/docker_dev/configserver.env"

if [ -f "$ENV_FILE" ]; then
    echo "Loading environment variables from $ENV_FILE"
    
    # Read the .env file and export variables (ignoring comments and empty lines)
    while IFS= read -r line || [ -n "$line" ]; do
        # Skip comments and empty lines
        [[ $line =~ ^#.*$ || -z $line ]] && continue
        
        # Extract variable and value
        var_name=$(echo "$line" | cut -d= -f1)
        var_value=$(echo "$line" | cut -d= -f2-)
        
        # Export the variable
        export "$var_name"="$var_value"
    done < "$ENV_FILE"
else
    echo "Error: Environment file $ENV_FILE not found."
    echo "Please create a .env file in the docker_dev folder with the required environment variables."
    exit 1
fi

# Display the environment configuration
echo "Starting Config Server with the following configuration:"
echo "----------------------------------------------------"
echo "Profile: $CONFIG_SERVICE_ACTIVE_PROFILE"
echo "Git URI: $GIT_URI"
echo "Git Branch: $GIT_BRANCH"
echo "Server Port: $SERVER_PORT"
echo "----------------------------------------------------"

# Trap EXIT signal to display a goodbye message
trap 'echo "Thank you for your hard work. See you next time 🥳"' EXIT

# Navigate to the config server directory
cd "$(dirname "$0")/configserver"

# Check for dry-run flag
if [[ "$*" == *--dry-run* ]]; then
    echo "Dry run complete. Would have started the config server with the above configuration."
    exit 0
fi

# Check if mvnw exists and is executable
if [ -f "./mvnw" ] && [ -x "./mvnw" ]; then
    ./mvnw spring-boot:run
else
    echo "Maven wrapper (mvnw) not found or not executable"
    echo "Attempting to run with Maven directly..."
    mvn spring-boot:run
fi
