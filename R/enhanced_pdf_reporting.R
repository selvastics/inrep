#' Enhanced PDF Reporting for inrep Package
#' 
#' This module provides smart PDF report generation with automatic plot capture,
#' professional templates, and efficient processing for inrep assessments.
#' 
#' @name enhanced_pdf_reporting
#' @keywords internal
NULL

# Global state for PDF generation
.pdf_state <- new.env()
.pdf_state$plot_cache <- list()
.pdf_state$template_cache <- list()

#' Initialize Enhanced PDF Reporting
#' 
#' Sets up the enhanced PDF reporting system with plot capture capabilities
#' 
#' @param enable_plot_capture Enable automatic plot capture for PDFs
#' @param plot_quality Quality setting for captured plots (1-3, higher = better quality)
#' @param cache_plots Cache captured plots for reuse
#' @param template_dir Directory containing PDF templates
#' @return Configuration for PDF reporting
#' @export
initialize_pdf_reporting <- function(
  enable_plot_capture = TRUE,
  plot_quality = 2,
  cache_plots = TRUE,
  template_dir = NULL
) {
  .pdf_state$enable_plot_capture <- enable_plot_capture
  .pdf_state$plot_quality <- plot_quality
  .pdf_state$cache_plots <- cache_plots
  .pdf_state$template_dir <- template_dir %||% system.file("templates", package = "inrep")
  
  # Check for required packages
  required_packages <- c("rmarkdown", "knitr", "ggplot2")
  optional_packages <- c("webshot", "magick", "plotly")
  
  missing_required <- c()
  for (pkg in required_packages) {
    if (!requireNamespace(pkg, quietly = TRUE)) {
      missing_required <- c(missing_required, pkg)
    }
  }
  
  if (length(missing_required) > 0) {
    warning("Missing required packages for PDF reporting: ", 
            paste(missing_required, collapse = ", "),
            ". Install with: install.packages(c('", 
            paste(missing_required, collapse = "', '"), "'))")
  }
  
  # Check for plot capture packages
  if (enable_plot_capture) {
    if (!requireNamespace("webshot", quietly = TRUE) && 
        !requireNamespace("magick", quietly = TRUE)) {
      warning("No plot capture package available. Install webshot or magick for plot capture.")
      .pdf_state$enable_plot_capture <- FALSE
    }
  }
  
  return(list(
    plot_capture = .pdf_state$enable_plot_capture,
    plot_quality = .pdf_state$plot_quality,
    cache_plots = .pdf_state$cache_plots,
    template_dir = .pdf_state$template_dir
  ))
}

#' Capture Plot as Image
#' 
#' Efficiently captures R plots as high-quality images for PDF inclusion
#' Optimized for minimal processing power and fast generation
#' 
#' @param plot_obj Plot object or expression to capture
#' @param width Image width in pixels
#' @param height Image height in pixels
#' @param dpi Resolution for the image
#' @param format Image format (png, jpeg, svg)
#' @param cache_key Optional cache key for plot reuse
#' @param optimize_for_speed Use faster, lower-quality settings
#' @return Path to captured image file
#' @export
capture_plot <- function(plot_obj, width = 800, height = 600, dpi = 300, 
                        format = "png", cache_key = NULL, optimize_for_speed = TRUE) {
  
  if (!.pdf_state$enable_plot_capture) {
    return(NULL)
  }
  
  # Optimize settings for speed if requested
  if (optimize_for_speed) {
    dpi <- min(dpi, 150)  # Cap DPI for speed
    width <- min(width, 600)  # Cap width for speed
    height <- min(height, 450)  # Cap height for speed
  }
  
  # Generate cache key if not provided
  if (is.null(cache_key)) {
    cache_key <- digest::digest(list(plot_obj, width, height, dpi, format))
  }
  
  # Check cache first
  if (.pdf_state$cache_plots && cache_key %in% names(.pdf_state$plot_cache)) {
    cached_path <- .pdf_state$plot_cache[[cache_key]]
    if (file.exists(cached_path)) {
      return(cached_path)
    }
  }
  
  # Create temporary file
  temp_file <- tempfile(fileext = paste0(".", format))
  
  tryCatch({
    # Use the fastest available method
    if (requireNamespace("magick", quietly = TRUE) && !optimize_for_speed) {
      # Use magick for high-quality capture (slower)
      if (is.function(plot_obj)) {
        plot_obj()
      } else {
        print(plot_obj)
      }
      
      # Capture current device
      dev.copy(png, temp_file, width = width, height = height, res = dpi)
      dev.off()
      
    } else {
      # Use base R for fastest capture
      if (format == "png") {
        png(temp_file, width = width, height = height, res = dpi, 
            type = "cairo", antialias = "default")
      } else if (format == "jpeg") {
        jpeg(temp_file, width = width, height = height, res = dpi, 
             quality = if (optimize_for_speed) 75 else 90)
      } else if (format == "svg") {
        svg(temp_file, width = width/72, height = height/72)
      }
      
      # Render plot
      if (is.function(plot_obj)) {
        plot_obj()
      } else {
        print(plot_obj)
      }
      dev.off()
    }
    
    # Cache the result
    if (.pdf_state$cache_plots) {
      .pdf_state$plot_cache[[cache_key]] <- temp_file
    }
    
    return(temp_file)
    
  }, error = function(e) {
    warning("Failed to capture plot: ", e$message)
    return(NULL)
  })
}

