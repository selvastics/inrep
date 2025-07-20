# Check brace balance line by line in launch_study.R
lines <- readLines('R/launch_study.R')
balance <- 0
for (i in 1:length(lines)) {
  open_count <- nchar(gsub("[^{]", "", lines[i]))
  close_count <- nchar(gsub("[^}]", "", lines[i]))
  balance <- balance + open_count - close_count
  if (balance < 0) {
    cat("Line", i, "Balance:", balance, "Content:", substr(lines[i], 1, 80), "\n")
  }
}
cat("Final balance:", balance, "\n")
