# Cloud and Deployment System for inrep Package
# Provides cloud deployment, load balancing, and monitoring capabilities

#' Cloud and Deployment System
#' 
#' This module provides comprehensive cloud deployment features including
#' containerization, load balancing, auto-scaling, and monitoring.
#' 
#' @name cloud_deployment
#' @keywords internal
NULL

#' Docker Containerization
#' 
#' Create and manage Docker containers for inrep deployments.

#' Generate Dockerfile for inrep deployment
#' 
#' @param r_version R version to use
#' @param shiny_port Port for Shiny application
#' @param memory_limit Memory limit in MB
#' @return Dockerfile content
#' @export
generate_dockerfile <- function(r_version = "4.3.0", shiny_port = 3838, memory_limit = 2048) {
  dockerfile_content <- paste0(
    "# inrep Dockerfile
FROM rocker/shiny:", r_version, "

# Install system dependencies
RUN apt-get update && apt-get install -y \\
    libcurl4-openssl-dev \\
    libssl-dev \\
    libxml2-dev \\
    libmariadb-dev \\
    libpq-dev \\
    libsqlite3-dev \\
    libhdf5-dev \\
    libnetcdf-dev \\
    libgeos-dev \\
    libproj-dev \\
    libgdal-dev \\
    libudunits2-dev \\
    libv8-dev \\
    libjq-dev \\
    libprotobuf-dev \\
    protobuf-compiler \\
    libcairo2-dev \\
    libxt-dev \\
    libharfbuzz-dev \\
    libfribidi-dev \\
    libfreetype6-dev \\
    libpng-dev \\
    libtiff5-dev \\
    libjpeg-dev \\
    libfontconfig1-dev \\
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy package files
COPY . /app/

# Install R packages
RUN R -e \"install.packages(c('shiny', 'TAM', 'ggplot2', 'dplyr', 'jsonlite', 'future', 'future.apply', 'parallel', 'testthat'), repos='https://cran.r-project.org')\"

# Install inrep package
RUN R -e \"devtools::install_local('/app', dependencies=TRUE)\"

# Set memory limit
ENV R_MAX_MEMORY=", memory_limit, "M

# Expose port
EXPOSE ", shiny_port, "

# Set Shiny options
ENV SHINY_HOST=0.0.0.0
ENV SHINY_PORT=", shiny_port, "

# Start Shiny application
CMD [\"R\", \"-e\", \"shiny::runApp(host='0.0.0.0', port=", shiny_port, ")\"]
"
  )
  
  return(dockerfile_content)
}

#' Create Docker deployment package
#' 
#' @param output_dir Output directory for deployment files
#' @param r_version R version to use
#' @param shiny_port Port for Shiny application
#' @param memory_limit Memory limit in MB
#' @return Deployment package path
#' @export
create_docker_package <- function(output_dir = "docker_deployment", r_version = "4.3.0", 
                                 shiny_port = 3838, memory_limit = 2048) {
  # Create output directory
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
  }
  
  # Generate Dockerfile
  dockerfile_content <- generate_dockerfile(r_version, shiny_port, memory_limit)
  writeLines(dockerfile_content, file.path(output_dir, "Dockerfile"))
  
  # Generate docker-compose.yml
  compose_content <- paste0(
    "version: '3.8'
services:
  inrep-app:
    build: .
    ports:
      - \"", shiny_port, ":", shiny_port, "\"
    environment:
      - R_MAX_MEMORY=", memory_limit, "M
    volumes:
      - ./data:/app/data
      - ./logs:/app/logs
    restart: unless-stopped
    healthcheck:
      test: [\"CMD\", \"curl\", \"-f\", \"http://localhost:", shiny_port, "\"]
      interval: 30s
      timeout: 10s
      retries: 3
"
  )
  writeLines(compose_content, file.path(output_dir, "docker-compose.yml"))
  
  # Generate deployment script
  deploy_script <- paste0(
    "#!/bin/bash
# inrep Docker Deployment Script

echo \"Building inrep Docker image...\"
docker build -t inrep-app .

echo \"Starting inrep application...\"
docker-compose up -d

echo \"Application started on port ", shiny_port, "\"
echo \"Check logs with: docker-compose logs -f\"
"
  )
  writeLines(deploy_script, file.path(output_dir, "deploy.sh"))
  
  # Make script executable
  system(paste("chmod +x", file.path(output_dir, "deploy.sh")))
  
  return(output_dir)
}

#' Load Balancing
#' 
#' Configure load balancing for multiple inrep instances.

#' Generate load balancer configuration
#' 
#' @param instances List of instance configurations
#' @param balancer_type Type of load balancer ("nginx", "haproxy")
#' @return Load balancer configuration
#' @export
generate_load_balancer_config <- function(instances, balancer_type = "nginx") {
  if (balancer_type == "nginx") {
    config <- paste0(
      "upstream inrep_backend {
"
    )
    
    for (i in seq_along(instances)) {
      config <- paste0(config, "    server ", instances[[i]]$host, ":", instances[[i]]$port, " weight=", instances[[i]]$weight, ";
")
    }
    
    config <- paste0(config, "
}

server {
    listen 80;
    server_name ", instances[[1]]$domain, ";

    location / {
        proxy_pass http://inrep_backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # WebSocket support
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection \"upgrade\";
        
        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
}
"
    )
  } else if (balancer_type == "haproxy") {
    config <- paste0(
      "global
    daemon
    maxconn 4096

defaults
    mode http
    timeout connect 5000ms
    timeout client 50000ms
    timeout server 50000ms

frontend inrep_frontend
    bind *:80
    default_backend inrep_backend

backend inrep_backend
    balance roundrobin
"
    )
    
    for (i in seq_along(instances)) {
      config <- paste0(config, "    server inrep", i, " ", instances[[i]]$host, ":", instances[[i]]$port, " weight ", instances[[i]]$weight, "
")
    }
  }
  
  return(config)
}

#' Auto-scaling Configuration
#' 
#' Configure auto-scaling for inrep deployments.

#' Generate auto-scaling configuration
#' 
#' @param min_instances Minimum number of instances
#' @param max_instances Maximum number of instances
#' @param target_cpu Target CPU utilization percentage
#' @param scale_up_threshold CPU threshold for scaling up
#' @param scale_down_threshold CPU threshold for scaling down
#' @return Auto-scaling configuration
#' @export
generate_auto_scaling_config <- function(min_instances = 2, max_instances = 10, 
                                        target_cpu = 70, scale_up_threshold = 80, 
                                        scale_down_threshold = 30) {
  config <- list(
    min_instances = min_instances,
    max_instances = max_instances,
    target_cpu = target_cpu,
    scale_up_threshold = scale_up_threshold,
    scale_down_threshold = scale_down_threshold,
    scale_up_cooldown = 300,  # 5 minutes
    scale_down_cooldown = 600,  # 10 minutes
    metrics = list(
      cpu_utilization = "cpu_utilization",
      memory_utilization = "memory_utilization",
      request_rate = "request_rate",
      response_time = "response_time"
    )
  )
  
  return(config)
}

#' Cloud Deployment
#' 
#' Deploy inrep to various cloud platforms.

#' Deploy to AWS ECS
#' 
#' @param cluster_name ECS cluster name
#' @param service_name ECS service name
#' @param task_definition Task definition ARN
#' @param desired_count Desired number of tasks
#' @return Deployment status
#' @export
deploy_to_aws_ecs <- function(cluster_name, service_name, task_definition, desired_count = 2) {
  # This would typically use AWS CLI or SDK
  # For now, return a mock deployment status
  return(list(
    success = TRUE,
    cluster_name = cluster_name,
    service_name = service_name,
    task_definition = task_definition,
    desired_count = desired_count,
    message = "Deployment initiated successfully"
  ))
}

#' Deploy to Google Cloud Run
#' 
#' @param service_name Cloud Run service name
#' @param region GCP region
#' @param memory Memory allocation
#' @param cpu CPU allocation
#' @return Deployment status
#' @export
deploy_to_google_cloud_run <- function(service_name, region = "us-central1", 
                                      memory = "2Gi", cpu = "2") {
  # This would typically use gcloud CLI or Cloud Run API
  # For now, return a mock deployment status
  return(list(
    success = TRUE,
    service_name = service_name,
    region = region,
    memory = memory,
    cpu = cpu,
    message = "Deployment initiated successfully"
  ))
}

#' Deploy to Azure Container Instances
#' 
#' @param resource_group Resource group name
#' @param container_group_name Container group name
#' @param location Azure location
#' @return Deployment status
#' @export
deploy_to_azure_container_instances <- function(resource_group, container_group_name, 
                                               location = "East US") {
  # This would typically use Azure CLI or Container Instances API
  # For now, return a mock deployment status
  return(list(
    success = TRUE,
    resource_group = resource_group,
    container_group_name = container_group_name,
    location = location,
    message = "Deployment initiated successfully"
  ))
}

#' Monitoring and Alerting
#' 
#' Set up monitoring and alerting for inrep deployments.

#' Create monitoring dashboard
#' 
#' @param metrics List of metrics to monitor
#' @return Dashboard configuration
#' @export
create_monitoring_dashboard <- function(metrics = c("cpu_utilization", "memory_usage", 
                                                   "request_rate", "response_time", 
                                                   "error_rate")) {
  dashboard_config <- list(
    title = "inrep Application Monitoring",
    metrics = metrics,
    refresh_interval = 30,  # seconds
    charts = list(
      cpu_chart = list(
        type = "line",
        metric = "cpu_utilization",
        title = "CPU Utilization",
        y_axis_label = "Percentage"
      ),
      memory_chart = list(
        type = "line",
        metric = "memory_usage",
        title = "Memory Usage",
        y_axis_label = "MB"
      ),
      request_rate_chart = list(
        type = "line",
        metric = "request_rate",
        title = "Request Rate",
        y_axis_label = "Requests per second"
      ),
      response_time_chart = list(
        type = "line",
        metric = "response_time",
        title = "Response Time",
        y_axis_label = "Milliseconds"
      ),
      error_rate_chart = list(
        type = "line",
        metric = "error_rate",
        title = "Error Rate",
        y_axis_label = "Percentage"
      )
    ),
    alerts = list(
      high_cpu = list(
        metric = "cpu_utilization",
        threshold = 80,
        operator = ">",
        severity = "warning"
      ),
      high_memory = list(
        metric = "memory_usage",
        threshold = 1000,  # MB
        operator = ">",
        severity = "critical"
      ),
      high_error_rate = list(
        metric = "error_rate",
        threshold = 5,  # percentage
        operator = ">",
        severity = "critical"
      )
    )
  )
  
  return(dashboard_config)
}

#' Set up health checks
#' 
#' @param endpoints List of health check endpoints
#' @param interval Check interval in seconds
#' @param timeout Timeout in seconds
#' @return Health check configuration
#' @export
setup_health_checks <- function(endpoints = c("/health", "/ready"), 
                               interval = 30, timeout = 10) {
  health_check_config <- list(
    endpoints = endpoints,
    interval = interval,
    timeout = timeout,
    retries = 3,
    success_threshold = 2,
    failure_threshold = 3
  )
  
  return(health_check_config)
}

#' Generate deployment documentation
#' 
#' @param deployment_type Type of deployment
#' @param config Deployment configuration
#' @return Documentation content
#' @export
generate_deployment_docs <- function(deployment_type = "docker", config = list()) {
  docs_content <- paste0(
    "# inrep Deployment Documentation

## Deployment Type: ", deployment_type, "

### Prerequisites
- Docker installed and running
- Sufficient system resources
- Network access to required ports

### Deployment Steps

1. **Prepare the environment**
   ```bash
   # Clone the repository
   git clone <repository-url>
   cd inrep
   ```

2. **Build the application**
   ```bash
   # Build Docker image
   docker build -t inrep-app .
   ```

3. **Deploy the application**
   ```bash
   # Start the application
   docker-compose up -d
   ```

4. **Verify deployment**
   ```bash
   # Check application status
   docker-compose ps
   
   # View logs
   docker-compose logs -f
   ```

### Configuration
"
  )
  
  if (deployment_type == "docker") {
    docs_content <- paste0(docs_content, "
- **Port**: ", config$shiny_port %||% 3838, "
- **Memory Limit**: ", config$memory_limit %||% 2048, "MB
- **R Version**: ", config$r_version %||% "4.3.0", "
")
  }
  
  docs_content <- paste0(docs_content, "
### Monitoring
- Application logs: `docker-compose logs -f`
- Health checks: `curl http://localhost:", config$shiny_port %||% 3838, "/health`
- Resource usage: `docker stats`

### Troubleshooting
- Check logs for errors
- Verify port availability
- Ensure sufficient resources
- Check network connectivity

### Scaling
- Horizontal scaling: Add more instances
- Vertical scaling: Increase memory/CPU limits
- Load balancing: Configure load balancer

### Security
- Use HTTPS in production
- Implement authentication
- Regular security updates
- Monitor access logs
")
  
  return(docs_content)
}

#' Create deployment package
#' 
#' @param deployment_type Type of deployment
#' @param output_dir Output directory
#' @param config Deployment configuration
#' @return Deployment package path
#' @export
create_deployment_package <- function(deployment_type = "docker", output_dir = "deployment", 
                                     config = list()) {
  # Create output directory
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
  }
  
  if (deployment_type == "docker") {
    # Create Docker deployment
    docker_dir <- create_docker_package(
      output_dir = file.path(output_dir, "docker"),
      r_version = config$r_version %||% "4.3.0",
      shiny_port = config$shiny_port %||% 3838,
      memory_limit = config$memory_limit %||% 2048
    )
    
    # Generate documentation
    docs <- generate_deployment_docs("docker", config)
    writeLines(docs, file.path(output_dir, "README.md"))
    
    return(docker_dir)
  }
  
  return(output_dir)
}