#' Generate Assessment Plots
#' 
#' Creates standard assessment visualizations for PDF reports
#' Optimized for fast generation with minimal processing power
#' 
#' @param cat_result CAT result object
#' @param config Study configuration
#' @param item_bank Item bank data
#' @param plot_types Types of plots to generate
#' @param fast_mode Use fast, simplified plots
#' @return List of plot objects and captured images
#' @export
generate_assessment_plots <- function(cat_result, config, item_bank, 
                                    plot_types = c("progress", "theta_history", "item_difficulty", "response_pattern"),
                                    fast_mode = TRUE) {
  
  plots <- list()
  captured_images <- list()
  
  # Progress plot
  if ("progress" %in% plot_types && config$adaptive) {
    progress_plot <- create_progress_plot(cat_result, fast_mode)
    plots$progress <- progress_plot
    captured_images$progress <- capture_plot(progress_plot, cache_key = "progress", 
                                           optimize_for_speed = fast_mode)
  }
  
  # Theta history plot
  if ("theta_history" %in% plot_types && config$adaptive && !is.null(cat_result$theta_history)) {
    theta_plot <- create_theta_history_plot(cat_result, fast_mode)
    plots$theta_history <- theta_plot
    captured_images$theta_history <- capture_plot(theta_plot, cache_key = "theta_history",
                                                optimize_for_speed = fast_mode)
  }
  
  # Item difficulty plot
  if ("item_difficulty" %in% plot_types) {
    difficulty_plot <- create_item_difficulty_plot(cat_result, item_bank, fast_mode)
    plots$item_difficulty <- difficulty_plot
    captured_images$item_difficulty <- capture_plot(difficulty_plot, cache_key = "item_difficulty",
                                                  optimize_for_speed = fast_mode)
  }
  
  # Response pattern plot
  if ("response_pattern" %in% plot_types) {
    pattern_plot <- create_response_pattern_plot(cat_result, item_bank, fast_mode)
    plots$response_pattern <- pattern_plot
    captured_images$response_pattern <- capture_plot(pattern_plot, cache_key = "response_pattern",
                                                   optimize_for_speed = fast_mode)
  }
  
  return(list(
    plots = plots,
    images = captured_images
  ))
}

