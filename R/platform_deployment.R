#'LaunchStudytoinrepPlatform
#'
#'@description
#'Createsacomprehensivedeploymentpackageforlaunchingadaptiveassessmentstudies
#'ontheinrepplatform.Thisfunctiongeneratesallnecessaryfilesandconfigurations
#'forprofessionalhostingofTAM-basedadaptiveassessments.Theresultingpackage
#'canbedeployedontheofficialinrepplatformoranycompatibleShinyserver.
#'
#'@details
#'Thisfunctioncreatesacompletedeploymentpackagethatincludes:
#'\itemize{
#'\item Study configuration and metadata
#'\item Item bank validation and preparation
#'\item UI components with professional styling
#'\item Assessment logic and scoring algorithms
#'\item Results processing and reporting systems
#'\item Quality assurance and validation checks
#'\item Deployment documentation and instructions
#'}
#'
#'Thegeneratedpackageisdesignedforprofessionaldeploymenton:
#'\itemize{
#'\item Official inrep platform (contact: selva@uni-hildesheim.de)
#'\item Posit Connect/RStudio Connect servers
#'\item ShinyApps.io
#'\item Custom Shiny Server installations
#'\item Docker containers for scalable deployment
#'}
#'
#'Forofficialinrepplatformdeployment,usersshouldcontactthemaintainer
#'atselva@uni-hildesheim.dewiththegenerateddeploymentpackageandprovide:
#'\itemize{
#'\item Brief study description and objectives
#'\item Expected study duration and participant numbers
#'   \item Special requirements (multilingual support, accessibility, etc.)
#'   \item Institutional affiliation and research context
#' }
#'
#' @param study_config A study configuration object created with \code{create_study_config()}
#' @param item_bank A validated item bank dataframe with proper IRT parameters
#' @param output_dir Character string specifying the output directory for deployment files
#' @param deployment_type Character string specifying deployment target:
#' \itemize{
#'   \item "inrep_platform" - Official inrep platform (default)
#'   \item "posit_connect" - Posit Connect server
#'   \item "shinyapps" - ShinyApps.io deployment
#'   \item "custom_server" - Custom Shiny server
#'   \item "docker" - Docker container deployment
#' }
#' @param contact_info List containing researcher contact information and study details
#' @param advanced_features List of advanced features to include:
#' \itemize{
#'   \item "multilingual" - Multi-language support
#'   \item "accessibility" - Accessibility features
#'   \item "mobile_optimized" - Mobile-responsive design
#'   \item "real_time_monitoring" - Live study monitoring  
#'   \item "automated_reporting" - Automated result generation
#' }
#' @param security_settings List of security configurations for professional deployment
#' @param backup_settings List of backup and recovery configurations  
#' @param validate_deployment Logical indicating whether to perform comprehensive validation
#'
#' @return A list containing:
#' \itemize{
#' \item \code{deployment_package} - Path to the generated deployment package
#' \item \code{validation_report} - Comprehensive validation results
#' \item \code{deployment_instructions} - Platform-specific deployment guide
#' \item \code{contact_template} - Template for contacting platform maintainer
#' \item \code{study_metadata} - Complete study metadata for hosting
#' }
#'
#'@export
#'
#'@examples
#'\dontrun{
#'#Example1:Basicdeploymentforinrepplatform
#'library(inrep)
#'data(bfi_items)
#'
#'#Createstudyconfiguration
#'config<-create_study_config(
#'name="BigFivePersonalityAssessment",
#'model="GRM",
#'max_items=20,
#'min_SEM=0.3,
#'language="en",
#'theme="Professional"
#')
#'
#'#Preparecontactinformation
#'contact_info<-list(
#'researcher_name="Dr.JaneSmith",
#'institution="UniversityofResearch",
#'email="jane.smith@university.edu",
#'study_title="AdaptivePersonalityAssessmentStudy",
#'study_description="Investigatingpersonalitytraitsusingadaptivetesting",
#'expected_duration="4weeks",
#'expected_participants=500,
#'institutional_approval="IRB-2025-001"
#')
#'
#'#Launchtoinrepplatform
#'deployment<-launch_to_inrep_platform(
#'study_config=config,
#'item_bank=bfi_items,
#'output_dir="deployment_package",
#'deployment_type="inrep_platform",
#'contact_info=contact_info
#')
#'
#'#Checkdeploymentresults
#'cat("Deploymentpackagecreated:",deployment$deployment_package,"\n")
#'cat("Contacttemplate:",deployment$contact_template,"\n")
#'}
#'
#'\dontrun{
#'#Example2:Advanceddeploymentwithmultilingualsupport
#'library(inrep)
#'data(bfi_items)
#'
#'#Createadvancedconfiguration
#'config<-create_study_config(
#'name="InternationalPersonalityStudy",
#'model="GRM",
#'max_items=25,
#'min_SEM=0.25,
#'language="en",
#'theme="International",
#'multilingual=TRUE,
#'languages=c("en","de","es","fr")
#')
#'
#'#Advancedfeatures
#'advanced_features<-list(
#'"multilingual",
#'"accessibility",
#'"mobile_optimized",
#'"real_time_monitoring"
#')
#'
#'#Contactinformationforinternationalstudy
#'contact_info<-list(
#'researcher_name="Prof.InternationalResearcher",
#'institution="GlobalResearchInstitute",
#'email="researcher@global-institute.org",
#'study_title="Cross-CulturalPersonalityAssessment",
#'study_description="Large-scaleinternationalstudyonpersonalitytraits",
#'expected_duration="12weeks",
#'expected_participants=2000,
#'languages_needed=c("English","German","Spanish","French"),
#'special_requirements="GDPRcompliance,accessibilitystandards"
#')
#'
#'#Launchwithadvancedfeatures
#'deployment<-launch_to_inrep_platform(
#'study_config=config,
#'item_bank=bfi_items,
#'output_dir="international_study_deployment",
#'deployment_type="inrep_platform",
#'contact_info=contact_info,
#'advanced_features=advanced_features
#')
#'
#'#Reviewdeploymentvalidation
#'print(deployment$validation_report)
#'}
#'
#'\dontrun{
#'#Example3:Clinicaldeploymentwithenhancedsecurity
#'library(inrep)
#'data(bfi_items)
#'
#'#Createclinicalconfiguration
#'config<-create_study_config(
#'name="ClinicalDepressionAssessment",
#'model="GRM",
#'max_items=15,
#'min_SEM=0.2,
#'language="en",
#'theme="Clinical",
#'clinical_mode=TRUE
#')
#'
#'#Securitysettingsforclinicaldata
#'security_settings<-list(
#'encryption_level="AES-256",
#'data_retention="7_years",
#'access_control="role_based",
#'audit_logging=TRUE,
#'hipaa_compliance=TRUE,
#'gdpr_compliance=TRUE
#')
#'
#'#Clinicalcontactinformation
#'contact_info<-list(
#'researcher_name="Dr.ClinicalResearcher",
#'institution="MedicalCenterHospital",
#'email="clinical.researcher@hospital.org",
#'study_title="AdaptiveDepressionScreening",
#'study_description="Clinicalvalidationofadaptivedepressionassessment",
#'expected_duration="6months",
#'expected_participants=300,
#'clinical_approval="IRB-CLINICAL-2025-005",
#'data_sensitivity="high",
#'compliance_requirements="HIPAA,GDPR"
#')
#'
#'#Launchclinicalstudy
#'deployment<-launch_to_inrep_platform(
#'study_config=config,
#'item_bank=bfi_items,
#'output_dir="clinical_deployment",
#'deployment_type="inrep_platform",
#'contact_info=contact_info,
#'security_settings=security_settings,
#'advanced_features=list("accessibility","real_time_monitoring")
#')
#'
#'#Verifysecurityconfiguration
#'cat("Securityvalidationpassed:",deployment$validation_report$security_check,"\n")
#'}
#'
#'\dontrun{
#'#Example4:EducationaldeploymentforPositConnect
#'library(inrep)
#'data(bfi_items)
#'
#'#Createeducationalconfiguration
#'config<-create_study_config(
#'name="StudentPersonalityAssessment",
#'model="2PL",
#'max_items=30,
#'min_SEM=0.4,
#'language="en",
#'theme="Educational",
#'adaptive_feedback=TRUE
#')
#'
#'#Educationalcontactinformation
#'contact_info<-list(
#'researcher_name="Prof.EducationResearcher",
#'institution="StateUniversity",
#'email="education.prof@state-university.edu",
#'study_title="StudentPersonalityandAcademicPerformance",
#'study_description="Longitudinalstudyofpersonalityandacademicoutcomes",
#'expected_duration="1academicyear",
#'expected_participants=1000,
#'educational_approval="University-IRB-2025-EDU-003"
#')
#'
#'#LaunchforPositConnect
#'deployment<-launch_to_inrep_platform(
#'study_config=config,
#'item_bank=bfi_items,
#'output_dir="educational_deployment",
#'deployment_type="posit_connect",
#'contact_info=contact_info,
#'advanced_features=list("mobile_optimized","automated_reporting")
#')
#'
#'#Generatedeploymentinstructions
#'cat("PositConnectdeploymentguide:",deployment$deployment_instructions,"\n")
#'}
#'
#'\dontrun{
#'#Example5:CorporatedeploymentwithDocker
#'library(inrep)
#'data(bfi_items)
#'
#'#Createcorporateconfiguration
#'config<-create_study_config(
#'name="EmployeeAssessmentPlatform",
#'model="GRM",
#'max_items=20,
#'min_SEM=0.3,
#'language="en",
#'theme="Corporate",
#'corporate_mode=TRUE
#')
#'
#'#Corporatecontactinformation
#'contact_info<-list(
#'researcher_name="HRAnalyticsTeam",
#'institution="GlobalCorporationLtd",
#'email="hr.analytics@globalcorp.com",
#'study_title="EmployeePersonalityAssessment",
#'study_description="Corporatepersonalityassessmentforteambuilding",
#'expected_duration="Ongoing",
#'expected_participants=5000,
#'corporate_approval="HR-STUDY-2025-001",
#'deployment_scale="enterprise"
#')
#'
#'#LaunchwithDockerdeployment
#'deployment<-launch_to_inrep_platform(
#'study_config=config,
#'item_bank=bfi_items,
#'output_dir="corporate_deployment",
#'deployment_type="docker",
#'contact_info=contact_info,
#'advanced_features=list("real_time_monitoring","automated_reporting")
#')
#'
#'#CheckDockerconfiguration
#'cat("Dockerdeploymentready:",deployment$deployment_package,"\n")
#'cat("Containerconfiguration:",deployment$docker_config,"\n")
#'}
#'
#'\dontrun{
#'#Example6:Customserverdeploymentwithbackupsettings
#'library(inrep)
#'data(bfi_items)
#'
#'#Createcustomconfiguration
#'config<-create_study_config(
#'name="ResearchPlatformAssessment",
#'model="GRM",
#'max_items=25,
#'min_SEM=0.25,
#'language="en",
#'theme="Research",
#'custom_styling=TRUE
#')
#'
#'#Backupsettingsforlong-termstudy
#'backup_settings<-list(
#'backup_frequency="daily",
#'backup_retention="1_year",
#'backup_location="cloud_storage",
#'automated_backups=TRUE,
#'disaster_recovery=TRUE
#')
#'
#'#Researchcontactinformation
#'contact_info<-list(
#'researcher_name="ResearchConsortium",
#'institution="Multi-UniversityResearchNetwork",
#'email="consortium@research-network.org",
#'study_title="Large-ScalePersonalityResearch",
#'study_description="Multi-sitelongitudinalpersonalitystudy",
#'expected_duration="3years",
#'expected_participants=10000,
#'multi_site=TRUE,
#'sites=c("UniversityA","UniversityB","UniversityC")
#')
#'
#'#Launchwithcustomserverconfiguration
#'deployment<-launch_to_inrep_platform(
#'study_config=config,
#'item_bank=bfi_items,
#'output_dir="research_consortium_deployment",
#'deployment_type="custom_server",
#'contact_info=contact_info,
#'backup_settings=backup_settings,
#'advanced_features=list("multilingual","real_time_monitoring","automated_reporting")
#')
#'
#'#Verifybackupconfiguration
#'cat("Backupsettingsvalidated:",deployment$validation_report$backup_check,"\n")
#'}
#'
#'@seealso
#'\code{\link{create_study_config}}forcreatingstudyconfigurations,
#'\code{\link{validate_item_bank}}foritembankvalidation,
#'\code{\link{build_study_ui}}forUIcomponents,
#'\code{\link{create_response_report}}forresultsprocessing
#'
#'@references
#'Forofficialinrepplatformdeployment,contact:selva@uni-hildesheim.de
#'
#'Platformdocumentation:https://inrep-platform.org
#'
#'Deploymentguides:https://inrep-platform.org/docs/deployment
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

