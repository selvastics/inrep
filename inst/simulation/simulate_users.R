# File: simulate_users.R
# User Behavior Simulation Framework for inrep Package

#' Simulate Realistic User Behavior in inrep Assessments
#'
#' This framework simulates realistic user interactions with inrep assessments,
#' including response patterns, timing, and navigation behavior.

library(inrep)
library(parallel)
library(future)
library(future.apply)

#' User Behavior Simulator Class
#'
#' Creates a user behavior simulator for testing inrep assessments.
#'
#' @param config Study configuration
#' @param item_bank Item bank data frame
#' @param n_users Number of users to simulate
#' @param user_profiles List of user profile types
#' @return User simulator object
#' @export
create_user_simulator <- function(config, item_bank, n_users = 100, user_profiles = NULL) {
  if (is.null(user_profiles)) {
    user_profiles <- create_default_user_profiles()
  }
  
  simulator <- list(
    config = config,
    item_bank = item_bank,
    n_users = n_users,
    user_profiles = user_profiles,
    users = list(),
    session_data = list(),
    performance_metrics = list(),
    start_time = Sys.time()
  )
  
  class(simulator) <- "inrep_user_simulator"
  return(simulator)
}

#' Create Default User Profiles
#'
#' Creates realistic user profiles for simulation.
#'
#' @return List of user profile configurations
#' @export
create_default_user_profiles <- function() {
  list(
    # Fast, accurate responders
    "fast_accurate" = list(
      name = "Fast Accurate Responders",
      proportion = 0.25,
      response_time_mean = 15,  # seconds per item
      response_time_sd = 5,
      accuracy_bias = 0.8,  # Higher accuracy
      ability_mean = 0.5,
      ability_sd = 0.8,
      navigation_style = "linear",  # Goes through items in order
      skip_probability = 0.05,
      review_probability = 0.1
    ),
    
    # Slow, careful responders
    "slow_careful" = list(
      name = "Slow Careful Responders",
      proportion = 0.20,
      response_time_mean = 45,
      response_time_sd = 15,
      accuracy_bias = 0.9,
      ability_mean = 0.2,
      ability_sd = 0.6,
      navigation_style = "thorough",  # Reviews items
      skip_probability = 0.01,
      review_probability = 0.3
    ),
    
    # Average users
    "average" = list(
      name = "Average Users",
      proportion = 0.35,
      response_time_mean = 30,
      response_time_sd = 10,
      accuracy_bias = 0.7,
      ability_mean = 0.0,
      ability_sd = 1.0,
      navigation_style = "mixed",
      skip_probability = 0.08,
      review_probability = 0.15
    ),
    
    # Quick, less accurate responders
    "quick_less_accurate" = list(
      name = "Quick Less Accurate Responders",
      proportion = 0.15,
      response_time_mean = 20,
      response_time_sd = 8,
      accuracy_bias = 0.6,
      ability_mean = -0.3,
      ability_sd = 1.2,
      navigation_style = "rushed",
      skip_probability = 0.12,
      review_probability = 0.05
    ),
    
    # Struggling users
    "struggling" = list(
      name = "Struggling Users",
      proportion = 0.05,
      response_time_mean = 60,
      response_time_sd = 20,
      accuracy_bias = 0.4,
      ability_mean = -1.0,
      ability_sd = 0.8,
      navigation_style = "confused",
      skip_probability = 0.15,
      review_probability = 0.4
    )
  )
}

#' Generate Simulated Users
#'
#' Generates simulated users based on profiles.
#'
#' @param simulator User simulator object
#' @return Updated simulator with generated users
#' @export
generate_simulated_users <- function(simulator) {
  n_users <- simulator$n_users
  profiles <- simulator$user_profiles
  
  # Calculate number of users per profile
  profile_counts <- sapply(profiles, function(p) round(p$proportion * n_users))
  profile_counts[length(profile_counts)] <- n_users - sum(profile_counts[-length(profile_counts)])
  
  users <- list()
  user_id <- 1
  
  for (profile_name in names(profiles)) {
    profile <- profiles[[profile_name]]
    n_profile_users <- profile_counts[profile_name]
    
    for (i in 1:n_profile_users) {
      user <- create_single_user(user_id, profile, simulator$config)
      users[[user_id]] <- user
      user_id <- user_id + 1
    }
  }
  
  simulator$users <- users
  return(simulator)
}

