#!/bin/bash

# Backup Script
# This script backs up a specified source directory to a destination directory, 
# with optional compression, logging, and old backup cleanup.

LOG_FILE="/var/log/backup_script.log"

# Function to log messages
log_message() {
    local MESSAGE=$1
    echo "$(date '+%Y-%m-%d %H:%M:%S') : $MESSAGE" >> "$LOG_FILE"
}

# Check for valid arguments
if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <source_directory> <destination_directory> [--compress]"
    log_message "ERROR: Insufficient arguments provided."
    exit 1
fi

SOURCE_DIR=$1
DEST_DIR=$2
COMPRESS=false

# Check for --compress flag
if [ "$#" -eq 3 ] && [ "$3" == "--compress" ]; then
    COMPRESS=true
fi

# Verify source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    log_message "ERROR: Source directory '$SOURCE_DIR' does not exist."
    exit 1
fi

# Create destination directory if it doesn't exist
if [ ! -d "$DEST_DIR" ]; then
    mkdir -p "$DEST_DIR"
    if [ $? -ne 0 ]; then
        log_message "ERROR: Failed to create destination directory '$DEST_DIR'."
        exit 1
    fi
fi

# Backup filename with timestamp
TIMESTAMP=$(date '+%Y-%m-%d_%H-%M-%S')
BACKUP_NAME="backup_${TIMESTAMP}"
BACKUP_PATH="$DEST_DIR/$BACKUP_NAME"

# Perform backup
if [ "$COMPRESS" = true ]; then
    BACKUP_PATH="${BACKUP_PATH}.tar.gz"
    tar -czf "$BACKUP_PATH" -C "$SOURCE_DIR" .
    if [ $? -eq 0 ]; then
        log_message "Backup created with compression: $BACKUP_PATH"
    else
        log_message "ERROR: Failed to create compressed backup."
        exit 1
    fi
else
    cp -r "$SOURCE_DIR" "$BACKUP_PATH"
    if [ $? -eq 0 ]; then
        log_message "Backup created without compression: $BACKUP_PATH"
    else
        log_message "ERROR: Failed to copy files for backup."
        exit 1
    fi
fi

# Cleanup old backups (older than 7 days)
find "$DEST_DIR" -type f -mtime +7 -exec rm -f {} \;
if [ $? -eq 0 ]; then
    log_message "Old backups (older than 7 days) removed from '$DEST_DIR'."
else
    log_message "ERROR: Failed to remove old backups."
fi

log_message "Backup process completed successfully."
exit 0
