# File: visualization_dashboard.R
# Visualization and Monitoring Dashboard for inrep Package

#' Create Real-time Monitoring Dashboard
#'
#' Creates a real-time monitoring dashboard for inrep simulations.
#'
#' @param simulator User simulator object
#' @param update_interval Update interval in seconds
#' @return Dashboard object
#' @export
create_monitoring_dashboard <- function(simulator, update_interval = 5) {
  dashboard <- list(
    simulator = simulator,
    update_interval = update_interval,
    start_time = Sys.time(),
    metrics_history = list(),
    is_running = FALSE
  )
  
  class(dashboard) <- "inrep_monitoring_dashboard"
  return(dashboard)
}

#' Start Real-time Monitoring
#'
#' Starts real-time monitoring of simulation progress.
#'
#' @param dashboard Monitoring dashboard
#' @param duration Monitoring duration in seconds
#' @return Updated dashboard
#' @export
start_real_time_monitoring <- function(dashboard, duration = 300) {
  dashboard$is_running <- TRUE
  dashboard$monitoring_duration <- duration
  
  cat("=== STARTING REAL-TIME MONITORING ===\n")
  cat("Monitoring duration:", duration, "seconds\n")
  cat("Update interval:", dashboard$update_interval, "seconds\n\n")
  
  # Start monitoring loop
  end_time <- Sys.time() + duration
  
  while (Sys.time() < end_time && dashboard$is_running) {
    # Capture current metrics
    metrics <- capture_current_metrics(dashboard$simulator)
    dashboard$metrics_history[[length(dashboard$metrics_history) + 1]] <- metrics
    
    # Print current status
    print_current_status(metrics)
    
    # Wait for next update
    Sys.sleep(dashboard$update_interval)
  }
  
  dashboard$is_running <- FALSE
  cat("\n=== MONITORING COMPLETED ===\n")
  
  return(dashboard)
}

#' Capture Current Metrics
#'
#' Captures current simulation metrics.
#'
#' @param simulator User simulator object
#' @return Current metrics
#' @noRd
capture_current_metrics <- function(simulator) {
  users <- simulator$users
  n_users <- length(users)
  
  # Calculate current statistics
  completed_users <- sum(sapply(users, function(u) u$completed %||% FALSE))
  active_users <- sum(sapply(users, function(u) {
    !is.null(u$session_start) && is.null(u$session_end)
  }))
  
  # Calculate average progress
  avg_progress <- if (n_users > 0) {
    mean(sapply(users, function(u) {
      if (is.null(u$responses)) 0 else length(u$responses)
    }), na.rm = TRUE)
  } else 0
  
  # Calculate response rate
  total_responses <- sum(sapply(users, function(u) {
    if (is.null(u$responses)) 0 else length(u$responses)
  }), na.rm = TRUE)
  
  # Calculate average response time
  avg_response_time <- if (total_responses > 0) {
    all_response_times <- unlist(sapply(users, function(u) {
      if (is.null(u$response_times)) numeric(0) else unlist(u$response_times)
    }))
    mean(all_response_times, na.rm = TRUE)
  } else 0
  
  return(list(
    timestamp = Sys.time(),
    n_users = n_users,
    completed_users = completed_users,
    active_users = active_users,
    avg_progress = avg_progress,
    total_responses = total_responses,
    avg_response_time = avg_response_time,
    completion_rate = if (n_users > 0) completed_users / n_users else 0
  ))
}

#' Print Current Status
#'
#' Prints current simulation status.
#'
#' @param metrics Current metrics
#' @export
print_current_status <- function(metrics) {
  cat(sprintf("[%s] Users: %d | Completed: %d (%.1f%%) | Active: %d | Avg Progress: %.1f | Responses: %d\n",
             format(metrics$timestamp, "%H:%M:%S"),
             metrics$n_users,
             metrics$completed_users,
             metrics$completion_rate * 100,
             metrics$active_users,
             metrics$avg_progress,
             metrics$total_responses))
}

