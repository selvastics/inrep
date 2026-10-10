#' Create a deployment folder for hosting a study
#'
#' @description
#' Writes a folder with the study configuration, the item bank, a minimal
#' \code{app.R} and Markdown notes for hosting the study on a Shiny server.
#'
#' @details
#' The folder \code{<output_dir>/inrep_deployment_<timestamp>/} contains:
#' \itemize{
#'   \item \code{app/app.R}: reads the configuration and item bank and calls
#'     \code{inrep::launch_study()}. The server must have inrep and its
#'     dependencies installed.
#'   \item \code{config/study_config.rds}, \code{config/deployment_config.rds}
#'     and \code{data/item_bank.rds}.
#'   \item \code{docs/deployment_instructions.md} and, when
#'     \code{contact_info} is given, \code{docs/contact_template.md}.
#'   \item \code{deployment/manifest.json} and \code{DEPLOYMENT_SUMMARY.md}.
#' }
#' The function does not upload or deploy anything, and it writes no
#' Dockerfile. The \code{security_settings} and \code{backup_settings} are
#' stored in the configuration file only; nothing enforces them.
#'
#' \code{deployment_type = "inrep_platform"} produces a template for
#' requesting hosting from the package maintainer. There is no public inrep
#' hosting service.
#'
#' @param study_config A study configuration object created with \code{create_study_config()}.
#' @param item_bank A data frame containing item parameters.
#' @param output_dir Character string specifying the output directory for deployment files.
#' @param deployment_type Character string specifying deployment target.
#'   Supported values: \code{"inrep_platform"}, \code{"posit_connect"}, \code{"shinyapps"},
#'   \code{"custom_server"}, \code{"docker"}. It only changes the notes and the
#'   stored deployment configuration.
#' @param contact_info Optional list containing researcher contact information and study details.
#' @param advanced_features Optional list stored in the deployment configuration.
#' @param security_settings Optional list stored in the deployment configuration
#'   (\code{"inrep_platform"} only). Not enforced by the package.
#' @param backup_settings Currently unused.
#' @param validate_deployment Logical. If \code{TRUE}, runs
#'   \code{validate_item_bank()} and checks that the expected files were written.
#'
#' @return A list containing:
#' \itemize{
#'   \item \code{deployment_package} Path to the generated folder
#'   \item \code{validation_report} Validation results (if enabled)
#'   \item \code{deployment_instructions} Path to the instructions file
#'   \item \code{contact_template} Path to the contact template (if \code{contact_info} was given)
#'   \item \code{study_metadata} Study metadata
#' }
#'
#' @export
#'
#' @examples
#' \dontrun{
#' data(bfi_items)
#'
#' config <- create_study_config(
#'   name = "Example Study",
#'   model = "GRM",
#'   max_items = 20,
#'   min_SEM = 0.3,
#'   language = "en",
#'   theme = "Professional"
#' )
#'
#' deployment <- launch_to_inrep_platform(
#'   study_config = config,
#'   item_bank = bfi_items,
#'   output_dir = "deployment_package",
#'   deployment_type = "custom_server"
#' )
#'
#' deployment$deployment_package
#' }
#'
#' @seealso
#' \code{\link{prepare_shinyapps_deploy}} for deploying a study script to shinyapps.io,
#' \code{\link{create_study_config}} for creating study configurations,
#' \code{\link{validate_item_bank}} for item bank validation.
launch_to_inrep_platform <- function(study_config,
                                       item_bank,
                                       output_dir = "inrep_deployment",
                                       deployment_type = "inrep_platform",
                                       contact_info = NULL,
                                       advanced_features = NULL,
                                       security_settings = NULL,
                                       backup_settings = NULL,
                                       validate_deployment = TRUE) {

  if (missing(study_config) || !is.list(study_config)) {
    stop("study_config must be a valid configuration object created with create_study_config()")
  }

  if (missing(item_bank) || !is.data.frame(item_bank)) {
    stop("item_bank must be a data frame")
  }

  valid_deployments <- c("inrep_platform", "posit_connect", "shinyapps", "custom_server", "docker")
  if (!deployment_type %in% valid_deployments) {
    stop(paste("deployment_type must be one of:", paste(valid_deployments, collapse = ", ")))
  }

  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
  }

  timestamp <- format(Sys.time(), "%Y%m%d_%H%M%S")
  deployment_id <- paste0("inrep_deployment_", timestamp)

  deployment_path <- file.path(output_dir, deployment_id)
  dir.create(deployment_path, recursive = TRUE)

  subdirs <- c("app", "data", "config", "docs", "validation", "deployment")
  for (subdir in subdirs) {
    dir.create(file.path(deployment_path, subdir), recursive = TRUE)
  }

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

  if (validate_deployment) {
    validation_results <- validate_item_bank(item_bank, model = study_config$model, adaptive = isTRUE(study_config$adaptive))
    deployment_results$validation_report$item_bank_validation <- validation_results
  }

  saveRDS(study_config, file.path(deployment_path, "config", "study_config.rds"))
  saveRDS(item_bank, file.path(deployment_path, "data", "item_bank.rds"))

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

  if (!is.null(contact_info)) {
    deployment_results$contact_template <- generate_contact_template(
      contact_info,
      deployment_results,
      deployment_type
    )
  }

  deployment_results$deployment_instructions <- generate_deployment_instructions(
    deployment_type,
    deployment_path,
    study_config
  )

  deployment_results$study_metadata <- create_study_metadata(
    study_config,
    item_bank,
    contact_info,
    deployment_results
  )

  if (validate_deployment) {
    final_validation <- validate_deployment_package(deployment_path, deployment_type,
                                                    has_contact = !is.null(contact_info))
    deployment_results$validation_report$final_validation <- final_validation
  }

  generate_deployment_summary(deployment_results, deployment_path)

  message("Deployment folder created: ", deployment_path)
  message("Deployment type: ", deployment_type)
  message("See the notes in: ", file.path(deployment_path, "docs"))

  return(deployment_results)
}