#' Create Single User
#'
#' Creates a single simulated user based on profile.
#'
#' @param user_id User identifier
#' @param profile User profile configuration
#' @param config Study configuration
#' @return Simulated user object
#' @noRd
create_single_user <- function(user_id, profile, config) {
  # Generate user demographics
  demographics <- list(
    Age = sample(18:65, 1),
    Gender = sample(c("Male", "Female", "Other"), 1, prob = c(0.48, 0.50, 0.02)),
    Education = sample(c("High School", "Bachelor", "Master", "PhD"), 1, 
                      prob = c(0.3, 0.4, 0.25, 0.05))
  )
  
  # Generate true ability
  true_ability <- rnorm(1, profile$ability_mean, profile$ability_sd)
  
  # Generate response time parameters
  response_time_mean <- profile$response_time_mean
  response_time_sd <- profile$response_time_sd
  
  user <- list(
    id = paste0("USER_", sprintf("%04d", user_id)),
    profile_type = profile$name,
    demographics = demographics,
    true_ability = true_ability,
    response_time_mean = response_time_mean,
    response_time_sd = response_time_sd,
    accuracy_bias = profile$accuracy_bias,
    navigation_style = profile$navigation_style,
    skip_probability = profile$skip_probability,
    review_probability = profile$review_probability,
    session_start = NULL,
    session_end = NULL,
    responses = list(),
    response_times = list(),
    navigation_events = list(),
    current_item = 1,
    completed = FALSE,
    errors = list()
  )
  
  return(user)
}

#' Simulate User Session
#'
#' Simulates a complete user session through the assessment.
#'
#' @param simulator User simulator object
#' @param user_id User identifier
#' @param parallel Logical indicating whether to use parallel processing
#' @return Updated simulator with session data
#' @export
simulate_user_session <- function(simulator, user_id, parallel = TRUE) {
  user <- simulator$users[[user_id]]
  if (is.null(user)) {
    stop("User not found: ", user_id)
  }
  
  # Initialize session
  user$session_start <- Sys.time()
  user$current_item <- 1
  user$responses <- list()
  user$response_times <- list()
  user$navigation_events <- list()
  user$completed <- FALSE
  
  # Create reactive values for the user
  rv <- list(
    administered = integer(0),
    responses = list(),
    current_ability = simulator$config$theta_prior[1] %||% 0,
    ability_se = simulator$config$theta_prior[2] %||% 1,
    demographics = user$demographics,
    item_info_cache = list(),
    item_counter = 0,
    session_start = user$session_start
  )
  
  # Simulate assessment progression
  max_items <- simulator$config$max_items %||% nrow(simulator$item_bank)
  min_items <- simulator$config$min_items %||% 5
  
  tryCatch({
    while (user$current_item <= max_items && !user$completed) {
      # Select next item
      if (simulator$config$adaptive) {
        next_item <- select_next_item(rv, simulator$item_bank, simulator$config)
      } else {
        next_item <- user$current_item
      }
      
      if (is.null(next_item)) {
        break
      }
      
      # Simulate item response
      response_data <- simulate_item_response(user, next_item, simulator$item_bank, simulator$config)
      
      # Record response
      rv$administered <- c(rv$administered, next_item)
      rv$responses <- c(rv$responses, response_data$response)
      user$responses[[user$current_item]] <- response_data$response
      user$response_times[[user$current_item]] <- response_data$response_time
      
      # Record navigation event
      user$navigation_events[[user$current_item]] <- list(
        item = next_item,
        response = response_data$response,
        response_time = response_data$response_time,
        timestamp = Sys.time(),
        action = "respond"
      )
      
      # Update ability estimate
      if (simulator$config$adaptive && length(rv$responses) >= 2) {
        ability_result <- estimate_ability(rv, simulator$item_bank, simulator$config)
        rv$current_ability <- ability_result$theta
        rv$ability_se <- ability_result$se
      }
      
      # Check stopping criteria
      if (length(rv$responses) >= min_items) {
        if (rv$ability_se <= simulator$config$min_SEM) {
          user$completed <- TRUE
          break
        }
      }
      
      user$current_item <- user$current_item + 1
      
      # Simulate user behavior (pauses, reviews, etc.)
      simulate_user_behavior(user, response_data)
    }
    
    # Final ability estimation
    if (length(rv$responses) > 0) {
      final_ability <- estimate_ability(rv, simulator$item_bank, simulator$config)
      user$final_ability <- final_ability$theta
      user$final_se <- final_ability$se
      user$final_method <- final_ability$method
    } else {
      user$final_ability <- user$true_ability
      user$final_se <- 1.0
      user$final_method <- "prior"
    }
    
    user$session_end <- Sys.time()
    user$completed <- TRUE
    user$total_time <- as.numeric(difftime(user$session_end, user$session_start, units = "mins"))
    
  }, error = function(e) {
    user$errors <- c(user$errors, list(
      error = e$message,
      timestamp = Sys.time(),
      item = user$current_item
    ))
    user$session_end <- Sys.time()
    user$completed <- FALSE
  })
  
  # Update simulator
  simulator$users[[user_id]] <- user
  simulator$session_data[[user_id]] <- rv
  
  return(simulator)
}

