#!/bin/bash

# <swiftbar.hideAbout>true</swiftbar.hideAbout>
# <swiftbar.hideRunInTerminal>true</swiftbar.hideRunInTerminal>
# <swiftbar.hideLastUpdated>false</swiftbar.hideLastUpdated>
# <swiftbar.hideDisablePlugin>false</swiftbar.hideDisablePlugin>
# <swiftbar.hideSwiftBar>true</swiftbar.hideSwiftBar>

# Get current date components
WEEKDAY=$(date +%u) # 1-7 (Monday-Sunday)
DAY=$(date +%d)
MONTH=$(date +%-m) # 1-12
TIME=$(date +%H:%M)

# Arrays for Chinese characters
WEEKDAYS=('Mo' 'Tu' 'We' 'Th' 'Fr' 'Sa' 'Su')
MONTHS=('Jan' 'Feb' 'Mar' 'Apr' 'May' 'June' 'July' 'Aug' 'Sep' 'Oct' 'Nov' 'Dec')

# Convert to 0-based index for array access
WEEKDAY_INDEX=$((WEEKDAY - 1))
MONTH_INDEX=$((MONTH - 1))

# Format the date string
# echo "${WEEKDAYS[$WEEKDAY_INDEX]} $DAY/${MONTHS[$MONTH_INDEX]} $TIME"
echo "${WEEKDAYS[$WEEKDAY_INDEX]} $DAY/${MONTHS[$MONTH_INDEX]}"
echo "---"
echo "Full Date: $(date '+%Y-%m-%d %H:%M:%S')"
