#!/bin/zsh
# Build all services and deploy with Docker Compose
# Usage: ./build-and-deploy.sh [dev|prod]

ENVIRONMENT=${1:-dev}

# Build JARs for each service
./configserver/mvnw -f ./configserver/pom.xml clean package -DskipTests
if [[ $? -ne 0 ]]; then
  echo "\033[0;31mERROR: Failed to build configserver. Aborting.\033[0m"
  exit 1
fi

./account/mvnw -f ./account/pom.xml clean package -DskipTests
if [[ $? -ne 0 ]]; then
  echo "\033[0;31mERROR: Failed to build account service. Aborting.\033[0m"
  exit 1
fi

if [[ "$ENVIRONMENT" == "prod" ]]; then
  cd docker_prod
  docker compose -f docker-compose.prod.yml up --build -d
  if [[ $? -ne 0 ]]; then
    echo "\033[0;31mERROR: Docker Compose failed for PROD environment.\033[0m"
    exit 1
  fi
  echo "All services are built and running in PROD environment. Use 'docker compose -f docker-compose.prod.yml ps' to check status."
else
  cd docker_dev
  
  # Check if .env file exists
  if [[ ! -f account.env || ! -f configserver.env ]]; then
    echo "\033[0;33mWARNING: No .env file found in docker_dev directory.\033[0m"
    echo "\033[0;33mPlease make sure to create a .env file with GIT_USERNAME and GIT_PASSWORD for private repo access.\033[0m"
    echo "Continuing with deployment..."
  fi
  
  docker compose -f docker-compose.dev.yml up --build -d
  if [[ $? -ne 0 ]]; then
    echo "\033[0;31mERROR: Docker Compose failed for DEV environment.\033[0m"
    exit 1
  fi
  
  # Wait for services to be healthy
  echo "Waiting for services to become healthy..."
  sleep 10
  
  # Check if services are running correctly
  if ! docker ps | grep -q "configserver-dev" || ! docker ps | grep -q "account-dev"; then
    echo "\033[0;31mERROR: Some services failed to start. Check logs with 'docker compose -f docker-compose.dev.yml logs'.\033[0m"
    exit 1
  fi
  
  echo "All services are built and running in DEV environment."
  echo "Use 'docker compose -f docker-compose.dev.yml ps' to check status."
  echo "Use 'docker compose -f docker-compose.dev.yml logs' to view logs."
fi
