.onAttach <- function(libname, pkgname) {
  packageStartupMessage(
    paste0(
      "\n===============================================================================\n",
      "   Welcome to inrep (v", utils::packageVersion("inrep"), ")\n",
      "===============================================================================\n",
      "   Instant Report for Adaptive Assessments\n",
      "   A comprehensive framework wrapper around TAM for psychometric research\n",
      "   \n",
      "   TAM Integration: All psychometric computations performed by TAM package\n",
      "   - IRT modeling: TAM's tam.mml family functions\n",
      "   - Ability estimation: TAM's WLE and EAP procedures  \n",
      "   - Information calculations: TAM's IRT.informationCurves\n",
      "   \n",
      "   inrep Framework: Workflow orchestration and interface management\n",
      "   - Shiny-based assessment interfaces with accessibility features\n",
      "   - Real-time data collection and session management\n",
      "   - Enterprise logging, cloud storage, and audit capabilities\n",
      "   \n",
      "   Documentation and Support:\n",
      "     - Comprehensive vignettes: browseVignettes('inrep')\n",
      "     - Function help: ?inrep or help(package='inrep')\n",
      "     - GitHub repository: https://github.com/selvastics/inrep\n",
      "     - TAM documentation: help(package='TAM')\n",
      "   \n",
      "   Quick Start:\n",
      "     config <- create_study_config(name='Demo', model='2PL', max_items=10)\n",
      "     launch_study(config, bfi_items)  # Requires Shiny environment\n",
      "   \n",
      "   Citation:\n",
      "     Selva, C. (2025). inrep: Instant Report for Adaptive\n",
      "     Assessments. R package version ", utils::packageVersion("inrep"), ".\n",
      "     \n",
      "   Note: Ensure TAM package is installed for psychometric computations and properly cited.\n",
      "===============================================================================\n"
    )
  )
}
