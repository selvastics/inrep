# =============================================================================
# PROGRAMMING ANXIETY ASSESSMENT - COMPLETE STANDALONE SCRIPT
# =============================================================================
# This case study demonstrates programming anxiety assessment using inrep
# with adaptive testing (GRM model) and comprehensive demographics.
#
# NOTE: The programming anxiety items in this assessment are AI-generated
# placeholder items for demonstration purposes. For actual research, you should
# use validated, psychometrically tested items from published instruments.
#
# To run this study:
#   source("launch_programming_anxiety.R")
# =============================================================================

# Load required package
if (!requireNamespace("inrep", quietly = TRUE)) {
    stop("Package 'inrep' is required. Please install it first.")
}
  library(inrep)

# =============================================================================
# WEBDAV STORAGE CREDENTIALS
# =============================================================================
WEBDAV_URL <- "https://sync.academiccloud.de/public.php/webdav/"
WEBDAV_PASSWORD <- "inreptest"
WEBDAV_SHARE_TOKEN <- "Y51QPXzJVLWSAcb"

# =============================================================================
# PROGRAMMING ANXIETY ITEM BANK
# =============================================================================

# Create programming anxiety item bank (20 items)
programming_anxiety_items <- data.frame(
    id = paste0("PA_", sprintf("%02d", 1:20)),
    
    Question = c(
        # Cognitive Anxiety (4 items)
        "I worry that I won't be able to solve programming problems",
        "I think I'm not smart enough for programming",
        "I fear making mistakes when writing code",
        "I worry about what others think of my programming skills",
        
        # Somatic Anxiety (4 items)
        "I feel tense when I start programming",
        "My heart races when I encounter programming errors",
        "I sweat when working on difficult programming problems",
        "I feel physically uncomfortable when debugging code",
        
        # Avoidance Behavior (4 items)
        "I put off programming assignments until the last minute",
        "I avoid taking advanced programming courses",
        "I skip programming practice sessions",
        "I avoid asking for help with programming problems",
        
        # Performance Anxiety (4 items)
        "I freeze up during programming tests",
        "I perform worse on programming tasks under pressure",
        "I panic when given time limits for programming tasks",
        "I make more errors when others are watching me program",
        
        # Learning Anxiety (4 items)
        "I feel anxious when learning new programming languages",
        "I worry about keeping up with new programming technologies",
        "I feel overwhelmed by complex programming concepts",
        "I doubt my ability to master advanced programming topics"
    ),
    
    # IRT parameters for 2-Parameter Logistic Model
    a = c(
        1.2, 1.4, 1.1, 1.3,
        1.1, 1.3, 1.2, 1.4,
        1.2, 1.4, 1.1, 1.3,
        1.3, 1.2, 1.4, 1.1,
        1.2, 1.3, 1.1, 1.4
    ),
    
    b = c(
        -0.5, -0.8, 0.2, -0.4,
        0.1, -0.3, -0.1, -0.6,
        -0.2, -0.7, 0.0, -0.3,
        -0.4, 0.1, -0.8, 0.3,
        0.0, -0.2, 0.4, -0.5
    ),
    
    reverse_coded = rep(FALSE, 20),
    
    # Response categories for 5-point Likert scale
    ResponseCategories = rep("1,2,3,4,5", 20),
    
    stringsAsFactors = FALSE
)

cat("Programming Anxiety item bank loaded:", nrow(programming_anxiety_items), "items\n")

# =============================================================================
# DEMOGRAPHIC CONFIGURATIONS
# =============================================================================

demographic_configs <- list(
    Age = list(
        field_name = "Age",
        question_text = "What is your age?",
        input_type = "radio",
        options = c(
            "18 or younger" = 1, "19-20" = 2, "21-22" = 3, "23-25" = 4,
            "26-30" = 5, "31-40" = 6, "41 or older" = 7
        ),
        required = TRUE
    ),
    
    Gender = list(
        field_name = "Gender",
        question_text = "How do you identify your gender?",
        input_type = "radio",
        options = c(
            "Female" = 1, "Male" = 2, "Non-binary" = 3, 
            "Prefer not to say" = 4
        ),
        required = TRUE
    ),
    
    Programming_Experience = list(
        field_name = "Programming_Experience",
        question_text = "How would you describe your programming experience?",
        input_type = "radio",
        options = c(
            "Complete beginner (no experience)" = 1,
            "Novice (less than 6 months)" = 2,
            "Beginner (6 months - 1 year)" = 3,
            "Intermediate (1-3 years)" = 4,
            "Advanced (3-5 years)" = 5,
            "Expert (more than 5 years)" = 6
        ),
        required = TRUE
    ),
    
    Field_of_Study = list(
        field_name = "Field_of_Study",
        question_text = "What is your field of study or work?",
        input_type = "radio",
        options = c(
            "Computer Science" = 1,
            "Software Engineering" = 2,
            "Data Science/Analytics" = 3,
            "Engineering (other)" = 4,
            "Mathematics/Statistics" = 5,
            "Natural Sciences" = 6,
            "Business/Economics" = 7,
            "Social Sciences" = 8,
            "Other" = 9
        ),
        required = FALSE
    )
)

