#!/bin/bash

# Directory containing the scripts (current directory)
SCRIPTS_DIR=$(dirname "$0")

# File to store last modified dates
TIMESTAMP_FILE="$SCRIPTS_DIR/last_modified.txt"

# Mapping of files to scripts and their execution order
declare -A FILE_TO_SCRIPT_MAP=(
    ["libraries_public_python.txt"]="install_libraries_public_python.ps1"
    # Add more mappings as needed
    # ["other_file.txt"]="other_script.sh"
)
'
# Function to schedule a script using Task Scheduler
schedule_task() {
    local script_path=$1
    local schedule_time=$(date -d "+1 minute" +"%H:%M")
    local schedule_date=$(date -d "+1 minute" +"%m/%d/%Y")
    local task_name=$(basename "$script_path" .ps1)_task

    schtasks /create /tn "$task_name" /tr "$script_path" /sc once /st $schedule_time /sd $schedule_date /f
    echo "Scheduled task for $script_path at $schedule_date $schedule_time"
}

# Initialize the timestamp file if it does not exist
if [ ! -f "$TIMESTAMP_FILE" ]; then
    touch "$TIMESTAMP_FILE"
fi

# Iterate through the mapping of files to scripts
for file_name in "${!FILE_TO_SCRIPT_MAP[@]}"; do
    script_name="${FILE_TO_SCRIPT_MAP[$file_name]}"
    script_path="$SCRIPTS_DIR/$script_name"
    file_path="$SCRIPTS_DIR/$file_name"

    if [ -f "$file_path" ] && [ -f "$script_path" ]; then
        # Get the last modified date of the file
        last_modified=$(stat -c %Y "$file_path")

        # Check if the file has a previous timestamp recorded
        previous_modified=$(grep "$file_path" "$TIMESTAMP_FILE" | cut -d' ' -f2)

        # If the file is modified or new, schedule the corresponding script
        if [ "$last_modified" != "$previous_modified" ]; then
            schedule_task "$script_path"

            # Update the timestamp file
            grep -v "$file_path" "$TIMESTAMP_FILE" > tmpfile && mv tmpfile "$TIMESTAMP_FILE"
            echo "$file_path $last_modified" >> "$TIMESTAMP_FILE"
        fi
    else
        if [ ! -f "$file_path" ]; then
            echo "File $file_path not found!"
        fi
        if [ ! -f "$script_path" ]; then
            echo "Script $script_path not found!"
        fi
    fi
done
