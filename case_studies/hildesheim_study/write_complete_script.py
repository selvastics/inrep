# This Python script writes the complete hildesheim_production.R file

complete_script = '''# =============================================================================
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
'''

with open('hildesheim_production.R', 'w') as f:
    f.write(complete_script)

print("File started. Now appending the rest...")
