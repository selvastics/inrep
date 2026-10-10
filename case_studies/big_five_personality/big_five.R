# Big Five Personality Assessment ----
# Fixed-form (non-adaptive) administration of the 25 IPIP items in the bfi
# data set of the R packages psych/psychTools (SAPA project; Revelle), five
# items per trait, six response categories. Scale scores are item means after
# reverse coding and are compared with the bfi sample (N = 2800). The bfi
# sample answered on an accuracy scale (very inaccurate to very accurate);
# inrep labels six categories as agreement, so the comparison is approximate.

suppressPackageStartupMessages({
  library(inrep)
  library(ggplot2)
  library(base64enc)
})

# WebDAV storage ----

# Convert public share URL to WebDAV format
# Public share: https://sync.academiccloud.de/index.php/s/TOKEN
# WebDAV endpoint: https://sync.academiccloud.de/public.php/webdav/
# ADAPT THIS FOR YOUR OWN STUDY: the WebDAV address and credentials below are
# this case study's own storage (academiccloud). Replace them with your
# storage - any WebDAV server works, see ?inrep::webdav_upload - and read the
# password from an environment variable instead of writing it here.
WEBDAV_URL <- "https://sync.academiccloud.de/public.php/webdav/"
WEBDAV_PASSWORD <- "inreptest"

# Upload one participant row as CSV to the WebDAV folder
save_to_cloud <- function(data, session_id = NULL, study_name = "BigFive") {
  tryCatch({
    if (is.null(session_id)) {
      session_id <- paste0("BF_", format(Sys.time(), "%Y%m%d_%H%M%S"))
    }
    
    filename <- paste0(study_name, "_", session_id, ".csv")
    cat("\n=== UPLOADING TO CLOUD ===\n")
    cat("Session ID:", session_id, "\n")
    cat("Filename:", filename, "\n")
    
    # Create CSV in memory
    temp_file <- tempfile(fileext = ".csv")
    write.csv(data, temp_file, row.names = FALSE, fileEncoding = "UTF-8")
    
    # Upload using httr::PUT
    response <- httr::PUT(
      url = paste0(WEBDAV_URL, filename),
      body = httr::upload_file(temp_file),
      httr::authenticate("public", WEBDAV_PASSWORD, type = "basic"),
      httr::content_type("text/csv")
    )
    
    unlink(temp_file)
    
    if (httr::status_code(response) %in% c(200, 201, 204)) {
      cat("Upload successful (status", httr::status_code(response), ")\n")
      return(TRUE)
    } else {
      cat("Upload failed (status", httr::status_code(response), ")\n")
      return(FALSE)
    }
  }, error = function(e) {
    cat("Upload error:", e$message, "\n")
    return(FALSE)
  })
}

# Item bank ----
# Item texts and keying as in psychTools::bfi.dictionary. The GRM parameters
# below are placeholders: they are not calibrated and are not used in a
# fixed-form administration.

