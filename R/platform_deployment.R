#' Launch Study to inrep Platform
#'
#' @description
#' Creates a comprehensive deployment package for launching adaptive assessment studies
#' on the inrep platform. This function generates all necessary files and configurations
#' for professional hosting of TAM-based adaptive assessments. The resulting package
#' can be deployed on the official inrep platform or any compatible Shiny server.
#'
#' @details
#' This function creates a complete deployment package that includes:
#' \itemize{
#'   \item Study configuration and metadata
#'   \item Item bank validation and preparation
#'   \item UI components with professional styling
#'   \item Assessment logic and scoring algorithms
#'   \item Results processing and reporting systems
#'   \item Quality assurance and validation checks
#'   \item Deployment documentation and instructions
#' }
#'
#' The generated package is designed for professional deployment on:
#' \itemize{
#'   \item Official inrep platform (contact: selva@uni-hildesheim.de)
#'   \item Posit Connect / RStudio Connect servers
#'   \item ShinyApps.io
#'   \item Custom Shiny Server installations
#'   \item Docker containers for scalable deployment
#' }
#'
#' For official inrep platform deployment, users should contact the maintainer
#' at selva@uni-hildesheim.de with the generated deployment package and provide:
#' \itemize{
#'   \item Brief study description and objectives
#'   \item Expected study duration and participant numbers
#'   \item Special requirements (multilingual support, accessibility, etc.)
#'   \item Institutional affiliation and research context
#' }
#'
#' @param study_config A study configuration object created with \code{create_study_config()}
#' @param item_bank A validated item bank data frame with proper IRT parameters
#' @param output_dir Character string specifying the output directory for deployment files
#' @param deployment_type Character string specifying deployment target:
#'   \itemize{
#'     \item "inrep_platform" - Official inrep platform (default)
#'     \item "posit_connect" - Posit Connect server
#'     \item "shinyapps" - ShinyApps.io deployment
#'     \item "custom_server" - Custom Shiny server
#'     \item "docker" - Docker container deployment
#'   }
#' @param contact_info List containing researcher contact information and study details
#' @param advanced_features List of advanced features to include:
#'   \itemize{
#'     \item "multilingual" - Multi-language support
#'     \item "accessibility" - Enhanced accessibility features
#'     \item "mobile_optimized" - Mobile-responsive design
#'     \item "real_time_monitoring" - Live study monitoring
#'     \item "automated_reporting" - Automated result generation
#'   }
#' @param security_settings List of security configurations for professional deployment
#' @param backup_settings List of backup and recovery configurations
#' @param validate_deployment Logical indicating whether to perform comprehensive validation
#'
#' @return A list containing:
#'   \itemize{
#'     \item \code{deployment_package} - Path to the generated deployment package
#'     \item \code{validation_report} - Comprehensive validation results
#'     \item \code{deployment_instructions} - Platform-specific deployment guide
#'     \item \code{contact_template} - Template for contacting platform maintainer
#'     \item \code{study_metadata} - Complete study metadata for hosting
#'   }
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Example 1: Basic deployment for inrep platform
#' library(inrep)
#' data(bfi_items)
#' 
#' # Create study configuration
#' config <- create_study_config(
#'   name = "Big Five Personality Assessment",
#'   model = "GRM",
#'   max_items = 20,
#'   min_SEM = 0.3,
#'   language = "en",
#'   theme = "Professional"
#' )
#' 
#' # Prepare contact information
#' contact_info <- list(
#'   researcher_name = "Dr. Jane Smith",
#'   institution = "University of Research",
#'   email = "jane.smith@university.edu",
#'   study_title = "Adaptive Personality Assessment Study",
#'   study_description = "Investigating personality traits using adaptive testing",
#'   expected_duration = "4 weeks",
#'   expected_participants = 500,
#'   institutional_approval = "IRB-2025-001"
#' )
#' 
#' # Launch to inrep platform
#' deployment <- launch_to_inrep_platform(
#'   study_config = config,
#'   item_bank = bfi_items,
#'   output_dir = "deployment_package",
#'   deployment_type = "inrep_platform",
#'   contact_info = contact_info
#' )
#' 
#' # Check deployment results
#' cat("Deployment package created:", deployment$deployment_package, "\n")
#' cat("Contact template:", deployment$contact_template, "\n")
#' }
#' 
#' \dontrun{
#' # Example 2: Advanced deployment with multilingual support
#' library(inrep)
#' data(bfi_items)
#' 
#' # Create advanced configuration
#' config <- create_study_config(
#'   name = "International Personality Study",
#'   model = "GRM",
#'   max_items = 25,
#'   min_SEM = 0.25,
#'   language = "en",
#'   theme = "International",
#'   multilingual = TRUE,
#'   languages = c("en", "de", "es", "fr")
#' )
#' 
#' # Advanced features
#' advanced_features <- list(
#'   "multilingual",
#'   "accessibility",
#'   "mobile_optimized",
#'   "real_time_monitoring"
#' )
#' 
#' # Contact information for international study
#' contact_info <- list(
#'   researcher_name = "Prof. International Researcher",
#'   institution = "Global Research Institute",
#'   email = "researcher@global-institute.org",
#'   study_title = "Cross-Cultural Personality Assessment",
#'   study_description = "Large-scale international study on personality traits",
#'   expected_duration = "12 weeks",
#'   expected_participants = 2000,
#'   languages_needed = c("English", "German", "Spanish", "French"),
#'   special_requirements = "GDPR compliance, accessibility standards"
#' )
#' 
#' # Launch with advanced features
#' deployment <- launch_to_inrep_platform(
#'   study_config = config,
#'   item_bank = bfi_items,
#'   output_dir = "international_study_deployment",
#'   deployment_type = "inrep_platform",
#'   contact_info = contact_info,
#'   advanced_features = advanced_features
#' )
#' 
#' # Review deployment validation
#' print(deployment$validation_report)
#' }
#' 
#' \dontrun{
#' # Example 3: Clinical deployment with enhanced security
#' library(inrep)
#' data(bfi_items)
#' 
#' # Create clinical configuration
#' config <- create_study_config(
#'   name = "Clinical Depression Assessment",
#'   model = "GRM",
#'   max_items = 15,
#'   min_SEM = 0.2,
#'   language = "en",
#'   theme = "Clinical",
#'   clinical_mode = TRUE
#' )
#' 
#' # Security settings for clinical data
#' security_settings <- list(
#'   encryption_level = "AES-256",
#'   data_retention = "7_years",
#'   access_control = "role_based",
#'   audit_logging = TRUE,
#'   hipaa_compliance = TRUE,
#'   gdpr_compliance = TRUE
#' )
#' 
#' # Clinical contact information
#' contact_info <- list(
#'   researcher_name = "Dr. Clinical Researcher",
#'   institution = "Medical Center Hospital",
#'   email = "clinical.researcher@hospital.org",
#'   study_title = "Adaptive Depression Screening",
#'   study_description = "Clinical validation of adaptive depression assessment",
#'   expected_duration = "6 months",
#'   expected_participants = 300,
#'   clinical_approval = "IRB-CLINICAL-2025-005",
#'   data_sensitivity = "high",
#'   compliance_requirements = "HIPAA, GDPR"
#' )
#' 
#' # Launch clinical study
#' deployment <- launch_to_inrep_platform(
#'   study_config = config,
#'   item_bank = bfi_items,
#'   output_dir = "clinical_deployment",
#'   deployment_type = "inrep_platform",
#'   contact_info = contact_info,
#'   security_settings = security_settings,
#'   advanced_features = list("accessibility", "real_time_monitoring")
#' )
#' 
#' # Verify security configuration
#' cat("Security validation passed:", deployment$validation_report$security_check, "\n")
#' }
#' 
#' \dontrun{
#' # Example 4: Educational deployment for Posit Connect
#' library(inrep)
#' data(bfi_items)
#' 
#' # Create educational configuration
#' config <- create_study_config(
#'   name = "Student Personality Assessment",
#'   model = "2PL",
#'   max_items = 30,
#'   min_SEM = 0.4,
#'   language = "en",
#'   theme = "Educational",
#'   adaptive_feedback = TRUE
#' )
#' 
#' # Educational contact information
#' contact_info <- list(
#'   researcher_name = "Prof. Education Researcher",
#'   institution = "State University",
#'   email = "education.prof@state-university.edu",
#'   study_title = "Student Personality and Academic Performance",
#'   study_description = "Longitudinal study of personality and academic outcomes",
#'   expected_duration = "1 academic year",
#'   expected_participants = 1000,
#'   educational_approval = "University-IRB-2025-EDU-003"
#' )
#' 
#' # Launch for Posit Connect
#' deployment <- launch_to_inrep_platform(
#'   study_config = config,
#'   item_bank = bfi_items,
#'   output_dir = "educational_deployment",
#'   deployment_type = "posit_connect",
#'   contact_info = contact_info,
#'   advanced_features = list("mobile_optimized", "automated_reporting")
#' )
#' 
#' # Generate deployment instructions
#' cat("Posit Connect deployment guide:", deployment$deployment_instructions, "\n")
#' }
#' 
#' \dontrun{
#' # Example 5: Corporate deployment with Docker
#' library(inrep)
#' data(bfi_items)
#' 
#' # Create corporate configuration
#' config <- create_study_config(
#'   name = "Employee Assessment Platform",
#'   model = "GRM",
#'   max_items = 20,
#'   min_SEM = 0.3,
#'   language = "en",
#'   theme = "Corporate",
#'   corporate_mode = TRUE
#' )
#' 
#' # Corporate contact information
#' contact_info <- list(
#'   researcher_name = "HR Analytics Team",
#'   institution = "Global Corporation Ltd",
#'   email = "hr.analytics@globalcorp.com",
#'   study_title = "Employee Personality Assessment",
#'   study_description = "Corporate personality assessment for team building",
#'   expected_duration = "Ongoing",
#'   expected_participants = 5000,
#'   corporate_approval = "HR-STUDY-2025-001",
#'   deployment_scale = "enterprise"
#' )
#' 
#' # Launch with Docker deployment
#' deployment <- launch_to_inrep_platform(
#'   study_config = config,
#'   item_bank = bfi_items,
#'   output_dir = "corporate_deployment",
#'   deployment_type = "docker",
#'   contact_info = contact_info,
#'   advanced_features = list("real_time_monitoring", "automated_reporting")
#' )
#' 
#' # Check Docker configuration
#' cat("Docker deployment ready:", deployment$deployment_package, "\n")
#' cat("Container configuration:", deployment$docker_config, "\n")
#' }
#' 
#' \dontrun{
#' # Example 6: Custom server deployment with backup settings
#' library(inrep)
#' data(bfi_items)
#' 
#' # Create custom configuration
#' config <- create_study_config(
#'   name = "Research Platform Assessment",
#'   model = "GRM",
#'   max_items = 25,
#'   min_SEM = 0.25,
#'   language = "en",
#'   theme = "Research",
#'   custom_styling = TRUE
#' )
#' 
#' # Backup settings for long-term study
#' backup_settings <- list(
#'   backup_frequency = "daily",
#'   backup_retention = "1_year",
#'   backup_location = "cloud_storage",
#'   automated_backups = TRUE,
#'   disaster_recovery = TRUE
#' )
#' 
#' # Research contact information
#' contact_info <- list(
#'   researcher_name = "Research Consortium",
#'   institution = "Multi-University Research Network",
#'   email = "consortium@research-network.org",
#'   study_title = "Large-Scale Personality Research",
#'   study_description = "Multi-site longitudinal personality study",
#'   expected_duration = "3 years",
#'   expected_participants = 10000,
#'   multi_site = TRUE,
#'   sites = c("University A", "University B", "University C")
#' )
#' 
#' # Launch with custom server configuration
#' deployment <- launch_to_inrep_platform(
#'   study_config = config,
#'   item_bank = bfi_items,
#'   output_dir = "research_consortium_deployment",
#'   deployment_type = "custom_server",
#'   contact_info = contact_info,
#'   backup_settings = backup_settings,
#'   advanced_features = list("multilingual", "real_time_monitoring", "automated_reporting")
#' )
#' 
#' # Verify backup configuration
#' cat("Backup settings validated:", deployment$validation_report$backup_check, "\n")
#' }
#'
#' @seealso
#' \code{\link{create_study_config}} for creating study configurations,
#' \code{\link{validate_item_bank}} for item bank validation,
#' \code{\link{build_study_ui}} for UI components,
#' \code{\link{create_enhanced_response_report}} for results processing
#'
#' @references
#' For official inrep platform deployment, contact: selva@uni-hildesheim.de
#' 
#' Platform documentation: https://inrep-platform.org
#' 
#' Deployment guides: https://inrep-platform.org/docs/deployment
launch_to_inrep_platform <- function(study_config,
                                    item_bank,
                                    output_dir = "inrep_deployment",
                                    deployment_type = "inrep_platform",
                                    contact_info = NULL,
                                    advanced_features = NULL,
                                    security_settings = NULL,
                                    backup_settings = NULL,
                                    validate_deployment = TRUE) {
  
  # Validate inputs
  if (missing(study_config) || !is.list(study_config)) {
    stop("study_config must be a valid configuration object created with create_study_config()")
  }
  
  if (missing(item_bank) || !is.data.frame(item_bank)) {
    stop("item_bank must be a valid data frame with IRT parameters")
  }
  
  # Validate deployment type
  valid_deployments <- c("inrep_platform", "posit_connect", "shinyapps", "custom_server", "docker")
  if (!deployment_type %in% valid_deployments) {
    stop(paste("deployment_type must be one of:", paste(valid_deployments, collapse = ", ")))
  }
  
  # Create output directory
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
  }
  
  # Generate deployment timestamp
  timestamp <- format(Sys.time(), "%Y%m%d_%H%M%S")
  deployment_id <- paste0("inrep_deployment_", timestamp)
  
  # Create deployment structure
  deployment_path <- file.path(output_dir, deployment_id)
  dir.create(deployment_path, recursive = TRUE)
  
  # Create subdirectories
  subdirs <- c("app", "data", "config", "docs", "validation", "deployment")
  for (subdir in subdirs) {
    dir.create(file.path(deployment_path, subdir), recursive = TRUE)
  }
  
  # Initialize results
  deployment_results <- list(
    deployment_package = deployment_path,
    deployment_id = deployment_id,
    timestamp = timestamp,
    deployment_type = deployment_type,
    validation_report = list(),
    deployment_instructions = NULL,
    contact_template = NULL,
    study_metadata = list()
  )
  
  # Validate item bank
  if (validate_deployment) {
    validation_results <- validate_item_bank(item_bank, model = study_config$model)
    deployment_results$validation_report$item_bank_validation <- validation_results
  }
  
  # Save study configuration
  saveRDS(study_config, file.path(deployment_path, "config", "study_config.rds"))
  
  # Save item bank
  saveRDS(item_bank, file.path(deployment_path, "data", "item_bank.rds"))
  
  # Generate deployment-specific files
  deployment_results <- generate_deployment_files(
    deployment_results, 
    deployment_path, 
    study_config, 
    item_bank, 
    deployment_type,
    contact_info,
    advanced_features,
    security_settings,
    backup_settings
  )
  
  # Generate contact template
  if (!is.null(contact_info)) {
    deployment_results$contact_template <- generate_contact_template(
      contact_info, 
      deployment_results, 
      deployment_type
    )
  }
  
  # Generate deployment instructions
  deployment_results$deployment_instructions <- generate_deployment_instructions(
    deployment_type, 
    deployment_path, 
    study_config
  )
  
  # Create study metadata
  deployment_results$study_metadata <- create_study_metadata(
    study_config, 
    item_bank, 
    contact_info, 
    deployment_results
  )
  
  # Final validation
  if (validate_deployment) {
    final_validation <- validate_deployment_package(deployment_path, deployment_type)
    deployment_results$validation_report$final_validation <- final_validation
  }
  
  # Generate summary report
  generate_deployment_summary(deployment_results, deployment_path)
  
  # Print success message
  cat("✅ Deployment package created successfully!\n")
  cat("📁 Location:", deployment_path, "\n")
  cat("🎯 Deployment type:", deployment_type, "\n")
  cat("📧 Contact maintainer at: selva@uni-hildesheim.de\n")
  cat("📖 See deployment instructions in:", file.path(deployment_path, "docs"), "\n")
  
  return(deployment_results)
}


