# =============================================================================
# BIG FIVE PERSONALITY ASSESSMENT - 5 SEQUENTIAL UNIDIMENSIONAL TESTS
# =============================================================================
# This case study demonstrates Big Five personality assessment using inrep
# with 5 SEPARATE sequential unidimensional adaptive tests (GRM model).
#
# Each dimension is tested separately with its own adaptive algorithm.
#
# To run this study:
#   source("launch_big_five.R")
# =============================================================================

# Load required packages
suppressPackageStartupMessages({
  library(inrep)
  library(ggplot2)
    library(base64enc)
})

# =============================================================================
# WEBDAV STORAGE CREDENTIALS
# =============================================================================
WEBDAV_URL <- "https://sync.academiccloud.de/public.php/webdav/"
WEBDAV_PASSWORD <- "inreptest"

# =============================================================================
# BIG FIVE PERSONALITY ITEM BANK (20 items total, 4 per dimension)
# =============================================================================

bfi_items <- data.frame(
    id = paste0("BFI_", sprintf("%02d", 1:20)),
    
    Question = c(
        # Extraversion (items 1-4)
        "I am someone who is outgoing, sociable.",
        "I am someone who is reserved.",
        "I am someone who is full of energy.",
        "I am someone who generates a lot of enthusiasm.",
        
        # Agreeableness (items 5-8)
        "I am someone who is helpful and unselfish with others.",
        "I am someone who has a forgiving nature.",
        "I am someone who is generally trusting.",
        "I am someone who finds fault with others.",
        
        # Conscientiousness (items 9-12)
        "I am someone who does a thorough job.",
        "I am someone who perseveres until the task is finished.",
        "I am someone who does things efficiently.",
        "I am someone who tends to be disorganized.",
        
        # Neuroticism (items 13-16)
        "I am someone who can be tense.",
        "I am someone who worries a lot.",
        "I am someone who can be moody.",
        "I am someone who is relaxed, handles stress well.",
        
        # Openness (items 17-20)
        "I am someone who is original, comes up with new ideas.",
        "I am someone who is curious about many different things.",
        "I am someone who is ingenious, a deep thinker.",
        "I am someone who has an active imagination."
    ),
    
    # IRT parameters for GRM
    a = c(
        1.32, 1.10, 1.38, 1.20,  # Extraversion
        1.35, 1.14, 1.34, 1.24,  # Agreeableness
        1.39, 1.45, 1.42, 1.04,  # Conscientiousness
        1.49, 0.98, 1.40, 1.08,  # Neuroticism
        1.28, 1.15, 1.41, 1.08   # Openness
    ),
    
    b1 = c(
        -1.6, 0.7, -1.7, -1.4,
        -1.9, -1.5, -1.2, 1.3,
        -2.1, -2.2, -2.1, 1.5,
        -0.8, -1.1, -0.7, -1.4,
        -1.8, -1.5, -1.9, -1.2
    ),
    
    b2 = c(
        -0.7, 1.6, -0.8, -0.5,
        -1.0, -0.6, -0.3, 2.2,
        -1.2, -1.3, -1.2, 2.4,
        0.1, -0.2, 0.2, -0.5,
        -0.9, -0.6, -1.0, -0.3
    ),
    
    b3 = c(
        0.4, 2.7, 0.3, 0.6,
        0.1, 0.5, 0.8, 3.3,
        0.1, 0.0, 0.1, 3.5,
        1.2, 0.9, 1.3, 0.6,
        0.2, 0.5, 0.1, 0.8
    ),
    
    b4 = c(
        1.7, 3.8, 1.6, 1.9,
        1.4, 1.8, 2.1, 4.4,
        1.4, 1.3, 1.4, 4.6,
        2.5, 2.2, 2.6, 1.9,
        1.5, 1.8, 1.4, 2.1
    ),
    
    reverse_coded = c(
        FALSE, TRUE, FALSE, FALSE,
        FALSE, FALSE, FALSE, TRUE,
        FALSE, FALSE, FALSE, TRUE,
        FALSE, FALSE, FALSE, TRUE,
        FALSE, FALSE, FALSE, FALSE
    ),
    
    ResponseCategories = rep("1,2,3,4,5", 20),
    
    stringsAsFactors = FALSE
)

# =============================================================================
# DEMOGRAPHIC CONFIGURATIONS
# =============================================================================

