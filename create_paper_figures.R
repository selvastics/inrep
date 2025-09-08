#!/usr/bin/env Rscript
# Create figures for the research paper

suppressPackageStartupMessages({
  library(ggplot2)
  library(dplyr)
  library(gridExtra)
})

# Load test results
load_test_results <- data.frame(
  users = c(10, 25, 50, 100, 200),
  seq_time = c(0.01, 0.02, 0.04, 0.08, 0.16),
  par_time = c(0.06, 0.06, 0.08, 0.09, 0.12),
  speedup = c(0.16, 0.31, 0.57, 0.90, 1.39),
  efficiency = c(5.3, 10.3, 19.0, 30.0, 46.3)
)

large_scale_results <- data.frame(
  users = c(100, 250, 500, 1000, 2000, 5000),
  seq_time = c(0.19, 0.28, 0.53, 1.05, 2.00, 5.05),
  par_time = c(0.18, 0.18, 0.29, 0.45, 0.83, 1.74),
  speedup = c(1.02, 1.51, 1.86, 2.31, 2.42, 2.91),
  efficiency = c(34.1, 50.5, 61.9, 77.0, 80.6, 96.8),
  throughput_seq = c(549.3, 907.2, 941.2, 955.7, 997.7, 990.0),
  throughput_par = c(549.3, 1374.2, 1748.3, 2206.3, 2413.3, 2876.3),
  memory_usage = c(0.12, 0.26, 0.51, 1.02, 2.05, 5.11)
)

# Figure 1: Throughput Comparison
throughput_data <- data.frame(
  users = rep(large_scale_results$users, 2),
  throughput = c(large_scale_results$throughput_seq, large_scale_results$throughput_par),
  method = rep(c("Sequential", "Parallel"), each = nrow(large_scale_results))
)

p1 <- ggplot(throughput_data, aes(x = users, y = throughput, color = method)) +
  geom_line(size = 1.2) +
  geom_point(size = 3) +
  scale_x_log10(breaks = c(100, 250, 500, 1000, 2000, 5000)) +
  scale_y_continuous(breaks = seq(0, 3000, 500)) +
  labs(
    title = "Figure 1: Throughput Comparison (Sequential vs. Parallel)",
    x = "Number of Users (log scale)",
    y = "Throughput (users/second)",
    color = "Processing Method"
  ) +
  theme_minimal() +
  theme(
    legend.position = "bottom",
    plot.title = element_text(size = 14, face = "bold"),
    axis.title = element_text(size = 12),
    legend.text = element_text(size = 11)
  ) +
  scale_color_manual(values = c("Sequential" = "#E74C3C", "Parallel" = "#3498DB"))

ggsave("Figure1_Throughput_Comparison.png", p1, width = 10, height = 6, dpi = 300)

# Figure 2: Parallel Efficiency by User Scale
p2 <- ggplot(large_scale_results, aes(x = users, y = efficiency)) +
  geom_line(color = "#27AE60", size = 1.2) +
  geom_point(color = "#27AE60", size = 3) +
  scale_x_log10(breaks = c(100, 250, 500, 1000, 2000, 5000)) +
  scale_y_continuous(limits = c(0, 100), breaks = seq(0, 100, 20)) +
  labs(
    title = "Figure 2: Parallel Efficiency by User Scale",
    x = "Number of Users (log scale)",
    y = "Parallel Efficiency (%)"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 14, face = "bold"),
    axis.title = element_text(size = 12)
  ) +
  geom_hline(yintercept = 80, linetype = "dashed", color = "red", alpha = 0.7) +
  annotate("text", x = 2000, y = 85, label = "80% Efficiency Threshold", 
           color = "red", size = 3.5)

ggsave("Figure2_Parallel_Efficiency.png", p2, width = 10, height = 6, dpi = 300)

# Figure 3: Memory Usage Visualization
p3 <- ggplot(large_scale_results, aes(x = users, y = memory_usage)) +
  geom_line(color = "#8E44AD", size = 1.2) +
  geom_point(color = "#8E44AD", size = 3) +
  scale_x_log10(breaks = c(100, 250, 500, 1000, 2000, 5000)) +
  scale_y_continuous(limits = c(0, 6), breaks = seq(0, 6, 1)) +
  labs(
    title = "Figure 3: Memory Usage Patterns",
    x = "Number of Users (log scale)",
    y = "Memory Usage (MB)"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 14, face = "bold"),
    axis.title = element_text(size = 12)
  ) +
  geom_smooth(method = "lm", se = TRUE, alpha = 0.2, color = "blue") +
  annotate("text", x = 1000, y = 5, 
           label = "Linear scaling: 0.001 MB per user", 
           color = "blue", size = 3.5)

ggsave("Figure3_Memory_Usage.png", p3, width = 10, height = 6, dpi = 300)

# Figure 4: User Ability Distribution
set.seed(123)
abilities <- rnorm(5000, 0, 1)
ability_data <- data.frame(ability = abilities)

p4 <- ggplot(ability_data, aes(x = ability)) +
  geom_histogram(bins = 30, fill = "#F39C12", alpha = 0.7, color = "white") +
  stat_function(fun = dnorm, args = list(mean = 0, sd = 1), 
                color = "red", size = 1.2) +
  labs(
    title = "Figure 4: User Ability Distribution",
    x = "Ability Score",
    y = "Frequency"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 14, face = "bold"),
    axis.title = element_text(size = 12)
  ) +
  annotate("text", x = 2, y = 200, 
           label = "Normal Distribution\n(μ = 0, σ = 1)", 
           color = "red", size = 3.5)

