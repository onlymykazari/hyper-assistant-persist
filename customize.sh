#!/system/bin/sh
# 安装脚本（KernelSU / Magisk 通用）
SKIPUNZIP=0

ui_print "*******************************"
ui_print "  HyperOS 助手持久化 v1.0.0"
ui_print "  长按电源键 -> 数字助理(谷歌)"
ui_print "*******************************"
ui_print "- 设置脚本权限..."
chmod 755 "$MODDIR/service.sh" 2>/dev/null
chmod 755 "$MODDIR/uninstall.sh" 2>/dev/null
chmod 755 "$MODDIR/action.sh" 2>/dev/null
chmod 755 "$MODDIR/scripts/"*.sh 2>/dev/null
set_perm "$MODDIR/service.sh" 0 0 0755 2>/dev/null
set_perm "$MODDIR/uninstall.sh" 0 0 0755 2>/dev/null
set_perm "$MODDIR/action.sh" 0 0 0755 2>/dev/null
set_perm "$MODDIR/scripts/watcher.sh" 0 0 0755 2>/dev/null
set_perm "$MODDIR/scripts/env.sh" 0 0 0755 2>/dev/null
set_perm "$MODDIR/scripts/apply_once.sh" 0 0 0755 2>/dev/null

ui_print "- 配置文件: /data/adb/modules/hyper_assistant_persist/config.conf"
ui_print "- 运行日志: /data/adb/hyper_assistant_persist.log"
ui_print "- 暂停巡检: touch /data/adb/hyper_assistant_persist.pause"
ui_print "- 恢复巡检: rm /data/adb/hyper_assistant_persist.pause"
ui_print "- 立即应用: sh /data/adb/modules/hyper_assistant_persist/scripts/apply_once.sh"
ui_print "- 重启手机后生效"
