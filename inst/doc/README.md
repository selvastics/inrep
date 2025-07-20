# Documentation Files for inrep Package

This directory contains additional documentation for the inrep package beyond the standard R package documentation.

## Cloud Storage Configuration

For detailed information about setting up cloud storage with WebDAV for the `launch_study()` function, please refer to the main package documentation and examples.

### Key Points:
- Both `webdav_url` and `password` are required together for cloud storage
- Use environment variables for secure password handling
- Support for academic cloud storage, Nextcloud/ownCloud, and commercial WebDAV providers

### Example Usage:
```r
# Set environment variable
Sys.setenv(WEBDAV_PASSWORD = "your_secure_password")

# Launch study with cloud backup
launch_study(
  config, 
  item_bank,
  webdav_url = "https://your-cloud-storage.com/path/",
  password = Sys.getenv("WEBDAV_PASSWORD")
)
```

## See Also
- Package vignettes for comprehensive examples
- `?launch_study` for complete parameter documentation
- Examples in `inst/examples/` directory
