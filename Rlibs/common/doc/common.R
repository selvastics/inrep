## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----eval=FALSE, echo=TRUE----------------------------------------------------
#  # Variable names passed to subset are quoted
#  dat <- mtcars[1:10 , c("mpg", "cyl", "disp")]
#  
#  # View results
#  dat
#                     mpg cyl  disp
#  Mazda RX4         21.0   6 160.0
#  Mazda RX4 Wag     21.0   6 160.0
#  Datsun 710        22.8   4 108.0
#  Hornet 4 Drive    21.4   6 258.0
#  Hornet Sportabout 18.7   8 360.0
#  Valiant           18.1   6 225.0
#  Duster 360        14.3   8 360.0
#  Merc 240D         24.4   4 146.7
#  Merc 230          22.8   4 140.8
#  Merc 280          19.2   6 167.6

## ----eval=FALSE, echo=TRUE----------------------------------------------------
#  # No quotes on "cyl" using subset() function
#  dt <- subset(dat, cyl == 4)
#  
#  # View results
#  dt
#  #             mpg cyl  disp
#  # Datsun 710 22.8   4 108.0
#  # Merc 240D  24.4   4 146.7
#  # Merc 230   22.8   4 140.8

## ----eval=FALSE, echo=TRUE----------------------------------------------------
#  # Create a vector of unquoted names
#  v1 <- v(mpg, cyl, disp)
#  
#  # Result is a quoted vector
#  v1
#  # [1] "mpg"  "cyl"  "disp"
#  
#  # Variable names not quoted
#  dat2 <- mtcars[1:10, v(mpg, cyl, disp)]
#  
#  # Works as expected
#  dat2
#  #                    mpg cyl  disp
#  # Mazda RX4         21.0   6 160.0
#  # Mazda RX4 Wag     21.0   6 160.0
#  # Datsun 710        22.8   4 108.0
#  # Hornet 4 Drive    21.4   6 258.0
#  # Hornet Sportabout 18.7   8 360.0
#  # Valiant           18.1   6 225.0
#  # Duster 360        14.3   8 360.0
#  # Merc 240D         24.4   4 146.7
#  # Merc 230          22.8   4 140.8
#  # Merc 280          19.2   6 167.6
#  

## ----eval=FALSE, echo=TRUE----------------------------------------------------
#  # Prepare data
#  dat <- mtcars[1:10, 1:3]
#  
#  # Get sort order
#  ord <- do.call('order', dat[ ,c("cyl", "mpg")])
#  
#  # Sort data
#  dat[ord, ]
#  #                    mpg cyl  disp
#  # Datsun 710        22.8   4 108.0
#  # Merc 230          22.8   4 140.8
#  # Merc 240D         24.4   4 146.7
#  # Valiant           18.1   6 225.0
#  # Merc 280          19.2   6 167.6
#  # Mazda RX4         21.0   6 160.0
#  # Mazda RX4 Wag     21.0   6 160.0
#  # Hornet 4 Drive    21.4   6 258.0
#  # Duster 360        14.3   8 360.0
#  # Hornet Sportabout 18.7   8 360.0

## ----eval=FALSE, echo=TRUE----------------------------------------------------
#  # Sort by cyl then mpg
#  dat1 <- sort(dat, by = v(cyl, mpg))
#  dat1
#  #                    mpg cyl  disp
#  # Datsun 710        22.8   4 108.0
#  # Merc 230          22.8   4 140.8
#  # Merc 240D         24.4   4 146.7
#  # Valiant           18.1   6 225.0
#  # Merc 280          19.2   6 167.6
#  # Mazda RX4         21.0   6 160.0
#  # Mazda RX4 Wag     21.0   6 160.0
#  # Hornet 4 Drive    21.4   6 258.0
#  # Duster 360        14.3   8 360.0
#  # Hornet Sportabout 18.7   8 360.0
#  
#  # Sort by cyl descending then mpg ascending
#  dat2 <- sort(dat, by = v(cyl, mpg),
#               ascending = c(FALSE, TRUE))
#  dat2
#  #                    mpg cyl  disp
#  # Duster 360        14.3   8 360.0
#  # Hornet Sportabout 18.7   8 360.0
#  # Valiant           18.1   6 225.0
#  # Merc 280          19.2   6 167.6
#  # Mazda RX4         21.0   6 160.0
#  # Mazda RX4 Wag     21.0   6 160.0
#  # Hornet 4 Drive    21.4   6 258.0
#  # Datsun 710        22.8   4 108.0
#  # Merc 230          22.8   4 140.8
#  # Merc 240D         24.4   4 146.7
#  