bfi_items <- data.frame(
  id = c(
    paste0("A", 1:5), paste0("C", 1:5), paste0("E", 1:5),
    paste0("N", 1:5), paste0("O", 1:5)
  ),
  Question = c(
    "Am indifferent to the feelings of others.",
    "Inquire about others' well-being.",
    "Know how to comfort others.",
    "Love children.",
    "Make people feel at ease.",
    "Am exacting in my work.",
    "Continue until everything is perfect.",
    "Do things according to a plan.",
    "Do things in a half-way manner.",
    "Waste my time.",
    "Don't talk a lot.",
    "Find it difficult to approach others.",
    "Know how to captivate people.",
    "Make friends easily.",
    "Take charge.",
    "Get angry easily.",
    "Get irritated easily.",
    "Have frequent mood swings.",
    "Often feel blue.",
    "Panic easily.",
    "Am full of ideas.",
    "Avoid difficult reading material.",
    "Carry the conversation to a higher level.",
    "Spend time reflecting on things.",
    "Will not probe deeply into a subject."
  ),
  dimension = rep(c("Agreeableness", "Conscientiousness", "Extraversion", "Neuroticism", "Openness"), each = 5),
  # Reverse-keyed: A1, C4, C5, E1, E2, O2, O5 (Neuroticism items are all
  # keyed in the direction of Neuroticism)
  reverse_coded = c(TRUE, FALSE, FALSE, FALSE, FALSE,
                    FALSE, FALSE, FALSE, TRUE, TRUE,
                    TRUE, TRUE, FALSE, FALSE, FALSE,
                    FALSE, FALSE, FALSE, FALSE, FALSE,
                    FALSE, TRUE, FALSE, FALSE, TRUE),
  a = c(
    rep(1.20, 5), rep(1.30, 5), rep(1.25, 5), rep(1.35, 5), rep(1.22, 5)
  ),
  b1 = c(
    -2.5, -2.8, -2.6, -2.4, -2.3,
    -2.6, -2.7, -2.5, -2.4, -2.2,
    -2.7, -2.5, -2.6, -2.8, -2.5,
    -2.4, -2.6, -2.3, -2.5, -2.2,
    -2.6, -2.4, -2.5, -2.5, -2.3
  ),
  b2 = c(
    -1.5, -1.7, -1.5, -1.4, -1.3,
    -1.6, -1.6, -1.4, -1.3, -1.2,
    -1.5, -1.3, -1.4, -1.5, -1.4,
    -1.4, -1.5, -1.3, -1.4, -1.3,
    -1.5, -1.3, -1.4, -1.4, -1.2
  ),
  b3 = c(
    -0.3, -0.2, -0.1, -0.2, -0.1,
    -0.2, -0.1, 0.0, 0.1, 0.0,
    -0.1, 0.1, 0.0, -0.1, 0.0,
    0.1, 0.0, 0.2, 0.1, 0.2,
    0.0, 0.2, 0.1, 0.1, 0.3
  ),
  b4 = c(
    0.8, 0.9, 1.0, 0.9, 1.0,
    0.9, 1.0, 1.2, 1.3, 1.1,
    1.0, 1.2, 1.1, 1.0, 1.1,
    1.2, 1.1, 1.4, 1.3, 1.4,
    1.1, 1.3, 1.2, 1.2, 1.4
  ),
  b5 = c(
    1.8, 1.9, 2.0, 2.0, 2.1,
    2.0, 2.1, 2.2, 2.4, 2.2,
    2.1, 2.3, 2.2, 2.1, 2.2,
    2.3, 2.2, 2.5, 2.4, 2.5,
    2.2, 2.4, 2.3, 2.3, 2.5
  ),
  ResponseCategories = "1,2,3,4,5,6",
  stringsAsFactors = FALSE
)

# Row indices per trait, used for the item pages
dimension_indices <- split(seq_len(nrow(bfi_items)), bfi_items$dimension)

# Demographics ----

demographic_configs <- list(
  Age = list(
    question = "How old are you?",
    input_type = "radio",
    options = c(
      "18 or younger" = "1",
      "19-25" = "2",
      "26-35" = "3",
      "36-50" = "4",
      "51 or older" = "5"
    ),
    required = FALSE
  ),
  Gender = list(
    question = "How do you describe your gender?",
    input_type = "radio",
    options = c(
      "Female" = "1",
      "Male" = "2",
      "Non-binary" = "3",
      "Prefer not to say" = "4"
    ),
    required = FALSE
  )
)

input_types <- list(
  Age = "radio",
  Gender = "radio"
)

# Page flow ----