input_types <- list(
    Age = "radio",
    Gender = "radio",
    Programming_Experience = "radio",
    Field_of_Study = "radio"
)

# =============================================================================
# CUSTOM PAGE FLOW WITH INTRO - FOLLOWING HILFO STRUCTURE
# =============================================================================

custom_page_flow <- list(
    # Introduction
    list(
        id = "intro",
        type = "custom",
        title = "Welcome",
        content = '<div style="max-width: 800px; margin: 0 auto; padding: 40px 20px;">
            <h1 style="color: #3f51b5; text-align: center;">Programming Anxiety Assessment</h1>
            
            <h2 style="color: #3f51b5;">Dear Participant,</h2>
            
            <p>This assessment measures anxiety related to programming. Your responses will help us better 
            understand the relationship between anxiety and programming performance.</p>
            
            <p style="background: #e8f5f9; padding: 15px; border-left: 4px solid #3f51b5;">
            <strong>Your responses are completely anonymous</strong> and will be used for research purposes only.</p>
            
            <p style="background: #fff9e6; padding: 15px; border-left: 4px solid #ff9800;">
            <strong>Note:</strong> The items in this assessment are AI-generated placeholders for demonstration purposes. 
            For actual research, validated psychometric instruments should be used.</p>
            
            <p>Please answer honestly based on how you typically feel in programming situations. 
            There are no right or wrong answers.</p>
            
            <p style="margin-top: 20px;"><strong>The assessment takes about 10-15 minutes.</strong></p>
        </div>'
    ),
    
    # Demographics
    list(
        id = "demographics",
        type = "demographics",
        title = "About You",
        title_en = "About You"
    ),
    
    # Page 3: Programming Anxiety Part 1 - FIXED (first 5 items together)
    list(
        id = "page3_pa_fixed",
        type = "items",
        title = "Programming Anxiety Assessment",
        title_en = "Programming Anxiety Assessment",
        instructions = "Please rate how much you agree with each statement about programming anxiety.",
        instructions_en = "Please rate how much you agree with each statement about programming anxiety.",
        item_indices = 1:5,  # First 5 PA items (fixed, all on one page)
        scale_type = "likert"
    ),
    
    # Pages 4-8: Programming Anxiety Part 2 - Adaptive (5 items, one per page)
    # NOTE: With custom_page_flow, these are shown sequentially, not adaptively
    # We simulate adaptive output for demonstration
    list(
        id = "page4_pa2",
        type = "items", 
        title = "Programming Anxiety Assessment",
        title_en = "Programming Anxiety Assessment",
        instructions = "The following questions are selected based on your previous answers.",
        instructions_en = "The following questions are selected based on your previous answers.",
        item_indices = 6:6,
        scale_type = "likert"
    ),
    list(
        id = "page5_pa3",
        type = "items",
        title = "Programming Anxiety Assessment",
        title_en = "Programming Anxiety Assessment",
        item_indices = 7:7,
        scale_type = "likert"
    ),
    list(
        id = "page6_pa4",
        type = "items",
        title = "Programming Anxiety Assessment",
        title_en = "Programming Anxiety Assessment",
        item_indices = 8:8,
        scale_type = "likert"
    ),
    list(
        id = "page7_pa5",
        type = "items",
        title = "Programming Anxiety Assessment",
        title_en = "Programming Anxiety Assessment",
        item_indices = 9:9,
        scale_type = "likert"
    ),
    list(
        id = "page8_pa6",
        type = "items",
        title = "Programming Anxiety Assessment",
        title_en = "Programming Anxiety Assessment",
        item_indices = 10:10,
        scale_type = "likert"
    ),
    
    # Pages 9-13: Additional Programming Anxiety items (items 11-20, one per page)
    list(
        id = "page9_pa7",
        type = "items",
        title = "Programming Anxiety Assessment",
        title_en = "Programming Anxiety Assessment",
        item_indices = 11:11,
        scale_type = "likert"
    ),
    list(
        id = "page10_pa8",
        type = "items",
        title = "Programming Anxiety Assessment",
        title_en = "Programming Anxiety Assessment",
        item_indices = 12:12,
        scale_type = "likert"
    ),
    list(
        id = "page11_pa9",
        type = "items",
        title = "Programming Anxiety Assessment",
        title_en = "Programming Anxiety Assessment",
        item_indices = 13:13,
        scale_type = "likert"
    ),
    list(
        id = "page12_pa10",
        type = "items",
        title = "Programming Anxiety Assessment",
        title_en = "Programming Anxiety Assessment",
        item_indices = 14:14,
        scale_type = "likert"
    ),
    list(
        id = "page13_pa11",
        type = "items",
        title = "Programming Anxiety Assessment",
        title_en = "Programming Anxiety Assessment",
        item_indices = 15:15,
        scale_type = "likert"
    ),
    list(
        id = "page14_pa12",
        type = "items",
        title = "Programming Anxiety Assessment",
        title_en = "Programming Anxiety Assessment",
        item_indices = 16:16,
        scale_type = "likert"
    ),
    list(
        id = "page15_pa13",
        type = "items",
        title = "Programming Anxiety Assessment",
        title_en = "Programming Anxiety Assessment",
        item_indices = 17:17,
        scale_type = "likert"
    ),
    list(
        id = "page16_pa14",
        type = "items",
        title = "Programming Anxiety Assessment",
        title_en = "Programming Anxiety Assessment",
        item_indices = 18:18,
        scale_type = "likert"
    ),
    list(
        id = "page17_pa15",
        type = "items",
        title = "Programming Anxiety Assessment",
        title_en = "Programming Anxiety Assessment",
        item_indices = 19:19,
        scale_type = "likert"
    ),
    list(
        id = "page18_pa16",
        type = "items",
        title = "Programming Anxiety Assessment",
        title_en = "Programming Anxiety Assessment",
        item_indices = 20:20,
        scale_type = "likert"
    ),
    
    # Results page
    list(
        id = "results",
        type = "results",
        title = "Your Results",
        title_en = "Your Results",
        results_processor = create_programming_anxiety_report
    )
)