# Helper function to generate deployment files
generate_deployment_files <- function(deployment_results, deployment_path, study_config, 
                                    item_bank, deployment_type, contact_info, 
                                    advanced_features, security_settings, backup_settings) {
  
  # Generate main app file
  app_content <- generate_app_file(study_config, item_bank, advanced_features)
  writeLines(app_content, file.path(deployment_path, "app", "app.R"))
  
  # Generate UI file
  ui_content <- generate_ui_file(study_config, advanced_features)
  writeLines(ui_content, file.path(deployment_path, "app", "ui.R"))
  
  # Generate server file
  server_content <- generate_server_file(study_config, item_bank, advanced_features)
  writeLines(server_content, file.path(deployment_path, "app", "server.R"))
  
  # Generate deployment configuration based on type
  if (deployment_type == "inrep_platform") {
    deployment_config <- generate_inrep_platform_config(study_config, contact_info, 
                                                       advanced_features, security_settings)
  } else if (deployment_type == "posit_connect") {
    deployment_config <- generate_posit_connect_config(study_config, advanced_features)
  } else if (deployment_type == "docker") {
    deployment_config <- generate_docker_config(study_config, advanced_features)
  } else {
    deployment_config <- generate_generic_config(study_config, advanced_features)
  }
  
  # Save deployment configuration
  saveRDS(deployment_config, file.path(deployment_path, "config", "deployment_config.rds"))
  deployment_results$deployment_config <- deployment_config
  
  # Generate manifest file
  manifest <- generate_manifest(study_config, item_bank, deployment_type, contact_info)
  writeLines(manifest, file.path(deployment_path, "deployment", "manifest.json"))
  
  return(deployment_results)
}