#' Create Performance Visualization
#'
#' Creates performance visualizations for simulation results.
#'
#' @param simulator User simulator object
#' @param output_dir Output directory for plots
#' @return Visualization results
#' @export
create_performance_visualizations <- function(simulator, output_dir = "./simulation_plots") {
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
  }
  
  # Load required packages
  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    warning("ggplot2 package not available for visualizations")
    return(NULL)
  }
  
  # Analyze results
  analysis <- analyze_simulation_results(simulator)
  user_data <- analysis$user_data
  
  # Create plots
  plots <- list()
  
  # 1. Completion Rate by Profile
  if (requireNamespace("ggplot2", quietly = TRUE)) {
    completion_plot <- ggplot2::ggplot(user_data, ggplot2::aes(x = profile_type, y = completion_rate)) +
      ggplot2::geom_bar(stat = "identity", fill = "steelblue") +
      ggplot2::labs(title = "Completion Rate by User Profile",
                   x = "User Profile", y = "Completion Rate") +
      ggplot2::theme_minimal() +
      ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 45, hjust = 1))
    
    plots$completion_rate <- completion_plot
    ggplot2::ggsave(file.path(output_dir, "completion_rate_by_profile.png"), 
                   completion_plot, width = 10, height = 6, dpi = 300)
  }
  
  # 2. Ability Estimation Accuracy
  if (requireNamespace("ggplot2", quietly = TRUE)) {
    accuracy_plot <- ggplot2::ggplot(user_data, ggplot2::aes(x = true_ability, y = final_ability)) +
      ggplot2::geom_point(alpha = 0.6, color = "steelblue") +
      ggplot2::geom_abline(intercept = 0, slope = 1, color = "red", linetype = "dashed") +
      ggplot2::labs(title = "Ability Estimation Accuracy",
                   x = "True Ability", y = "Estimated Ability") +
      ggplot2::theme_minimal()
    
    plots$ability_accuracy <- accuracy_plot
    ggplot2::ggsave(file.path(output_dir, "ability_estimation_accuracy.png"), 
                   accuracy_plot, width = 10, height = 6, dpi = 300)
  }
  
  # 3. Response Time Distribution
  if (requireNamespace("ggplot2", quietly = TRUE)) {
    # Extract response times
    response_times <- unlist(sapply(simulator$users, function(u) {
      if (is.null(u$response_times)) numeric(0) else unlist(u$response_times)
    }))
    
    if (length(response_times) > 0) {
      response_time_data <- data.frame(response_time = response_times)
      
      response_time_plot <- ggplot2::ggplot(response_time_data, ggplot2::aes(x = response_time)) +
        ggplot2::geom_histogram(bins = 30, fill = "steelblue", alpha = 0.7) +
        ggplot2::labs(title = "Response Time Distribution",
                     x = "Response Time (seconds)", y = "Frequency") +
        ggplot2::theme_minimal()
      
      plots$response_times <- response_time_plot
      ggplot2::ggsave(file.path(output_dir, "response_time_distribution.png"), 
                     response_time_plot, width = 10, height = 6, dpi = 300)
    }
  }
  
  # 4. Items per User
  if (requireNamespace("ggplot2", quietly = TRUE)) {
    items_plot <- ggplot2::ggplot(user_data, ggplot2::aes(x = n_items)) +
      ggplot2::geom_histogram(bins = 20, fill = "steelblue", alpha = 0.7) +
      ggplot2::labs(title = "Items Administered per User",
                   x = "Number of Items", y = "Frequency") +
      ggplot2::theme_minimal()
    
    plots$items_per_user <- items_plot
    ggplot2::ggsave(file.path(output_dir, "items_per_user.png"), 
                   items_plot, width = 10, height = 6, dpi = 300)
  }
  
  # 5. Session Duration
  if (requireNamespace("ggplot2", quietly = TRUE)) {
    duration_plot <- ggplot2::ggplot(user_data, ggplot2::aes(x = total_time)) +
      ggplot2::geom_histogram(bins = 20, fill = "steelblue", alpha = 0.7) +
      ggplot2::labs(title = "Session Duration Distribution",
                   x = "Session Duration (minutes)", y = "Frequency") +
      ggplot2::theme_minimal()
    
    plots$session_duration <- duration_plot
    ggplot2::ggsave(file.path(output_dir, "session_duration.png"), 
                   duration_plot, width = 10, height = 6, dpi = 300)
  }
  
  cat("Visualizations created in:", output_dir, "\n")
  return(plots)
}