#' Create Progress Plot
#' 
#' Creates a progress visualization for adaptive assessments
#' 
#' @param cat_result CAT result object
#' @param fast_mode Use simplified styling for faster rendering
#' @return ggplot2 plot object
create_progress_plot <- function(cat_result, fast_mode = TRUE) {
  if (is.null(cat_result$theta_history) || length(cat_result$theta_history) < 2) {
    return(NULL)
  }
  
  progress_data <- data.frame(
    item = seq_along(cat_result$theta_history),
    theta = cat_result$theta_history,
    se = cat_result$se_history %||% rep(NA, length(cat_result$theta_history))
  )
  
  if (fast_mode) {
    # Simplified plot for speed
    p <- ggplot2::ggplot(progress_data, ggplot2::aes(x = item, y = theta)) +
      ggplot2::geom_line(color = "#007bff", size = 1) +
      ggplot2::theme_minimal() +
      ggplot2::labs(
        title = "Assessment Progress",
        x = "Item Number",
        y = "Ability Estimate (θ)"
      ) +
      ggplot2::theme(
        plot.title = ggplot2::element_text(size = 12, face = "bold"),
        axis.title = ggplot2::element_text(size = 10),
        axis.text = ggplot2::element_text(size = 8)
      )
  } else {
    # Full-featured plot
    p <- ggplot2::ggplot(progress_data, ggplot2::aes(x = item, y = theta)) +
      ggplot2::geom_line(color = "#007bff", size = 1.2) +
      ggplot2::geom_ribbon(ggplot2::aes(ymin = theta - 1.96 * se, ymax = theta + 1.96 * se), 
                          alpha = 0.2, fill = "#007bff") +
      ggplot2::theme_minimal() +
      ggplot2::labs(
        title = "Assessment Progress",
        x = "Item Number",
        y = "Ability Estimate (θ)",
        subtitle = "Confidence intervals shown in light blue"
      ) +
      ggplot2::theme(
        plot.title = ggplot2::element_text(size = 14, face = "bold"),
        axis.title = ggplot2::element_text(size = 12),
        axis.text = ggplot2::element_text(size = 10)
      )
  }
  
  return(p)
}

#' Create Theta History Plot
#' 
#' Creates a detailed theta history visualization
#' 
#' @param cat_result CAT result object
#' @return ggplot2 plot object
create_theta_history_plot <- function(cat_result) {
  if (is.null(cat_result$theta_history) || length(cat_result$theta_history) < 2) {
    return(NULL)
  }
  
  history_data <- data.frame(
    item = seq_along(cat_result$theta_history),
    theta = cat_result$theta_history,
    se = cat_result$se_history %||% rep(NA, length(cat_result$theta_history))
  )
  
  p <- ggplot2::ggplot(history_data, ggplot2::aes(x = item)) +
    ggplot2::geom_line(ggplot2::aes(y = theta), color = "#007bff", size = 1.2) +
    ggplot2::geom_line(ggplot2::aes(y = se), color = "#dc3545", size = 1, linetype = "dashed") +
    ggplot2::theme_minimal() +
    ggplot2::labs(
      title = "Ability Estimation History",
      x = "Item Number",
      y = "Value",
      subtitle = "Blue: Ability estimate, Red: Standard error"
    ) +
    ggplot2::theme(
      plot.title = ggplot2::element_text(size = 14, face = "bold"),
      axis.title = ggplot2::element_text(size = 12),
      axis.text = ggplot2::element_text(size = 10)
    )
  
  return(p)
}

#' Create Item Difficulty Plot
#' 
#' Creates a visualization of item difficulties
#' 
#' @param cat_result CAT result object
#' @param item_bank Item bank data
#' @return ggplot2 plot object
create_item_difficulty_plot <- function(cat_result, item_bank) {
  if (is.null(cat_result$administered) || is.null(item_bank$difficulty)) {
    return(NULL)
  }
  
  administered_items <- item_bank[cat_result$administered, ]
  difficulty_data <- data.frame(
    item = seq_along(administered_items$difficulty),
    difficulty = administered_items$difficulty,
    response = cat_result$responses
  )
  
  p <- ggplot2::ggplot(difficulty_data, ggplot2::aes(x = item, y = difficulty, color = factor(response))) +
    ggplot2::geom_point(size = 3, alpha = 0.7) +
    ggplot2::scale_color_brewer(type = "qual", palette = "Set1", name = "Response") +
    ggplot2::theme_minimal() +
    ggplot2::labs(
      title = "Item Difficulty vs Response Pattern",
      x = "Item Order",
      y = "Item Difficulty",
      subtitle = "Color indicates response value"
    ) +
    ggplot2::theme(
      plot.title = ggplot2::element_text(size = 14, face = "bold"),
      axis.title = ggplot2::element_text(size = 12),
      axis.text = ggplot2::element_text(size = 10),
      legend.position = "bottom"
    )
  
  return(p)
}

