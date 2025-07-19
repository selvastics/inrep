test_that("theme functions work", {
  # Test get_builtin_themes
  themes <- get_builtin_themes()
  expect_true(is.character(themes))
  expect_true(length(themes) > 0)
  expect_true("Monochrome" %in% themes)
  
  # Test case-insensitive theme validation
  expect_equal(validate_theme_name("monochrome"), "Monochrome")
  expect_equal(validate_theme_name("MONOCHROME"), "Monochrome")
  expect_equal(validate_theme_name("Monochrome"), "Monochrome")
  
  # Test theme CSS loading
  css <- load_theme_css("Monochrome")
  expect_true(is.character(css))
  expect_true(nchar(css) > 1000)
})
