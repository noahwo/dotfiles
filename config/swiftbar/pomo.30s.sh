#!/bin/bash

# <xbar.title>Pomodoro Timer with Logging and Analysis</xbar.title>
# <xbar.version>v1.3</xbar.version>
# <xbar.author>Martin Kourim</xbar.author>
# <xbar.author.github>mkoura</xbar.author.github>
# <xbar.desc>Timer that uses Pomodoro timeboxing with usage logging and analysis.</xbar.desc>
# <xbar.image>https://i.imgur.com/WswKpT4.png</xbar.image>

# pomodoro duration
readonly POMODORO=1500 # 25 min
# break duration
readonly BREAK=240 # 4 min
# long break duration
readonly LONG_BREAK=1200 # 20 min
# script to run (file path)
SCRIPT=""

# Get the plugin directory from SwiftBar preferences
SWIFTBAR_PLUGINS_PATH=$(defaults read com.ameba.SwiftBar PluginDirectory)

# Export it as an environment variable
export SWIFTBAR_PLUGINS_PATH

# Logging file paths
readonly LOG_DIR="$SWIFTBAR_PLUGINS_PATH/.pomodoro_logs"
readonly SESSION_LOG="$LOG_DIR/sessions.log"

# Ensure log directory exists
mkdir -p "$LOG_DIR"

# SCRIPT file example
##!/bin/bash
## plays sound when activity is finished
#case "$1" in
#  "finished"|"break_finished"|"long_break_finished" )
#    play some_sound_file
#esac

# icons
readonly TOMATO_ICON="🍅"
readonly BREAK_ICON="☕"
readonly LONG_BREAK_ICON="🎉"
readonly PAUSE_BIG_ICON="▮▮"
readonly PAUSE_ICON="⏸"
readonly STOP_ICON="⏹"
readonly CHECKED_ICON="✓"
readonly UNCHECKED_ICON="✗"

# ---

# must be updated at least every $MAX_UPDATE_INTERVAL seconds
readonly MAX_UPDATE_INTERVAL=60

# file for saving status
readonly STATUS_FILE="$HOME/.bitbar_pomodoro"

# running on Linux or Mac OS X?
[ -e /proc/uptime ] && LINUX="true" || LINUX=""
readonly LINUX

# checks if script is executable
[ -x "$SCRIPT" ] || SCRIPT=""
readonly SCRIPT

# saves current timestamp to the "now" variable
set_now() {
  [ -n "$now" ] && return

  # avoid spawning processes if possible
  if [ -n "$LINUX" ]; then
    now="$(read -r s _ </proc/uptime && echo "${s%.*}")"
  else
    now="$(date +%s)"
  fi
}

run_script() {
  [ -n "$SCRIPT" ] && "$SCRIPT" "$@" &
}

# displays desktop notification
notify_osd() {
  if [ -n "$LINUX" ]; then
    notify-send "$@" 2>/dev/null
  else
    osascript -e "display notification \"$*\" with title \"$TOMATO_ICON Pomodoro\"" 2>/dev/null
  fi
}

# writes current status to status file
status_write() {
  echo "$tstamp $togo $pomodoros $state $activity $loop" >"$STATUS_FILE"
}

# resets the status file
status_reset() {
  tstamp=0
  togo=0
  pomodoros=0
  state="STOP"
  activity="pomodoro"
  loop="${loop:-on}"
  status_write
}

# toggles whether to loop pomodoros
loop_toggle() {
  [ "$loop" = "on" ] && loop="off" || loop="on"
  status_write
}

# Logs session data
log_session() {
  local event=$1
  local timestamp
  timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  echo "$timestamp,$event,$activity,$pomodoros" >>"$SESSION_LOG"
}

# starts pomodoro
pomodoro_start() {
  set_now
  tstamp="$now"
  togo="$POMODORO"
  state="RUN"
  activity="pomodoro"
  status_write
  run_script start
  log_session "start_pomodoro"
}

# starts break
pomodoro_break() {
  set_now
  tstamp="$now"
  togo="$BREAK"
  state="RUN"
  activity="break"
  status_write
  run_script break
  log_session "start_break"
}

# starts long break
pomodoro_long_break() {
  set_now
  tstamp="$now"
  togo="$LONG_BREAK"
  pomodoros=0
  state="RUN"
  activity="long_break"
  status_write
  run_script long_break
  log_session "start_long_break"
}