#' Create Performance Metrics Dashboard
#'
#' Creates a comprehensive performance metrics dashboard.
#'
#' @param simulator User simulator object
#' @param output_file Output file path
#' @return Dashboard data
#' @export
create_performance_dashboard <- function(simulator, output_file = NULL) {
  # Analyze results
  analysis <- analyze_simulation_results(simulator)
  
  # Create dashboard data
  dashboard_data <- list(
    timestamp = Sys.time(),
    simulation_config = list(
      n_users = length(simulator$users),
      config_name = simulator$config$name,
      model = simulator$config$model,
      parallel_computation = simulator$config$parallel_computation
    ),
    performance_metrics = simulator$performance_metrics,
    analysis = analysis,
    user_summary = create_user_summary(simulator),
    profile_analysis = analysis$profile_analysis,
    overall_analysis = analysis$overall_analysis
  )
  
  # Create HTML dashboard if requested
  if (!is.null(output_file)) {
    create_html_dashboard(dashboard_data, output_file)
  }
  
  return(dashboard_data)
}

#' Create User Summary
#'
#' Creates a summary of user characteristics.
#'
#' @param simulator User simulator object
#' @return User summary
#' @noRd
create_user_summary <- function(simulator) {
  users <- simulator$users
  
  # Demographics summary
  demographics <- list(
    age = sapply(users, function(u) u$demographics$Age %||% NA),
    gender = sapply(users, function(u) u$demographics$Gender %||% "Unknown"),
    education = sapply(users, function(u) u$demographics$Education %||% "Unknown")
  )
  
  # Profile distribution
  profile_distribution <- table(sapply(users, function(u) u$profile_type))
  
  # Response patterns
  response_patterns <- list(
    avg_response_time = mean(sapply(users, function(u) {
      if (is.null(u$response_times)) NA else mean(unlist(u$response_times), na.rm = TRUE)
    }), na.rm = TRUE),
    avg_items = mean(sapply(users, function(u) length(u$responses %||% 0)), na.rm = TRUE),
    completion_rate = mean(sapply(users, function(u) u$completed %||% FALSE), na.rm = TRUE)
  )
  
  return(list(
    demographics = demographics,
    profile_distribution = profile_distribution,
    response_patterns = response_patterns
  ))
}