demographic_configs <- list(
    Age = list(
        field_name = "Age",
        question_text = "What is your age?",
        input_type = "radio",
        options = c(
            "18 or younger" = 1, "19-20" = 2, "21-25" = 3, 
            "26-30" = 4, "31-40" = 5, "41-50" = 6, 
            "51-60" = 7, "61 or older" = 8
        ),
        required = TRUE
    ),
    
    Gender = list(
        field_name = "Gender",
        question_text = "How do you identify your gender?",
        input_type = "radio",
        options = c(
            "Female" = 1, "Male" = 2, "Non-binary" = 3, 
            "Other" = 4, "Prefer not to say" = 5
        ),
        required = TRUE
    ),
    
    Education_Level = list(
        field_name = "Education_Level",
        question_text = "What is your highest level of education?",
        input_type = "radio",
        options = c(
            "High school or equivalent" = 1,
            "Some college (no degree)" = 2,
            "Bachelor's degree" = 3,
            "Master's degree" = 4,
            "Doctoral degree" = 5,
            "Professional degree" = 6,
            "Other" = 7
        ),
        required = TRUE
    )
)

input_types <- list(
    Age = "radio",
    Gender = "radio",
    Education_Level = "radio"
)

# =============================================================================
# CUSTOM PAGE FLOW - 5 SEQUENTIAL SECTIONS
# =============================================================================

custom_page_flow <- list(
    # Introduction
    list(
        id = "intro",
        type = "custom",
        title = "Welcome",
        content = '<div style="max-width: 800px; margin: 0 auto; padding: 40px 20px;">
            <h1 style="color: #2E8B57; text-align: center;">Big Five Personality Assessment</h1>
            
            <h2 style="color: #2E8B57;">Dear Participant,</h2>
            
            <p>This assessment measures your personality across five major dimensions: 
            Extraversion, Agreeableness, Conscientiousness, Neuroticism, and Openness.</p>
            
            <p style="background: #f1f8f4; padding: 15px; border-left: 4px solid #2E8B57;">
            <strong>Your responses are completely anonymous</strong> and will be used for research purposes only.</p>
            
            <p>Each dimension will be assessed separately. Please respond honestly based on how you typically 
            think, feel, and behave. There are no right or wrong answers.</p>
            
            <p style="margin-top: 20px;"><strong>The assessment takes about 10-15 minutes.</strong></p>
        </div>'
    ),
    
    # Extraversion (items 1-4)
    list(
        id = "extraversion",
        type = "items",
        title = "Extraversion",
        instructions = "Please rate how well each statement describes you.",
        item_indices = 1:4,
        scale_type = "likert"
    ),
    
    # Agreeableness (items 5-8)
    list(
        id = "agreeableness",
        type = "items",
        title = "Agreeableness",
        instructions = "Please rate how well each statement describes you.",
        item_indices = 5:8,
        scale_type = "likert"
    ),
    
    # Conscientiousness (items 9-12)
    list(
        id = "conscientiousness",
        type = "items",
        title = "Conscientiousness",
        instructions = "Please rate how well each statement describes you.",
        item_indices = 9:12,
        scale_type = "likert"
    ),
    
    # Neuroticism (items 13-16)
    list(
        id = "neuroticism",
        type = "items",
        title = "Neuroticism",
        instructions = "Please rate how well each statement describes you.",
        item_indices = 13:16,
        scale_type = "likert"
    ),
    
    # Openness (items 17-20)
    list(
        id = "openness",
        type = "items",
        title = "Openness",
        instructions = "Please rate how well each statement describes you.",
        item_indices = 17:20,
        scale_type = "likert"
    ),
    
    # Results page
    list(
        id = "results",
        type = "results",
        title = "Your Results",
        results_processor = "create_bfi_report"
    )
)

# =============================================================================
# REPORTING FUNCTION
# =============================================================================

