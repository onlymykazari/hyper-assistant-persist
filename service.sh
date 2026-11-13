#!/system/bin/sh
# KernelSU / Magisk 开机服务脚本：拉起常驻守护
MODDIR=${0%/*}
if command -v setsid >/dev/null 2>&1; then
  (setsid sh "$MODDIR/scripts/watcher.sh" "$MODDIR" </dev/null >/dev/null 2>&1 &)
else
  (nohup sh "$MODDIR/scripts/watcher.sh" "$MODDIR" </dev/null >/dev/null 2>&1 &)
fi
exit 0
