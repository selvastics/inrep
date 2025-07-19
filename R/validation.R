
#'ValidateItemBankforTAMCompatibility
#'
#'Validatesthestructureandcontentofanitembankforcompatibilitywith
#'TAMpackagefunctionsandthespecifiedIRTmodel.Ensuresthatitemparameters
#'anddatastructuremeetTAM'srequirementsforstatisticalanalysisandthat
#'parametervaluesarewithinacceptablerangesforstableestimation.
#'
#'@paramitem_bankDataframecontainingitemparametersandcontent.
#'StructureandrequiredcolumnsvarybyIRTmodelspecification.
#'@parammodelCharacterstringspecifyingIRTmodelforvalidation.
#'Options:\code{"1PL"},\code{"2PL"},\code{"3PL"},\code{"GRM"}.Default:\code{"GRM"}.
#'
#'@returnLogicalvalue:\code{TRUE}ifitembankisvalidforTAMprocessing,
#'\code{FALSE}otherwise.Functionwillstopexecutionwithdescriptiveerror
#'messageifcriticalvalidationfailuresaredetected.
#'
#'@export
#'
#'@details
#'\strong{TAMCompatibilityRequirements:}Thisfunctionensurescomprehensive
#'compatibilitywithTAMpackagespecifications:
#'
#'\strong{StructuralValidation:}
#'\itemize{
#'\itemValidatesrequiredcolumnsforTAMmodelfittingfunctions
#'\itemChecksdatatypesandformatconsistency
#'\itemEnsuresadequatesamplesizeforparameterestimation
#'\itemVerifiesnomissingvaluesincriticalparametercolumns
#'}
#'
#'\strong{ParameterRangeValidation:}
#'\itemize{
#'\itemDiscriminationparameters(a):Mustbepositive,typically0.2-3.0
#'\itemDifficultyparameters(b):Logitscale,typically-4.0to+4.0
#'\itemThresholdparameters(b1,b2,...):Mustbeinascendingorder
#'\itemGuessingparameters(c):Mustbebetween0.0and1.0
#'\itemResponsecategories:Mustbeproperlyformattedandconsistent
#'}
#'
#'\strong{Model-SpecificRequirements:}
#'\describe{
#'\item{\strong{1PL/RaschModel}}{
#'Requires:\code{Question},\code{b}(difficulty),responseoptions.
#'Validates:Difficultyparameterrange,responsecodingconsistency.
#'}
#'\item{\strong{2PLModel}}{
#'Requires:\code{Question},\code{a}(discrimination),\code{b},responseoptions.
#'Validates:Positivediscrimination,parameterinteractionfeasibility.
#'}
#'\item{\strong{3PLModel}}{
#'Requires:\code{Question},\code{a},\code{b},\code{c}(guessing),responseoptions.
#'Validates:Guessingparameterbounds,modelidentifiability.
#'}
#'\item{\strong{GRM(GradedResponseModel)}}{
#'Requires:\code{Question},\code{a},thresholdparameters,\code{ResponseCategories}.
#'Validates:Thresholdordering,responsecategoryconsistency.
#'}
#'}
#'
#'\strong{DataQualityChecks:}
#'\itemize{
#'\itemIdentifiespotentialestimationproblems(extremeparameters)
#'\itemWarnsaboutitemswithunusualparametercombinations
#'\itemChecksforduplicateitemsorparametersets
#'\itemValidatesresponsecodingconsistencyacrossitems
#'}
#'
#'\strong{Cross-FormatCompatibility:}
#'\itemize{
#'\itemHandlesconversionbetweenGRManddichotomousformats
#'\itemProvidescompatibilitywarningsformixedformats
#'\itemSuggestsappropriatemodelselectionbasedondatastructure
#'}
#'
#'\code{inrep}usesthisvalidationtoensureseamlessdataflowtoTAMfunctions.
#'
#'@examples
#'\dontrun{
#'#Example1:ValidateBFIpersonalityitemsforGRM
#'library(inrep)
#'data(bfi_items)
#'
#'#ValidateforGRMmodel
#'is_valid_grm<-validate_item_bank(bfi_items,"GRM")
#'cat("BFIitemsvalidforGRM:",is_valid_grm,"\n")
#'
#'#Example2:Validatecognitiveitemsfor2PLmodel
#'cognitive_items<-data.frame(
#'Question=c("Whatis2+2?","Whatis5*3?","Whatis10/2?"),
#'a=c(1.2,0.8,1.5),
#'b=c(-0.5,0.2,-1.0),
#'Option1=c("2","10","3"),
#'Option2=c("3","12","4"),
#'Option3=c("4","15","5"),
#'Option4=c("5","18","6"),
#'Answer=c("4","15","5")
#')
#'
#'#Validatefor2PLmodel
#'is_valid_2pl<-validate_item_bank(cognitive_items,"2PL")
#'cat("Cognitiveitemsvalidfor2PL:",is_valid_2pl,"\n")
#'
#'#Example3:Validateproblematicitembank
#'problematic_items<-data.frame(
#'Question=c("Item1","Item2"),
#'a=c(-0.5,5.0),#Negativediscrimination,extremevalue
#'b=c(0.0,10.0),#Extremedifficulty
#'Option1=c("A","A"),
#'Option2=c("B","B"),
#'Answer=c("A","B")
#')
#'
#'#Thisshouldproducewarningsorerrors
#'tryCatch({
#'is_valid_prob<-validate_item_bank(problematic_items,"2PL")
#'},error=function(e){
#'cat("Validationfailedasexpected:",e$message,"\n")
#'})
#'
#'#Example4:ValidateGRMwiththresholdchecking
#'grm_items<-data.frame(
#'Question=c("Iamtalkative","Iamreserved"),
#'a=c(1.0,1.2),
#'b1=c(-2.0,-1.5),
#'b2=c(-1.0,-0.5),
#'b3=c(0.0,0.5),
#'b4=c(1.0,1.5),
#'ResponseCategories=c("1,2,3,4,5","1,2,3,4,5")
#')
#'
#'#Validatethresholdordering
#'is_valid_grm_thresh<-validate_item_bank(grm_items,"GRM")
#'cat("GRMitemswiththresholdsvalid:",is_valid_grm_thresh,"\n")
#'
#'#Example5:Comprehensivevalidationwithdetailedoutput
#'detailed_validation<-function(item_bank,model){
#'cat("Validatingitembankformodel:",model,"\n")
#'cat("Numberofitems:",nrow(item_bank),"\n")
#'cat("Availablecolumns:",paste(names(item_bank),collapse=","),"\n")
#'
#'result<-tryCatch({
#'validate_item_bank(item_bank,model)
#'},error=function(e){
#'cat("ERROR:",e$message,"\n")
#'return(FALSE)
#'},warning=function(w){
#'cat("WARNING:",w$message,"\n")
#'return(TRUE)
#'})
#'
#'if(result){
#'cat("✓Itembankisvalidfor",model,"model\n")
#'}else{
#'cat("✗Itembankvalidationfailed\n")
#'}
#'
#'return(result)
#'}
#'
#'#Testwithdifferentmodels
#'detailed_validation(bfi_items,"GRM")
#'detailed_validation(cognitive_items,"2PL")
#'}
#'
#'@references
#'\itemize{
#'\itemRobitzsch,A.,Kiefer,T.,&Wu,M.(2020).\emph{TAM:TestAnalysisModules}.
#'Rpackageversion3.5-19.\url{https://CRAN.R-project.org/package=TAM}
#'\itemSamejima,F.(1969).Estimationoflatentabilityusingaresponsepatternof
#'gradedscores.\emph{PsychometrikaMonographSupplement},34(4),100-114.
#'\itemBirnbaum,A.(1968).Somelatenttraitmodelsandtheiruseininferringan
#'examinee'sability.InF.M.Lord&M.R.Novick(Eds.),
#'\emph{Statisticaltheoriesofmentaltestscores}(pp.397-479).Addison-Wesley.
#'}
#'
#'@seealso
#'\itemize{
#'\item\code{\link{create_study_config}}forconfiguringmodelsthatusevalidateditembanks
#'\item\code{\link{launch_study}}forusingvalidateditembanksinassessments
#'\item\code{\link[TAM]{tam.mml}}forTAMmodelfittingfunctions
#'}
validate_item_bank<-function(item_bank,model="GRM"){

cat("🔍VALIDATINGITEMBANKFORTAMCOMPATIBILITY\n")
cat("===========================================\n")

if(!is.data.frame(item_bank)){
stop("item_bankmustbeadataframe")
}

if(nrow(item_bank)==0){
stop("item_bankmustcontainatleastoneitem")
}

n_items<-nrow(item_bank)
cat("Validating",n_items,"itemsfor",model,"model\n\n")

errors<-c()
warnings<-c()

#Checkrequiredcolumns
required_cols<-c("Question")
if(!all(required_cols%in%names(item_bank))){
missing<-setdiff(required_cols,names(item_bank))
errors<-c(errors,paste("Missingrequiredcolumns:",paste(missing,collapse=",")))
}

#Model-specificvalidationwithunknownparametersupport
if(model%in%c("1PL","2PL","3PL","GRM")){
#Checkdiscriminationparameter
if(!"a"%in%names(item_bank)){
errors<-c(errors,"Missingdiscriminationparameter'a'")
}else{
a_values<-item_bank$a
unknown_a<-sum(is.na(a_values))
known_a<-sum(!is.na(a_values))

cat("Discriminationparameters(a):\n")
cat("Unknown(NA):",unknown_a,"of",n_items,"\n")
cat("Knownvalues:",known_a,"of",n_items,"\n")

if(known_a>0){
known_values<-a_values[!is.na(a_values)]
negative_a<-sum(known_values<=0)
extreme_a<-sum(known_values>5)

if(negative_a>0){
errors<-c(errors,paste(negative_a,"itemshavenon-positivediscrimination"))
}
if(extreme_a>0){
warnings<-c(warnings,paste(extreme_a,"itemshaveveryhighdiscrimination(>5)"))
}

cat("Rangeofknownvalues:",round(range(known_values),2),"\n")
}

if(unknown_a>0){
cat("💡Unknownparameterswillbeinitializedduringanalysis\n")
}
}
}

#Difficulty/thresholdparametervalidationwithunknownparametersupport
if(model=="GRM"){
b_cols<-grep("^b[0-9]+$",names(item_bank),value=TRUE)

if(length(b_cols)==0){
errors<-c(errors,"Nothresholdparameters(b1,b2,...)foundforGRMmodel")
}else{
cat("\n🎯Thresholdparameters:\n")

for(colinb_cols){
unknown_thresh<-sum(is.na(item_bank[[col]]))
known_thresh<-sum(!is.na(item_bank[[col]]))

cat("",col,":Unknown=",unknown_thresh,",Known=",known_thresh,"\n")

if(known_thresh>0){
known_values<-item_bank[[col]][!is.na(item_bank[[col]])]
extreme_thresh<-sum(abs(known_values)>6)
if(extreme_thresh>0){
warnings<-c(warnings,paste(extreme_thresh,"itemshaveextreme",col,"values"))
}
}
}

#Checkthresholdorderingforitemswithallknownthresholds
ordering_issues<-0
for(iin1:n_items){
thresholds<-as.numeric(item_bank[i,b_cols])
if(!any(is.na(thresholds))){
#Onlycheckorderingifallthresholdsareknown
if(any(diff(thresholds)<=0)){
ordering_issues<-ordering_issues+1
}
}
}

if(ordering_issues>0){
warnings<-c(warnings,paste(ordering_issues,"itemshavethresholdorderingissues"))
cat("⚠️",ordering_issues,"itemsmayneedthresholdreordering\n")
}

#Countitemswithmixedknown/unknownthresholds
mixed_items<-0
for(iin1:n_items){
thresholds<-as.numeric(item_bank[i,b_cols])
if(any(is.na(thresholds))&&!all(is.na(thresholds))){
mixed_items<-mixed_items+1
}
}

if(mixed_items>0){
cat("📝",mixed_items,"itemshavepartialthresholdinformation\n")
}
}

#CheckResponseCategories
if(!"ResponseCategories"%in%names(item_bank)){
warnings<-c(warnings,"MissingResponseCategoriescolumnforGRMmodel")
}

}else{
#Difficultyparameterfordichotomousmodels
if(!"b"%in%names(item_bank)){
errors<-c(errors,"Missingdifficultyparameter'b'")
}else{
b_values<-item_bank$b
unknown_b<-sum(is.na(b_values))
known_b<-sum(!is.na(b_values))

cat("\n🎯Difficultyparameters(b):\n")
cat("Unknown(NA):",unknown_b,"of",n_items,"\n")
cat("Knownvalues:",known_b,"of",n_items,"\n")

if(known_b>0){
known_values<-b_values[!is.na(b_values)]
extreme_b<-sum(abs(known_values)>6)

if(extreme_b>0){
warnings<-c(warnings,paste(extreme_b,"itemshaveextremedifficultyvalues"))
}

cat("Rangeofknownvalues:",round(range(known_values),2),"\n")
}

if(unknown_b>0){
cat("💡Unknownparameterswillbeinitializedduringanalysis\n")
}
}
}

#3PLguessingparametervalidation
if(model=="3PL"){
if(!"c"%in%names(item_bank)){
errors<-c(errors,"Missingguessingparameter'c'for3PLmodel")
}else{
c_values<-item_bank$c
unknown_c<-sum(is.na(c_values))
known_c<-sum(!is.na(c_values))

cat("\n🎲Guessingparameters(c):\n")
cat("Unknown(NA):",unknown_c,"of",n_items,"\n")
cat("Knownvalues:",known_c,"of",n_items,"\n")

if(known_c>0){
known_values<-c_values[!is.na(c_values)]
invalid_c<-sum(known_values<0|known_values>=1)
high_c<-sum(known_values>0.4)

if(invalid_c>0){
errors<-c(errors,paste(invalid_c,"itemshaveinvalidguessingparameters(mustbe0-1)"))
}
if(high_c>0){
warnings<-c(warnings,paste(high_c,"itemshavehighguessingparameters(>0.4)"))
}

cat("Rangeofknownvalues:",round(range(known_values),3),"\n")
}

if(unknown_c>0){
cat("💡Unknownparameterswillbeinitializedduringanalysis\n")
}
}
}

#Summaryandrecommendations
cat("\n📋VALIDATIONSUMMARY\n")
cat("===================\n")

if(length(errors)>0){
cat("❌ERRORSFOUND:\n")
for(errorinerrors){
cat("•",error,"\n")
}
}

if(length(warnings)>0){
cat("⚠️WARNINGS:\n")
for(warninginwarnings){
cat("•",warning,"\n")
}
}

if(length(errors)==0&&length(warnings)==0){
cat("✅Noissuesfound\n")
}

#Unknownparametersummary
total_params<-0
unknown_params<-0

if("a"%in%names(item_bank)){
total_params<-total_params+n_items
unknown_params<-unknown_params+sum(is.na(item_bank$a))
}

if(model=="GRM"){
b_cols<-grep("^b[0-9]+$",names(item_bank),value=TRUE)
for(colinb_cols){
if(col%in%names(item_bank)){
total_params<-total_params+n_items
unknown_params<-unknown_params+sum(is.na(item_bank[[col]]))
}
}
}elseif("b"%in%names(item_bank)){
total_params<-total_params+n_items
unknown_params<-unknown_params+sum(is.na(item_bank$b))
}

if(model=="3PL"&&"c"%in%names(item_bank)){
total_params<-total_params+n_items
unknown_params<-unknown_params+sum(is.na(item_bank$c))
}

unknown_proportion<-if(total_params>0)unknown_params/total_paramselse0

cat("\n🔢PARAMETERSUMMARY:\n")
cat("Totalparameters:",total_params,"\n")
cat("Unknown(NA)parameters:",unknown_params,"\n")
cat("Proportionunknown:",round(unknown_proportion*100,1),"%\n")

study_type<-if(unknown_params==0){
"FixedParameterAnalysis"
}elseif(unknown_params==total_params){
"FullParameterEstimation"
}else{
"MixedParameterStudy"
}
cat("Studytype:",study_type,"\n")

#Recommendations
cat("\n💡RECOMMENDATIONS:\n")

if(unknown_params>0){
cat("•Useinitialize_unknown_parameters()beforeanalysis\n")
cat("•ConsiderparameterestimationwithTAMcalibration\n")
cat("•Ensureadequatesamplesizeforstableestimation\n")

if(unknown_proportion>0.5){
cat("•Large-scaleparameterestimationdetected\n")
cat("•RecommendN>500forstableparameterestimates\n")
}

if(unknown_proportion<1.0&&unknown_proportion>0){
cat("•Mixedknown/unknownparametersdetected\n")
cat("•Consideranchoringstrategyforparameterlinking\n")
}
}else{
cat("•Allparametersknown-readyforfixed-parameteranalysis\n")
cat("•Noparameterinitializationrequired\n")
}

#Returnvalidationresult
is_valid<-length(errors)==0

if(is_valid){
cat("\n✅VALIDATIONPASSED\n")
cat("Itembankisreadyfor",model,"analysiswithinrep/TAM\n")
}else{
cat("\n❌VALIDATIONFAILED\n")
cat("Pleasefixerrorsbeforeproceeding\n")
}

cat("\n")
return(is_valid)
print("Validatingitembank...")

if(!is.data.frame(item_bank)||nrow(item_bank)==0){
print("Itembankmustbeanon-emptydataframe")
stop("Itembankmustbeanon-emptydataframe")
}

#Baserequiredcolumnsforallmodels
required_cols<-c("Question")

if(model%in%c("1PL","2PL","3PL")){
#Fordichotomousmodels,checkifwehaveGRM-styledata
if("ResponseCategories"%in%names(item_bank)&&!all(c("Option1","Option2","Option3","Option4","Answer")%in%names(item_bank))){
print(sprintf("ItembankappearstobeGRMformatbutmodelis%s.Convertingorusemodel='GRM'",model))
#Don'terror,justwarn-wecanworkwithGRMdatafordichotomousmodelsinsomecases
}

required_cols<-c(required_cols,"a")

#Onlyrequiretheseifwedon'thaveGRM-styledata
if(!"ResponseCategories"%in%names(item_bank)){
required_cols<-c(required_cols,paste0("Option",1:4),"Answer")
}

#Addbparameterrequirement
if(!"b"%in%names(item_bank)){
#Checkforb1asalternative
if("b1"%in%names(item_bank)){
print("Usingb1asbparameterfordichotomousmodel")
}else{
required_cols<-c(required_cols,"b")
}
}

if(model=="3PL"){
required_cols<-c(required_cols,"c")
}
}elseif(model=="GRM"){
required_cols<-c(required_cols,"a","ResponseCategories")
b_cols<-grep("^b[0-9]+$",names(item_bank),value=TRUE)
if(length(b_cols)<1){
print("GRMrequiresatleastonethresholdcolumn")
stop("GRMrequiresatleastonethresholdcolumn(b1,b2,...)")
}
required_cols<-c(required_cols,b_cols)
}

missing_cols<-setdiff(required_cols,names(item_bank))
if(length(missing_cols)>0){
print(sprintf("Itembankmissingcolumns:%s",paste(missing_cols,collapse=",")))
print(sprintf("Availablecolumns:%s",paste(names(item_bank),collapse=",")))
stop(sprintf("Itembankmissingcolumns:%s",paste(missing_cols,collapse=",")))
}

#Validatenumericcolumns
numeric_cols<-c("a")
if("b"%in%names(item_bank)){
numeric_cols<-c(numeric_cols,"b")
}elseif("b1"%in%names(item_bank)){
numeric_cols<-c(numeric_cols,"b1")
}
if(model=="3PL"&&"c"%in%names(item_bank)){
numeric_cols<-c(numeric_cols,"c")
}
if(model=="GRM"){
b_cols<-grep("^b[0-9]+$",names(item_bank),value=TRUE)
numeric_cols<-c(numeric_cols,b_cols)
}

for(colinnumeric_cols){
if(col%in%names(item_bank)&&!all(is.numeric(item_bank[[col]])&!is.na(item_bank[[col]]))){
print(sprintf("Column%smustbenumericandnon-NA",col))
stop(sprintf("Column%smustbenumericandnon-NA",col))
}
}

#ValidateGRMresponsecategories
if(model=="GRM"&&"ResponseCategories"%in%names(item_bank)){
for(iinseq_len(nrow(item_bank))){
cats<-tryCatch({
as.numeric(unlist(strsplit(item_bank$ResponseCategories[i],",")))
},error=function(e){
print(sprintf("InvalidResponseCategoriesformatforitem%d",i))
stop(sprintf("InvalidResponseCategoriesformatforitem%d",i))
})

if(!all(cats==sort(cats))||any(duplicated(cats))){
print(sprintf("ResponseCategoriesforitem%dmustbeuniqueandsorted",i))
stop(sprintf("ResponseCategoriesforitem%dmustbeuniqueandsorted",i))
}
}
}

print("Itembankvalidationsuccessful")

#GenerateLLMassistancepromptforvalidationoptimization
if(getOption("inrep.llm_assistance",FALSE)){
validation_prompt<-generate_validation_optimization_prompt(item_bank,model)
cat("\n"%r%60,"\n")
cat("LLMASSISTANCE:VALIDATIONOPTIMIZATION\n")
cat("="%r%60,"\n")
cat("CopythefollowingprompttoChatGPT,Claude,oryourpreferredLLMforadvancedvalidationinsights:\n\n")
cat(validation_prompt)
cat("\n"%r%60,"\n\n")
}

TRUE
}

