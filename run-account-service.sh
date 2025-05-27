#!/bin/bash

# Source environment variables from docker_dev/account.env
ENV_FILE="$(dirname "$0")/docker_dev/account.env"

if [ -f "$ENV_FILE" ]; then
    echo "Loading environment variables from $ENV_FILE"
    
    # Read the .env file and export variables (ignoring comments and empty lines)
    while IFS= read -r line || [ -n "$line" ]; do
        # Skip comments and empty lines
        [[ $line =~ ^#.*$ || -z $line ]] && continue
        
        # Extract variable and value
        var_name=$(echo "$line" | cut -d= -f1)
        var_value=$(echo "$line" | cut -d= -f2-)
        
        # Check if it's an ACCOUNT_ prefixed variable and remove the prefix
        if [[ $var_name == ACCOUNT_* ]]; then
            # Remove ACCOUNT_ prefix and create a new variable
            new_var_name=${var_name#ACCOUNT_}
            echo "Loading variable: $new_var_name (from $var_name)"
            export "$new_var_name"="$var_value"
        fi
        
        # Handle special case for Eureka URL
        if [[ $var_name == "EUREKA_SERVER_URL" ]]; then
            # Replace shell parameter expansion with actual value, defaulting to localhost
            var_value="http://localhost:8761/eureka/"
            echo "Setting $var_name to $var_value for local development"
        fi
        
        # Also export the original variable
        export "$var_name"="$var_value"
    done < "$ENV_FILE"
else
    echo "Error: Environment file $ENV_FILE not found."
    echo "Please create an account.env file in the docker_dev folder with the required environment variables."
    exit 1
fi

# Display the environment configuration
echo "Starting Account Service with the following configuration:"
echo "----------------------------------------------------"
echo "Application Name: $APP_NAME (from $ACCOUNT_APP_NAME)"
echo "Profile: $PROFILE (from $ACCOUNT_PROFILE)"
echo "Server Port: $SERVER_PORT (from $ACCOUNT_SERVER_PORT)"
echo "Config Server: $SPRING_CONFIG_IMPORT"
echo "Eureka Server: $EUREKA_SERVER_URL"
echo "----------------------------------------------------"

# Force setting EUREKA_SERVER_URL directly
export EUREKA_SERVER_URL="http://localhost:8761/eureka/"

# Trap EXIT signal to display a goodbye message
trap 'echo "Thank you for your hard work. See you next time 🥳"' EXIT

# Navigate to the account directory
cd "$(dirname "$0")/account"

# Check for dry-run flag
if [[ "$*" == *--dry-run* ]]; then
    echo "Dry run complete. Would have started the account service with the above configuration."
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