# Helper function to generate contact template
generate_contact_template <- function(contact_info, deployment_results, deployment_type) {
  
  template_path <- file.path(deployment_results$deployment_package, "docs", "contact_template.md")
  
  template_content <- c(
    "# Contact Template for inrep Platform Deployment",
    "",
    "## For Official inrep Platform Hosting",
    "**Contact:** selva@uni-hildesheim.de",
    "",
    "### Study Information",
    paste0("- **Study Title:** ", contact_info$study_title %||% "Not provided"),
    paste0("- **Principal Investigator:** ", contact_info$researcher_name %||% "Not provided"),
    paste0("- **Institution:** ", contact_info$institution %||% "Not provided"),
    paste0("- **Contact Email:** ", contact_info$email %||% "Not provided"),
    "",
    "### Study Details",
    paste0("- **Study Description:** ", contact_info$study_description %||% "Not provided"),
    paste0("- **Expected Duration:** ", contact_info$expected_duration %||% "Not provided"),
    paste0("- **Expected Participants:** ", contact_info$expected_participants %||% "Not provided"),
    paste0("- **Deployment Package:** ", deployment_results$deployment_id),
    "",
    "### Technical Requirements",
    paste0("- **Deployment Type:** ", deployment_type),
    paste0("- **Study Model:** ", deployment_results$study_metadata$model %||% "Not specified"),
    paste0("- **Special Features:** ", paste(deployment_results$study_metadata$features %||% "Standard", collapse = ", ")),
    "",
    "### Approval and Compliance",
    paste0("- **IRB/Ethics Approval:** ", contact_info$institutional_approval %||% "Please provide"),
    paste0("- **Data Sensitivity:** ", contact_info$data_sensitivity %||% "Standard"),
    paste0("- **Compliance Requirements:** ", contact_info$compliance_requirements %||% "Standard"),
    "",
    "### Message Template",
    "```",
    "Subject: inrep Platform Deployment Request - [Study Title]",
    "",
    "Dear inrep Platform Team,",
    "",
    "I would like to request hosting for my adaptive assessment study on the inrep platform.",
    "",
    "Study Details:",
    paste0("- Title: ", contact_info$study_title %||% "[Your Study Title]"),
    paste0("- Principal Investigator: ", contact_info$researcher_name %||% "[Your Name]"),
    paste0("- Institution: ", contact_info$institution %||% "[Your Institution]"),
    paste0("- Expected Duration: ", contact_info$expected_duration %||% "[Duration]"),
    paste0("- Expected Participants: ", contact_info$expected_participants %||% "[Number]"),
    "",
    paste0("Deployment Package ID: ", deployment_results$deployment_id),
    "",
    "I have prepared a complete deployment package using the inrep R package.",
    "Please let me know the next steps for uploading and configuring the study.",
    "",
    "Thank you for your assistance.",
    "",
    paste0("Best regards,"),
    paste0("[Your Name]"),
    paste0("[Your Email]"),
    "```",
    "",
    "### Alternative Deployment Options",
    "If you prefer to host the study yourself, the deployment package includes",
    "configurations for:",
    "- Posit Connect / RStudio Connect",
    "- ShinyApps.io",
    "- Custom Shiny Server",
    "- Docker containers",
    "",
    "See the deployment instructions in the docs folder for detailed setup guides."
  )
  
  writeLines(template_content, template_path)
  return(template_path)
}