ggsave("Figure4_Ability_Distribution.png", p4, width = 10, height = 6, dpi = 300)

# Figure 5: Performance Scaling Analysis
perf_data <- data.frame(
  users = rep(large_scale_results$users, 2),
  time = c(large_scale_results$seq_time, large_scale_results$par_time),
  method = rep(c("Sequential", "Parallel"), each = nrow(large_scale_results))
)

p5 <- ggplot(perf_data, aes(x = users, y = time, color = method)) +
  geom_line(size = 1.2) +
  geom_point(size = 3) +
  scale_x_log10(breaks = c(100, 250, 500, 1000, 2000, 5000)) +
  scale_y_log10(breaks = c(0.1, 0.2, 0.5, 1, 2, 5)) +
  labs(
    title = "Figure 5: Performance Scaling Analysis",
    x = "Number of Users (log scale)",
    y = "Processing Time (seconds, log scale)",
    color = "Processing Method"
  ) +
  theme_minimal() +
  theme(
    legend.position = "bottom",
    plot.title = element_text(size = 14, face = "bold"),
    axis.title = element_text(size = 12),
    legend.text = element_text(size = 11)
  ) +
  scale_color_manual(values = c("Sequential" = "#E74C3C", "Parallel" = "#3498DB"))

ggsave("Figure5_Performance_Scaling.png", p5, width = 10, height = 6, dpi = 300)

# Figure 6: Speedup Analysis
p6 <- ggplot(large_scale_results, aes(x = users, y = speedup)) +
  geom_line(color = "#E67E22", size = 1.2) +
  geom_point(color = "#E67E22", size = 3) +
  scale_x_log10(breaks = c(100, 250, 500, 1000, 2000, 5000)) +
  scale_y_continuous(limits = c(0, 3), breaks = seq(0, 3, 0.5)) +
  labs(
    title = "Figure 6: Speedup Analysis",
    x = "Number of Users (log scale)",
    y = "Speedup (x)"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 14, face = "bold"),
    axis.title = element_text(size = 12)
  ) +
  geom_hline(yintercept = 1, linetype = "dashed", color = "red", alpha = 0.7) +
  annotate("text", x = 2000, y = 1.2, label = "No Speedup Line", 
           color = "red", size = 3.5) +
  annotate("text", x = 3000, y = 2.5, 
           label = "Maximum Speedup: 2.91x", 
           color = "#E67E22", size = 3.5, fontface = "bold")

ggsave("Figure6_Speedup_Analysis.png", p6, width = 10, height = 6, dpi = 300)

# Create a combined performance comparison figure
combined_data <- data.frame(
  users = large_scale_results$users,
  sequential_time = large_scale_results$seq_time,
  parallel_time = large_scale_results$par_time,
  speedup = large_scale_results$speedup,
  efficiency = large_scale_results$efficiency,
  throughput_seq = large_scale_results$throughput_seq,
  throughput_par = large_scale_results$throughput_par
)

# Before/After comparison
before_after_data <- data.frame(
  users = rep(combined_data$users, 2),
  throughput = c(combined_data$throughput_seq, combined_data$throughput_par),
  method = rep(c("Before (Sequential)", "After (Parallel)"), each = nrow(combined_data))
)

p_combined <- ggplot(before_after_data, aes(x = users, y = throughput, color = method)) +
  geom_line(size = 1.5) +
  geom_point(size = 4) +
  scale_x_log10(breaks = c(100, 250, 500, 1000, 2000, 5000)) +
  scale_y_continuous(limits = c(0, 3000), breaks = seq(0, 3000, 500)) +
  labs(
    title = "Performance Improvement: Before vs. After Parallel Processing Implementation",
    subtitle = "Throughput Comparison Across User Scales",
    x = "Number of Users (log scale)",
    y = "Throughput (users/second)",
    color = "Implementation"
  ) +
  theme_minimal() +
  theme(
    legend.position = "bottom",
    plot.title = element_text(size = 16, face = "bold"),
    plot.subtitle = element_text(size = 14),
    axis.title = element_text(size = 12),
    legend.text = element_text(size = 11),
    legend.title = element_text(size = 12)
  ) +
  scale_color_manual(values = c("Before (Sequential)" = "#E74C3C", "After (Parallel)" = "#27AE60")) +
  annotate("text", x = 2000, y = 2500, 
           label = "Up to 2.91x Speedup\n96.8% Efficiency", 
           color = "#27AE60", size = 4, fontface = "bold")

ggsave("Before_After_Performance_Comparison.png", p_combined, width = 12, height = 8, dpi = 300)

cat("All figures created successfully!\n")
cat("Generated files:\n")
cat("- Figure1_Throughput_Comparison.png\n")
cat("- Figure2_Parallel_Efficiency.png\n")
cat("- Figure3_Memory_Usage.png\n")
cat("- Figure4_Ability_Distribution.png\n")
cat("- Figure5_Performance_Scaling.png\n")
cat("- Figure6_Speedup_Analysis.png\n")
cat("- Before_After_Performance_Comparison.png\n")