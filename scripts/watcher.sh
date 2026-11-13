#!/system/bin/sh
# ================================================================
# HyperOS 助手持久化 - 常驻守护进程
# 由 service.sh 在开机时以 root 身份拉起（setsid 脱离会话）
# ================================================================

MODDIR="${1:-/data/adb/modules/hyper_assistant_persist}"
. "$MODDIR/scripts/env.sh"

PIDFILE=/data/adb/hyper_assistant_persist.pid
if [ -f "$PIDFILE" ]; then
  old=$(cat "$PIDFILE" 2>/dev/null | tr -d ' ')
  if [ -n "$old" ] && [ -d "/proc/$old" ]; then
    exit 0   # 已有实例在运行
  fi
fi
echo $$ > "$PIDFILE" 2>/dev/null

# 首次运行时记录原始值，供卸载时还原
if [ ! -f "$ORIG_FILE" ]; then
  o=$(settings get global power_button_long_press 2>/dev/null)
  echo "orig_pbl='${o:-null}'" > "$ORIG_FILE" 2>/dev/null
fi

# 等待 settings 服务（system_server 内）就绪，最长约 5 分钟
n=0
until settings get secure assistant >/dev/null 2>&1; do
  sleep 2
  n=$((n + 1))
  if [ "$n" -ge 150 ]; then break; fi
done

hap_log "watcher started (pid $$) pbl_target=$PBL_VALUE fix_assistant=$FIX_ASSISTANT force=$FORCE_ASSISTANT"

# 阶段一：开机高频巡检（对抗 HyperOS 开机/解锁写回）
hap_apply_all
hap_aggressive

# 阶段二：常态低频巡检；检测到软重启（sys.boot_completed 掉线）则重新高频
boot_lost=0
while :; do
  sleep "$STEADY_INTERVAL"
  [ -f "$PAUSE_FILE" ] && continue
  bc=$(getprop sys.boot_completed 2>/dev/null)
  if [ "$bc" != "1" ]; then
    boot_lost=1
    continue
  fi
  if [ "$boot_lost" = "1" ]; then
    boot_lost=0
    hap_log "framework restart (soft reboot) detected -> re-run aggressive phase"
    hap_aggressive
    continue
  fi
  hap_apply_all
done