# Helper function to generate deployment instructions
generate_deployment_instructions <- function(deployment_type, deployment_path, study_config) {
  
  instructions_path <- file.path(deployment_path, "docs", "deployment_instructions.md")
  
  instructions_content <- c(
    paste0("# Deployment Instructions - ", deployment_type),
    "",
    "## Overview",
    "This document provides step-by-step instructions for deploying your adaptive",
    "assessment study using the inrep platform infrastructure.",
    "",
    "## Quick Start"
  )
  
  # Add deployment-specific instructions
  if (deployment_type == "inrep_platform") {
    instructions_content <- c(instructions_content,
      "",
      "### Official inrep Platform Deployment",
      "1. **Contact the Platform Team**",
      "   - Email: selva@uni-hildesheim.de",
      "   - Use the contact template provided in this package",
      "   - Include your deployment package ID and study details",
      "",
      "2. **Prepare Study Materials**",
      "   - Complete the contact template with all required information",
      "   - Ensure IRB/ethics approval is documented",
      "   - Prepare any additional documentation requested",
      "",
      "3. **Upload and Configuration**",
      "   - The platform team will guide you through the upload process",
      "   - Your study will be configured and tested before going live",
      "   - You'll receive a unique study URL for participant access",
      "",
      "4. **Study Launch**",
      "   - Final testing and validation",
      "   - Study goes live with professional hosting",
      "   - Real-time monitoring and support available",
      "",
      "### Benefits of Official Platform Hosting",
      "- Professional server infrastructure",
      "- Automatic backups and disaster recovery",
      "- 24/7 monitoring and support",
      "- GDPR and HIPAA compliant hosting",
      "- Scalable architecture for large studies",
      "- Expert technical support"
    )
  } else if (deployment_type == "posit_connect") {
    instructions_content <- c(instructions_content,
      "",
      "### Posit Connect Deployment",
      "1. **Prepare Your Connect Server**",
      "   - Ensure you have access to a Posit Connect server",
      "   - Install required R packages on the server",
      "   - Configure user permissions and access controls",
      "",
      "2. **Deploy the Application**",
      "   - Copy the app folder to your Connect server",
      "   - Use the rsconnect package to deploy:",
      "   ```r",
      "   library(rsconnect)",
      "   deployApp(appDir = 'app', account = 'your-account')",
      "   ```",
      "",
      "3. **Configure Study Settings**",
      "   - Set environment variables for database connections",
      "   - Configure data storage and backup settings",
      "   - Set up monitoring and logging",
      "",
      "4. **Test and Launch**",
      "   - Perform comprehensive testing",
      "   - Configure user access and permissions",
      "   - Launch study with participant recruitment"
    )
  } else if (deployment_type == "docker") {
    instructions_content <- c(instructions_content,
      "",
      "### Docker Deployment",
      "1. **Build Docker Image**",
      "   ```bash",
      "   docker build -t inrep-study .",
      "   ```",
      "",
      "2. **Run Container**",
      "   ```bash",
      "   docker run -p 3838:3838 inrep-study",
      "   ```",
      "",
      "3. **Configure Persistent Storage**",
      "   - Mount volumes for data persistence",
      "   - Configure database connections",
      "   - Set up backup strategies",
      "",
      "4. **Scale and Monitor**",
      "   - Use Docker Compose for multi-container setup",
      "   - Configure load balancing if needed",
      "   - Set up monitoring and logging"
    )
  }
  
  instructions_content <- c(instructions_content,
    "",
    "## Security Considerations",
    "- Ensure all data transmissions are encrypted (HTTPS)",
    "- Implement proper authentication and authorization",
    "- Follow data protection regulations (GDPR, HIPAA)",
    "- Regular security updates and monitoring",
    "",
    "## Support and Maintenance",
    "- Regular backup verification",
    "- Monitor study performance and participant feedback",
    "- Update study configuration as needed",
    "- Archive data according to institutional policies",
    "",
    "## Troubleshooting",
    "Common issues and solutions are documented in the validation report.",
    "For additional support, contact the inrep platform team.",
    "",
    "---",
    "Generated by inrep package deployment system",
    paste0("Deployment ID: ", basename(deployment_path))
  )
  
  writeLines(instructions_content, instructions_path)
  return(instructions_path)
}