#' Create Response Pattern Plot
#' 
#' Creates a visualization of response patterns
#' 
#' @param cat_result CAT result object
#' @param item_bank Item bank data
#' @return ggplot2 plot object
create_response_pattern_plot <- function(cat_result, item_bank) {
  if (is.null(cat_result$responses) || is.null(cat_result$response_times)) {
    return(NULL)
  }
  
  pattern_data <- data.frame(
    item = seq_along(cat_result$responses),
    response = cat_result$responses,
    time = cat_result$response_times
  )
  
  p <- ggplot2::ggplot(pattern_data, ggplot2::aes(x = item, y = time, color = factor(response))) +
    ggplot2::geom_point(size = 3, alpha = 0.7) +
    ggplot2::geom_smooth(method = "loess", se = FALSE, color = "black", alpha = 0.5) +
    ggplot2::scale_color_brewer(type = "qual", palette = "Set2", name = "Response") +
    ggplot2::theme_minimal() +
    ggplot2::labs(
      title = "Response Time Pattern",
      x = "Item Number",
      y = "Response Time (seconds)",
      subtitle = "Color indicates response value, line shows trend"
    ) +
    ggplot2::theme(
      plot.title = ggplot2::element_text(size = 14, face = "bold"),
      axis.title = ggplot2::element_text(size = 12),
      axis.text = ggplot2::element_text(size = 10),
      legend.position = "bottom"
    )
  
  return(p)
}

#' Generate Smart PDF Report
#' 
#' Creates a comprehensive PDF report with automatic plot integration
#' Optimized for minimal processing power and fast generation
#' 
#' @param config Study configuration
#' @param cat_result CAT result object
#' @param item_bank Item bank data
#' @param demographics Demographics data
#' @param output_file Output file path
#' @param template Template name or custom template
#' @param include_plots Include captured plots in PDF
#' @param plot_quality Quality setting for plots
#' @param fast_mode Use fast generation mode with simplified plots
#' @return Path to generated PDF file
#' @export
generate_smart_pdf_report <- function(config, cat_result, item_bank, demographics = NULL, 
                                    output_file = NULL, template = "professional", 
                                    include_plots = TRUE, plot_quality = 2, fast_mode = TRUE) {
  
  if (is.null(output_file)) {
    timestamp <- format(Sys.time(), "%Y%m%d_%H%M%S")
    output_file <- file.path(tempdir(), paste0("inrep_report_", timestamp, ".pdf"))
  }
  
  # Generate plots if requested
  plot_data <- NULL
  if (include_plots && .pdf_state$enable_plot_capture) {
    plot_data <- generate_assessment_plots(cat_result, config, item_bank, fast_mode = fast_mode)
  }
  
  # Create R Markdown content
  rmd_content <- create_pdf_rmd_content(config, cat_result, item_bank, demographics, 
                                       plot_data, template, fast_mode)
  
  # Write R Markdown file
  rmd_file <- tempfile(fileext = ".Rmd")
  writeLines(rmd_content, rmd_file)
  
  # Generate PDF with optimized settings
  tryCatch({
    render_args <- list(
      input = rmd_file,
      output_file = output_file,
      quiet = TRUE,
      envir = new.env()
    )
    
    if (fast_mode) {
      # Use faster PDF generation settings
      render_args$output_format <- rmarkdown::pdf_document(
        toc = FALSE,
        number_sections = FALSE,
        fig_caption = FALSE,
        keep_tex = FALSE,
        latex_engine = "pdflatex"
      )
    } else {
      render_args$output_format <- "pdf_document"
    }
    
    do.call(rmarkdown::render, render_args)
    
    # Clean up
    unlink(rmd_file)
    if (!is.null(plot_data$images)) {
      for (img in plot_data$images) {
        if (!is.null(img) && file.exists(img)) {
          unlink(img)
        }
      }
    }
    
    return(output_file)
    
  }, error = function(e) {
    warning("PDF generation failed: ", e$message)
    return(NULL)
  })
}