generate_deployment_files <- function(deployment_results, deployment_path, study_config,
                                      item_bank, deployment_type, contact_info,
                                      advanced_features, security_settings, backup_settings) {

  app_content <- generate_app_file(study_config, item_bank, advanced_features)
  writeLines(app_content, file.path(deployment_path, "app", "app.R"))

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

  saveRDS(deployment_config, file.path(deployment_path, "config", "deployment_config.rds"))
  deployment_results$deployment_config <- deployment_config

  manifest <- generate_manifest(study_config, item_bank, deployment_type, contact_info)
  writeLines(manifest, file.path(deployment_path, "deployment", "manifest.json"))

  return(deployment_results)
}


generate_contact_template <- function(contact_info, deployment_results, deployment_type) {

  template_path <- file.path(deployment_results$deployment_package, "docs", "contact_template.md")

  template_content <- c(
    "# Contact template for hosting a study",
    "",
    "## Study information",
    paste0("- **Study title:** ", contact_info$study_title %||% "Not provided"),
    paste0("- **Principal investigator:** ", contact_info$researcher_name %||% "Not provided"),
    paste0("- **Institution:** ", contact_info$institution %||% "Not provided"),
    paste0("- **Contact email:** ", contact_info$email %||% "Not provided"),
    "",
    "## Study details",
    paste0("- **Study description:** ", contact_info$study_description %||% "Not provided"),
    paste0("- **Expected duration:** ", contact_info$expected_duration %||% "Not provided"),
    paste0("- **Expected participants:** ", contact_info$expected_participants %||% "Not provided"),
    paste0("- **Deployment package:** ", deployment_results$deployment_id),
    "",
    "## Technical details",
    paste0("- **Deployment type:** ", deployment_type),
    paste0("- **Model:** ", deployment_results$study_metadata$model %||% "Not specified"),
    "",
    "## Approvals and policies",
    paste0("- **Ethics approval reference:** ", contact_info$institutional_approval %||% "Please provide"),
    paste0("- **Data sensitivity:** ", contact_info$data_sensitivity %||% "Please provide"),
    paste0("- **Relevant policies:** ", contact_info$compliance_requirements %||% "Please provide"),
    "",
    "## Message template",
    "```",
    "Subject: Hosting request for an inrep study - [Study title]",
    "",
    "Dear hosting team,",
    "",
    "I would like to request hosting for my study.",
    "",
    "Study details:",
    paste0("- Title: ", contact_info$study_title %||% "[Study title]"),
    paste0("- Principal investigator: ", contact_info$researcher_name %||% "[Your name]"),
    paste0("- Institution: ", contact_info$institution %||% "[Your institution]"),
    paste0("- Expected duration: ", contact_info$expected_duration %||% "[Duration]"),
    paste0("- Expected participants: ", contact_info$expected_participants %||% "[Number]"),
    "",
    paste0("Deployment package ID: ", deployment_results$deployment_id),
    "",
    "The package was prepared with the inrep R package.",
    "Please let me know the next steps for uploading and configuring the study.",
    "",
    "Best regards,",
    "[Your name]",
    "[Your email]",
    "```"
  )

  writeLines(template_content, template_path)
  return(template_path)
}