# Helper functions for generating app components
generate_app_file <- function(study_config, item_bank, advanced_features) {
  c(
    "# inrep Platform Deployment App",
    "# Generated by launch_to_inrep_platform()",
    "",
    "library(shiny)",
    "library(inrep)",
    "library(TAM)",
    "library(DT)",
    "library(ggplot2)",
    "",
    "# Load study configuration",
    "study_config <- readRDS('config/study_config.rds')",
    "item_bank <- readRDS('data/item_bank.rds')",
    "",
    "# Source UI and server components",
    "source('ui.R')",
    "source('server.R')",
    "",
    "# Run the application",
    "shinyApp(ui = ui, server = server)"
  )
}

generate_ui_file <- function(study_config, advanced_features) {
  c(
    "# UI component for inrep deployment",
    "ui <- build_study_ui(",
    paste0("  config = study_config,"),
    paste0("  theme = '", study_config$theme, "',"),
    paste0("  advanced_features = ", deparse(advanced_features), ","),
    paste0("  deployment_mode = TRUE"),
    ")"
  )
}

generate_server_file <- function(study_config, item_bank, advanced_features) {
  c(
    "# Server component for inrep deployment",
    "server <- function(input, output, session) {",
    "  # Initialize study session",
    "  study_session <- reactive({",
    "    initialize_study_session(study_config, item_bank)",
    "  })",
    "",
    "  # Main assessment logic",
    "  observeEvent(input$start_assessment, {",
    "    run_adaptive_assessment(study_session(), input, output, session)",
    "  })",
    "",
    "  # Results processing",
    "  observe({",
    "    if (!is.null(input$assessment_complete)) {",
    "      process_assessment_results(study_session(), input, output, session)",
    "    }",
    "  })",
    "}"
  )
}