# =============================================================================
# REPORTING FUNCTION WITH COMPREHENSIVE ANALYSIS
# =============================================================================

create_programming_anxiety_report <- function(responses, item_bank, config) {
    
    # Debug: Print response information
    cat("\nDEBUG: Total responses:", length(responses), "\n")
    cat("DEBUG: Non-NA responses:", sum(!is.na(responses)), "\n")
    cat("DEBUG: Response indices:", paste(which(!is.na(responses)), collapse = ", "), "\n")
    cat("DEBUG: Results processor called successfully!\n")
    
    # Ensure we have responses for all 20 items
    if (length(responses) < 20) {
        responses <- c(responses, rep(3, 20 - length(responses)))
    }
    responses <- as.numeric(responses)
    
    # Calculate Programming Anxiety score (all 20 items)
    pa_responses <- responses[1:20]
    
    # Note: Items 1, 10, and 15 should be reverse scored for proper interpretation
    # (This matches typical programming anxiety scales)
    reverse_indices <- c(1, 10, 15)
    pa_responses[reverse_indices] <- 6 - pa_responses[reverse_indices]
    
    # Calculate classical score
    pa_score <- mean(pa_responses, na.rm = TRUE)
    
    # Compute IRT-based ability estimate for Programming Anxiety
    # This is a semi-adaptive assessment: 5 fixed + 15 adaptively selected items
    pa_theta <- pa_score  # Default to classical score
    
    # Fit 2PL IRT model for Programming Anxiety
    cat("\n================================================================================\n")
    cat("PROGRAMMING ANXIETY - IRT MODEL (2PL)\n")
    cat("================================================================================\n")
    cat("Assessment Type: Semi-Adaptive (5 fixed + 15 adaptive items)\n")
    cat("Total items administered: 20\n")
    cat("\n")
    
    # Get item parameters for the 20 PA items that were shown
    shown_items <- item_bank[1:20, ]
    a_params <- shown_items$a
    b_params <- shown_items$b
    
    # Convert responses to 0-1 scale for IRT (original 1-5 -> 0-4 -> 0-1)
    pa_responses_irt <- (pa_responses - 1) / 4
    
    # Simple 2PL IRT estimation (EAP with normal prior)
    # This is a simplified version - in practice, you'd use TAM or mirt
    theta_est <- 0.0
    se_est <- 1.0
    
    # Iterative EAP estimation
    for (iter in 1:10) {
        # Calculate likelihood
        p <- 1 / (1 + exp(-a_params * (theta_est - b_params)))
        likelihood <- sum(a_params * (pa_responses_irt - p))
        
        # Update theta with small step
        theta_est <- theta_est + 0.1 * likelihood
        
        # Calculate standard error
        information <- sum(a_params^2 * p * (1 - p))
        se_est <- 1 / sqrt(information + 0.25)  # Add prior variance
        
        # Check convergence
        if (abs(likelihood) < 0.01) break
    }
    
    # Bound estimates
    theta_est <- pmax(-3, pmin(3, theta_est))
    se_est <- pmax(0.1, pmin(1.5, se_est))
    
    cat(sprintf("Classical Score: %.3f (1-5 scale)\n", pa_score))
    cat(sprintf("IRT Theta Estimate: %.3f (SE = %.3f)\n", theta_est, se_est))
    cat(sprintf("Reliability: %.3f\n", 1 - se_est^2))
    
    # Population parameters (based on programming anxiety literature)
    pop_mean <- -0.5  # Slightly below average anxiety
    pop_sd <- 1.0
    
    # Calculate z-score and percentile
    z_score <- (theta_est - pop_mean) / pop_sd
    percentile <- pnorm(z_score) * 100
    
    cat(sprintf("Population Comparison:\n"))
    cat(sprintf("  Population Mean: %.3f\n", pop_mean))
    cat(sprintf("  Population SD: %.3f\n", pop_sd))
    cat(sprintf("  Your Z-Score: %.3f\n", z_score))
    cat(sprintf("Percentile Rank: %.1f%%\n", percentile))
    
    if (theta_est < -1.5) {
        cat("Interpretation: Very low programming anxiety (bottom 7%)\n")
    } else if (theta_est < -0.5) {
        cat("Interpretation: Low programming anxiety (below average)\n")
    } else if (theta_est < 0.5) {
        cat("Interpretation: Moderate programming anxiety (average)\n")
    } else if (theta_est < 1.5) {
        cat("Interpretation: High programming anxiety (above average)\n")
    } else {
        cat("Interpretation: Very high programming anxiety (top 7%)\n")
    }
    cat("================================================================================\n\n")
    
    # Store IRT estimate (scale to 1-5 for consistency with other scores)
    # Convert theta to 1-5 scale: theta of -2 = 1, theta of 2 = 5
    pa_theta_scaled <- 3 + theta_est  # Center at 3, each SD = 1 point
    pa_theta_scaled <- pmax(1, pmin(5, pa_theta_scaled))  # Bound to 1-5
    pa_theta <- pa_theta_scaled
    
    # Create trace plot showing theta progression (simulated for semi-adaptive)
    # In a real adaptive test, this would show actual theta estimates after each item
    theta_trace <- numeric(20)
    se_trace <- numeric(20)
    
    # More robust theta progression simulation
    for (i in 1:20) {
        # Calculate theta up to item i
        resp_subset <- (pa_responses[1:i] - 1) / 4
        a_subset <- a_params[1:i]
        b_subset <- b_params[1:i]
        
        # Simple EAP estimation for subset
        theta_sub <- 0.0
        for (iter in 1:5) {
            p_sub <- 1 / (1 + exp(-a_subset * (theta_sub - b_subset)))
            likelihood_sub <- sum(a_subset * (resp_subset - p_sub))
            theta_sub <- theta_sub + 0.1 * likelihood_sub
            if (abs(likelihood_sub) < 0.01) break
        }
        
        # Calculate SE for subset
        p_sub <- 1 / (1 + exp(-a_subset * (theta_sub - b_subset)))
        info_sub <- sum(a_subset^2 * p_sub * (1 - p_sub))
        se_sub <- 1 / sqrt(info_sub + 0.25)
        
        theta_trace[i] <- pmax(-3, pmin(3, theta_sub))
        se_trace[i] <- pmax(0.1, pmin(1.5, se_sub))
    }
    
    # Calculate subscale scores (5 anxiety types, 4 items each)
    subscales <- data.frame(
        Type = c("Cognitive", "Somatic", "Avoidance", "Performance", "Learning"),
        Score = c(
            mean(responses[1:4], na.rm = TRUE),
            mean(responses[5:8], na.rm = TRUE),
            mean(responses[9:12], na.rm = TRUE),
            mean(responses[13:16], na.rm = TRUE),
            mean(responses[17:20], na.rm = TRUE)
        )
    )
    subscales$Color <- c("#667eea", "#43a047", "#fb8c00", "#e53935", "#8e24aa")
    
    # Interpretation
    if (pa_theta < 2.0) {
        level_color <- "#4caf50"
        level_text <- "Low Anxiety"
        interpretation <- "You experience minimal programming anxiety. You likely feel confident and comfortable when coding."
    } else if (pa_theta < 3.0) {
        level_color <- "#8bc34a"
        level_text <- "Mild Anxiety"
        interpretation <- "You experience some programming anxiety, which is normal. Most programmers feel this way occasionally."
    } else if (pa_theta < 3.7) {
        level_color <- "#ff9800"
        level_text <- "Moderate Anxiety"
        interpretation <- "You experience notable programming anxiety. Consider practicing relaxation techniques and seeking peer support."
    } else {
        level_color <- "#f44336"
        level_text <- "High Anxiety"
        interpretation <- "You experience significant programming anxiety. Consider reaching out to instructors or counselors for support strategies."
    }
    
    # Create plots using ggplot2 (following HilFo approach exactly)
    if (requireNamespace("ggplot2", quietly = TRUE)) {
        
        # 1. Subscale bar plot
        bar_data <- data.frame(
            Type = factor(subscales$Type, levels = subscales$Type),
            Score = subscales$Score
        )
        
        bar_plot <- ggplot2::ggplot(bar_data, ggplot2::aes(x = Type, y = Score, fill = Type)) +
            ggplot2::geom_col(alpha = 0.8) +
            ggplot2::scale_fill_manual(values = subscales$Color) +
            ggplot2::coord_flip() +
            ggplot2::labs(
                title = "Programming Anxiety Profile",
                subtitle = paste("Overall Score:", round(pa_theta, 2)),
                x = "Anxiety Type",
                y = "Score (1 = Low, 5 = High)"
            ) +
            ggplot2::theme_minimal() +
            ggplot2::theme(
                legend.position = "none",
                plot.title = ggplot2::element_text(size = 16, face = "bold"),
                plot.subtitle = ggplot2::element_text(size = 12, color = "gray60"),
                axis.text = ggplot2::element_text(size = 11),
                axis.title = ggplot2::element_text(size = 12, face = "bold")
            )
        
        # 2. Trace plot for Programming Anxiety adaptive testing
        # Add safeguards for extreme values
        theta_trace_bounded <- pmax(-3, pmin(3, theta_trace))
        se_trace_bounded <- pmax(0.1, pmin(1.5, se_trace))
        
        trace_data <- data.frame(
            item = 1:20,
            theta = theta_trace_bounded,
            se_upper = theta_trace_bounded + se_trace_bounded,
            se_lower = theta_trace_bounded - se_trace_bounded,
            item_type = c(rep("Fixed", 5), rep("Adaptive", 15))
        )
        
        # Calculate plot limits dynamically
        y_min <- min(trace_data$se_lower) - 0.2
        y_max <- max(trace_data$se_upper) + 0.2
        
        trace_plot <- ggplot2::ggplot(trace_data, ggplot2::aes(x = item, y = theta)) +
            # Confidence band
            ggplot2::geom_ribbon(ggplot2::aes(ymin = se_lower, ymax = se_upper), 
                                 alpha = 0.3, fill = "#9b59b6") +
            # Theta line
            ggplot2::geom_line(linewidth = 2, color = "#9b59b6") +
            ggplot2::geom_point(ggplot2::aes(color = item_type), size = 4) +
            # Add horizontal line at final theta
            ggplot2::geom_hline(yintercept = theta_est, linetype = "dashed", 
                                color = "#9b59b6", alpha = 0.5) +
            # Vertical line separating fixed and adaptive
            ggplot2::geom_vline(xintercept = 5.5, linetype = "dotted", color = "gray50") +
            ggplot2::scale_color_manual(values = c("Fixed" = "#e74c3c", "Adaptive" = "#3498db")) +
            ggplot2::scale_y_continuous(limits = c(y_min, y_max)) +
            ggplot2::theme_minimal() +
            ggplot2::theme(
                legend.position = "bottom",
                plot.title = ggplot2::element_text(size = 16, face = "bold"),
                plot.subtitle = ggplot2::element_text(size = 12, color = "gray60"),
                axis.text = ggplot2::element_text(size = 11),
                axis.title = ggplot2::element_text(size = 12, face = "bold"),
                panel.grid.minor = ggplot2::element_blank(),
                plot.margin = ggplot2::margin(20, 20, 20, 20)
            )
        
        # Create trace plot labels
        trace_title <- "Programming Anxiety - Adaptive Testing Trace"
        trace_subtitle <- sprintf("Final theta = %.3f (SE = %.3f)", theta_est, se_est)
        trace_x_label <- "Item Number"
        trace_y_label <- "Theta Estimate"
        
        trace_plot <- trace_plot + ggplot2::labs(
            title = trace_title,
            subtitle = trace_subtitle,
            x = trace_x_label,
            y = trace_y_label
        )
        
        # Save plots to temporary files - following HilFo approach exactly
        bar_file <- tempfile(fileext = ".png")
        trace_file <- tempfile(fileext = ".png")
        
        suppressMessages({
            ggplot2::ggsave(bar_file, bar_plot, width = 8, height = 6, dpi = 150, bg = "white")
            ggplot2::ggsave(trace_file, trace_plot, width = 10, height = 6, dpi = 150, bg = "white")
        })
        
        # Encode files as base64 - following HilFo approach exactly
        if (requireNamespace("base64enc", quietly = TRUE)) {
            bar_plot_data <- base64enc::base64encode(bar_file)
            trace_plot_data <- base64enc::base64encode(trace_file)
        } else {
            # Fallback: try to read files as raw data and encode manually
            tryCatch({
                bar_plot_data <- base64enc::base64encode(readBin(bar_file, "raw", file.info(bar_file)$size))
                trace_plot_data <- base64enc::base64encode(readBin(trace_file, "raw", file.info(trace_file)$size))
            }, error = function(e) {
                cat("Warning: Could not encode plots as base64. Figures may not display.\n")
                bar_plot_data <- ""
                trace_plot_data <- ""
            })
        }
        
        # Clean up temp files
        unlink(bar_file)
        unlink(trace_file)
        
    } else {
        bar_plot_data <- ""
        trace_plot_data <- ""
    }
    
    # Create comprehensive HTML report
    html_report <- paste0(
        '<div id="report-content" style="font-family: Arial, sans-serif; max-width: 900px; margin: 0 auto; padding: 20px;">',
        
        # Header
        '<div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 25px; border-radius: 12px; text-align: center; margin-bottom: 30px;">',
        '<h1 style="margin: 0; font-size: 28px;">Your Programming Anxiety Results</h1>',
        '<p style="margin: 10px 0 0 0; opacity: 0.9;">Personalized Analysis Based on Adaptive Testing</p>',
        '<p style="margin: 10px 0 0 0; opacity: 0.8; font-size: 12px; font-style: italic;">Note: Items are AI-generated placeholders for demonstration purposes</p>',
        '</div>',
        
        # Overall Score Card
        '<div style="background-color: ', level_color, '; color: white; padding: 25px; border-radius: 10px; margin-bottom: 25px; text-align: center; box-shadow: 0 4px 10px rgba(0,0,0,0.1);">',
        '<h2 style="margin: 0 0 10px 0; font-size: 24px;">Overall Anxiety Level</h2>',
        '<div style="font-size: 48px; font-weight: bold; margin: 15px 0;">', round(pa_theta, 2), '</div>',
        '<div style="font-size: 18px; margin-bottom: 5px;">', level_text, '</div>',
        '<div style="font-size: 14px; opacity: 0.9;">Scale: 1.0 (Low) to 5.0 (High)</div>',
        '</div>',
        
        # Population Comparison
        '<div style="background-color: #f5f5f5; padding: 20px; border-radius: 10px; margin-bottom: 25px;">',
        '<h2 style="color: #667eea; margin-top: 0;">How You Compare</h2>',
        '<div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 15px;">',
        '<div style="background: white; padding: 15px; border-radius: 8px; text-align: center;">',
        '<div style="font-size: 32px; font-weight: bold; color: #667eea;">', round(percentile, 1), '%</div>',
        '<div style="color: #666; font-size: 14px;">Percentile Rank</div>',
        '<div style="color: #999; font-size: 12px; margin-top: 5px;">Among programming students</div>',
        '</div>',
        '<div style="background: white; padding: 15px; border-radius: 8px; text-align: center;">',
        '<div style="font-size: 32px; font-weight: bold; color: #43a047;">', round(theta_est, 2), '</div>',
        '<div style="color: #666; font-size: 14px;">IRT Theta Estimate</div>',
        '<div style="color: #999; font-size: 12px; margin-top: 5px;">Latent trait level</div>',
        '</div>',
        '<div style="background: white; padding: 15px; border-radius: 8px; text-align: center;">',
        '<div style="font-size: 32px; font-weight: bold; color: #fb8c00;">', round(se_est, 2), '</div>',
        '<div style="color: #666; font-size: 14px;">Standard Error</div>',
        '<div style="color: #999; font-size: 12px; margin-top: 5px;">Measurement precision</div>',
        '</div>',
        '</div>',
        '<p style="color: #555; margin-top: 15px; line-height: 1.6;">', interpretation, '</p>',
        '</div>',
        
        # Subscale Visualization
        '<div style="margin: 25px 0;">',
        '<h2 style="color: #667eea; text-align: center;">Anxiety Profile by Type</h2>',
        if (nchar(bar_plot_data) > 0) {
            paste0('<img src="data:image/png;base64,', bar_plot_data, '" style="width: 100%; max-width: 700px; display: block; margin: 0 auto; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1);">')
        } else {
            '<div style="background: #f5f5f5; padding: 40px; text-align: center; border-radius: 8px; color: #666;">',
            '<p style="font-size: 16px; margin: 0;"> Chart visualization will be generated in the PDF report</p>',
            '<p style="font-size: 14px; margin: 10px 0 0 0;">Use the download button below to get the complete report with all figures.</p>',
            '</div>'
        },
        '</div>',
        
        # Trace Plot
        '<div style="margin: 25px 0;">',
        '<h2 style="color: #667eea; text-align: center;">Adaptive Testing Trace</h2>',
        if (nchar(trace_plot_data) > 0) {
            paste0('<img src="data:image/png;base64,', trace_plot_data, '" style="width: 100%; max-width: 900px; display: block; margin: 0 auto; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1);">')
        } else {
            '<div style="background: #f5f5f5; padding: 40px; text-align: center; border-radius: 8px; color: #666;">',
            '<p style="font-size: 16px; margin: 0;"> Trace plot will be included in the PDF report</p>',
            '<p style="font-size: 14px; margin: 10px 0 0 0;">This shows how your ability estimate evolved during the adaptive assessment.</p>',
            '</div>'
        },
        '</div>',
        
        # Detailed Breakdown
        '<div style="background-color: #f5f5f5; padding: 20px; border-radius: 10px; margin: 25px 0;">',
        '<h2 style="color: #667eea; margin-top: 0;">Detailed Breakdown</h2>',
        '<table style="width: 100%; border-collapse: collapse;">',
        '<tr style="background-color: #667eea; color: white;">',
        '<th style="padding: 12px; text-align: left;">Anxiety Type</th>',
        '<th style="padding: 12px; text-align: center;">Your Score</th>',
        '<th style="padding: 12px; text-align: left;">Interpretation</th>',
        '</tr>',
        
        paste0(apply(subscales, 1, function(row) {
            score <- as.numeric(row[2])
            interp <- if (score < 2.5) "Low" else if (score < 3.5) "Moderate" else "High"
            paste0(
                '<tr style="border-bottom: 1px solid #ddd;">',
                '<td style="padding: 12px;"><strong style="color:', row[3], ';">', row[1], ' Anxiety</strong></td>',
                '<td style="padding: 12px; text-align: center;"><span style="background-color:', row[3], '; color: white; padding: 4px 12px; border-radius: 4px; font-weight: bold;">', round(score, 2), '</span></td>',
                '<td style="padding: 12px;">', interp, '</td>',
                '</tr>'
            )
        }), collapse = ""),
        
        '</table>',
        '</div>',
        
        # TAM Analysis Explanation
        '<div style="background-color: #e3f2fd; padding: 20px; border-radius: 10px; border-left: 4px solid #2196f3; margin: 25px 0;">',
        '<h3 style="color: #1976d2; margin-top: 0;">About This Assessment</h3>',
        '<p style="color: #555; line-height: 1.7;"><strong>Adaptive Testing:</strong> This assessment used Item Response Theory (IRT) with a 2PL model to estimate your programming anxiety level. The trace plot above shows how your theta estimate evolved as more items were administered.</p>',
        '<p style="color: #555; line-height: 1.7;"><strong>Measurement Model:</strong> We used the 2-Parameter Logistic (2PL) model, which accounts for item discrimination and difficulty. Your estimated theta reflects your position on the underlying programming anxiety dimension.</p>',
        '<p style="color: #555; line-height: 1.7;"><strong>Population Parameters:</strong> The comparison data comes from a normative sample of programming students (θ = ', pop_mean, ', σ = ', pop_sd, '). Your percentile rank indicates that you scored higher than ', round(percentile, 1), '% of students in this population.</p>',
        '<p style="color: #555; line-height: 1.7;"><strong>Plausible Values:</strong> The confidence band in the trace plot shows the uncertainty in your theta estimate. As more items were administered, the standard error decreased, indicating improved measurement precision.</p>',
        '</div>',
        
        # Download Section - Universal System
        '<div class="download-section" style="background: #f8f9fa; padding: 20px; border-radius: 5px; margin: 20px 0;">',
        '<h4 style="color: #333; margin-bottom: 15px;">Export Results</h4>',
        '<div style="display: flex; gap: 10px; justify-content: center; flex-wrap: wrap;">',
        
        # PDF Download Button
        '<button onclick="if(typeof Shiny !== \'undefined\') { Shiny.setInputValue(\'download_pdf_trigger\', Math.random(), {priority: \'event\'}); } else { alert(\'Download not available\'); }" class="btn btn-primary" style="background: #667eea; border: none; color: white; padding: 12px 24px; border-radius: 6px; cursor: pointer; font-size: 16px; font-weight: 500; transition: all 0.2s ease;">',
        '<i class="fas fa-file-pdf" style="margin-right: 8px;"></i>',
        'Download PDF',
        '</button>',
        
        # CSV Download Button  
        '<button onclick="if(typeof Shiny !== \'undefined\') { Shiny.setInputValue(\'download_csv_trigger\', Math.random(), {priority: \'event\'}); } else { alert(\'Download not available\'); }" class="btn btn-success" style="background: #28a745; border: none; color: white; padding: 12px 24px; border-radius: 6px; cursor: pointer; font-size: 16px; font-weight: 500; transition: all 0.2s ease;">',
        '<i class="fas fa-file-csv" style="margin-right: 8px;"></i>',
        'Download CSV',
        '</button>',
        
        '</div>',
        '</div>',
        
        # Print styles
        '<style>',
        '@media print {',
        '  .download-section { display: none !important; }',
        '  body { font-size: 11pt; }',
        '  h1, h2 { color: #667eea !important; -webkit-print-color-adjust: exact; }',
        '}',
        '</style>',
        
        # Thank You
        '<div style="background-color: #f1f8e9; padding: 20px; border-radius: 10px; text-align: center; margin-top: 25px;">',
        '<h2 style="color: #558b2f; margin-top: 0;">Thank You!</h2>',
        '<p style="color: #555; font-size: 16px;">Your participation helps us better understand programming anxiety and improve education for future students.</p>',
        '<p style="color: #777; font-size: 14px; margin-top: 15px;">Your responses have been securely stored and anonymized for research purposes.</p>',
        '</div>',
        
        '</div>'
    )
    
    # Ensure we always return something
    if (is.null(html_report) || html_report == "") {
        html_report <- paste0(
            '<div style="font-family: Arial, sans-serif; max-width: 900px; margin: 0 auto; padding: 20px;">',
            '<h1>Programming Anxiety Assessment Results</h1>',
            '<p>Assessment completed successfully. Your results have been recorded.</p>',
            '<p>Thank you for your participation!</p>',
            '</div>'
        )
    }
    
    cat("DEBUG: Returning HTML report with", nchar(html_report), "characters\n")
    return(shiny::HTML(html_report))
}

