# inrep Package Simulation and Testing Framework

## Overview

The inrep package now includes a comprehensive simulation and testing framework that allows researchers to validate study designs, test performance under various load conditions, and optimize parallel processing settings before deploying real studies.

## Features

### 1. User Behavior Simulation
- **Realistic User Profiles**: Multiple user types (fast accurate, slow careful, average, quick less accurate, struggling)
- **Response Patterns**: Realistic response times and accuracy based on user profiles
- **Navigation Behavior**: Simulates user interactions, pauses, reviews, and skips
- **Demographics**: Realistic demographic distributions

### 2. Parallel Processing Testing
- **Performance Comparison**: Sequential vs parallel processing benchmarks
- **Scalability Testing**: Tests performance with different numbers of users and items
- **Resource Monitoring**: Memory usage and CPU utilization tracking
- **Optimization**: Automatic configuration optimization based on system resources

### 3. Load Testing
- **Multiple Load Levels**: Light, medium, heavy, and extreme load tests
- **Realistic User Arrivals**: Poisson process simulation of user arrival patterns
- **Performance Metrics**: Throughput, completion rates, and response times
- **Scalability Analysis**: Identifies performance bottlenecks and limits

### 4. Real-time Monitoring
- **Live Dashboard**: Real-time monitoring of simulation progress
- **Performance Metrics**: Live updates of key performance indicators
- **Visualization**: Charts and graphs for performance analysis
- **Alert System**: Notifications for performance issues

### 5. Comprehensive Reporting
- **Performance Reports**: Detailed analysis of simulation results
- **Visualization**: Charts, graphs, and interactive dashboards
- **Export Options**: Multiple formats (CSV, JSON, RDS, HTML)
- **Recommendations**: Optimization suggestions based on results

## Quick Start

### Basic Simulation

```r
library(inrep)

# Create configuration
config <- create_study_config(
  name = "My Simulation Study",
  model = "2PL",
  parallel_computation = TRUE,
  cache_enabled = TRUE
)

# Create item bank
item_bank <- data.frame(
  Question = paste("Item", 1:50),
  a = runif(50, 0.5, 2.0),
  b = runif(50, -2, 2),
  # ... other columns
)

# Create and run simulator
simulator <- create_user_simulator(config, item_bank, n_users = 100)
simulator <- generate_simulated_users(simulator)
simulator <- run_parallel_simulation(simulator, parallel = TRUE)

# Analyze results
analysis <- analyze_simulation_results(simulator)
print_simulation_summary(simulator)
```

### Load Testing

```r
# Run load test suite
load_results <- run_load_test_suite(
  test_types = c("light", "medium", "heavy"),
  output_dir = "./load_test_results"
)

# Print summary
print_load_test_suite_summary(load_results$summary)
```

### Interactive Simulation

```r
# Run interactive simulation with real-time monitoring
interactive_results <- run_interactive_simulation(
  config = config,
  item_bank = item_bank,
  n_users = 100,
  monitoring_duration = 300  # 5 minutes
)
```

## File Structure

```
inst/simulation/
├── simulate_users.R          # User behavior simulation
├── test_simulation.R         # Comprehensive testing framework
├── load_testing.R           # Load testing and scalability
├── visualization_dashboard.R # Monitoring and visualization
├── run_simulation_tests.R   # Main test runner
└── README.md               # This file
```

## User Profiles

The simulation framework includes five realistic user profiles:

### 1. Fast Accurate Responders (25%)
- Quick response times (15±5 seconds)
- High accuracy (80% bias)
- Linear navigation style
- Low skip probability (5%)

### 2. Slow Careful Responders (20%)
- Slow response times (45±15 seconds)
- Very high accuracy (90% bias)
- Thorough navigation with reviews
- Very low skip probability (1%)

### 3. Average Users (35%)
- Moderate response times (30±10 seconds)
- Average accuracy (70% bias)
- Mixed navigation style
- Moderate skip probability (8%)

### 4. Quick Less Accurate Responders (15%)
- Fast response times (20±8 seconds)
- Lower accuracy (60% bias)
- Rushed navigation style
- Higher skip probability (12%)