#' Create PDF R Markdown Content
#' 
#' Generates R Markdown content for PDF reports
#' 
#' @param config Study configuration
#' @param cat_result CAT result object
#' @param item_bank Item bank data
#' @param demographics Demographics data
#' @param plot_data Plot data and images
#' @param template Template name
#' @param fast_mode Use simplified template for faster generation
#' @return R Markdown content as character string
create_pdf_rmd_content <- function(config, cat_result, item_bank, demographics, 
                                 plot_data, template, fast_mode = TRUE) {
  
  # Get template (use fast template if in fast mode)
  template_name <- if (fast_mode && template == "professional") "fast" else template
  template_content <- get_pdf_template(template_name)
  
  # Prepare data for template
  report_data <- list(
    title = config$name %||% "Assessment Report",
    date = format(Sys.time(), "%B %d, %Y"),
    participant_id = demographics$participant_id %||% "Unknown",
    theta = if (config$adaptive) cat_result$theta else NA,
    se = if (config$adaptive) cat_result$se else NA,
    items_administered = length(cat_result$administered),
    total_items = nrow(item_bank),
    responses = cat_result$responses,
    response_times = cat_result$response_times,
    administered_items = cat_result$administered,
    item_bank = item_bank,
    demographics = demographics,
    plot_data = plot_data,
    config = config
  )
  
  # Replace template placeholders
  content <- template_content
  for (key in names(report_data)) {
    placeholder <- paste0("{{", key, "}}")
    if (grepl(placeholder, content)) {
      content <- gsub(placeholder, format_report_value(report_data[[key]], key), content)
    }
  }
  
  return(content)
}

#' Get PDF Template
#' 
#' Retrieves PDF template content
#' 
#' @param template_name Template name
#' @return Template content as character string
get_pdf_template <- function(template_name) {
  
  # Check cache first
  if (template_name %in% names(.pdf_state$template_cache)) {
    return(.pdf_state$template_cache[[template_name]])
  }
  
  # Fast template for quick generation
  if (template_name == "fast") {
    template <- '
---
title: "{{title}}"
author: "inrep Assessment System"
date: "{{date}}"
output: 
  pdf_document:
    geometry: margin=1in
    fontsize: 10pt
    documentclass: article
    toc: false
    number_sections: false
    fig_caption: false
    keep_tex: false
header-includes:
  - \\usepackage{booktabs}
  - \\usepackage{longtable}
  - \\usepackage{array}
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = FALSE, warning = FALSE, message = FALSE, 
                      fig.width = 6, fig.height = 4, dpi = 150)
```

# Assessment Report

**{{title}}** - {{date}}

## Participant Information

{{if(!is.null(demographics))}}
- **Participant ID**: {{participant_id}}
- **Demographics**: {{demographics}}
{{}}

## Results Summary

{{if(config$adaptive)}}
- **Ability Estimate (θ)**: {{theta}} (SE = {{se}})
{{}}
- **Items Administered**: {{items_administered}} of {{total_items}}
- **Assessment Model**: {{config$model}}

# Visualizations

{{if(!is.null(plot_data) && !is.null(plot_data$images))}}

{{if(!is.null(plot_data$images$progress))}}
## Progress
![Progress]({{plot_data$images$progress}})
{{}}

{{if(!is.null(plot_data$images$theta_history))}}
## Ability History
![History]({{plot_data$images$theta_history}})
{{}}

{{}}

# Item Results

```{r item-results, echo=FALSE}
item_results <- data.frame(
  Item = seq_along({{administered_items}}),
  Question = {{item_bank}}$Question[{{administered_items}}],
  Response = {{responses}},
  Time_Seconds = round({{response_times}}, 1)
)
knitr::kable(item_results, format = "latex", booktabs = TRUE)
```

---
*Generated by inrep Assessment System*
'
  } else if (template_name == "professional") {
    template <- '
---
title: "{{title}}"
author: "inrep Assessment System"
date: "{{date}}"
output: 
  pdf_document:
    geometry: margin=1in
    fontsize: 11pt
    documentclass: article
    toc: true
    number_sections: true
    fig_caption: true
    keep_tex: false
header-includes:
  - \\usepackage{booktabs}
  - \\usepackage{longtable}
  - \\usepackage{array}
  - \\usepackage{multirow}
  - \\usepackage{wrapfig}
  - \\usepackage{float}
  - \\usepackage{colortbl}
  - \\usepackage{pdflscape}
  - \\usepackage{tabu}
  - \\usepackage{threeparttable}
  - \\usepackage{threeparttablex}
  - \\usepackage{makecell}
  - \\usepackage{xcolor}
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = FALSE, warning = FALSE, message = FALSE, 
                      fig.width = 8, fig.height = 6, dpi = 300)
```

# Executive Summary

This report presents the results of the **{{title}}** assessment completed on {{date}}.

## Key Findings

- **Participant ID**: {{participant_id}}
- **Items Administered**: {{items_administered}} of {{total_items}} available
- **Assessment Type**: {{config$model}} model
- **Adaptive Assessment**: {{if(config$adaptive) "Yes" else "No"}}

{{if(config$adaptive)}}
- **Final Ability Estimate (θ)**: {{theta}} (SE = {{se}})
{{}}

# Assessment Details

## Demographics

{{if(!is.null(demographics))}}
```{r demographics-table, echo=FALSE}
if (!is.null(demographics)) {
  demo_df <- data.frame(
    Variable = names(demographics),
    Value = unlist(demographics)
  )
  knitr::kable(demo_df, caption = "Participant Demographics", 
               format = "latex", booktabs = TRUE) %>%
    kableExtra::kable_styling(latex_options = c("striped", "hold_position"))
}
```
{{}}

## Assessment Results

{{if(config$adaptive)}}
The assessment used an adaptive algorithm that selected items based on the participant\'s responses to maximize measurement precision.

**Final Results:**
- Ability Estimate (θ): {{theta}}
- Standard Error: {{se}}
- 95% Confidence Interval: [{{theta - 1.96*se}}, {{theta + 1.96*se}}]

{{}}

# Visualizations

{{if(!is.null(plot_data) && !is.null(plot_data$images))}}

{{if(!is.null(plot_data$images$progress))}}
## Assessment Progress

![Assessment Progress]({{plot_data$images$progress}})

*Figure 1: Shows the progression of ability estimates throughout the assessment.*
{{}}

{{if(!is.null(plot_data$images$theta_history))}}
## Ability Estimation History

![Ability History]({{plot_data$images$theta_history}})

*Figure 2: Detailed view of ability estimation and standard error over time.*
{{}}

{{if(!is.null(plot_data$images$item_difficulty))}}
## Item Difficulty Analysis

![Item Difficulty]({{plot_data$images$item_difficulty}})

*Figure 3: Relationship between item difficulty and participant responses.*
{{}}

{{if(!is.null(plot_data$images$response_pattern))}}
## Response Pattern Analysis

![Response Pattern]({{plot_data$images$response_pattern}})

*Figure 4: Analysis of response times and patterns throughout the assessment.*
{{}}

{{}}

# Item-by-Item Results

```{r item-results, echo=FALSE}
# Create item results table
item_results <- data.frame(
  Item = seq_along({{administered_items}}),
  Question = {{item_bank}}$Question[{{administered_items}}],
  Response = {{responses}},
  Time_Seconds = round({{response_times}}, 1)
)

knitr::kable(item_results, caption = "Individual Item Results", 
             format = "latex", booktabs = TRUE) %>%
  kableExtra::kable_styling(latex_options = c("striped", "hold_position"))
```

# Technical Information

- **Assessment Engine**: inrep v{{packageVersion("inrep")}}
- **IRT Model**: {{config$model}}
- **Language**: {{config$language}}
- **Theme**: {{config$theme}}
- **Report Generated**: {{date}}

---

*This report was automatically generated by the inrep assessment system.*
'
  } else {
    # Load custom template
    template_file <- file.path(.pdf_state$template_dir, paste0(template_name, ".Rmd"))
    if (file.exists(template_file)) {
      template <- readLines(template_file, warn = FALSE)
      template <- paste(template, collapse = "\n")
    } else {
      warning("Template not found: ", template_name, ". Using default template.")
      template <- get_pdf_template("professional")
    }
  }
  
  # Cache template
  .pdf_state$template_cache[[template_name]] <- template
  
  return(template)
}