#' Create HTML Dashboard
#'
#' Creates an HTML dashboard for viewing results.
#'
#' @param dashboard_data Dashboard data
#' @param output_file Output file path
#' @noRd
create_html_dashboard <- function(dashboard_data, output_file) {
  html_content <- paste0(
    "<!DOCTYPE html>
    <html>
    <head>
        <title>inrep Simulation Dashboard</title>
        <style>
            body { font-family: Arial, sans-serif; margin: 20px; }
            .header { background-color: #f0f0f0; padding: 20px; border-radius: 5px; }
            .metric { display: inline-block; margin: 10px; padding: 10px; background-color: #e8f4f8; border-radius: 5px; }
            .section { margin: 20px 0; }
            table { border-collapse: collapse; width: 100%; }
            th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
            th { background-color: #f2f2f2; }
        </style>
    </head>
    <body>
        <div class='header'>
            <h1>inrep Simulation Dashboard</h1>
            <p>Generated at: ", format(dashboard_data$timestamp), "</p>
        </div>
        
        <div class='section'>
            <h2>Simulation Overview</h2>
            <div class='metric'>
                <strong>Users:</strong> ", dashboard_data$simulation_config$n_users, "
            </div>
            <div class='metric'>
                <strong>Model:</strong> ", dashboard_data$simulation_config$model, "
            </div>
            <div class='metric'>
                <strong>Parallel:</strong> ", dashboard_data$simulation_config$parallel_computation, "
            </div>
        </div>
        
        <div class='section'>
            <h2>Performance Metrics</h2>
            <div class='metric'>
                <strong>Completion Rate:</strong> ", round(dashboard_data$overall_analysis$completion_rate * 100, 1), "%
            </div>
            <div class='metric'>
                <strong>Average Items:</strong> ", round(dashboard_data$overall_analysis$avg_items, 1), "
            </div>
            <div class='metric'>
                <strong>Average Time:</strong> ", round(dashboard_data$overall_analysis$avg_time, 1), " min
            </div>
            <div class='metric'>
                <strong>Ability Bias:</strong> ", round(dashboard_data$overall_analysis$avg_ability_bias, 3), "
            </div>
        </div>
        
        <div class='section'>
            <h2>Profile Analysis</h2>
            <table>
                <tr><th>Profile</th><th>Users</th><th>Completion Rate</th><th>Avg Items</th><th>Avg Time</th></tr>"
  )
  
  # Add profile analysis rows
  for (profile_name in names(dashboard_data$profile_analysis)) {
    profile <- dashboard_data$profile_analysis[[profile_name]]
    html_content <- paste0(html_content, "
        <tr>
            <td>", profile_name, "</td>
            <td>", profile$n_users, "</td>
            <td>", round(profile$completion_rate * 100, 1), "%</td>
            <td>", round(profile$avg_items, 1), "</td>
            <td>", round(profile$avg_time, 1), " min</td>
        </tr>")
  }
  
  html_content <- paste0(html_content, "
            </table>
        </div>
        
        <div class='section'>
            <h2>User Demographics</h2>
            <p><strong>Age Range:</strong> ", min(dashboard_data$user_summary$demographics$age, na.rm = TRUE), " - ", max(dashboard_data$user_summary$demographics$age, na.rm = TRUE), "</p>
            <p><strong>Gender Distribution:</strong> ", paste(names(table(dashboard_data$user_summary$demographics$gender)), ":", table(dashboard_data$user_summary$demographics$gender), collapse = ", "), "</p>
            <p><strong>Education Distribution:</strong> ", paste(names(table(dashboard_data$user_summary$demographics$education)), ":", table(dashboard_data$user_summary$demographics$education), collapse = ", "), "</p>
        </div>
        
        <div class='section'>
            <h2>Response Patterns</h2>
            <div class='metric'>
                <strong>Avg Response Time:</strong> ", round(dashboard_data$user_summary$response_patterns$avg_response_time, 2), " sec
            </div>
            <div class='metric'>
                <strong>Avg Items per User:</strong> ", round(dashboard_data$user_summary$response_patterns$avg_items, 1), "
            </div>
        </div>
    </body>
    </html>"
  )
  
  writeLines(html_content, output_file)
  cat("HTML dashboard created:", output_file, "\n")
}

#' Run Interactive Simulation
#'
#' Runs an interactive simulation with real-time monitoring.
#'
#' @param config Study configuration
#' @param item_bank Item bank data frame
#' @param n_users Number of users to simulate
#' @param monitoring_duration Monitoring duration in seconds
#' @return Simulation results
#' @export
run_interactive_simulation <- function(config, item_bank, n_users = 50, monitoring_duration = 300) {
  cat("=== INTERACTIVE SIMULATION ===\n")
  cat("Starting interactive simulation with", n_users, "users\n")
  cat("Monitoring duration:", monitoring_duration, "seconds\n\n")
  
  # Create simulator
  simulator <- create_user_simulator(config, item_bank, n_users)
  simulator <- generate_simulated_users(simulator)
  
  # Create monitoring dashboard
  dashboard <- create_monitoring_dashboard(simulator, update_interval = 5)
  
  # Start monitoring in background
  cat("Starting real-time monitoring...\n")
  dashboard <- start_real_time_monitoring(dashboard, monitoring_duration)
  
  # Run simulation
  cat("Running parallel simulation...\n")
  simulator <- run_parallel_simulation(simulator, parallel = TRUE)
  
  # Create visualizations
  cat("Creating visualizations...\n")
  plots <- create_performance_visualizations(simulator, "./interactive_simulation_plots")
  
  # Create dashboard
  dashboard_data <- create_performance_dashboard(simulator, "./interactive_simulation_dashboard.html")
  
  # Print final summary
  print_simulation_summary(simulator)
  
  return(list(
    simulator = simulator,
    dashboard = dashboard,
    plots = plots,
    dashboard_data = dashboard_data
  ))
}