#' Simulate Item Response
#'
#' Simulates a user's response to a specific item.
#'
#' @param user Simulated user object
#' @param item_idx Item index
#' @param item_bank Item bank data frame
#' @param config Study configuration
#' @return Response data
#' @noRd
simulate_item_response <- function(user, item_idx, item_bank, config) {
  # Get item parameters
  item <- item_bank[item_idx, ]
  
  # Calculate response probability based on true ability
  if (config$model == "GRM") {
    # Graded Response Model
    a <- item$a %||% 1.0
    b_cols <- grep("^b[0-9]+$", names(item), value = TRUE)
    if (length(b_cols) > 0) {
      b_thresholds <- as.numeric(item[b_cols])
      n_categories <- length(b_thresholds) + 1
      
      # Calculate category probabilities
      probs <- numeric(n_categories)
      probs[1] <- 1 / (1 + exp(a * (user$true_ability - b_thresholds[1])))
      for (k in 2:(n_categories - 1)) {
        probs[k] <- 1 / (1 + exp(a * (user$true_ability - b_thresholds[k - 1]))) -
          1 / (1 + exp(a * (user$true_ability - b_thresholds[k])))
      }
      probs[n_categories] <- 1 - 1 / (1 + exp(a * (user$true_ability - b_thresholds[n_categories - 1])))
      
      # Add accuracy bias
      probs <- probs * user$accuracy_bias + (1 - user$accuracy_bias) * (1 / n_categories)
      probs <- probs / sum(probs)
      
      response <- sample(1:n_categories, 1, prob = probs)
    } else {
      response <- sample(1:5, 1)  # Default 5-point scale
    }
  } else {
    # Dichotomous models
    a <- item$a %||% 1.0
    b <- item$b %||% 0
    c_param <- if (config$model == "3PL" && "c" %in% names(item)) item$c else 0
    
    p_correct <- c_param + (1 - c_param) / (1 + exp(-a * (user$true_ability - b)))
    
    # Add accuracy bias
    p_correct <- p_correct * user$accuracy_bias + (1 - user$accuracy_bias) * 0.5
    
    response <- rbinom(1, 1, p_correct)
  }
  
  # Simulate response time
  response_time <- max(1, rnorm(1, user$response_time_mean, user$response_time_sd))
  
  return(list(
    response = response,
    response_time = response_time
  ))
}