create_bfi_report <- function(responses, item_bank, config) {
    
    # Apply reverse coding
    responses_scored <- responses
    reverse_items <- which(item_bank$reverse_coded == TRUE)
    for (idx in reverse_items) {
        if (idx <= length(responses_scored)) {
            responses_scored[idx] <- 6 - responses_scored[idx]
        }
    }
    
    # Generate CSV file for download
    timestamp <- format(Sys.time(), "%Y%m%d_%H%M%S")
    csv_filename <- paste0("bfi_results_", timestamp, ".csv")
    
    tryCatch({
        # Create CSV data
        csv_data <- data.frame(
            timestamp = Sys.time(),
            study = "Big Five Personality Assessment",
            session_id = if (!is.null(config) && !is.null(config$study_key)) config$study_key else "unknown"
        )
        
        # Add individual item responses
        for (i in 1:length(responses)) {
            csv_data[[paste0("item_", sprintf("%02d", i))]] <- responses[i]
        }
        
        # Add dimension scores
        dimension_scores <- list(
            Extraversion = mean(responses_scored[1:4], na.rm = TRUE),
            Agreeableness = mean(responses_scored[5:8], na.rm = TRUE),
            Conscientiousness = mean(responses_scored[9:12], na.rm = TRUE),
            Neuroticism = mean(responses_scored[13:16], na.rm = TRUE),
            Openness = mean(responses_scored[17:20], na.rm = TRUE)
        )
        
        for (dim in names(dimension_scores)) {
            csv_data[[paste0("score_", dim)]] <- round(dimension_scores[[dim]], 3)
        }
        
        # Write CSV file
        utils::write.csv(csv_data, csv_filename, row.names = FALSE)
        message("CSV file generated: ", csv_filename)
        
        # Store filename in global environment for download handler
        assign("last_csv_file", csv_filename, envir = .GlobalEnv)
        
    }, error = function(e) {
        message("Failed to generate CSV file: ", e$message)
    })
    
    # Calculate dimension scores (4 items each)
    dimension_scores <- list(
        Extraversion = mean(responses_scored[1:4], na.rm = TRUE),
        Agreeableness = mean(responses_scored[5:8], na.rm = TRUE),
        Conscientiousness = mean(responses_scored[9:12], na.rm = TRUE),
        Neuroticism = mean(responses_scored[13:16], na.rm = TRUE),
        Openness = mean(responses_scored[17:20], na.rm = TRUE)
    )
    
    # Create bar plot - following HilFo approach
    plot_base64 <- ""
    tryCatch({
        # Check if required packages are available
        if (!requireNamespace("ggplot2", quietly = TRUE)) {
            stop("ggplot2 package not available")
        }
        if (!requireNamespace("base64enc", quietly = TRUE)) {
            stop("base64enc package not available")
        }
        
        plot_data <- data.frame(
            Dimension = names(dimension_scores),
            Score = unlist(dimension_scores)
        )
        
        message("Creating plot with data: ", paste(names(dimension_scores), "=", round(unlist(dimension_scores), 2), collapse = ", "))
        
        # Create the plot
        p <- ggplot2::ggplot(plot_data, ggplot2::aes(x = reorder(Dimension, Score), y = Score)) +
            ggplot2::geom_bar(stat = "identity", fill = "#2E8B57", alpha = 0.7) +
            ggplot2::geom_hline(yintercept = 3, linetype = "dashed", color = "red") +
            ggplot2::geom_text(ggplot2::aes(label = sprintf("%.2f", Score)), hjust = -0.2, size = 4) +
            ggplot2::coord_flip() +
            ggplot2::ylim(1, 5.5) +
            ggplot2::labs(title = "Your Big Five Personality Profile",
                         x = "Personality Dimension",
                         y = "Score (1-5)") +
            ggplot2::theme_minimal() +
            ggplot2::theme(plot.title = ggplot2::element_text(hjust = 0.5, size = 16, face = "bold"))
        
        # Save plot to temporary file - following HilFo approach exactly
        temp_file <- tempfile(fileext = ".png")
        
        suppressMessages({
            ggplot2::ggsave(temp_file, p, width = 8, height = 6, dpi = 150, bg = "white")
        })
        
        # Encode file as base64 - following HilFo approach exactly
        if (requireNamespace("base64enc", quietly = TRUE)) {
            plot_base64 <- base64enc::base64encode(temp_file)
        }
        
        # Clean up temp file
        unlink(temp_file)
        
        message("Plot generated successfully, base64 length: ", nchar(plot_base64))
    }, error = function(e) {
        message("Plot generation failed: ", e$message)
        plot_base64 <<- ""
    })
    
    # Create HTML report
    html_report <- paste0(
        '<div id="report-content" style="font-family: Arial, sans-serif; max-width: 900px; margin: 0 auto; padding: 20px;">',
        '<h1 style="color: #2E8B57; text-align: center;">Big Five Personality Assessment Results</h1>',
        
        if (plot_base64 != "" && nchar(plot_base64) > 100) paste0(
            '<div style="margin: 30px 0;">',
            '<img src="data:image/png;base64,', plot_base64, '" style="width: 100%; max-width: 700px; display: block; margin: 20px auto; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1);">',
            '</div>'
        ) else paste0(
            '<div style="margin: 30px 0; padding: 20px; background-color: #f9f9f9; border-radius: 8px; text-align: center;">',
            '<p style="color: #666; font-style: italic;">Visualization not available, but your scores are shown below.</p>',
            '</div>'
        ),
        
        '<div style="background-color: #f5f5f5; padding: 20px; border-radius: 8px; margin: 20px 0;">',
        '<h2 style="color: #2E8B57;">Your Dimension Scores</h2>',
        '<table style="width: 100%; border-collapse: collapse;">',
        '<tr style="background-color: #2E8B57; color: white;">',
        '<th style="padding: 12px; text-align: left;">Dimension</th>',
        '<th style="padding: 12px; text-align: center;">Score</th>',
        '<th style="padding: 12px; text-align: left;">Interpretation</th>',
        '</tr>',
        
        paste0(sapply(names(dimension_scores), function(dim) {
            score <- round(dimension_scores[[dim]], 2)
            interpretation <- if (score >= 3.5) "High" else if (score >= 2.5) "Moderate" else "Low"
            color <- if (score >= 3.5) "#4CAF50" else if (score >= 2.5) "#FFC107" else "#F44336"
            paste0(
                '<tr style="border-bottom: 1px solid #ddd;">',
                '<td style="padding: 12px;"><strong>', dim, '</strong></td>',
                '<td style="padding: 12px; text-align: center;"><span style="background-color:', color, '; color: white; padding: 4px 8px; border-radius: 4px;">', score, '</span></td>',
                '<td style="padding: 12px;">', interpretation, '</td>',
                '</tr>'
            )
        }), collapse = ''),
        
        '</table>',
        '</div>',
        
        '<div style="margin-top: 30px;">',
        '<h2 style="color: #2E8B57;">Thank you for your participation!</h2>',
        '<p>Your responses have been recorded for research purposes.</p>',
        '<p><strong>Note:</strong> Scores range from 1 (low) to 5 (high), with 3 being average.</p>',
        '</div>',
        
        # Add download section
        '<div class="download-section" style="background: #f8f9fa; padding: 20px; border-radius: 5px; margin: 20px 0;">',
        '<h4 style="color: #333; margin-bottom: 15px;">Export Results</h4>',
        '<div style="display: flex; gap: 10px; justify-content: center; flex-wrap: wrap;">',
        
        # PDF Download Button
        '<button onclick="if(typeof Shiny !== \'undefined\') { Shiny.setInputValue(\'download_pdf_trigger\', Math.random(), {priority: \'event\'}); } else { alert(\'Download not available\'); }" class="btn btn-primary" style="background: #2E8B57; border: none; color: white; padding: 12px 24px; border-radius: 6px; cursor: pointer; font-size: 16px; font-weight: 500; transition: all 0.2s ease;">',
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
        '  .report-section { page-break-inside: avoid; }',
        '  h1, h2 { color: #2E8B57 !important; -webkit-print-color-adjust: exact; }',
        '}',
        '</style>',
        '</div>'
    )
    
    # Return as shiny::HTML for proper rendering
    return(shiny::HTML(html_report))
}

