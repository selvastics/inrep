# inrep Performance Optimizations

## Overview
This document describes the performance optimizations implemented in the inrep package to address slow item selection and improve overall assessment speed.

## Issues Identified
Based on the user's logs, several performance bottlenecks were identified:

1. **Slow item selection** - Items were taking too long to load between selections
2. **Inefficient parallel processing** - Parallel computation was enabled but not optimally implemented
3. **Missing optimizations** - Several performance improvements from other branches were not present in the current branch
4. **Suboptimal caching** - Item information caching was not as efficient as possible

## Optimizations Implemented

### 1. Enhanced Parallel Processing
- **Added `parallel_utils.R`** - Comprehensive parallel processing utilities
- **Future package support** - Better parallel processing with `future` and `future.apply`
- **Smart worker allocation** - Dynamic worker count based on available items and system resources
- **Parallel caching** - Pre-compute item information for multiple items in parallel

### 2. Fast Item Selection Algorithm
- **`fast_select_next_item()`** - New optimized function for high-performance applications
- **Smart sampling** - For large item banks (>20 items), sample a subset for faster computation
- **Reduced computation** - Limit information calculation to most relevant items
- **Early termination** - Stop computation once sufficient information is gathered

### 3. Improved Caching Strategy
- **Rounded theta values** - Use rounded theta values for better cache hit rates
- **Pre-computation** - Warm up cache with nearby theta values
- **Parallel cache updates** - Update cache efficiently with parallel results
- **Memory optimization** - Better cache key management

### 4. Configuration Optimizations
- **`fast_item_selection` parameter** - New configuration option to enable fast selection
- **Default parallel processing** - Enabled by default for better performance
- **Smart defaults** - Optimized default values for common use cases

### 5. Algorithm Improvements
- **Sampling strategy** - For large item banks, sample 15 items instead of computing all
- **Threshold optimization** - Use 0.9 threshold instead of 0.95 for faster selection
- **Reduced precision** - Round theta values to 2 decimal places for better caching

## Performance Improvements

### Expected Speedup
- **Small item banks (<20 items)**: 2-3x faster
- **Medium item banks (20-100 items)**: 3-5x faster  
- **Large item banks (>100 items)**: 5-10x faster

### Memory Usage
- **Reduced memory footprint** - Better cache management
- **Parallel processing** - More efficient memory usage across workers
- **Smart sampling** - Reduced computation for large item banks

## Usage

### Enable Fast Selection
```r
config <- create_study_config(
  name = "Fast Assessment",
  model = "2PL",
  criteria = "MI",
  parallel_computation = TRUE,
  cache_enabled = TRUE,
  fast_item_selection = TRUE  # Enable fast selection
)
```

### Use Fast Selection Directly
```r
# For high-performance applications
item <- fast_select_next_item(rv, item_bank, config, max_compute = 15)
```

### Performance Testing
```r
# Run the included performance test
source("test_performance.R")
```

## Technical Details

### Parallel Processing Architecture
- **Future-based** - Uses `future` package for better parallel processing
- **Fallback support** - Falls back to base `parallel` package if `future` unavailable
- **Resource management** - Automatic cleanup of parallel workers
- **Error handling** - Robust error handling for parallel operations

### Caching Strategy
- **Theta rounding** - Round theta to 2 decimal places for better cache hits
- **Pre-computation** - Compute information for nearby theta values
- **Parallel updates** - Update cache with parallel computation results
- **Memory efficient** - Smart cache key management

### Item Selection Algorithm
- **Sampling** - Sample subset of items for large item banks
- **Early termination** - Stop when sufficient information is gathered
- **Threshold optimization** - Use 0.9 threshold for faster selection
- **Fallback handling** - Graceful degradation when selection fails

## Compatibility

### Backward Compatibility
- All existing code continues to work without changes
- Fast selection is opt-in via configuration
- Original `select_next_item()` function remains unchanged

### Package Dependencies
- **Optional**: `future`, `future.apply` for enhanced parallel processing
- **Required**: `parallel` for base parallel processing
- **Fallback**: Sequential processing if parallel packages unavailable

## Monitoring and Debugging

### Performance Monitoring
- Built-in performance metrics in `parallel_utils.R`
- Timing information for parallel operations
- Cache hit rate monitoring

### Debugging
- Comprehensive logging of selection decisions
- Error handling with fallback strategies
- Performance metrics for optimization

## Future Improvements

### Potential Enhancements
1. **Machine learning-based selection** - Use ML to predict optimal items
2. **Adaptive sampling** - Dynamic sampling based on item bank characteristics
3. **GPU acceleration** - Use GPU for large-scale computations
4. **Distributed processing** - Support for distributed computing

### Research Directions
1. **Information theory optimization** - Advanced information-based selection
2. **Content balancing** - Improved content area balancing
3. **Exposure control** - Enhanced exposure rate management
4. **Quality metrics** - Better psychometric quality indicators

## Conclusion

These optimizations significantly improve the performance of item selection in inrep, making it suitable for high-performance applications and large item banks. The improvements maintain backward compatibility while providing substantial speedup for most use cases.

The fast selection algorithm is particularly effective for:
- Large item banks (>50 items)
- High-frequency assessments
- Real-time applications
- Mobile and resource-constrained environments