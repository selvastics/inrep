## -----------------------------------------------------------------------------
library(profvis)
library(knitr)

knitr::opts_chunk$set(collapse = TRUE, comment = "#>")

# Make output a little less tall by default
registerS3method("knit_print", "htmlwidget", function(x, ...) {
  # Get the chunk height
  height <- knitr::opts_current$get("height")
  if (length(height) > 0 && height != FALSE)
    x$height <- height
  else
    x$height <- "450px"

  htmlwidgets:::knit_print.htmlwidget(x, ...)
})

## ----abline, fig.show="hide"--------------------------------------------------
library(profvis)

profvis({
  df <- data.frame(x = rnorm(5e5), y = rnorm(5e5))

  plot(y ~ x, data = df)
  m <- lm(y ~ x, data = df)
  abline(m, col = "red")
})

