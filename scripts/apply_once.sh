#!/system/bin/sh
# ================================================================
# HyperOS 助手持久化 - 手动立即应用一次（调试/应急用）
# 用法（root 终端或 adb shell su -c）：
#   sh /data/adb/modules/hyper_assistant_persist/scripts/apply_once.sh
# ================================================================

MODDIR="${1:-/data/adb/modules/hyper_assistant_persist}"
. "$MODDIR/scripts/env.sh"

echo "===== HyperOS 助手持久化 ====="
echo "global power_button_long_press 当前: $(settings get global power_button_long_press 2>/dev/null)"
echo "global power_button_long_press 目标: $PBL_VALUE"
echo "secure assistant               当前: $(settings get secure assistant 2>/dev/null)"
echo "secure voice_interaction_service当前: $(settings get secure voice_interaction_service 2>/dev/null)"

hap_apply_all

echo "----- 已应用一次，当前状态 -----"
echo "global power_button_long_press 当前: $(settings get global power_button_long_press 2>/dev/null)"
echo "secure assistant               当前: $(settings get secure assistant 2>/dev/null)"
echo "完成。"
