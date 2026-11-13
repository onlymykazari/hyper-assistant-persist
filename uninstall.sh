#!/system/bin/sh
# 卸载脚本：停止守护进程，还原模块安装前记录的电源键行为
# （助手组件设置保持现状不动，避免误还原到已卸载的小爱）

if [ -f /data/adb/hyper_assistant_persist.pid ]; then
  kill "$(cat /data/adb/hyper_assistant_persist.pid 2>/dev/null)" 2>/dev/null
  rm -f /data/adb/hyper_assistant_persist.pid
fi

if [ -f /data/adb/hyper_assistant_persist_originals.txt ]; then
  . /data/adb/hyper_assistant_persist_originals.txt
  if [ -n "$orig_pbl" ] && [ "$orig_pbl" != "null" ]; then
    settings put global power_button_long_press "$orig_pbl" 2>/dev/null
  fi
  rm -f /data/adb/hyper_assistant_persist_originals.txt
fi

rm -f /data/adb/hyper_assistant_persist.log 2>/dev/null
exit 0