#' Format Report Value
#' 
#' Formats values for inclusion in report templates
#' 
#' @param value Value to format
#' @param key Key name for context
#' @return Formatted value as character string
format_report_value <- function(value, key) {
  if (is.null(value)) return("N/A")
  
  switch(key,
    "title" = as.character(value),
    "date" = as.character(value),
    "participant_id" = as.character(value),
    "theta" = sprintf("%.3f", value),
    "se" = sprintf("%.3f", value),
    "items_administered" = as.character(value),
    "total_items" = as.character(value),
    "responses" = paste(value, collapse = ", "),
    "response_times" = paste(sprintf("%.1f", value), collapse = ", "),
    "administered_items" = paste(value, collapse = ", "),
    "demographics" = if (is.list(value)) {
      paste(names(value), ":", unlist(value), collapse = "; ")
    } else {
      as.character(value)
    },
    as.character(value)
  )
}

#' Clear PDF Cache
#' 
#' Clears cached plots and templates
#' 
#' @export
clear_pdf_cache <- function() {
  .pdf_state$plot_cache <- list()
  .pdf_state$template_cache <- list()
  invisible(NULL)
}

#' Get PDF Status
#' 
#' Returns current PDF reporting system status
#' 
#' @return List with PDF system status
#' @export
get_pdf_status <- function() {
  list(
    plot_capture_enabled = .pdf_state$enable_plot_capture,
    plot_quality = .pdf_state$plot_quality,
    cache_plots = .pdf_state$cache_plots,
    cached_plots = length(.pdf_state$plot_cache),
    cached_templates = length(.pdf_state$template_cache),
    template_dir = .pdf_state$template_dir
  )
}