custom_page_flow <- list(
  list(
    id = "intro",
    type = "custom",
    title = "Big Five",
    content = '<div style="max-width: 780px; margin: 0 auto; padding: 24px;">
      <h1 style="color: #2E8B57; text-align: center;">Big Five Personality Assessment</h1>
      <p>This questionnaire contains 25 statements from the International Personality Item Pool (IPIP), five for each of the Big Five traits. Please rate how well each statement describes you on a six-point scale.</p>
      <p>Please respond based on how you usually behave; there are no right or wrong answers.</p>
    </div>'
  ),
  list(
    id = "demographics",
    type = "demographics",
    title = "Background",
    demographics = names(demographic_configs)
  ),
  list(
    id = "agreeableness",
    type = "items",
    title = "Agreeableness",
    instructions = "How well do the statements describe you?",
    item_indices = dimension_indices$Agreeableness,
    scale_type = "likert"
  ),
  list(
    id = "conscientiousness",
    type = "items",
    title = "Conscientiousness",
    instructions = "How well do the statements describe you?",
    item_indices = dimension_indices$Conscientiousness,
    scale_type = "likert"
  ),
  list(
    id = "extraversion",
    type = "items",
    title = "Extraversion",
    instructions = "How well do the statements describe you?",
    item_indices = dimension_indices$Extraversion,
    scale_type = "likert"
  ),
  list(
    id = "neuroticism",
    type = "items",
    title = "Neuroticism",
    instructions = "How well do the statements describe you?",
    item_indices = dimension_indices$Neuroticism,
    scale_type = "likert"
  ),
  list(
    id = "openness",
    type = "items",
    title = "Openness",
    instructions = "How well do the statements describe you?",
    item_indices = dimension_indices$Openness,
    scale_type = "likert"
  ),
  list(
    id = "results",
    type = "results",
    title = "Results",
    results_processor = "create_bfi_report"
  )
)

# Results processor ----