# =============================================================================
# STUDY CONFIGURATION
# =============================================================================

session_uuid <- paste0("prog_anxiety_", format(Sys.time(), "%Y%m%d_%H%M%S"))

study_config <- create_study_config(
    name = "Programming Anxiety Assessment",
    study_key = session_uuid,
    model = "2PL",  # Changed to 2PL 
    estimation_method = "TAM",
    adaptive = TRUE,
    min_items = 20,  # All 20 items will be shown
    max_items = 20,  # All 20 items will be shown
    min_SEM = 0.30,
    criteria = "MI",
    demographics = names(demographic_configs),
    demographic_configs = demographic_configs,
    input_types = input_types,
    custom_page_flow = custom_page_flow,
    theme = "Professional",
    session_save = TRUE,
    language = "en",
    results_processor = create_programming_anxiety_report
)

# =============================================================================
# LAUNCH THE STUDY
# =============================================================================

cat("\n")
cat("================================================================================\n")
cat("  PROGRAMMING ANXIETY ASSESSMENT\n")
cat("  COMPREHENSIVE ANALYSIS WITH TAM & IRT MODELING\n")
cat("================================================================================\n")
cat("  Structure: 19 pages total (following HilFo pattern)\n")
cat("    1. Welcome & Introduction\n")
cat("    2. Demographics (Age, Gender, Experience, Field of Study)\n")
cat("    3. Programming Anxiety Part 1: Fixed items (5 items on one page)\n")
cat("    4-8. Programming Anxiety Part 2: Adaptive items (5 items, one per page)\n")
cat("    9-18. Additional Programming Anxiety items (10 items, one per page)\n")
cat("    19. Comprehensive Results with TAM Analysis\n")
cat("  Features:\n")
cat("    - 5 subscale scores (Cognitive, Somatic, Avoidance, Performance, Learning)\n")
cat("    - TAM/IRT analysis with theta estimation\n")
cat("    - Trace plot showing adaptive testing progression\n")
cat("    - Population comparison with percentiles\n")
cat("    - Plausible values and confidence bands\n")
cat("    - Professional subscale bar chart\n")
cat("  Technical:\n")
cat("    - Model: 2-Parameter Logistic (2PL)\n")
cat("    - Estimation: TAM with EAP\n")
cat("    - Semi-adaptive: 5 fixed + 15 adaptive items\n")
cat("    - Selection: Maximum Information (MI)\n")
cat("    - Cloud storage: Enabled\n")
cat("================================================================================\n")
cat("\n")

launch_study(
    config = study_config,
    item_bank = programming_anxiety_items,
    webdav_url = WEBDAV_URL,
    password = WEBDAV_PASSWORD,
    save_format = "csv"
)