# detects stale records, i.e. when computer
# was turned off during pomodoro
stale_record() {
  case "$activity" in
  "pomodoro")
    local interval="$POMODORO"
    ;;
  "break")
    local interval="$BREAK"
    ;;
  "long_break")
    local interval="$LONG_BREAK"
    ;;
  esac
  if ((tdiff < 0)) || ((tdiff > (interval + MAX_UPDATE_INTERVAL + 1))); then
    status_reset
    log_session "stale_reset"
    return 1
  fi
  return 0
}

# checks if activity is finished
# notifies if so and starts a new activity
pomodoro_update() {
  case "$state" in
  "STOP" | "PAUSE")
    return
    ;;
  "RUN") ;;
  *)
    status_reset
    log_session "unknown_state_reset"
    return
    ;;
  esac

  # RUN
  set_now
  tdiff="$((now - tstamp))"
  stale_record || return 1
  case "$activity" in
  "pomodoro")
    togo="$((POMODORO - tdiff))"
    if [ "$togo" -le 0 ]; then
      pomodoros="$((pomodoros + 1))"
      run_script finished
      log_session "finish_pomodoro"
      if [ "$pomodoros" -lt 4 ]; then
        notify_osd "Pomodoro completed, take a break."
        pomodoro_break
      else
        notify_osd "Four pomodoros completed, take a long break."
        pomodoro_long_break
      fi
    fi
    ;;
  "break")
    togo="$((BREAK - tdiff))"
    if [ "$togo" -le 0 ]; then
      run_script break_finished
      log_session "finish_break"
      if [ "$loop" = "off" ]; then
        notify_osd "Break is over."
        status_reset
        log_session "end_break_no_loop"
      else
        notify_osd "Break is over, focus on new pomodoro."
        pomodoro_start
      fi
    fi
    ;;
  "long_break")
    togo="$((LONG_BREAK - tdiff))"
    if [ "$togo" -le 0 ]; then
      run_script long_break_finished
      log_session "finish_long_break"
      if [ "$loop" = "off" ]; then
        notify_osd "Long break is over."
        status_reset
        log_session "end_long_break_no_loop"
      else
        notify_osd "Long break is over, focus on new pomodoro."
        pomodoro_start
      fi
    fi
    ;;
  *)
    status_reset
    log_session "unknown_activity_reset"
    ;;
  esac
}

# pauses or resumes activity
pause_resume() {
  pomodoro_update
  case "$state" in
  "RUN")
    # pause
    state="PAUSE"
    status_write # saves also up-to-date "togo"
    run_script pause
    log_session "pause"
    ;;
  "PAUSE")
    # resume
    set_now
    # sets new timestamp according to the saved "togo"
    case "$activity" in
    "pomodoro")
      tstamp="$((now - (POMODORO - togo)))"
      ;;
    "break")
      tstamp="$((now - (BREAK - togo)))"
      ;;
    "long_break")
      tstamp="$((now - (LONG_BREAK - togo)))"
      ;;
    esac
    state="RUN"
    status_write
    run_script resume
    log_session "resume"
    ;;
  *)
    status_reset
    log_session "unknown_pause_reset"
    ;;
  esac
}

# calculates remaining time
# saves remaining minutes to "rem"
# saves remaining seconds to "res"
calc_remaining_time() {
  [ -n "$rem" ] && return
  rem="$((togo / 60 % 60))"
  res="$((togo % 60))"
}

# prints remaining time in MIN:SEC format
print_remaining_time() {
  calc_remaining_time
  printf "%02d:%02d" "$rem" "$res"
}

# prints remaining time in whole minutes
print_remaining_minutes() {
  calc_remaining_time
  if [ "$rem" -eq 0 ]; then
    printf "<1m"
  else
    [ "$res" -ge 30 ] && remaining="$((rem + 1))" || remaining="$rem"
    printf "%02dm" "$remaining"
  fi
}

# Prints common menu items to avoid repetition
print_common_menu() {
  echo "---"
  echo "Generate Report | bash=\"$0\" param1=report terminal=true refresh=false"
}

