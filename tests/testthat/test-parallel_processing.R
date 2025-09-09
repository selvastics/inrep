# Test suite for parallel processing functions
# Tests parallel computation, batch processing, and performance monitoring

context("parallel_processing")

test_that("initialize_parallel_env sets up parallel environment correctly", {
  # Test with 2 workers
  result <- initialize_parallel_env(workers = 2)
  
  expect_is(result, "list")
  expect_true("workers" %in% names(result))
  expect_true("plan" %in% names(result))
  expect_equal(result$workers, 2)
})

test_that("initialize_parallel_env handles invalid worker count", {
  # Test with 0 workers (should default to 1)
  result <- initialize_parallel_env(workers = 0)
  expect_true(result$workers >= 1)
  
  # Test with negative workers (should default to 1)
  result <- initialize_parallel_env(workers = -1)
  expect_true(result$workers >= 1)
})

test_that("parallel_item_info processes items in parallel", {
  # Create test item bank
  item_bank <- data.frame(
    item_id = 1:5,
    a = c(1.2, 0.8, 1.5, 1.0, 1.3),
    b = c(0.0, -0.5, 0.3, -0.2, 0.1),
    stringsAsFactors = FALSE
  )
  
  config <- create_study_config(
    name = "Parallel Test",
    model = "2PL",
    parallel_computation = TRUE,
    parallel_workers = 2
  )
  
  result <- parallel_item_info(
    item_bank = item_bank,
    config = config,
    current_ability = 0.0
  )
  
  expect_is(result, "data.frame")
  expect_equal(nrow(result), 5)
  expect_true("item_id" %in% names(result))
  expect_true("information" %in% names(result))
})

test_that("parallel_batch_process handles batch processing", {
  # Create test data
  participants <- 1:10
  config <- create_study_config(
    name = "Batch Test",
    model = "2PL",
    parallel_computation = TRUE,
    parallel_workers = 2,
    parallel_batch_size = 5
  )
  
  # Mock processing function
  process_func <- function(participant_id) {
    return(list(
      participant_id = participant_id,
      result = paste("Processed", participant_id)
    ))
  }
  
  result <- parallel_batch_process(
    participants = participants,
    process_func = process_func,
    config = config
  )
  
  expect_is(result, "list")
  expect_equal(length(result), 10)
  expect_true(all(sapply(result, function(x) "participant_id" %in% names(x))))
})

test_that("parallel_data_export exports data in parallel", {
  # Create test data
  data_list <- list(
    participant1 = data.frame(response = 1, item = 1),
    participant2 = data.frame(response = 0, item = 1),
    participant3 = data.frame(response = 1, item = 2)
  )
  
  config <- create_study_config(
    name = "Export Test",
    model = "2PL",
    parallel_computation = TRUE,
    parallel_workers = 2
  )
  
  # Test CSV export
  result <- parallel_data_export(
    data_list = data_list,
    format = "csv",
    config = config
  )
  
  expect_is(result, "character")
  expect_true(length(result) > 0)
})

test_that("create_performance_monitor creates monitoring system", {
  monitor <- create_performance_monitor()
  
  expect_is(monitor, "list")
  expect_true("start_time" %in% names(monitor))
  expect_true("operations" %in% names(monitor))
  expect_true("memory_usage" %in% names(monitor))
})

test_that("start_operation_timing records operation start", {
  monitor <- create_performance_monitor()
  
  result <- start_operation_timing(monitor, "test_operation")
  
  expect_is(result, "list")
  expect_true("test_operation" %in% names(result$operations))
})

test_that("end_operation_timing records operation end", {
  monitor <- create_performance_monitor()
  monitor <- start_operation_timing(monitor, "test_operation")
  
  # Simulate some processing time
  Sys.sleep(0.01)
  
  result <- end_operation_timing(monitor, "test_operation")
  
  expect_is(result, "list")
  expect_true("test_operation" %in% names(result$operations))
  expect_true("duration" %in% names(result$operations$test_operation))
})