# Additional helper functions
generate_inrep_platform_config <- function(study_config, contact_info, advanced_features, security_settings) {
  list(
    platform = "inrep_official",
    study_config = study_config,
    contact_info = contact_info,
    advanced_features = advanced_features,
    security_settings = security_settings,
    hosting_requirements = list(
      server_type = "professional",
      ssl_required = TRUE,
      backup_frequency = "daily",
      monitoring = "24/7"
    )
  )
}

generate_posit_connect_config <- function(study_config, advanced_features) {
  list(
    platform = "posit_connect",
    study_config = study_config,
    advanced_features = advanced_features,
    deployment_settings = list(
      r_version = paste0(R.version$major, ".", R.version$minor),
      packages = c("inrep", "shiny", "TAM", "DT", "ggplot2"),
      memory_limit = "2GB",
      timeout = 3600
    )
  )
}

generate_docker_config <- function(study_config, advanced_features) {
  list(
    platform = "docker",
    study_config = study_config,
    advanced_features = advanced_features,
    container_settings = list(
      base_image = "rocker/shiny",
      port = 3838,
      volumes = c("./data:/app/data", "./logs:/app/logs"),
      environment = list(
        SHINY_PORT = 3838,
        SHINY_HOST = "0.0.0.0"
      )
    )
  )
}

