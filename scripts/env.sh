#!/system/bin/sh
# ================================================================
# HyperOS 助手持久化 - 公共配置加载与应用函数
# 被 watcher.sh（守护）和 apply_once.sh（手动执行）source
# ================================================================

MODDIR="${MODDIR:-/data/adb/modules/hyper_assistant_persist}"
[ -f "$MODDIR/config.conf" ] && . "$MODDIR/config.conf"

# ---- 默认值（config.conf 可覆盖）----
PBL_VALUE="${PBL_VALUE:-5}"
ALSO_WRITE_SECURE="${ALSO_WRITE_SECURE:-1}"
FIX_ASSISTANT="${FIX_ASSISTANT:-1}"
FORCE_ASSISTANT="${FORCE_ASSISTANT:-0}"
ASSISTANT_COMPONENT="${ASSISTANT_COMPONENT:-com.google.android.googlequicksearchbox/com.google.android.voiceinteraction.GsaVoiceInteractionService}"
RECOGNITION_COMPONENT="${RECOGNITION_COMPONENT:-com.google.android.googlequicksearchbox/com.google.android.voicesearch.serviceapi.GoogleRecognitionService}"
ASSISTANT_PACKAGE="${ASSISTANT_PACKAGE:-com.google.android.googlequicksearchbox}"
ASSIST_STRUCTURE="${ASSIST_STRUCTURE:-1}"
ASSIST_SCREENSHOT="${ASSIST_SCREENSHOT:-1}"
AGGRESSIVE_SECS="${AGGRESSIVE_SECS:-180}"
AGGRESSIVE_STEP="${AGGRESSIVE_STEP:-3}"
STEADY_INTERVAL="${STEADY_INTERVAL:-30}"
LOG_MAX_BYTES="${LOG_MAX_BYTES:-262144}"
LOGFILE="${LOGFILE:-/data/adb/hyper_assistant_persist.log}"
PAUSE_FILE="${PAUSE_FILE:-/data/adb/hyper_assistant_persist.pause}"
ORIG_FILE="${ORIG_FILE:-/data/adb/hyper_assistant_persist_originals.txt}"

hap_log() {
  echo "$(date '+%m-%d %H:%M:%S') $*" >> "$LOGFILE" 2>/dev/null
  sz=$(wc -c < "$LOGFILE" 2>/dev/null | tr -d ' ')
  if [ "$(( ${sz:-0} + 0 ))" -gt "$LOG_MAX_BYTES" ]; then
    tail -n 300 "$LOGFILE" > "$LOGFILE.tmp" 2>/dev/null && mv -f "$LOGFILE.tmp" "$LOGFILE"
  fi
}

# 判断助手键是否被 HyperOS 写回小爱或清空
hap_is_broken_assistant() {
  case "$1" in
    ""|"null"|*voiceassist*|*xiaomi.voiceassistant*|*aiasst*) return 0 ;;
    *) return 1 ;;
  esac
}

hap_write_assistant() {
  settings put secure assistant "$ASSISTANT_COMPONENT" 2>/dev/null
  settings put secure voice_interaction_service "$ASSISTANT_COMPONENT" 2>/dev/null
  settings put secure voice_recognition_service "$RECOGNITION_COMPONENT" 2>/dev/null
  settings put secure assistant_package_name "$ASSISTANT_PACKAGE" 2>/dev/null
  hap_log "FIX assistant keys -> $ASSISTANT_COMPONENT"
}

hap_apply_all() {
  # 1) 长按电源键行为：数字助理
  cur=$(settings get global power_button_long_press 2>/dev/null)
  if [ "$cur" != "$PBL_VALUE" ]; then
    if settings put global power_button_long_press "$PBL_VALUE" 2>/dev/null; then
      hap_log "FIX power_button_long_press(global): ${cur:-null} -> $PBL_VALUE"
    fi
    if [ "$ALSO_WRITE_SECURE" = "1" ]; then
      settings put secure power_button_long_press "$PBL_VALUE" 2>/dev/null
    fi
  fi

  # 2) 助手组件
  if [ "$FORCE_ASSISTANT" = "1" ]; then
    hap_write_assistant
  elif [ "$FIX_ASSISTANT" = "1" ]; then
    a=$(settings get secure assistant 2>/dev/null)
    if hap_is_broken_assistant "$a"; then hap_write_assistant; else
      v=$(settings get secure voice_interaction_service 2>/dev/null)
      if hap_is_broken_assistant "$v"; then hap_write_assistant; fi
    fi
  fi

  # 3) 助手读屏/截图开关
  s=$(settings get secure assist_structure_enabled 2>/dev/null)
  if [ "$s" != "$ASSIST_STRUCTURE" ]; then
    settings put secure assist_structure_enabled "$ASSIST_STRUCTURE" 2>/dev/null
  fi
  s=$(settings get secure assist_screenshot_enabled 2>/dev/null)
  if [ "$s" != "$ASSIST_SCREENSHOT" ]; then
    settings put secure assist_screenshot_enabled "$ASSIST_SCREENSHOT" 2>/dev/null
  fi
}

# 高频巡检阶段：对抗开机/解锁时的系统写回
hap_aggressive() {
  aggr=0
  while [ "$aggr" -lt "$AGGRESSIVE_SECS" ]; do
    hap_apply_all
    sleep "$AGGRESSIVE_STEP"
    aggr=$((aggr + AGGRESSIVE_STEP))
  done
  hap_log "aggressive phase done"
}