create_bfi_report <- function(responses, item_bank, demographics = NULL, session = NULL) {
  
  # Upload first, so the data are stored even if the report fails
  cat("\nUploading Big Five data\n")
  tryCatch({
    # Get session ID
    session_id <- "unknown"
    if (!is.null(session) && !is.null(session$userData$session_id)) {
      session_id <- session$userData$session_id
    } else if (!is.null(session) && !is.null(session$token)) {
      session_id <- session$token
    } else {
      session_id <- paste0("BF_", format(Sys.time(), "%Y%m%d_%H%M%S"))
    }
    
    # Build upload data
    upload_data <- data.frame(
      session_id = session_id,
      timestamp = as.character(Sys.time()),
      study = "BigFive",
      stringsAsFactors = FALSE
    )
    
    # Add demographics
    if (!is.null(demographics) && length(demographics) > 0) {
      for (demo_name in names(demographics)) {
        upload_data[[demo_name]] <- demographics[[demo_name]]
      }
    }
    
    # Add item responses
    if (!is.null(responses) && length(responses) >= nrow(item_bank)) {
      for (i in 1:nrow(item_bank)) {
        item_id <- as.character(item_bank$id[i])
        upload_data[[item_id]] <- responses[i]
      }
    }
    
    # Compute and add scale scores
    if (!is.null(responses) && length(responses) == nrow(item_bank)) {
      scored <- responses
      scored[item_bank$reverse_coded] <- 7 - scored[item_bank$reverse_coded]
      
      scale_scores <- vapply(split(seq_along(scored), item_bank$dimension), function(idx) {
        mean(scored[idx], na.rm = TRUE)
      }, numeric(1))
      
      upload_data$Agreeableness <- scale_scores["Agreeableness"]
      upload_data$Conscientiousness <- scale_scores["Conscientiousness"]
      upload_data$Extraversion <- scale_scores["Extraversion"]
      upload_data$Neuroticism <- scale_scores["Neuroticism"]
      upload_data$Openness <- scale_scores["Openness"]
    }
    
    # Upload to cloud
    save_to_cloud(upload_data, session_id = session_id, study_name = "BigFive")
    
  }, error = function(e) {
    cat("Upload error:", e$message, "\n")
  })
  
  if (is.null(responses) || length(responses) != nrow(item_bank)) {
    return(shiny::HTML("<div style='max-width: 800px; margin: 0 auto; padding: 24px;'><p>Responses were incomplete. Please restart the questionnaire.</p></div>"))
  }

  scored <- responses
  scored[item_bank$reverse_coded] <- 7 - scored[item_bank$reverse_coded]

  scale_scores <- vapply(split(seq_along(scored), item_bank$dimension), function(idx) {
    mean(scored[idx], na.rm = TRUE)
  }, numeric(1))

  # Reference values: means and SDs of the scale scores (item means after
  # reverse coding, available items) in the bfi data set (psychTools::bfi,
  # N = 2800; mean age 28.78, SD 11.13; 67% female). They apply only to these
  # 25 items with the same six-point response scale.
  bfi_norms <- data.frame(
    Dimension = c("Agreeableness", "Conscientiousness", "Extraversion", "Neuroticism", "Openness"),
    Mean = c(4.65, 4.27, 4.15, 3.16, 4.59),
    SD = c(0.90, 0.95, 1.06, 1.20, 0.81),
    stringsAsFactors = FALSE
  )
  
  # z-scores; percentiles assume normally distributed scale scores
  norm_comparisons <- data.frame(
    Dimension = names(scale_scores),
    Your_Score = round(scale_scores, 2),
    stringsAsFactors = FALSE
  )
  
  for (i in seq_len(nrow(norm_comparisons))) {
    dim_name <- norm_comparisons$Dimension[i]
    norm_row <- bfi_norms[bfi_norms$Dimension == dim_name, ]
    
    if (nrow(norm_row) == 1) {
      z_score <- (norm_comparisons$Your_Score[i] - norm_row$Mean) / norm_row$SD
      norm_comparisons$Z_Score[i] <- round(z_score, 2)
      norm_comparisons$Percentile[i] <- round(pnorm(z_score) * 100, 0)
      norm_comparisons$Norm_Mean[i] <- round(norm_row$Mean, 2)
      norm_comparisons$Norm_SD[i] <- round(norm_row$SD, 2)
      
      # Interpretation
      if (abs(z_score) < 0.5) {
        norm_comparisons$Interpretation[i] <- "Average"
      } else if (z_score >= 0.5 && z_score < 1.0) {
        norm_comparisons$Interpretation[i] <- "Above Average"
      } else if (z_score >= 1.0) {
        norm_comparisons$Interpretation[i] <- "High"
      } else if (z_score <= -0.5 && z_score > -1.0) {
        norm_comparisons$Interpretation[i] <- "Below Average"
      } else {
        norm_comparisons$Interpretation[i] <- "Low"
      }
    }
  }

  # Radar plot (only if the ggradar package is installed)
  radar_base64 <- ""
  
  try({
    # Map the 1-6 scale to 0-1 so that the grid labels 1, 3.5, 6 fit
    to_unit <- function(x) (x - 1) / 5
    radar_data <- data.frame(
      group = "Personality",
      Extraversion = to_unit(scale_scores["Extraversion"]),
      Agreeableness = to_unit(scale_scores["Agreeableness"]),
      Conscientiousness = to_unit(scale_scores["Conscientiousness"]),
      Neuroticism = to_unit(scale_scores["Neuroticism"]),
      Openness = to_unit(scale_scores["Openness"]),
      stringsAsFactors = FALSE
    )
    
    radar_plot <- ggradar::ggradar(
      radar_data,
      values.radar = c("1", "3.5", "6"),
      grid.min = 0,
      grid.mid = 0.5,
      grid.max = 1,
      group.line.width = 1.5,
      group.point.size = 4,
      group.colours = c("#2E8B57"),
      background.circle.colour = "white",
      gridline.mid.colour = "grey",
      legend.position = "none",
      plot.title = ""
    )
    
    temp <- tempfile(fileext = ".png")
    ggplot2::ggsave(temp, radar_plot, width = 8, height = 8, dpi = 150, bg = "white")
    radar_base64 <- base64enc::base64encode(temp)
    unlink(temp)
  }, silent = TRUE)

  html <- paste0(
    '<div style="font-family: -apple-system, BlinkMacSystemFont, \'Segoe UI\', Arial, sans-serif; max-width: 900px; margin: 0 auto; padding: 32px; background: #f8f9fa; border-radius: 8px;">',
    
    # Title
    '<h1 style="color: #2E8B57; text-align: center; margin-bottom: 8px; font-size: 28px;">Your Big Five Personality Profile</h1>',
    '<p style="text-align: center; color: #666; font-size: 14px; margin-bottom: 32px;">Results based on 25 IPIP Big Five items</p>',
    
    # Visualization
    if (nzchar(radar_base64)) paste0(
      '<div style="background: white; padding: 24px; border-radius: 8px; margin-bottom: 32px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">',
      '<img src="data:image/png;base64,', radar_base64, '" style="width: 100%; max-width: 750px; display: block; margin: 0 auto;">',
      '</div>'
    ) else "",
    
    # Scores Table
    '<div style="background: white; padding: 24px; border-radius: 8px; margin-bottom: 32px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">',
    '<h2 style="color: #2E8B57; font-size: 20px; margin-bottom: 16px;">Your Dimension Scores</h2>',
    '<table style="width: 100%; border-collapse: collapse;">',
    '<thead>',
    '<tr style="background: #2E8B57; color: white;">',
    '<th style="padding: 12px; text-align: left; border-radius: 4px 0 0 0;">Dimension</th>',
    '<th style="padding: 12px; text-align: center; border-radius: 0 4px 0 0;">Score (1-6)</th>',
    '</tr>',
    '</thead>',
    '<tbody>',
    paste0(vapply(names(scale_scores), function(dim) {
      score <- sprintf("%.2f", scale_scores[[dim]])
      row_class <- if (match(dim, names(scale_scores)) %% 2 == 0) "background: #f8f9fa;" else "background: white;"
      paste0(
        '<tr style="', row_class, ' border-bottom: 1px solid #e0e0e0;">',
        '<td style="padding: 14px;"><strong>', dim, '</strong></td>',
        '<td style="padding: 14px; text-align: center; font-size: 18px; color: #2E8B57;"><strong>', score, '</strong></td>',
        '</tr>'
      )
    }, character(1)), collapse = ""),
    '</tbody>',
    '</table>',
    '</div>',
    
    # Norm Comparison Table
    '<div style="background: white; padding: 24px; border-radius: 8px; margin-bottom: 32px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">',
    '<h2 style="color: #2E8B57; font-size: 20px; margin-bottom: 12px;">Comparison to Normative Sample</h2>',
    '<p style="color: #666; font-size: 14px; margin-bottom: 16px; line-height: 1.6;">',
    '<strong>Reference group:</strong> Online sample of the SAPA project (N = 2,800), distributed as the bfi data set with the R packages psych and psychTools.<br>',
    '<strong>Demographics:</strong> Mean age 28.78 years (SD = 11.13), 67% female, 33% male.<br>',
    '<strong>Source:</strong> Revelle, W. <em>psychTools: Tools to Accompany the psych Package for Psychological Research</em> (R package). Northwestern University.',
    '</p>',
    '<table style="width: 100%; border-collapse: collapse; font-size: 13px;">',
    '<thead>',
    '<tr style="background: #2E8B57; color: white;">',
    '<th style="padding: 10px; text-align: left;">Dimension</th>',
    '<th style="padding: 10px; text-align: center;">Your Score</th>',
    '<th style="padding: 10px; text-align: center;">Norm Mean</th>',
    '<th style="padding: 10px; text-align: center;">Norm SD</th>',
    '<th style="padding: 10px; text-align: center;">Z-Score</th>',
    '<th style="padding: 10px; text-align: center;">Percentile</th>',
    '<th style="padding: 10px; text-align: center;">Interpretation</th>',
    '</tr>',
    '</thead>',
    '<tbody>',
    paste0(vapply(seq_len(nrow(norm_comparisons)), function(i) {
      row <- norm_comparisons[i, ]
      row_class <- if (i %% 2 == 0) "background: #f8f9fa;" else "background: white;"
      
      # Color code z-score
      z_color <- if (abs(row$Z_Score) < 0.5) "#666" else if (row$Z_Score >= 0.5) "#2E8B57" else "#dc3545"
      
      paste0(
        '<tr style="', row_class, ' border-bottom: 1px solid #e0e0e0;">',
        '<td style="padding: 12px;"><strong>', row$Dimension, '</strong></td>',
        '<td style="padding: 12px; text-align: center;">', row$Your_Score, '</td>',
        '<td style="padding: 12px; text-align: center;">', row$Norm_Mean, '</td>',
        '<td style="padding: 12px; text-align: center;">', row$Norm_SD, '</td>',
        '<td style="padding: 12px; text-align: center; color: ', z_color, '; font-weight: bold;">', 
        ifelse(row$Z_Score > 0, "+", ""), row$Z_Score, '</td>',
        '<td style="padding: 12px; text-align: center;">', row$Percentile, '%</td>',
        '<td style="padding: 12px; text-align: center;"><em>', row$Interpretation, '</em></td>',
        '</tr>'
      )
    }, character(1)), collapse = ""),
    '</tbody>',
    '</table>',
    '<p style="color: #666; font-size: 12px; margin-top: 12px; line-height: 1.5;">',
    '<strong>Understanding the metrics:</strong><br>',
    '<strong>Z-Score:</strong> Number of standard deviations from the norm mean. Values between -0.5 and +0.5 are considered average.<br>',
    '<strong>Percentile:</strong> Approximate percentage of the reference sample scoring below your score, assuming normally distributed scores.<br>',
    '<strong>Note:</strong> The reference values pool all ages and genders. The reference sample is a self-selected online sample, not a representative population sample.',
    '</p>',
    '</div>',
    
    # Debriefing Section
    '<div style="background: white; padding: 24px; border-radius: 8px; margin-bottom: 24px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">',
    '<h2 style="color: #2E8B57; font-size: 20px; margin-bottom: 16px;">Understanding Your Results</h2>',
    
    '<h3 style="color: #2E8B57; font-size: 16px; margin-top: 20px; margin-bottom: 8px;">What is the Big Five?</h3>',
    '<p style="line-height: 1.6; color: #333;">The Big Five model describes personality with five broad dimensions. Your scores show your self-ratings on each dimension.</p>',
    
    '<h3 style="color: #2E8B57; font-size: 16px; margin-top: 20px; margin-bottom: 8px;">The Five Dimensions:</h3>',
    '<ul style="line-height: 1.8; color: #333;">',
    '<li><strong>Agreeableness:</strong> Tendency to be compassionate, cooperative, and kind to others. Higher scores indicate more trusting, helpful, and empathetic behavior.</li>',
    '<li><strong>Conscientiousness:</strong> Degree of organization, dependability, and self-discipline. Higher scores suggest better planning, attention to detail, and goal-directed behavior.</li>',
    '<li><strong>Extraversion:</strong> Energy, assertiveness, and sociability. Higher scores indicate more outgoing, talkative, and enthusiastic tendencies.</li>',
    '<li><strong>Neuroticism:</strong> Emotional stability and tendency to experience negative emotions. Higher scores suggest greater susceptibility to stress, worry, and mood fluctuations.</li>',
    '<li><strong>Openness:</strong> Intellectual curiosity, creativity, and appreciation for new experiences. Higher scores indicate more imaginative, artistic, and open-minded thinking.</li>',
    '</ul>',
    
    '<h3 style="color: #2E8B57; font-size: 16px; margin-top: 20px; margin-bottom: 8px;">Interpreting Your Scores:</h3>',
    '<p style="line-height: 1.6; color: #333;"><strong>Raw scale:</strong> 1 (strongly disagree) to 6 (strongly agree)</p>',
    '<p style="line-height: 1.6; color: #333; margin-top: 8px;">Your scores are compared with a reference sample of 2,800 people. The <strong>z-score</strong> shows how many standard deviations your score lies from the reference mean:</p>',
    '<ul style="line-height: 1.8; color: #333;">',
    '<li><strong>Low (z < -1.0):</strong> Substantially below average for this dimension</li>',
    '<li><strong>Below Average (-1.0 ≤ z < -0.5):</strong> Somewhat lower than typical</li>',
    '<li><strong>Average (-0.5 ≤ z < 0.5):</strong> Within the typical range</li>',
    '<li><strong>Above Average (0.5 ≤ z < 1.0):</strong> Somewhat higher than typical</li>',
    '<li><strong>High (z ≥ 1.0):</strong> Substantially above average for this dimension</li>',
    '</ul>',
    '<p style="line-height: 1.6; color: #333; margin-top: 8px;">The <strong>percentile</strong> indicates what percentage of people scored below you. For example, a percentile of 75 means you scored higher than 75% of the normative sample.</p>',
    
    '<h3 style="color: #2E8B57; font-size: 16px; margin-top: 20px; margin-bottom: 8px;">About the Normative Sample:</h3>',
    '<p style="line-height: 1.6; color: #333;">The reference group consists of 2,800 participants of an online study (SAPA project), with a mean age of 28.78 years. It is a convenience sample, so the comparison is a rough orientation, not a population norm.</p>',
    
    '<h3 style="color: #2E8B57; font-size: 16px; margin-top: 20px; margin-bottom: 8px;">Important Notes:</h3>',
    '<ul style="line-height: 1.8; color: #333;">',
    '<li>There are no "good" or "bad" scores. Each dimension represents a continuum of normal personality variation.</li>',
    '<li>Your scores reflect your self-perception based on how you responded to the questionnaire items.</li>',
    '<li>Personality traits can vary across situations and may change gradually over time.</li>',
    '<li>This assessment provides a snapshot of your current self-reported tendencies compared with the reference sample.</li>',
    '</ul>',
    '</div>',
    
    # Data Privacy
    '<div style="background: #fff3cd; padding: 16px; border-left: 4px solid #ffc107; border-radius: 4px; margin-bottom: 24px;">',
    '<p style="margin: 0; color: #856404; line-height: 1.6;"><strong>Data Privacy:</strong> Data handling depends on how this study is hosted and configured. Review the study information provided by the researcher for details.</p>',
    '</div>',
    
    # Thank You
    '<div style="text-align: center; padding: 24px; background: white; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">',
    '<p style="font-size: 18px; color: #2E8B57; margin: 0;"><strong>Thank you for completing the Big Five Personality Assessment!</strong></p>',
    '</div>',
    
    '</div>'
  )

  shiny::HTML(html)
}

# Configuration and launch ----

session_uuid <- paste0("BF_", format(Sys.time(), "%Y%m%d_%H%M%S"))

study_config <- create_study_config(
  name = "Big Five Personality Assessment",
  study_key = session_uuid,
  model = "GRM",
  adaptive = FALSE,
  custom_page_flow = custom_page_flow,
  demographics = names(demographic_configs),
  demographic_configs = demographic_configs,
  input_types = input_types,
  theme = "Professional",
  language = "en",
  session_save = TRUE,
  results_processor = create_bfi_report
)

launch_study(
  config = study_config,
  item_bank = bfi_items,
  webdav_url = WEBDAV_URL,
  password = WEBDAV_PASSWORD,
  save_format = "csv"
)
