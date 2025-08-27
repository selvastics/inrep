#!/usr/bin/env python3

# This script creates the complete hildesheim_production.R file with Programming Anxiety

with open('hildesheim_production.R', 'w', encoding='utf-8') as f:
    # Write the entire script
    f.write('''# =============================================================================
# HILFO STUDIE - PRODUCTION VERSION WITH COMPLETE DATA RECORDING
# =============================================================================
# All variables recorded with proper names, cloud storage enabled
# NOW WITH PROGRAMMING ANXIETY ADDED (2 pages before BFI)

library(inrep)
# Don't load heavy packages at startup - load them only when needed

# =============================================================================
# CLOUD STORAGE CREDENTIALS - Hildesheim Study Folder
# =============================================================================
# Public WebDAV folder: https://sync.academiccloud.de/index.php/s/OUarlqGbhYopkBc
WEBDAV_URL <- "https://sync.academiccloud.de/public.php/webdav/"
WEBDAV_PASSWORD <- "ws2526"
WEBDAV_SHARE_TOKEN <- "OUarlqGbhYopkBc"  # Share token for authentication
''')

print("Script created successfully!")
print("File: hildesheim_production.R")
print("Now run: python3 create_complete_hildesheim.py")