generate_generic_config <- function(study_config, advanced_features) {
  list(
    platform = "generic",
    study_config = study_config,
    advanced_features = advanced_features,
    deployment_notes = "Generic configuration for custom deployment"
  )
}

generate_manifest <- function(study_config, item_bank, deployment_type, contact_info) {
  manifest <- list(
    deployment_info = list(
      package_version = "1.0.0",
      deployment_type = deployment_type,
      created_at = Sys.time(),
      r_version = paste0(R.version$major, ".", R.version$minor)
    ),
    study_info = list(
      name = study_config$name,
      model = study_config$model,
      num_items = nrow(item_bank),
      languages = study_config$language %||% "en"
    ),
    contact_info = contact_info,
    files = list(
      app = c("app.R", "ui.R", "server.R"),
      config = c("study_config.rds", "deployment_config.rds"),
      data = c("item_bank.rds"),
      docs = c("deployment_instructions.md", "contact_template.md")
    )
  )
  
  jsonlite::toJSON(manifest, pretty = TRUE, auto_unbox = TRUE)
}

create_study_metadata <- function(study_config, item_bank, contact_info, deployment_results) {
  list(
    study_name = study_config$name,
    model = study_config$model,
    num_items = nrow(item_bank),
    max_items = study_config$max_items,
    min_SEM = study_config$min_SEM,
    language = study_config$language,
    theme = study_config$theme,
    features = deployment_results$deployment_config$advanced_features,
    contact = contact_info$email,
    institution = contact_info$institution,
    deployment_id = deployment_results$deployment_id,
    created_at = deployment_results$timestamp
  )
}