generate_deployment_instructions <- function(deployment_type, deployment_path, study_config) {

  instructions_path <- file.path(deployment_path, "docs", "deployment_instructions.md")

  instructions_content <- c(
    paste0("# Deployment notes: ", deployment_type),
    "",
    "The folder `app/` contains `app.R`, which reads `config/study_config.rds`",
    "and `data/item_bank.rds` and calls `inrep::launch_study()`. Copy `app/`,",
    "`config/` and `data/` to the server so that these relative paths still work,",
    "or adjust the paths in `app.R`. The server needs R, inrep and its dependencies."
  )

  if (deployment_type == "inrep_platform") {
    instructions_content <- c(instructions_content,
      "",
      "## Hosting through the package maintainer",
      "There is no public inrep hosting service. Hosting can be requested from the",
      "package maintainer; whether and on what terms it is offered is decided case by case.",
      "",
      "1. Fill in `docs/contact_template.md` (created when `contact_info` is given).",
      "2. Include the deployment package ID and the ethics approval reference.",
      "3. Data protection (controller, processor agreement, storage location) must be",
      "   agreed with the host before data collection starts."
    )
  } else if (deployment_type == "posit_connect" || deployment_type == "shinyapps") {
    instructions_content <- c(instructions_content,
      "",
      "## Posit Connect or shinyapps.io",
      "Deploy with the rsconnect package from the folder that contains `app/`:",
      "```r",
      "rsconnect::deployApp(appDir = 'app')",
      "```",
      "The configuration and item bank must be inside the deployed folder; move",
      "them into `app/` and change the paths in `app.R` accordingly.",
      "For shinyapps.io, `prepare_shinyapps_deploy()` is usually simpler."
    )
  } else if (deployment_type == "docker") {
    instructions_content <- c(instructions_content,
      "",
      "## Docker",
      "No Dockerfile is generated. A Dockerfile based on `rocker/shiny` that installs",
      "inrep and copies the app folder into `/srv/shiny-server/` is one option.",
      "```bash",
      "docker build -t inrep-study .",
      "docker run -p 3838:3838 inrep-study",
      "```",
      "Mount a volume for the data directory so that results persist when the",
      "container is replaced."
    )
  } else {
    instructions_content <- c(instructions_content,
      "",
      "## Shiny Server",
      "Copy the folder to the Shiny Server application directory",
      "(for example `/srv/shiny-server/<study>/`) and install inrep on the server."
    )
  }

  instructions_content <- c(instructions_content,
    "",
    "## Operational notes",
    "- Use HTTPS when the study is reachable from the internet.",
    "- Check where participant data are stored and who can access them.",
    "- Test the full study flow, including data saving, before inviting participants.",
    "",
    "---",
    paste0("Generated by inrep::launch_to_inrep_platform(). Deployment ID: ", basename(deployment_path))
  )

  writeLines(instructions_content, instructions_path)
  return(instructions_path)
}