test_that("record_parallel_stats records parallel processing statistics", {
  monitor <- create_performance_monitor()
  
  result <- record_parallel_stats(
    monitor = monitor,
    workers = 4,
    items_processed = 100,
    processing_time = 2.5
  )
  
  expect_is(result, "list")
  expect_true("parallel_stats" %in% names(result))
  expect_equal(result$parallel_stats$workers, 4)
  expect_equal(result$parallel_stats$items_processed, 100)
})

test_that("record_cache_stats records caching statistics", {
  monitor <- create_performance_monitor()
  
  result <- record_cache_stats(
    monitor = monitor,
    cache_hits = 50,
    cache_misses = 10,
    cache_size = 1024
  )
  
  expect_is(result, "list")
  expect_true("cache_stats" %in% names(result))
  expect_equal(result$cache_stats$hits, 50)
  expect_equal(result$cache_stats$misses, 10)
})

test_that("monitor_memory_usage tracks memory consumption", {
  result <- monitor_memory_usage()
  
  expect_is(result, "numeric")
  expect_true(result > 0)
})

test_that("get_performance_summary provides performance overview", {
  monitor <- create_performance_monitor()
  monitor <- start_operation_timing(monitor, "test_operation")
  Sys.sleep(0.01)
  monitor <- end_operation_timing(monitor, "test_operation")
  
  summary <- get_performance_summary(monitor)
  
  expect_is(summary, "list")
  expect_true("total_operations" %in% names(summary))
  expect_true("total_time" %in% names(summary))
  expect_true("memory_usage" %in% names(summary))
})

test_that("print_performance_summary displays performance information", {
  monitor <- create_performance_monitor()
  monitor <- start_operation_timing(monitor, "test_operation")
  Sys.sleep(0.01)
  monitor <- end_operation_timing(monitor, "test_operation")
  
  # This should not throw an error
  expect_output(print_performance_summary(monitor), "Performance Summary")
})

test_that("optimize_configuration optimizes parallel settings", {
  config <- create_study_config(
    name = "Optimization Test",
    model = "2PL",
    parallel_computation = TRUE
  )
  
  # Mock performance data
  performance_data <- data.frame(
    workers = c(1, 2, 4, 8),
    processing_time = c(10, 6, 4, 5),
    memory_usage = c(100, 120, 140, 160)
  )
  
  result <- optimize_configuration(config, performance_data)
  
  expect_is(result, "list")
  expect_true("optimized_workers" %in% names(result))
  expect_true("optimized_batch_size" %in% names(result))
})

test_that("benchmark_configurations compares different configurations", {
  configs <- list(
    config1 = create_study_config(name = "Config1", model = "2PL", parallel_workers = 1),
    config2 = create_study_config(name = "Config2", model = "2PL", parallel_workers = 2),
    config3 = create_study_config(name = "Config3", model = "2PL", parallel_workers = 4)
  )
  
  # Mock benchmark function
  benchmark_func <- function(config) {
    return(list(
      processing_time = runif(1, 1, 10),
      memory_usage = runif(1, 100, 500)
    ))
  }
  
  result <- benchmark_configurations(configs, benchmark_func)
  
  expect_is(result, "data.frame")
  expect_true("config_name" %in% names(result))
  expect_true("processing_time" %in% names(result))
  expect_true("memory_usage" %in% names(result))
})

test_that("generate_performance_report creates comprehensive report", {
  monitor <- create_performance_monitor()
  monitor <- start_operation_timing(monitor, "test_operation")
  Sys.sleep(0.01)
  monitor <- end_operation_timing(monitor, "test_operation")
  
  report <- generate_performance_report(monitor)
  
  expect_is(report, "list")
  expect_true("summary" %in% names(report))
  expect_true("operations" %in% names(report))
  expect_true("recommendations" %in% names(report))
})