#' Generate Fallback PDF Report
#' 
#' Generates a simple PDF report using LaTeX as fallback
#' 
#' @param report_data Report data
#' @param config Study configuration
#' @param item_bank Item bank data
#' @param cat_result CAT result
#' @param demo_data Demographics data
#' @param file Output file path
#' @param logger Logger function
#' @return Invisible NULL
generate_fallback_pdf <- function(report_data, config, item_bank, cat_result, demo_data, file, logger) {
  safe_title <- gsub("[_%&#$]", "\\\\\\0", config$name)
  latex_content <- sprintf('
    \\documentclass{article}
    \\usepackage{geometry}
    \\usepackage{booktabs}
    \\usepackage[utf8]{inputenc}
    \\usepackage{amsmath}
    \\usepackage{fontspec}
    \\setmainfont{Inter}
    \\geometry{margin=0.75in}
    \\begin{document}
    
    \\title{%s}
    \\author{}
    \\date{%s}
    \\maketitle
    
    \\section{Participant Information}
    \\begin{tabular}{ll}
    %s
    \\end{tabular}
    
    \\section{Assessment Results}
    \\begin{itemize}
    %s
        \\item \\textbf{Items Administered}: %d
    \\end{itemize}
    
    \\section{Responses}
    \\begin{table}[h]
    \\centering
    \\small
    \\begin{tabular}{p{5cm}lp{2cm}}
    \\toprule
    \\textbf{Question} & \\textbf{Response} & \\textbf{Time (Sec.)} \\\\
    \\midrule
    %s
    \\bottomrule
    \\end{tabular}
    \\caption{Individual Item Results}
    \\end{table}
    
    \\section{Recommendations}
    \\begin{itemize}
    %s
    \\end{itemize}
    
    \\end{document}
    ',
    safe_title,
    format(Sys.time(), "%B %d, %Y"),
    paste(sapply(names(demo_data), function(d) sprintf("%s & %s \\\\", d, demo_data[d] %||% "N/A")), collapse = "\n"),
    if (config$adaptive) sprintf("\\item \\textbf{Trait Score}: %.2f\n\\item \\textbf{Standard Error}: %.3f", cat_result$theta, cat_result$se) else "",
    length(cat_result$administered),
    paste(sapply(seq_along(cat_result$administered), function(i) {
      sprintf("%s & %s & %.1f \\\\", 
              item_bank$Question[cat_result$administered[i]], 
              cat_result$responses[i],
              cat_result$response_times[i])
    }), collapse = "\n"),
    paste(sprintf("\\item %s", report_data$recommendations), collapse = "\n")
  )
  
  temp_dir <- tempdir()
  tex_file <- file.path(temp_dir, "report.tex")
  writeLines(latex_content, tex_file)
  
  tryCatch({
    if (requireNamespace("tinytex", quietly = TRUE)) {
      tinytex::latexmk(tex_file, "pdflatex")
      file.copy(paste0(tools::file_path_sans_ext(tex_file), ".pdf"), file)
    } else {
      # Fallback to system pdflatex
      system(paste("pdflatex", tex_file), ignore.stdout = TRUE, ignore.stderr = TRUE)
      file.copy(paste0(tools::file_path_sans_ext(tex_file), ".pdf"), file)
    }
  }, error = function(e) {
    logger(sprintf("Fallback PDF generation failed: %s", e$message))
    jsonlite::write_json(report_data, file, pretty = TRUE, auto_unbox = TRUE)
  })
  
  # Clean up
  unlink(tex_file)
  unlink(paste0(tools::file_path_sans_ext(tex_file), c(".pdf", ".log", ".aux")))
  
  invisible(NULL)
}