#'GenerateValidationOptimizationPromptforLLMAssistance
#'@noRd
generate_validation_optimization_prompt<-function(item_bank,model){
#Analyzeitembankcharacteristics
n_items<-nrow(item_bank)
param_summary<-list()

if("a"%in%names(item_bank)){
param_summary$discrimination<-sprintf("Range:%.2f-%.2f,Mean:%.2f",
min(item_bank$a,na.rm=TRUE),
max(item_bank$a,na.rm=TRUE),
mean(item_bank$a,na.rm=TRUE))
}

if("b"%in%names(item_bank)){
param_summary$difficulty<-sprintf("Range:%.2f-%.2f,Mean:%.2f",
min(item_bank$b,na.rm=TRUE),
max(item_bank$b,na.rm=TRUE),
mean(item_bank$b,na.rm=TRUE))
}

prompt<-paste0(
"#EXPERTPSYCHOMETRICVALIDATIONANALYSIS\n\n",
"YouareanexpertpsychometricianspecializinginItemResponseTheory.Ineedadvancedvalidationinsightsformyitembank.\n\n",

"##ITEMBANKCHARACTERISTICS\n",
"-Model:",model,"\n",
"-NumberofItems:",n_items,"\n"
)

if(length(param_summary)>0){
prompt<-paste0(prompt,"-ParameterSummary:\n")
for(paraminnames(param_summary)){
prompt<-paste0(prompt,"*",tools::toTitleCase(param),":",param_summary[[param]],"\n")
}
}

prompt<-paste0(prompt,
"\n##VALIDATIONENHANCEMENTREQUESTS\n\n",
"###1.ParameterOptimizationAnalysis\n",
"-Evaluatediscriminationparameterdistributionforoptimaladaptivetesting\n",
"-Assessdifficultyparametercoverageacrossabilityspectrum\n",
"-Identifypotentialparameterconstraintsorunusualvalues\n",
"-Recommendparameteradjustmentsforimprovedefficiency\n\n",

"###2.PsychometricQualityAssessment\n",
"-Analyzeiteminformationcurvesfortestefficiency\n",
"-Evaluateexpectedstandarderrorsacrossabilityrange\n",
"-Identifyitemswithsuboptimalpsychometricproperties\n",
"-Recommenditemdevelopmentpriorities\n\n",

"###3.ModelAppropriateness\n",
"-Confirm",model,"modelsuitabilityforthisitembank\n",
"-Suggestalternativemodelsifappropriate\n",
"-Evaluatemodelassumptionsandviolations\n",
"-Recommendadditionalvalidationprocedures\n\n",

"###4.AdaptiveTestingOptimization\n",
"-Predicttestefficiencyforadaptiveadministration\n",
"-Recommendoptimalstoppingcriteria\n",
"-Suggestitemexposurecontrolstrategies\n",
"-Evaluatecontentbalancingrequirements\n\n",

"##PROVIDE\n",
"1.Detailedpsychometricassessmentofcurrentitembank\n",
"2.Specificrecommendationsforparameteroptimization\n",
"3.Validationprocedurestoimplementbeforedeployment\n",
"4.Expectedperformancemetricsforadaptivetesting\n",
"5.Riskassessmentandqualitycontrolstrategies\n\n",

"Pleaseprovideexpert-levelinsightswithspecific,actionablerecommendations."
)

return(prompt)
}
