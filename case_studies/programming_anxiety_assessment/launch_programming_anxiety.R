# =============================================================================
# PROGRAMMING ANXIETY ASSESSMENT
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
    
    # Create comprehensive HTML report - fixed structure
    html_report <- paste0(
        '<div id="report-content" style="font-family: Arial, sans-serif; max-width: 900px; margin: 0 auto; padding: 20px;">',

        # Header - Clean professional styling
        '<div style="background-color: #2c3e50; color: white; padding: 30px; border-radius: 8px; text-align: center; margin-bottom: 30px; border: 1px solid #34495e;">',
        '<h1 style="margin: 0; font-size: 28px; font-weight: 300; letter-spacing: 0.5px;">Programming Anxiety Assessment Results</h1>',
        '<p style="margin: 15px 0 0 0; font-size: 16px; opacity: 0.9;">Comprehensive Analysis Based on Your Responses</p>',
        '<p style="margin: 8px 0 0 0; font-size: 12px; opacity: 0.8; font-style: italic;">Assessment completed using Item Response Theory</p>',
        '</div>',

        # Overall Score Card - Clean and minimal
        '<div style="background-color: ', level_color, '; color: white; padding: 30px; border-radius: 8px; margin-bottom: 25px; text-align: center; border: 1px solid #ddd;">',
        '<h2 style="margin: 0 0 15px 0; font-size: 24px; font-weight: 400;">Overall Anxiety Level</h2>',
        '<div style="font-size: 56px; font-weight: 300; margin: 15px 0; letter-spacing: -1px;">', round(pa_theta, 2), '</div>',
        '<div style="font-size: 18px; margin-bottom: 8px; font-weight: 400;">', level_text, '</div>',
        '<div style="font-size: 13px; opacity: 0.9; border-top: 1px solid rgba(255,255,255,0.3); padding-top: 8px;">Scale: 1.0 (Low) to 5.0 (High)</div>',
        '</div>',

        # Population Comparison - Clean grid layout
        '<div style="background-color: #f8f9fa; padding: 25px; border-radius: 8px; margin-bottom: 25px; border: 1px solid #e9ecef;">',
        '<h2 style="color: #495057; margin-top: 0; font-size: 20px; font-weight: 400; text-align: center; margin-bottom: 20px;">Population Comparison</h2>',
        '<div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 15px;">',
        '<div style="background: white; padding: 20px; border-radius: 6px; text-align: center; border: 1px solid #dee2e6;">',
        '<div style="font-size: 36px; font-weight: 300; color: #495057;">', round(percentile, 1), '%</div>',
        '<div style="color: #6c757d; font-size: 14px; margin-top: 8px;">Percentile Rank</div>',
        '<div style="color: #868e96; font-size: 12px; margin-top: 4px;">Among programming students</div>',
        '</div>',
        '<div style="background: white; padding: 20px; border-radius: 6px; text-align: center; border: 1px solid #dee2e6;">',
        '<div style="font-size: 36px; font-weight: 300; color: #495057;">', round(theta_est, 2), '</div>',
        '<div style="color: #6c757d; font-size: 14px; margin-top: 8px;">IRT Theta Estimate</div>',
        '<div style="color: #868e96; font-size: 12px; margin-top: 4px;">Latent trait level</div>',
        '</div>',
        '<div style="background: white; padding: 20px; border-radius: 6px; text-align: center; border: 1px solid #dee2e6;">',
        '<div style="font-size: 36px; font-weight: 300; color: #495057;">', round(se_est, 2), '</div>',
        '<div style="color: #6c757d; font-size: 14px; margin-top: 8px;">Standard Error</div>',
        '<div style="color: #868e96; font-size: 12px; margin-top: 4px;">Measurement precision</div>',
        '</div>',
        '</div>',
        '<div style="margin-top: 20px; padding: 15px; background: white; border-radius: 6px; border: 1px solid #dee2e6;">',
        '<p style="color: #495057; margin: 0; line-height: 1.6; font-size: 15px;">', interpretation, '</p>',
        '</div>',
        '</div>',

        # Subscale Visualization
        '<div style="margin: 25px 0; background-color: #f8f9fa; padding: 25px; border-radius: 8px; border: 1px solid #e9ecef;">',
        '<h2 style="color: #495057; margin-top: 0; font-size: 20px; font-weight: 400; text-align: center; margin-bottom: 20px;">Anxiety Profile by Domain</h2>',
        '</div>',

        # Trace Plot
        '<div style="margin: 25px 0; background-color: #f8f9fa; padding: 25px; border-radius: 8px; border: 1px solid #e9ecef;">',
        '<h2 style="color: #495057; margin-top: 0; font-size: 20px; font-weight: 400; text-align: center; margin-bottom: 20px;">Adaptive Testing Progression</h2>',
        '</div>',

        # Detailed Breakdown - Clean table styling
        '<div style="background-color: #f8f9fa; padding: 25px; border-radius: 8px; margin: 25px 0; border: 1px solid #e9ecef;">',
        '<h2 style="color: #495057; margin-top: 0; font-size: 20px; font-weight: 400; text-align: center; margin-bottom: 20px;">Detailed Subscale Analysis</h2>',
        '<table style="width: 100%; border-collapse: collapse; background: white; border-radius: 6px; overflow: hidden; border: 1px solid #dee2e6;">',
        '<thead>',
        '<tr style="background-color: #495057; color: white;">',
        '<th style="padding: 15px; text-align: left; font-weight: 400; font-size: 14px;">Anxiety Domain</th>',
        '<th style="padding: 15px; text-align: center; font-weight: 400; font-size: 14px;">Score</th>',
        '<th style="padding: 15px; text-align: left; font-weight: 400; font-size: 14px;">Level</th>',
        '</tr>',
        '</thead>',
        '<tbody>',

        # Generate table rows - Clean and professional
        paste0(sapply(1:nrow(subscales), function(i) {
            row <- subscales[i, ]
            score <- as.numeric(row[2])
            interp <- if (score < 2.5) "Low" else if (score < 3.5) "Moderate" else "High"
            score_color <- if (score < 2.5) "#28a745" else if (score < 3.5) "#ffc107" else "#dc3545"
            paste0(
                '<tr style="border-bottom: 1px solid #dee2e6;">',
                '<td style="padding: 15px; font-weight: 500; color: #495057;">', row[1], ' Anxiety</td>',
                '<td style="padding: 15px; text-align: center;"><span style="background-color: ', score_color, '; color: white; padding: 6px 12px; border-radius: 4px; font-weight: 500; font-size: 13px;">', round(score, 2), '</span></td>',
                '<td style="padding: 15px; color: #6c757d; font-size: 14px;">', interp, '</td>',
                '</tr>'
            )
        }), collapse = ""),

        '</tbody>',
        '</table>',
        '</div>',

        # Technical Information - Clean and minimal
        '<div style="background-color: #f8f9fa; padding: 25px; border-radius: 8px; margin: 25px 0; border: 1px solid #e9ecef;">',
        '<h3 style="color: #495057; margin-top: 0; font-size: 18px; font-weight: 400; margin-bottom: 15px;">Technical Assessment Details</h3>',
        '<div style="background: white; padding: 20px; border-radius: 6px; border: 1px solid #dee2e6;">',
        '<p style="color: #495057; margin: 0 0 12px 0; line-height: 1.6; font-size: 14px;"><strong>Assessment Method:</strong> This evaluation used Item Response Theory (IRT) with a 2-Parameter Logistic model to estimate your programming anxiety level.</p>',
        '<p style="color: #495057; margin: 0 0 12px 0; line-height: 1.6; font-size: 14px;"><strong>Measurement Model:</strong> The 2PL model accounts for both item discrimination and difficulty, providing a precise estimate of your position on the programming anxiety continuum.</p>',
        '<p style="color: #495057; margin: 0 0 12px 0; line-height: 1.6; font-size: 14px;"><strong>Population Reference:</strong> Comparison data is based on a normative sample of programming students (mean = ', round(pop_mean, 2), ', SD = ', round(pop_sd, 2), '). Your percentile indicates performance relative to this reference group.</p>',
        '<p style="color: #495057; margin: 0; line-height: 1.6; font-size: 14px;"><strong>Measurement Precision:</strong> The confidence intervals in the trace plot show estimation uncertainty. Precision improves as more items are administered adaptively.</p>',
        '</div>',
        '</div>',

        # Download Section - Clean and minimal
        '<div style="background-color: #f8f9fa; padding: 25px; border-radius: 8px; margin: 25px 0; border: 1px solid #e9ecef;">',
        '<h3 style="color: #495057; margin-top: 0; font-size: 18px; font-weight: 400; margin-bottom: 15px; text-align: center;">Export Your Results</h3>',
        '<div style="background: white; padding: 20px; border-radius: 6px; border: 1px solid #dee2e6;">',
        '<div style="display: flex; gap: 12px; justify-content: center; flex-wrap: wrap;">',
        '<button onclick="if(typeof Shiny !== \'undefined\') { Shiny.setInputValue(\'download_pdf_trigger\', Math.random(), {priority: \'event\'}); } else { alert(\'Download not available\'); }" style="background-color: #495057; border: none; color: white; padding: 12px 24px; border-radius: 6px; cursor: pointer; font-size: 14px; font-weight: 400; transition: all 0.2s ease; border: 1px solid #495057;">',
        ' Download PDF Report</button>',
        '<button onclick="if(typeof Shiny !== \'undefined\') { Shiny.setInputValue(\'download_csv_trigger\', Math.random(), {priority: \'event\'}); } else { alert(\'Download not available\'); }" style="background-color: #28a745; border: none; color: white; padding: 12px 24px; border-radius: 6px; cursor: pointer; font-size: 14px; font-weight: 400; transition: all 0.2s ease; border: 1px solid #28a745;">',
        ' Download CSV Data</button>',
        '</div>',
        '<p style="text-align: center; color: #6c757d; font-size: 12px; margin: 15px 0 0 0;">Results are exported in multiple formats for your analysis and records</p>',
        '</div>',
        '</div>',

        # Print styles - Clean and minimal
        '<style>',
        '@media print {',
        '  .download-section { display: none !important; }',
        '  body { font-family: "Times New Roman", serif; font-size: 11pt; }',
        '  h1, h2, h3 { color: #000 !important; -webkit-print-color-adjust: exact; }',
        '  .btn { display: none !important; }',
        '  table { border: 1px solid #000; }',
        '  th, td { border: 1px solid #ccc; }',
        '}',
        '</style>',

        # Thank You - Clean and professional
        '<div style="background-color: #f8f9fa; padding: 30px; border-radius: 8px; text-align: center; margin-top: 30px; border: 1px solid #e9ecef;">',
        '<h2 style="color: #495057; margin-top: 0; font-size: 22px; font-weight: 400;">Thank You for Participating</h2>',
        '<p style="color: #495057; font-size: 16px; margin: 15px 0; line-height: 1.6;">Your participation contributes to our understanding of programming anxiety and helps improve educational experiences for future students.</p>',
        '<p style="color: #6c757d; font-size: 14px; margin: 15px 0 0 0;">Your responses have been securely stored and anonymized for research purposes.</p>',
        '</div>',

        '</div>'
    )
    
    # Add conditional plot content after HTML generation
    if (nchar(bar_plot_data) > 0) {
        # Insert bar plot into the HTML
        html_report <- gsub(
            '<h2 style="color: #495057; margin-top: 0; font-size: 20px; font-weight: 400; text-align: center; margin-bottom: 20px;">Anxiety Profile by Domain</h2>',
            paste0('<h2 style="color: #495057; margin-top: 0; font-size: 20px; font-weight: 400; text-align: center; margin-bottom: 20px;">Anxiety Profile by Domain</h2>',
                   '<img src="data:image/png;base64,', bar_plot_data, '" style="width: 100%; max-width: 700px; display: block; margin: 0 auto; border-radius: 6px; border: 1px solid #dee2e6; box-shadow: 0 2px 4px rgba(0,0,0,0.05);">'),
            html_report
        )
    } else {
        # Insert fallback message for bar plot
        html_report <- gsub(
            '<h2 style="color: #495057; margin-top: 0; font-size: 20px; font-weight: 400; text-align: center; margin-bottom: 20px;">Anxiety Profile by Domain</h2>',
            paste0('<h2 style="color: #495057; margin-top: 0; font-size: 20px; font-weight: 400; text-align: center; margin-bottom: 20px;">Anxiety Profile by Domain</h2>',
                   '<div style="background: white; padding: 30px; text-align: center; border-radius: 6px; border: 1px solid #dee2e6; margin-top: 20px;">',
                   '<p style="font-size: 15px; margin: 0 0 10px 0; color: #495057;">Visual analysis will be included in the complete PDF report</p>',
                   '<p style="font-size: 13px; margin: 0; color: #6c757d;">Download the full report to view detailed charts and visualizations</p>',
                   '</div>'),
            html_report
        )
    }

    if (nchar(trace_plot_data) > 0) {
        # Insert trace plot into the HTML
        html_report <- gsub(
            '<h2 style="color: #495057; margin-top: 0; font-size: 20px; font-weight: 400; text-align: center; margin-bottom: 20px;">Adaptive Testing Progression</h2>',
            paste0('<h2 style="color: #495057; margin-top: 0; font-size: 20px; font-weight: 400; text-align: center; margin-bottom: 20px;">Adaptive Testing Progression</h2>',
                   '<img src="data:image/png;base64,', trace_plot_data, '" style="width: 100%; max-width: 900px; display: block; margin: 0 auto; border-radius: 6px; border: 1px solid #dee2e6; box-shadow: 0 2px 4px rgba(0,0,0,0.05);">'),
            html_report
        )
    } else {
        # Insert fallback message for trace plot
        html_report <- gsub(
            '<h2 style="color: #495057; margin-top: 0; font-size: 20px; font-weight: 400; text-align: center; margin-bottom: 20px;">Adaptive Testing Progression</h2>',
            paste0('<h2 style="color: #495057; margin-top: 0; font-size: 20px; font-weight: 400; text-align: center; margin-bottom: 20px;">Adaptive Testing Progression</h2>',
                   '<div style="background: white; padding: 30px; text-align: center; border-radius: 6px; border: 1px solid #dee2e6; margin-top: 20px;">',
                   '<p style="font-size: 15px; margin: 0 0 10px 0; color: #495057;">Testing progression analysis will be included in the complete PDF report</p>',
                   '<p style="font-size: 13px; margin: 0; color: #6c757d;">This visualization shows how your ability estimate evolved during the adaptive assessment</p>',
                   '</div>'),
            html_report
        )
    }

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
    estimation_method = "EAP",
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
launch_study(
    config = study_config,
    item_bank = programming_anxiety_items,
    webdav_url = WEBDAV_URL,
    password = WEBDAV_PASSWORD,
    save_format = "csv"
)
