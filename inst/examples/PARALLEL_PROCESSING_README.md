# Parallel Processing in inrep Package

## Overview

The inrep package now includes comprehensive parallel processing capabilities that significantly improve performance for large-scale studies. This document describes the parallel processing features and how to use them effectively.

## Key Features

### 1. Parallel Item Selection
- **Parallel Information Computation**: Computes Fisher information for multiple items simultaneously
- **Future Package Integration**: Uses `future` and `future.apply` for modern parallel processing
- **Fallback Support**: Falls back to base `parallel` package if `future` is not available
- **Intelligent Worker Management**: Automatically determines optimal number of workers

### 2. Parallel Ability Estimation
- **TAM Integration**: Enhanced TAM model fitting with parallel processing
- **Multiple Estimation Methods**: Supports parallel processing for TAM, EAP, WLE, and MIRT methods
- **Resource Optimization**: Adjusts computational parameters based on parallel processing availability

### 3. Batch Processing
- **Multiple Participants**: Process multiple participants simultaneously
- **Parallel Item Selection**: Select items for multiple participants in parallel
- **Parallel Data Export**: Export data in multiple formats simultaneously

### 4. Performance Monitoring
- **Real-time Metrics**: Track performance during operations
- **Memory Usage**: Monitor memory consumption and optimization
- **Cache Statistics**: Track cache hit rates and efficiency
- **Optimization Suggestions**: Get recommendations for improving performance

## Configuration

### Basic Parallel Processing Setup

```r
# Enable parallel processing
config <- create_study_config(
  name = "My Study",
  model = "2PL",
  parallel_computation = TRUE,        # Enable parallel processing
  parallel_workers = NULL,           # Auto-detect optimal workers
  parallel_batch_size = 50,          # Batch size for operations
  parallel_optimization = TRUE,      # Auto-optimize settings
  cache_enabled = TRUE               # Enable caching for better performance
)
```

### Advanced Configuration

```r
# Advanced parallel processing configuration
config <- create_study_config(
  name = "Advanced Study",
  model = "GRM",
  estimation_method = "TAM",
  
  # Parallel processing settings
  parallel_computation = TRUE,
  parallel_workers = 4,              # Specify number of workers
  parallel_batch_size = 100,         # Larger batches for better efficiency
  parallel_optimization = TRUE,
  
  # Performance settings
  cache_enabled = TRUE,
  max_session_duration = 60,
  
  # Study-specific settings
  min_items = 15,
  max_items = 30,
  min_SEM = 0.25
)
```

## Usage Examples

### 1. Basic Parallel Processing

```r
library(inrep)

# Create configuration with parallel processing
config <- create_study_config(
  name = "Parallel Demo",
  parallel_computation = TRUE,
  cache_enabled = TRUE
)

# Process participants in parallel
results <- process_participants_batch(participants, item_bank, config, parallel = TRUE)
```

### 2. Performance Monitoring

```r
# Create performance monitor
monitor <- create_performance_monitor(config)

# Start timing an operation
monitor <- start_operation_timing(monitor, "my_operation", "item_selection")

# Perform operation
# ... your code here ...

# End timing and record metrics
monitor <- end_operation_timing(monitor, "my_operation", list(n_items = 100))

# Get performance summary
summary <- get_performance_summary(monitor)
print_performance_summary(monitor)
```

### 3. Batch Processing

```r
# Process multiple participants
results <- process_participants_batch(participants, item_bank, config, parallel = TRUE)

# Select items for multiple participants
selected_items <- batch_item_selection(participant_states, item_bank, config, parallel = TRUE)

# Export data in parallel
exported_files <- batch_data_export(results, config, 
                                   formats = c("csv", "json", "rds"),
                                   output_dir = "./output",
                                   parallel = TRUE)
```

### 4. Configuration Optimization

```r
# Get optimization suggestions
suggestions <- optimize_configuration(monitor, item_bank_size = 200, expected_participants = 100)

# Benchmark different configurations
test_configs <- list(
  "sequential" = modifyList(config, list(parallel_computation = FALSE)),
  "parallel_2" = modifyList(config, list(parallel_workers = 2)),
  "parallel_4" = modifyList(config, list(parallel_workers = 4))
)

benchmark_results <- benchmark_configurations(participants, item_bank, config, test_configs)
```

## Performance Benefits

### Speed Improvements
- **Item Selection**: 2-4x faster for large item banks (>100 items)
- **Ability Estimation**: 1.5-3x faster for complex models
- **Batch Processing**: 3-8x faster for multiple participants
- **Data Export**: 2-5x faster for multiple formats

### Memory Efficiency
- **Intelligent Caching**: Reduces redundant computations
- **Memory Monitoring**: Tracks and optimizes memory usage
- **Garbage Collection**: Automatic cleanup of unused objects

### Scalability
- **Auto-scaling**: Automatically adjusts to system resources
- **Load Balancing**: Distributes work evenly across workers
- **Resource Management**: Prevents system overload

## System Requirements

### Required Packages
- `parallel` (base R)
- `TAM` (for psychometric computations)

### Optional Packages (for enhanced performance)
- `future` and `future.apply` (recommended)
- `pryr` (for memory monitoring)
- `jsonlite` (for JSON export)
- `openxlsx` (for Excel export)

### System Recommendations
- **CPU**: Multi-core processor (4+ cores recommended)
- **Memory**: 8GB+ RAM for large studies
- **Storage**: SSD recommended for better I/O performance

## Best Practices

### 1. Configuration
- Enable `parallel_optimization = TRUE` for automatic tuning
- Use `cache_enabled = TRUE` for better performance
- Set appropriate `parallel_batch_size` based on available memory

### 2. Resource Management
- Monitor memory usage with `monitor_memory_usage()`
- Use performance monitoring to identify bottlenecks
- Adjust worker count based on system resources

### 3. Error Handling
- Always use `tryCatch()` for parallel operations
- Implement fallback to sequential processing
- Monitor for convergence issues in TAM estimation

### 4. Testing
- Benchmark different configurations
- Test with realistic data sizes
- Validate results against sequential processing

## Troubleshooting

### Common Issues

1. **Memory Errors**
   - Reduce `parallel_batch_size`
   - Enable garbage collection
   - Monitor memory usage

2. **Slow Performance**
   - Check if parallel processing is actually enabled
   - Verify worker count is appropriate
   - Enable caching

3. **Convergence Issues**
   - Check TAM model parameters
   - Verify item bank quality
   - Consider different estimation methods

### Debug Mode

```r
# Enable verbose logging
options(inrep.verbose = TRUE)

# Monitor performance
monitor <- create_performance_monitor(config)
# ... perform operations ...
print_performance_summary(monitor)
```

## Future Enhancements

The parallel processing system is designed to be extensible. Future enhancements may include:

- **GPU Acceleration**: Support for GPU-based computations
- **Distributed Processing**: Support for cluster computing
- **Real-time Optimization**: Dynamic adjustment of parallel settings
- **Advanced Caching**: More sophisticated caching strategies

## Conclusion

The parallel processing capabilities in the inrep package provide significant performance improvements for large-scale studies while maintaining the same ease of use. By following the best practices outlined in this document, users can achieve optimal performance for their specific use cases.

For more examples and detailed documentation, see the package vignettes and help files.