# prints menu for argos/bitbar
print_menu() {
  case "$state" in
  "STOP")
    echo "$TOMATO_ICON"
    echo "---"
    echo "Pomodoro | bash=\"$0\" param1=start terminal=false refresh=true"
    echo "Break | bash=\"$0\" param1=break terminal=false refresh=true"
    echo "Long break | bash=\"$0\" param1=long_break terminal=false refresh=true"
    print_common_menu
    ;;
  "RUN")
    case "$activity" in
    "pomodoro")
      echo "$TOMATO_ICON $(print_remaining_minutes)"
      local caption=""
      ;;
    "break")
      echo "$BREAK_ICON $(print_remaining_minutes)"
      local caption="Break: "
      ;;
    "long_break")
      echo "$LONG_BREAK_ICON $(print_remaining_minutes)"
      local caption="Long break: "
      ;;
    esac
    echo "---"
    echo "${caption}$(print_remaining_time) | refresh=true"
    echo "${PAUSE_ICON} pause | bash=\"$0\" param1=pause terminal=false refresh=true"
    echo "${STOP_ICON} stop | bash=\"$0\" param1=stop terminal=false refresh=true"
    print_common_menu
    ;;
  "PAUSE")
    echo "$PAUSE_BIG_ICON $(print_remaining_minutes)"
    echo "---"
    case "$activity" in
    "pomodoro")
      local caption="Paused"
      ;;
    "break")
      local caption="Break"
      ;;
    "long_break")
      local caption="Long break"
      ;;
    esac
    echo "${caption}: $(print_remaining_time) | refresh=true"
    echo "${PAUSE_ICON} resume | bash=\"$0\" param1=pause terminal=false refresh=true"
    echo "${STOP_ICON} stop | bash=\"$0\" param1=stop terminal=false refresh=true"
    print_common_menu
    ;;
  esac

  echo "---"
  if [ "$loop" = "off" ]; then
    local acheck="$UNCHECKED_ICON"
  else
    local acheck="$CHECKED_ICON"
  fi
  echo "Loop pomodoros: ${acheck} | bash=\"$0\" param1=loop_toggle terminal=false refresh=true"
}

# Generates usage analysis report
generate_report() {
  if [ ! -f "$SESSION_LOG" ]; then
    echo "No session data available."
    exit 0
  fi

  echo "Pomodoro Usage Report"
  echo "---"

  # Total Pomodoros
  total_pomodoros=$(grep "finish_pomodoro" "$SESSION_LOG" | wc -l)
  echo "Total Pomodoros: $total_pomodoros"

  # Today's Pomodoros
  today=$(date +"%Y-%m-%d")
  todays_pomodoros=$(grep "$today" "$SESSION_LOG" | grep "finish_pomodoro" | wc -l)
  echo "Today's Pomodoros: $todays_pomodoros"

  # Weekly Pomodoros
  start_week=$(date -v -$(date +%w)d +"%Y-%m-%d") # macOS
  weekly_pomodoros=$(awk -F, -v start="$start_week" '$1 >= start && $2 == "finish_pomodoro" {count++} END {print count+0}' "$SESSION_LOG")
  echo "This Week's Pomodoros: $weekly_pomodoros"

  # Monthly Pomodoros
  start_month=$(date +"%Y-%m-01")
  monthly_pomodoros=$(awk -F, -v start="$start_month" '$1 >= start && $2 == "finish_pomodoro" {count++} END {print count+0}' "$SESSION_LOG")
  echo "This Month's Pomodoros: $monthly_pomodoros"

  echo "---"
  echo "View Detailed Logs | bash=\"open\" param1=\"file://$SESSION_LOG\" terminal=false refresh=false"
}

# Run main function and capture only its output
main() {
  [ ! -e "$STATUS_FILE" ] && : >"$STATUS_FILE"

  # reads current status from status file
  read -r tstamp togo pomodoros state activity loop _ < <({
    read -r line
    echo "$line"
  } <"$STATUS_FILE")

  case "$1" in
  "start")
    pomodoro_start
    ;;
  "stop")
    status_reset
    run_script stop
    log_session "stop"
    ;;
  "pause")
    pause_resume
    ;;
  "break")
    pomodoro_break
    ;;
  "long_break")
    pomodoro_long_break
    ;;
  "loop_toggle")
    loop_toggle
    ;;
  "report")
    generate_report
    ;;
  *)
    pomodoro_update
    ;;
  esac

  print_menu
}

main "$@" 2>/dev/null
