.onAttach <- function(libname, pkgname) {
  packageStartupMessage(
    paste0(
      "\n===============================================================================\n",
      "   Welcome to inrep (v", utils::packageVersion("inrep"), ")\n",
      "===============================================================================\n",
      "   Instant Reports for Adaptive Assessments\n",
      "   A comprehensive framework wrapper around TAM for psychometric research\n",
      "   \n",
      "===============================================================================\n"
    )
  )
}