#' Simulate User Behavior
#'
#' Simulates additional user behavior patterns.
#'
#' @param user Simulated user object
#' @param response_data Response data from current item
#' @return Updated user object
#' @noRd
simulate_user_behavior <- function(user, response_data) {
  # Simulate thinking time based on response time
  thinking_time <- response_data$response_time * runif(1, 0.1, 0.3)
  Sys.sleep(min(thinking_time / 1000, 0.1))  # Cap at 100ms for simulation speed
  
  # Simulate occasional pauses
  if (runif(1) < 0.05) {  # 5% chance of pause
    pause_time <- runif(1, 5, 30)  # 5-30 second pause
    Sys.sleep(min(pause_time / 1000, 0.5))  # Cap at 500ms
    
    user$navigation_events[[length(user$navigation_events) + 1]] <- list(
      action = "pause",
      duration = pause_time,
      timestamp = Sys.time()
    )
  }
  
  # Simulate review behavior
  if (runif(1) < user$review_probability) {
    user$navigation_events[[length(user$navigation_events) + 1]] <- list(
      action = "review",
      timestamp = Sys.time()
    )
  }
  
  # Simulate skip behavior
  if (runif(1) < user$skip_probability) {
    user$navigation_events[[length(user$navigation_events) + 1]] <- list(
      action = "skip",
      timestamp = Sys.time()
    )
  }
}

#' Run Parallel User Simulation
#'
#' Runs simulation for multiple users in parallel.
#'
#' @param simulator User simulator object
#' @param parallel Logical indicating whether to use parallel processing
#' @param n_workers Number of parallel workers
#' @return Updated simulator with all user sessions
#' @export
run_parallel_simulation <- function(simulator, parallel = TRUE, n_workers = NULL) {
  n_users <- length(simulator$users)
  
  if (n_users == 0) {
    warning("No users to simulate")
    return(simulator)
  }
  
  # Set up parallel processing
  if (parallel && isTRUE(simulator$config$parallel_computation)) {
    if (is.null(n_workers)) {
      n_workers <- min(4, parallel::detectCores() - 1)
    }
    
    if (requireNamespace("future", quietly = TRUE)) {
      future::plan(future::multisession, workers = n_workers)
      on.exit(future::plan(future::sequential), add = TRUE)
    }
  }
  
  # Simulate users
  start_time <- Sys.time()
  
  if (parallel && requireNamespace("future.apply", quietly = TRUE)) {
    # Parallel simulation using future.apply
    user_ids <- 1:n_users
    results <- future.apply::future_lapply(user_ids, function(user_id) {
      simulate_user_session(simulator, user_id, parallel = FALSE)
    }, future.seed = TRUE)
    
    # Update simulator with results
    for (i in seq_along(results)) {
      simulator <- results[[i]]
    }
  } else {
    # Sequential simulation
    for (user_id in 1:n_users) {
      simulator <- simulate_user_session(simulator, user_id, parallel = FALSE)
    }
  }
  
  end_time <- Sys.time()
  total_time <- as.numeric(difftime(end_time, start_time, units = "secs"))
  
  # Record performance metrics
  simulator$performance_metrics$simulation_time <- total_time
  simulator$performance_metrics$users_per_second <- n_users / total_time
  simulator$performance_metrics$parallel <- parallel
  simulator$performance_metrics$n_workers <- n_workers %||% 1
  
  return(simulator)
}

#' Analyze Simulation Results
#'
#' Analyzes the results of user simulation.
#'
#' @param simulator User simulator object
#' @return Analysis results
#' @export
analyze_simulation_results <- function(simulator) {
  users <- simulator$users
  n_users <- length(users)
  
  if (n_users == 0) {
    return(list(error = "No users to analyze"))
  }
  
  # Extract user data
  user_data <- data.frame(
    user_id = sapply(users, function(u) u$id),
    profile_type = sapply(users, function(u) u$profile_type),
    true_ability = sapply(users, function(u) u$true_ability),
    final_ability = sapply(users, function(u) u$final_ability %||% NA),
    final_se = sapply(users, function(u) u$final_se %||% NA),
    n_items = sapply(users, function(u) length(u$responses)),
    total_time = sapply(users, function(u) u$total_time %||% NA),
    completed = sapply(users, function(u) u$completed %||% FALSE),
    stringsAsFactors = FALSE
  )
  
  # Calculate accuracy metrics
  user_data$ability_bias <- user_data$final_ability - user_data$true_ability
  user_data$ability_rmse <- sqrt((user_data$final_ability - user_data$true_ability)^2)
  
  # Profile-based analysis
  profile_analysis <- list()
  for (profile in unique(user_data$profile_type)) {
    profile_data <- user_data[user_data$profile_type == profile, ]
    
    profile_analysis[[profile]] <- list(
      n_users = nrow(profile_data),
      avg_ability_bias = mean(profile_data$ability_bias, na.rm = TRUE),
      avg_ability_rmse = mean(profile_data$ability_rmse, na.rm = TRUE),
      avg_items = mean(profile_data$n_items, na.rm = TRUE),
      avg_time = mean(profile_data$total_time, na.rm = TRUE),
      completion_rate = mean(profile_data$completed, na.rm = TRUE)
    )
  }
  
  # Overall analysis
  overall_analysis <- list(
    total_users = n_users,
    completion_rate = mean(user_data$completed, na.rm = TRUE),
    avg_ability_bias = mean(user_data$ability_bias, na.rm = TRUE),
    avg_ability_rmse = mean(user_data$ability_rmse, na.rm = TRUE),
    avg_items = mean(user_data$n_items, na.rm = TRUE),
    avg_time = mean(user_data$total_time, na.rm = TRUE),
    simulation_time = simulator$performance_metrics$simulation_time,
    users_per_second = simulator$performance_metrics$users_per_second
  )
  
  return(list(
    user_data = user_data,
    profile_analysis = profile_analysis,
    overall_analysis = overall_analysis,
    performance_metrics = simulator$performance_metrics
  ))
}