generate_app_file <- function(study_config, item_bank, advanced_features) {
  c(
    "# Generated by inrep::launch_to_inrep_platform()",
    "",
    "library(inrep)",
    "",
    "study_config <- readRDS('../config/study_config.rds')",
    "item_bank <- readRDS('../data/item_bank.rds')",
    "",
    "# launch_study() returns a shiny.appobj when launch_browser = FALSE",
    "launch_study(study_config, item_bank)"
  )
}

generate_inrep_platform_config <- function(study_config, contact_info, advanced_features, security_settings) {
  list(
    platform = "inrep_platform",
    study_config = study_config,
    contact_info = contact_info,
    advanced_features = advanced_features,
    security_settings = security_settings
  )
}

generate_posit_connect_config <- function(study_config, advanced_features) {
  list(
    platform = "posit_connect",
    study_config = study_config,
    advanced_features = advanced_features,
    deployment_settings = list(
      r_version = paste0(R.version$major, ".", R.version$minor),
      packages = c("inrep", "shiny")
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
      port = 3838
    )
  )
}

generate_generic_config <- function(study_config, advanced_features) {
  list(
    platform = "generic",
    study_config = study_config,
    advanced_features = advanced_features
  )
}

generate_manifest <- function(study_config, item_bank, deployment_type, contact_info) {
  manifest <- list(
    deployment_info = list(
      package_version = as.character(utils::packageVersion("inrep")),
      deployment_type = deployment_type,
      created_at = format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z"),
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
      app = "app.R",
      config = c("study_config.rds", "deployment_config.rds"),
      data = "item_bank.rds",
      docs = c("deployment_instructions.md",
               if (!is.null(contact_info)) "contact_template.md")
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

validate_deployment_package <- function(deployment_path, deployment_type, has_contact = TRUE) {
  docs <- c("deployment_instructions.md", if (has_contact) "contact_template.md")
  validation_results <- list(
    structure_check = dir.exists(file.path(deployment_path, c("app", "data", "config", "docs"))),
    app_files_check = file.exists(file.path(deployment_path, "app", "app.R")),
    config_files_check = file.exists(file.path(deployment_path, "config", c("study_config.rds", "deployment_config.rds"))),
    data_files_check = file.exists(file.path(deployment_path, "data", "item_bank.rds")),
    docs_check = file.exists(file.path(deployment_path, "docs", docs)),
    overall_status = "PASS"
  )

  if (any(unlist(validation_results[1:5]) == FALSE)) {
    validation_results$overall_status <- "FAIL"
  }

  return(validation_results)
}

generate_deployment_summary <- function(deployment_results, deployment_path) {
  summary_content <- c(
    "# inrep deployment summary",
    "",
    paste0("**Deployment ID:** ", deployment_results$deployment_id),
    paste0("**Created:** ", deployment_results$timestamp),
    paste0("**Deployment type:** ", deployment_results$deployment_type),
    "",
    "## Study",
    paste0("- **Name:** ", deployment_results$study_metadata$study_name),
    paste0("- **Model:** ", deployment_results$study_metadata$model),
    paste0("- **Items in bank:** ", deployment_results$study_metadata$num_items),
    paste0("- **Maximum items:** ", deployment_results$study_metadata$max_items),
    paste0("- **Minimum SEM:** ", deployment_results$study_metadata$min_SEM),
    "",
    "## Contents",
    "```",
    paste0(basename(deployment_path), "/"),
    "  app/          app.R",
    "  config/       study and deployment configuration",
    "  data/         item bank",
    "  docs/         deployment notes (and contact template)",
    "  validation/   empty; validation results are in the returned list",
    "  deployment/   manifest.json",
    "```",
    "",
    "## Next steps",
    "1. Read docs/deployment_instructions.md.",
    "2. Test the app locally with shiny::runApp('app').",
    "3. Copy the folder to the server."
  )

  writeLines(summary_content, file.path(deployment_path, "DEPLOYMENT_SUMMARY.md"))
}


#' Prepare a study script for deployment to shinyapps.io
#'
#' @description
#' Creates a deployment-ready folder from a study R script.
#' The folder contains an \code{app.R} wrapper and can be deployed directly
#' with \code{rsconnect::deployApp()}.
#'
#' @param study_script Path to the study R script (e.g. \code{"my_study.R"}).
#' @param output_dir Directory to create. Defaults to \code{"deploy"} next to the script.
#' @param app_name Optional application name for shinyapps.io.
#' @param deploy Logical. If \code{TRUE}, calls \code{rsconnect::deployApp()}
#'   after creating the folder. Default \code{FALSE}.
#' @param account Optional shinyapps.io account name.
#'
#' @return Invisibly returns the path to the deployment folder.
#'
#' @details
#' The function creates a minimal deployment folder containing:
#' \itemize{
#'   \item \code{app.R}, which \code{source()}s the copied study script
#'   \item A copy of the original study script
#'   \item A \code{.rscignore} to exclude unnecessary files
#' }
#'
#' For shinyapps.io to install \code{inrep} automatically, the GitHub repository
#' (\url{https://github.com/selvastics/inrep}) must be public.
#'
#' @export
#' @examples
#' \dontrun{
#' # Prepare deployment folder (without deploying)
#' prepare_shinyapps_deploy("case_studies/my_study.R")
#'
#' # Prepare and deploy in one step
#' prepare_shinyapps_deploy("case_studies/my_study.R", deploy = TRUE)
#' }
prepare_shinyapps_deploy <- function(study_script,
                                      output_dir = NULL,
                                      app_name = NULL,
                                      deploy = FALSE,
                                      account = NULL) {

  if (!file.exists(study_script)) {
    stop("Study script not found: ", study_script)
  }

  study_script <- normalizePath(study_script, winslash = "/")

  if (is.null(output_dir)) {
    output_dir <- file.path(dirname(study_script), "deploy")
  }

  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
  }

  # Copy the study script
  script_name <- basename(study_script)
  file.copy(study_script, file.path(output_dir, script_name), overwrite = TRUE)

  # Create app.R wrapper
  app_content <- paste0(
    '# app.R -- generated by inrep::prepare_shinyapps_deploy()\n',
    '# Deploy with: rsconnect::deployApp("', gsub("\\\\", "/", output_dir), '")\n\n',
    'source("', script_name, '")\n'
  )
  writeLines(app_content, file.path(output_dir, "app.R"))

  # Create .rscignore
  rscignore <- c("*.exe", "*.pyc", "*.zip", "*.toc", "*.pyz",
                  "get_data/", "data/", "*.spec")
  writeLines(rscignore, file.path(output_dir, ".rscignore"))

  message("Deployment folder ready: ", output_dir)
  message("Contents: ", paste(list.files(output_dir), collapse = ", "))
  message("")
  message("To deploy, run:")
  message('  rsconnect::deployApp("', output_dir, '")')

  if (isTRUE(deploy)) {
    if (!requireNamespace("rsconnect", quietly = TRUE)) {
      stop("Install rsconnect first: install.packages('rsconnect')")
    }
    deploy_args <- list(appDir = output_dir, forceUpdate = TRUE)
    if (!is.null(app_name)) deploy_args$appName <- app_name
    if (!is.null(account)) deploy_args$account <- account
    do.call(rsconnect::deployApp, deploy_args)
  }

  invisible(output_dir)
}
