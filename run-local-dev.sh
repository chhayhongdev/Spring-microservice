#!/bin/zsh
# Script to run services locally with local development properties

# Define colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "${YELLOW}Starting Local Development Environment${NC}"

# Check if services are running in Docker and warn user
if docker ps | grep -q "account-dev\|configserver-dev"; then
  echo "${YELLOW}Warning: Some services are already running in Docker.${NC}"
  echo "This might cause port conflicts. Consider stopping Docker services first:"
  echo "cd docker_dev && docker compose -f docker-compose.dev.yml down"
  read -p "Continue anyway? (y/n) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Exiting..."
    exit 1
  fi
fi

# By default, start both services, but allow for individual service selection
SERVICE=${1:-all}

# Start Config Server if requested
if [[ "$SERVICE" == "config" || "$SERVICE" == "all" ]]; then
  echo "${GREEN}Starting Config Server with local profile...${NC}"
  cd configserver
  # Start Config Server detached
  ./mvnw spring-boot:run -Dspring-boot.run.profiles=local -Dspring-boot.run.arguments="--spring.config.location=classpath:/application.properties,classpath:/application-local.properties" &
  CONFIG_PID=$!
  cd ..
  
  # Wait for Config Server to start
  echo "Waiting for Config Server to start..."
  sleep 10
fi

# Start Account Service if requested
if [[ "$SERVICE" == "account" || "$SERVICE" == "all" ]]; then
  echo "${GREEN}Starting Account Service with local profile...${NC}"
  cd account
  ./mvnw spring-boot:run -Dspring-boot.run.profiles=local -Dspring-boot.run.arguments="--spring.config.location=classpath:/application.properties,classpath:/application-local.properties"
  cd ..
fi

# If we're running all services, keep this script alive so we can kill both processes
if [[ "$SERVICE" == "all" ]]; then
  trap "kill $CONFIG_PID 2>/dev/null" EXIT
  wait $CONFIG_PID
fi