#' Generate Simulation Report
#'
#' Generates a comprehensive report of simulation results.
#'
#' @param simulator User simulator object
#' @param output_file Output file path (optional)
#' @return Simulation report
#' @export
generate_simulation_report <- function(simulator, output_file = NULL) {
  analysis <- analyze_simulation_results(simulator)
  
  # Create report content
  report <- list(
    timestamp = Sys.time(),
    simulation_config = list(
      n_users = simulator$n_users,
      config_name = simulator$config$name,
      model = simulator$config$model,
      parallel_computation = simulator$config$parallel_computation
    ),
    analysis = analysis,
    performance_metrics = simulator$performance_metrics
  )
  
  # Write to file if specified
  if (!is.null(output_file)) {
    if (requireNamespace("jsonlite", quietly = TRUE)) {
      jsonlite::write_json(report, output_file, pretty = TRUE)
    } else {
      saveRDS(report, output_file)
    }
  }
  
  return(report)
}

#' Print Simulation Summary
#'
#' Prints a summary of simulation results.
#'
#' @param simulator User simulator object
#' @export
print_simulation_summary <- function(simulator) {
  analysis <- analyze_simulation_results(simulator)
  
  cat("=== INREP USER SIMULATION SUMMARY ===\n")
  cat(sprintf("Total Users: %d\n", analysis$overall_analysis$total_users))
  cat(sprintf("Completion Rate: %.1f%%\n", analysis$overall_analysis$completion_rate * 100))
  cat(sprintf("Average Items: %.1f\n", analysis$overall_analysis$avg_items))
  cat(sprintf("Average Time: %.1f minutes\n", analysis$overall_analysis$avg_time))
  cat(sprintf("Ability Bias: %.3f\n", analysis$overall_analysis$avg_ability_bias))
  cat(sprintf("Ability RMSE: %.3f\n", analysis$overall_analysis$avg_ability_rmse))
  cat(sprintf("Simulation Time: %.2f seconds\n", analysis$overall_analysis$simulation_time))
  cat(sprintf("Users/Second: %.2f\n", analysis$overall_analysis$users_per_second))
  
  cat("\n=== PROFILE ANALYSIS ===\n")
  for (profile_name in names(analysis$profile_analysis)) {
    profile <- analysis$profile_analysis[[profile_name]]
    cat(sprintf("\n%s:\n", profile_name))
    cat(sprintf("  Users: %d\n", profile$n_users))
    cat(sprintf("  Completion: %.1f%%\n", profile$completion_rate * 100))
    cat(sprintf("  Avg Items: %.1f\n", profile$avg_items))
    cat(sprintf("  Avg Time: %.1f min\n", profile$avg_time))
    cat(sprintf("  Ability Bias: %.3f\n", profile$avg_ability_bias))
    cat(sprintf("  Ability RMSE: %.3f\n", profile$avg_ability_rmse))
  }
}