### 5. Struggling Users (5%)
- Very slow response times (60±20 seconds)
- Low accuracy (40% bias)
- Confused navigation with many reviews
- High skip probability (15%)

## Performance Metrics

The framework tracks comprehensive performance metrics:

### Simulation Metrics
- **Completion Rate**: Percentage of users who complete the assessment
- **Average Items**: Mean number of items administered per user
- **Session Duration**: Average time spent per user
- **Response Times**: Distribution of response times across users
- **Navigation Events**: Pauses, reviews, skips, and other interactions

### Parallel Processing Metrics
- **Speedup**: Performance improvement over sequential processing
- **Efficiency**: Speedup divided by number of workers
- **Throughput**: Users processed per second
- **Resource Usage**: Memory and CPU utilization

### Load Testing Metrics
- **Peak Throughput**: Maximum users per second under load
- **Response Time Distribution**: How response times change under load
- **Error Rates**: Frequency of errors under different load conditions
- **Scalability Limits**: Maximum sustainable load

## Configuration Options

### Study Configuration
```r
config <- create_study_config(
  # Basic settings
  name = "Study Name",
  model = "2PL",  # or "1PL", "3PL", "GRM"
  estimation_method = "TAM",
  
  # Parallel processing
  parallel_computation = TRUE,
  parallel_workers = 4,
  parallel_batch_size = 50,
  parallel_optimization = TRUE,
  
  # Performance
  cache_enabled = TRUE,
  max_session_duration = 60,
  
  # Study parameters
  min_items = 5,
  max_items = 25,
  min_SEM = 0.3
)
```

### Load Test Configuration
```r
load_config <- create_load_test_config("heavy")
# Options: "light", "medium", "heavy", "extreme"

# Custom load test
load_config <- list(
  name = "Custom Load Test",
  n_users = 200,
  n_items = 100,
  parallel_workers = 8,
  test_duration = 600,
  user_arrival_rate = 5.0
)
```

## Visualization and Reporting

### Performance Plots
- Completion rate by user profile
- Ability estimation accuracy scatter plots
- Response time distributions
- Items administered per user
- Session duration distributions

### Interactive Dashboard
- Real-time monitoring during simulation
- Live performance metrics
- User progress tracking
- System resource monitoring

### Export Options
- **CSV**: Tabular data for analysis
- **JSON**: Structured data for web applications
- **RDS**: R objects for further processing
- **HTML**: Interactive dashboards
- **PDF**: Reports for documentation

## Best Practices

### 1. Study Design Validation
- Use simulation to test study parameters before deployment
- Validate item banks with realistic user behavior
- Test different user profiles and demographics

### 2. Performance Optimization
- Run load tests to identify bottlenecks
- Optimize parallel processing settings
- Monitor resource usage during large simulations

### 3. Quality Assurance
- Compare simulation results with real data when available
- Validate user behavior models against actual usage
- Test edge cases and error conditions

### 4. Scalability Planning
- Use load testing to plan infrastructure needs
- Test performance under expected peak loads
- Plan for growth and increased usage

## Troubleshooting

### Common Issues

1. **Memory Errors**
   - Reduce batch size or number of users
   - Enable garbage collection
   - Monitor memory usage

2. **Slow Performance**
   - Enable parallel processing
   - Increase number of workers
   - Enable caching

3. **Simulation Errors**
   - Check item bank format
   - Validate configuration parameters
   - Review error logs

### Debug Mode

```r
# Enable verbose logging
options(inrep.verbose = TRUE)

# Monitor performance
monitor <- create_performance_monitor(config)
# ... run simulation ...
print_performance_summary(monitor)
```

## Examples

See the following example files:
- `inst/examples/simulation_demo.R` - Comprehensive demonstration
- `inst/examples/parallel_processing_example.R` - Parallel processing example
- `inst/simulation/run_simulation_tests.R` - Test runner script

## Conclusion

The simulation and testing framework provides researchers with powerful tools to validate study designs, optimize performance, and ensure reliable operation under various conditions. By simulating realistic user behavior and testing under load, researchers can confidently deploy studies knowing they will perform well in production.

For more information, see the package documentation and help files.