#Savestudyconfiguration
saveRDS(study_config,file.path(deployment_path,"config","study_config.rds"))

#Saveitembank
saveRDS(item_bank,file.path(deployment_path,"data","item_bank.rds"))

#Generatedeployment-specificfiles
deployment_results<-generate_deployment_files(
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

#Generatecontacttemplate
if(!is.null(contact_info)){
deployment_results$contact_template<-generate_contact_template(
contact_info,
deployment_results,
deployment_type
)
}

#Generatedeploymentinstructions
deployment_results$deployment_instructions<-generate_deployment_instructions(
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

#Finalvalidation
if(validate_deployment){
final_validation<-validate_deployment_package(deployment_path,deployment_type)
deployment_results$validation_report$final_validation<-final_validation
}

#Generatesummaryreport
generate_deployment_summary(deployment_results,deployment_path)

# Print success message
message("Deployment package created successfully!")
message("Location: ", deployment_path)
message("Deployment type: ", deployment_type)
message("Contact maintainer at: selva@uni-hildesheim.de")
message("See deployment instructions in: ", file.path(deployment_path, "docs"))

return(deployment_results)
}


#Helperfunctiontogeneratedeploymentfiles
generate_deployment_files<-function(deployment_results,deployment_path,study_config,
item_bank,deployment_type,contact_info,
advanced_features,security_settings,backup_settings){

#Generatemainappfile
app_content<-generate_app_file(study_config,item_bank,advanced_features)
writeLines(app_content,file.path(deployment_path,"app","app.R"))

#GenerateUIfile
ui_content<-generate_ui_file(study_config,advanced_features)
writeLines(ui_content,file.path(deployment_path,"app","ui.R"))

#Generateserverfile
server_content<-generate_server_file(study_config,item_bank,advanced_features)
writeLines(server_content,file.path(deployment_path,"app","server.R"))

# Generate deployment configuration based on type
if(deployment_type=="inrep_platform"){
deployment_config<-generate_inrep_platform_config(study_config,contact_info,
advanced_features,security_settings)
}else if(deployment_type=="posit_connect"){
deployment_config<-generate_posit_connect_config(study_config,advanced_features)
}else if(deployment_type=="docker"){
deployment_config<-generate_docker_config(study_config,advanced_features)
}else{
deployment_config<-generate_generic_config(study_config,advanced_features)
}

#Savedeploymentconfiguration
saveRDS(deployment_config,file.path(deployment_path,"config","deployment_config.rds"))
deployment_results$deployment_config<-deployment_config

#Generatemanifestfile
manifest<-generate_manifest(study_config,item_bank,deployment_type,contact_info)
writeLines(manifest,file.path(deployment_path,"deployment","manifest.json"))

return(deployment_results)
}


#Helperfunctiontogeneratecontacttemplate
generate_contact_template<-function(contact_info,deployment_results,deployment_type){

template_path<-file.path(deployment_results$deployment_package,"docs","contact_template.md")

template_content<-c(
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
paste0("[YourName]"),
paste0("[YourEmail]"),
"```",
"",
"###AlternativeDeploymentOptions",
"Ifyouprefertohostthestudyyourself,thedeploymentpackageincludes",
"configurationsfor:",
"-PositConnect/RStudioConnect",
"-ShinyApps.io",
"-CustomShinyServer",
"-Dockercontainers",
"",
"Seethedeploymentinstructionsinthedocsfolderfordetailedsetupguides."
)

writeLines(template_content,template_path)
return(template_path)
}


#Helperfunctiontogeneratedeploymentinstructions
generate_deployment_instructions<-function(deployment_type,deployment_path,study_config){

instructions_path<-file.path(deployment_path,"docs","deployment_instructions.md")

instructions_content<-c(
paste0("#DeploymentInstructions-",deployment_type),
"",
"##Overview",
"Thisdocumentprovidesstep-by-stepinstructionsfordeployingyouradaptive",
"assessmentstudyusingtheinrepplatforminfrastructure.",
"",
"##QuickStart"
)

#Adddeployment-specificinstructions
if(deployment_type=="inrep_platform"){
instructions_content<-c(instructions_content,
"",
"###OfficialinrepPlatformDeployment",
"1.**ContactthePlatformTeam**",
"-Email:selva@uni-hildesheim.de",
"-Usethecontacttemplateprovidedinthispackage",
"-IncludeyourdeploymentpackageIDandstudydetails",
"",
"2.**PrepareStudyMaterials**",
"-Completethecontacttemplatewithallrequiredinformation",
"-EnsureIRB/ethicsapprovalisdocumented",
"-Prepareanyadditionaldocumentationrequested",
"",
"3.**UploadandConfiguration**",
"-Theplatformteamwillguideyouthroughtheuploadprocess",
"-Yourstudywillbeconfiguredandtestedbeforegoinglive",
"-You'llreceiveauniquestudyURLforparticipantaccess",
"",
"4.**StudyLaunch**",
"-Finaltestingandvalidation",
"-Studygoeslivewithprofessionalhosting",
"-Real-timemonitoringandsupportavailable",
"",
"###BenefitsofOfficialPlatformHosting",
"-Professionalserverinfrastructure",
"-Automaticbackupsanddisasterrecovery",
"-24/7monitoringandsupport",
"-GDPRandHIPAAcomplianthosting",
"-Scalablearchitectureforlargestudies",
"-Experttechnicalsupport"
)
}else if(deployment_type=="posit_connect"){
instructions_content<-c(instructions_content,
"",
"###PositConnectDeployment",
"1.**PrepareYourConnectServer**",
"-EnsureyouhaveaccesstoaPositConnectserver",
"-InstallrequiredRpackagesontheserver",
"-Configureuserpermissionsandaccesscontrols",
"",
"2.**DeploytheApplication**",
"-CopytheappfoldertoyourConnectserver",
"-Usethersconnectpackagetodeploy:",
"```r",
"library(rsconnect)",
"deployApp(appDir='app',account='your-account')",
"```",
"",
"3.**ConfigureStudySettings**",
"-Setenvironmentvariablesfordatabaseconnections",
"-Configuredatastorageandbackupsettings",
"-Setupmonitoringandlogging",
"",
"4.**TestandLaunch**",
"-Performcomprehensivetesting",
"-Configureuseraccessandpermissions",
"-Launchstudywithparticipantrecruitment"
)
}else if(deployment_type=="docker"){
instructions_content<-c(instructions_content,
"",
"###DockerDeployment",
"1.**BuildDockerImage**",
"```bash",
"dockerbuild-tinrep-study.",
"```",
"",
"2.**RunContainer**",
"```bash",
"dockerrun-p3838:3838inrep-study",
"```",
"",
"3.**ConfigurePersistentStorage**",
"-Mountvolumesfordatapersistence",
"-Configuredatabaseconnections",
"-Setupbackupstrategies",
"",
"4.**ScaleandMonitor**",
"-UseDockerComposeformulti-containersetup",
"-Configureloadbalancingifneeded",
"-Setupmonitoringandlogging"
)
}

instructions_content<-c(instructions_content,
"",
"##SecurityConsiderations",
"-Ensurealldatatransmissionsareencrypted(HTTPS)",
"-Implementproperauthenticationandauthorization",
"-Followdataprotectionregulations(GDPR,HIPAA)",
"-Regularsecurityupdatesandmonitoring",
"",
"##SupportandMaintenance",
"-Regularbackupverification",
"-Monitorstudyperformanceandparticipantfeedback",
"-Updatestudyconfigurationasneeded",
"-Archivedataaccordingtoinstitutionalpolicies",
"",
"##Troubleshooting",
"Commonissuesandsolutionsaredocumentedinthevalidationreport.",
"Foradditionalsupport,contacttheinrepplatformteam.",
"",
"---",
"Generatedbyinreppackagedeploymentsystem",
paste0("DeploymentID:",basename(deployment_path))
)

writeLines(instructions_content,instructions_path)
return(instructions_path)
}


#Helperfunctionsforgeneratingappcomponents
generate_app_file<-function(study_config,item_bank,advanced_features){
c(
"#inrepPlatformDeploymentApp",
"#Generatedbylaunch_to_inrep_platform()",
"",
"library(shiny)",
"library(inrep)",
"library(TAM)",
"library(DT)",
"library(ggplot2)",
"",
"#Loadstudyconfiguration",
"study_config<-readRDS('config/study_config.rds')",
"item_bank<-readRDS('data/item_bank.rds')",
"",
"#SourceUIandservercomponents",
"source('ui.R')",
"source('server.R')",
"",
"#Runtheapplication",
"shinyApp(ui=ui,server=server)"
)
}

generate_ui_file<-function(study_config,advanced_features){
c(
"#UIcomponentforinrepdeployment",
"ui<-build_study_ui(",
paste0("config=study_config,"),
paste0("theme='",study_config$theme,"',"),
paste0("advanced_features=",deparse(advanced_features),","),
paste0("deployment_mode=TRUE"),
")"
)
}

generate_server_file<-function(study_config,item_bank,advanced_features){
c(
"#Servercomponentforinrepdeployment",
"server<-function(input,output,session){",
"#Initializestudysession",
"study_session<-reactive({",
"initialize_study_session(study_config,item_bank)",
"})",
"",
"#Mainassessmentlogic",
"observeEvent(input$start_assessment,{",
"run_adaptive_assessment(study_session(),input,output,session)",
"})",
"",
"#Resultsprocessing",
"observe({",
"if(!is.null(input$assessment_complete)){",
"process_assessment_results(study_session(),input,output,session)",
"}",
"})",
"}"
)
}

#Additionalhelperfunctions
generate_inrep_platform_config<-function(study_config,contact_info,advanced_features,security_settings){
list(
platform="inrep_official",
study_config=study_config,
contact_info=contact_info,
advanced_features=advanced_features,
security_settings=security_settings,
hosting_requirements=list(
server_type="professional",
ssl_required=TRUE,
backup_frequency="daily",
monitoring="24/7"
)
)
}

generate_posit_connect_config<-function(study_config,advanced_features){
list(
platform="posit_connect",
study_config=study_config,
advanced_features=advanced_features,
deployment_settings=list(
r_version=paste0(R.version$major,".",R.version$minor),
packages=c("inrep","shiny","TAM","DT","ggplot2"),
memory_limit="2GB",
timeout=3600
)
)
}

generate_docker_config<-function(study_config,advanced_features){
list(
platform="docker",
study_config=study_config,
advanced_features=advanced_features,
container_settings=list(
base_image="rocker/shiny",
port=3838,
volumes=c("./data:/app/data","./logs:/app/logs"),
environment=list(
SHINY_PORT=3838,
SHINY_HOST="0.0.0.0"
)
)
)
}

generate_generic_config<-function(study_config,advanced_features){
list(
platform="generic",
study_config=study_config,
advanced_features=advanced_features,
deployment_notes="Genericconfigurationforcustomdeployment"
)
}

generate_manifest<-function(study_config,item_bank,deployment_type,contact_info){
manifest<-list(
deployment_info=list(
package_version="1.0.0",
deployment_type=deployment_type,
created_at=Sys.time(),
r_version=paste0(R.version$major,".",R.version$minor)
),
study_info=list(
name=study_config$name,
model=study_config$model,
num_items=nrow(item_bank),
languages=study_config$language %||% "en"
),
contact_info=contact_info,
files=list(
app=c("app.R","ui.R","server.R"),
config=c("study_config.rds","deployment_config.rds"),
data=c("item_bank.rds"),
docs=c("deployment_instructions.md","contact_template.md")
)
)

jsonlite::toJSON(manifest,pretty=TRUE,auto_unbox=TRUE)
}

create_study_metadata<-function(study_config,item_bank,contact_info,deployment_results){
list(
study_name=study_config$name,
model=study_config$model,
num_items=nrow(item_bank),
max_items=study_config$max_items,
min_SEM=study_config$min_SEM,
language=study_config$language,
theme=study_config$theme,
features=deployment_results$deployment_config$advanced_features,
contact=contact_info$email,
institution=contact_info$institution,
deployment_id=deployment_results$deployment_id,
created_at=deployment_results$timestamp
)
}

validate_deployment_package<-function(deployment_path,deployment_type){
validation_results<-list(
structure_check=dir.exists(file.path(deployment_path,c("app","data","config","docs"))),
app_files_check=file.exists(file.path(deployment_path,"app",c("app.R","ui.R","server.R"))),
config_files_check=file.exists(file.path(deployment_path,"config",c("study_config.rds","deployment_config.rds"))),
data_files_check=file.exists(file.path(deployment_path,"data","item_bank.rds")),
docs_check=file.exists(file.path(deployment_path,"docs",c("deployment_instructions.md","contact_template.md"))),
overall_status="PASS"
)

if(any(unlist(validation_results[1:5])==FALSE)){
validation_results$overall_status<-"FAIL"
}

return(validation_results)
}

generate_deployment_summary<-function(deployment_results,deployment_path){
summary_content<-c(
"#inrepPlatformDeploymentSummary",
"",
paste0("**DeploymentID:**",deployment_results$deployment_id),
paste0("**Created:**",deployment_results$timestamp),
paste0("**DeploymentType:**",deployment_results$deployment_type),
"",
"##StudyInformation",
paste0("-**StudyName:**",deployment_results$study_metadata$study_name),
paste0("-**Model:**",deployment_results$study_metadata$model),
paste0("-**NumberofItems:**",deployment_results$study_metadata$num_items),
paste0("-**MaximumItems:**",deployment_results$study_metadata$max_items),
paste0("-**MinimumSEM:**",deployment_results$study_metadata$min_SEM),
"",
"##DeploymentPackageContents",
"- Application files (app.R, ui.R, server.R)",
"- Study configuration and item bank",
"- Deployment instructions and documentation",
"- Contact template for platform team",
"- Validation reports and quality checks",
"",
"##NextSteps",
"1.Reviewthecontacttemplateindocs/contact_template.md",
"2.Followdeploymentinstructionsindocs/deployment_instructions.md",
"3.Contactselva@uni-hildesheim.deforofficialplatformhosting",
"",
"##PackageStructure",
"```",
paste0(basename(deployment_path),"/"),
"├──app/#Shinyapplicationfiles",
"├──config/#Studyanddeploymentconfiguration",
"├──data/#Itembankandstudydata",
"├──docs/#Documentationandinstructions",
"├──validation/#Validationreports",
"└──deployment/#Deploymentmanifestandmetadata",
"```"
)

writeLines(summary_content,file.path(deployment_path,"DEPLOYMENT_SUMMARY.md"))
}

# (NULL coalescing operator defined in study_flow_helpers.R)