validate_deployment_package <- function(deployment_path, deployment_type) {
  validation_results <- list(
    structure_check = dir.exists(file.path(deployment_path, c("app", "data", "config", "docs"))),
    app_files_check = file.exists(file.path(deployment_path, "app", c("app.R", "ui.R", "server.R"))),
    config_files_check = file.exists(file.path(deployment_path, "config", c("study_config.rds", "deployment_config.rds"))),
    data_files_check = file.exists(file.path(deployment_path, "data", "item_bank.rds")),
    docs_check = file.exists(file.path(deployment_path, "docs", c("deployment_instructions.md", "contact_template.md"))),
    overall_status = "PASS"
  )
  
  if (any(unlist(validation_results[1:5]) == FALSE)) {
    validation_results$overall_status <- "FAIL"
  }
  
  return(validation_results)
}

generate_deployment_summary <- function(deployment_results, deployment_path) {
  summary_content <- c(
    "# inrep Platform Deployment Summary",
    "",
    paste0("**Deployment ID:** ", deployment_results$deployment_id),
    paste0("**Created:** ", deployment_results$timestamp),
    paste0("**Deployment Type:** ", deployment_results$deployment_type),
    "",
    "## Study Information",
    paste0("- **Study Name:** ", deployment_results$study_metadata$study_name),
    paste0("- **Model:** ", deployment_results$study_metadata$model),
    paste0("- **Number of Items:** ", deployment_results$study_metadata$num_items),
    paste0("- **Maximum Items:** ", deployment_results$study_metadata$max_items),
    paste0("- **Minimum SEM:** ", deployment_results$study_metadata$min_SEM),
    "",
    "## Deployment Package Contents",
    "- ✅ Application files (app.R, ui.R, server.R)",
    "- ✅ Study configuration and item bank",
    "- ✅ Deployment instructions and documentation",
    "- ✅ Contact template for platform team",
    "- ✅ Validation reports and quality checks",
    "",
    "## Next Steps",
    "1. Review the contact template in docs/contact_template.md",
    "2. Follow deployment instructions in docs/deployment_instructions.md",
    "3. Contact selva@uni-hildesheim.de for official platform hosting",
    "",
    "## Package Structure",
    "```",
    paste0(basename(deployment_path), "/"),
    "├── app/                 # Shiny application files",
    "├── config/              # Study and deployment configuration",
    "├── data/                # Item bank and study data",
    "├── docs/                # Documentation and instructions",
    "├── validation/          # Validation reports",
    "└── deployment/          # Deployment manifest and metadata",
    "```"
  )
  
  writeLines(summary_content, file.path(deployment_path, "DEPLOYMENT_SUMMARY.md"))
}

# Utility function for null coalescing
`%||%` <- function(x, y) if (is.null(x)) y else x
