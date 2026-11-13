#!/system/bin/sh
# 管理器"操作"按钮 / 手动触发：立即应用一次设置
MODDIR=${0%/*}
sh "$MODDIR/scripts/apply_once.sh" "$MODDIR"