# =============================================================================
# STUDY CONFIGURATION
# =============================================================================

session_uuid <- paste0("bfi_", format(Sys.time(), "%Y%m%d_%H%M%S"))

study_config <- create_study_config(
    name = "Big Five Personality Assessment",
    study_key = session_uuid,
    model = "GRM",
    estimation_method = "EAP",
    adaptive = FALSE,  # Using custom_page_flow for sequential sections
    custom_page_flow = custom_page_flow,
    demographics = names(demographic_configs),
    demographic_configs = demographic_configs,
    input_types = input_types,
    theme = "Professional",
    session_save = TRUE,
    language = "en",
    results_processor = create_bfi_report
)

# =============================================================================
# LAUNCH THE STUDY
# =============================================================================

cat("\n")
cat("================================================================================\n")
cat("  BIG FIVE PERSONALITY ASSESSMENT\n")
cat("  5 SEQUENTIAL UNIDIMENSIONAL TESTS\n")
cat("================================================================================\n")
cat("  Structure: 7 pages total\n")
cat("    1. Welcome & Introduction\n")
cat("    2. Extraversion Assessment (4 items)\n")
cat("    3. Agreeableness Assessment (4 items)\n")
cat("    4. Conscientiousness Assessment (4 items)\n")
cat("    5. Neuroticism Assessment (4 items)\n")
cat("    6. Openness Assessment (4 items)\n")
cat("    7. Results with Visualization\n")
cat("  Technical:\n")
cat("    - GRM model with sequential unidimensional tests\n")
cat("    - Item Response Theory (IRT) framework\n")
cat("    - Clean, professional UI design\n")
cat("    - Cloud storage enabled\n")
cat("================================================================================\n")
cat("\n")

launch_study(
    config = study_config,
    item_bank = bfi_items,
    webdav_url = WEBDAV_URL,
    password = WEBDAV_PASSWORD,
    save_format = "csv"
)