## ----eval=FALSE, echo=TRUE----------------------------------------------------
#  # Prepare data
#  dat <- mtcars[1:10, 1:3]
#  
#  # Assign labels
#  attr(dat$mpg, "label") <- "Miles Per Gallon"
#  attr(dat$cyl, "label") <- "Cylinders"
#  attr(dat$disp, "label") <- "Displacement"
#  

## ----eval=FALSE, echo=TRUE----------------------------------------------------
#  # Prepare data
#  dat <- mtcars[1:10, 1:3]
#  
#  # Assign labels
#  labels(dat) <- list(mpg = "Miles Per Gallon",
#                      cyl = "Cylinders",
#                      disp = "Displacement")
#  
#  # View label attributes
#  labels(dat)
#  # $mpg
#  # [1] "Miles Per Gallon"
#  #
#  # $cyl
#  # [1] "Cylinders"
#  #
#  # $disp
#  # [1] "Displacement"

## ----eval=FALSE, echo=TRUE----------------------------------------------------
#  # Concatenation using paste0() function
#  paste0("There are ", nrow(mtcars), " rows in the mtcars data frame")
#  # [1] "There are 32 rows in the mtcars data frame"
#  
#  # Concatenation using %p% operator
#  "There are " %p% nrow(mtcars) %p% " rows in the mtcars data frame"
#  # [1] "There are 32 rows in the mtcars data frame"
#  

## ----eval=FALSE, echo=TRUE----------------------------------------------------
#  
#  # Comparing of NULLs and NA
#  NULL %eq% NULL        # TRUE
#  NULL %eq% NA          # FALSE
#  NA %eq% NA            # TRUE
#  1 %eq% NULL           # FALSE
#  1 %eq% NA             # FALSE
#  
#  # Comparing of atomic values
#  1 %eq% 1              # TRUE
#  "one" %eq% "one"      # TRUE
#  1 %eq% "one"          # FALSE
#  1 %eq% Sys.Date()     # FALSE
#  
#  # Comparing of vectors
#  v1 <- c("A", "B", "C")
#  v2 <- c("A", "B", "C", "D")
#  v1 %eq% v1            # TRUE
#  v1 %eq% v2            # FALSE
#  
#  # Comparing of data frames
#  mtcars %eq% mtcars    # TRUE
#  mtcars %eq% iris      # FALSE
#  iris %eq% iris[1:50,] # FALSE
#  
#  # Mixing it up
#  mtcars %eq% NULL      # FALSE
#  v1 %eq% NA            # FALSE
#  1 %eq% v1             # FALSE

## ----eval=FALSE, echo=TRUE----------------------------------------------------
#  # Get current path
#  pth <- Sys.path()
#  
#  # View path
#  pth
#  # [1] "C:/packages/common/vignettes/common.Rmd"

## ----eval=FALSE, echo=TRUE----------------------------------------------------
#  # Prepare sample vector
#  v1 <- seq(0.5,9.5,by=1)
#  v1
#  # [1] 0.5 1.5 2.5 3.5 4.5 5.5 6.5 7.5 8.5 9.5
#  
#  # Base R round function
#  r1 <- round(v1)
#  
#  # Rounds to nearest even
#  r1
#  # [1]  0  2  2  4  4  6  6  8  8 10
#  

## ----eval=FALSE, echo=TRUE----------------------------------------------------
#  # Round up function
#  r2 <- roundup(v1)
#  
#  # Rounds 5 up
#  r2
#  # [1]  1  2  3  4  5  6  7  8  9 10
#  

## ----eval=FALSE, echo=TRUE----------------------------------------------------
#  # Negate original vector
#  v2 <- -v1
#  v2
#  # [1] -0.5 -1.5 -2.5 -3.5 -4.5 -5.5 -6.5 -7.5 -8.5 -9.5
#  
#  # Rounding negative values
#  r3 <- roundup(v2)
#  
#  # Rounds away from zero
#  r3
#  # [1]  -1  -2  -3  -4  -5  -6  -7  -8  -9 -10

## ----eval=FALSE, echo=TRUE----------------------------------------------------
#  # Look for a file named "globals.R"
#  pths <- file.find(getwd(), "globals.R")
#  pths
#  
#  # Look for Rdata files three levels up, and two levels down
#  pths <- file.find(getwd(), "*.Rdata", up = 3, down = 2)
#  pths

## ----eval=FALSE, echo=TRUE----------------------------------------------------
#  # Prepare data
#  dat <- mtcars
#  
#  # View names
#  names(dat)
#  # [1] "mpg"  "cyl"  "disp" "hp"   "drat" "wt"   "qsec" "vs"   "am"   "gear" "carb"
#  
#  # Get all names starting with "c"
#  find.names(dat, pattern = "c*")
#  # [1] "cyl"  "carb"
#  
#  # Get all names starting with "c" or "d"
#  find.names(dat, pattern = c("c*", "d*"))
#  # [1] "cyl"  "carb" "disp" "drat"
#  
#  # Get names starting with "c" or "d" from column 4 on
#  find.names(dat, pattern = c("c*", "d*"), start = 4)
#  # [1] "carb" "drat"
#  

## ----eval=FALSE, echo=TRUE----------------------------------------------------
#  # Prepare sample dataset
#  dat <- mtcars[ , 1:3]
#  
#  # Assign some labels
#  labels(dat) <- list(mpg = "Miles Per Gallon",
#                      cyl = "Cylinders",
#                      disp = "Displacement")
#  
#  # View labels
#  labels(dat)
#  # $mpg
#  # [1] "Miles Per Gallon"
#  #
#  # $cyl
#  # [1] "Cylinders"
#  #
#  # $disp
#  # [1] "Displacement"
#  
#  # Subset the data
#  dat2 <- subset(dat, cyl == 4)
#  
#  # Labels are gone!
#  labels(dat2)
#  # list()
#  

## ----eval=FALSE, echo=TRUE----------------------------------------------------
#  # Restore attributes
#  dat2 <- copy.attributes(dat, dat2)
#  
#  # Labels are back!
#  labels(dat2)
#  # $mpg
#  # [1] "Miles Per Gallon"
#  #
#  # $cyl
#  # [1] "Cylinders"
#  #
#  # $disp
#  # [1] "Displacement"
#  

## ----eval=FALSE, echo=TRUE----------------------------------------------------
#  # Separate two strings by 25 spaces
#  str <- paste0("Left", paste0(rep(" ", 25), collapse = ""), "Right", collapse = "")
#  str
#  # [1] "Left                         Right"
#  

## ----eval=FALSE, echo=TRUE----------------------------------------------------
#  # Separate two strings by 25 spaces
#  str <- "Left" %p% spaces(25) %p% "Right"
#  str
#  # [1] "Left                         Right"

## ----eval=FALSE, echo=TRUE----------------------------------------------------
#  # Create sample vector
#  v1 <- c(1, 1, 1, 2, 2, 3, 3, 3, 1, 1)
#  
#  # Identify duplicated values
#  res1 <- !duplicated(v1)
#  
#  # View duplicated results
#  res1
#  # [1] TRUE FALSE FALSE  TRUE FALSE  TRUE FALSE FALSE FALSE FALSE
#  

## ----eval=FALSE, echo=TRUE----------------------------------------------------
#  # Identify changed values
#  res2 <- changed(v1)
#  
#  # View changed results
#  res2
#  # [1] TRUE FALSE FALSE  TRUE FALSE  TRUE FALSE FALSE  TRUE FALSE
#  

## ----eval=FALSE, echo=TRUE----------------------------------------------------
#  # Create sample data frame
#  v2 <- c("A", "A", "A", "A", "A", "A", "B", "B", "B", "B")
#  dat <- data.frame(v1, v2)
#  
#  # View original data frame
#  dat
#  #    v1 v2
#  # 1   1  A
#  # 2   1  A
#  # 3   1  A
#  # 4   2  A
#  # 5   2  A
#  # 6   3  A
#  # 7   3  B
#  # 8   3  B
#  # 9   1  B
#  # 10  1  B
#  
#  # Get changed values for each column
#  res3 <- changed(dat)
#  
#  # View results
#  res3
#  #    v1.changed v2.changed
#  # 1        TRUE       TRUE
#  # 2       FALSE      FALSE
#  # 3       FALSE      FALSE
#  # 4        TRUE      FALSE
#  # 5       FALSE      FALSE
#  # 6        TRUE      FALSE
#  # 7       FALSE       TRUE
#  # 8       FALSE      FALSE
#  # 9        TRUE      FALSE
#  # 10      FALSE      FALSE

## ----eval=FALSE, echo=TRUE----------------------------------------------------
#  # Get changed values for each column
#  res4 <- changed(dat, simplify = TRUE)
#  
#  # View results
#  res4
#  # [1]  TRUE FALSE FALSE  TRUE FALSE  TRUE  TRUE FALSE  TRUE FALSE

## ----eval=FALSE, echo=TRUE----------------------------------------------------
#  # Find last items in each group
#  res3 <- changed(dat, reverse = TRUE)
#  
#  # View results
#  res3
#  #    v1.changed v2.changed
#  # 1       FALSE      FALSE
#  # 2       FALSE      FALSE
#  # 3        TRUE      FALSE
#  # 4       FALSE      FALSE
#  # 5        TRUE      FALSE
#  # 6       FALSE       TRUE
#  # 7       FALSE      FALSE
#  # 8        TRUE      FALSE
#  # 9       FALSE      FALSE
#  # 10       TRUE       TRUE
#  

