# HyperAssistantPersist

**国行 HyperOS「长按电源键 → 数字助理」持久化模块**（KernelSU / Magisk 通用）

让长按电源键持续唤起你设置的数字助理（如谷歌助手/Gemini），对抗 HyperOS 在每次开机、解锁（含软重启）时对助手设置的自动重置。

> English: A KernelSU/Magisk module that keeps "long-press power button → digital assistant" working on China-region Xiaomi HyperOS, by re-applying assistant settings that HyperOS resets on every boot and user unlock.

## 问题根因

国行 HyperOS 在**每次 system_server 启动（含软重启）和用户解锁时**，都会在框架层重写助手相关设置——把长按电源键行为重置为默认，开机窗口期甚至直接把数字助理写回小爱。这就是通过原生设置强开开关后"每次重启都失效"的原因。该开关在 HyperOS 设置页里也被隐藏/屏蔽。

关键设置键（参考 [GeminiMi](https://github.com/SherlockChiang/Gemini-mi) 源码实测）：

| 键 | 命名空间 | 目标值 |
|---|---|---|
| `power_button_long_press` | **Global**（双保险另写 Secure） | `5` = 数字助理 |
| `assistant` / `voice_interaction_service` | Secure | 谷歌 App 的 `GsaVoiceInteractionService` |
| `voice_recognition_service` | Secure | 谷歌的 `GoogleRecognitionService` |
| `assist_structure_enabled` / `assist_screenshot_enabled` | Secure | `1`（助手读屏/截图） |

## 工作机制

模块安装一个 root 常驻守护进程（`service.sh` 拉起，setsid 脱离会话）：

1. 开机等 settings 服务就绪 → 立即写回全部正确值；
2. 前 180 秒每 3 秒巡检一次（对抗开机/解锁写回窗口）；
3. 之后每 30 秒巡检一次，**只在值被改动时才写**（幂等，无写入风暴，开销可忽略）；
4. 检测到软重启（`sys.boot_completed` 掉线）自动重新进入高频巡检。

## 下载安装

从 [Releases](../../releases/latest/download/HyperAssistantPersist-v1.0.0.zip) 下载 zip：

1. 传到手机 → KernelSU 管理器 → 模块 → 从存储安装 → 重启
2. 解锁后长按电源键应唤起数字助理（按住约 3 秒以上仍是关机菜单）

## 验证

```bash
adb shell su -c "settings get global power_button_long_press"    # 应为 5
adb shell su -c "settings get secure voice_interaction_service"  # 应为谷歌组件
cat /data/adb/hyper_assistant_persist.log                        # 模块日志
```

## 数值适配（如果长按仍进电源菜单）

不同 HyperOS 版本 `power_button_long_press` 的"数字助理"枚举值可能不同（GeminiMi 实测 `5`）。抓取你机型的真实值：

1. 用原生设置强开开关（此时功能正常）；
2. 立刻执行 `adb shell su -c "settings get global power_button_long_press"`；
3. 把得到的数字填进 `/data/adb/modules/hyper_assistant_persist/config.conf` 的 `PBL_VALUE=`，重启。

## 日常管理

| 操作 | 命令 |
|---|---|
| 配置 | `/data/adb/modules/hyper_assistant_persist/config.conf` |
| 日志 | `/data/adb/hyper_assistant_persist.log` |
| 立即应用 | `sh /data/adb/modules/hyper_assistant_persist/scripts/apply_once.sh` |
| 暂停巡检 | `touch /data/adb/hyper_assistant_persist.pause`（恢复：删除该文件） |
| 卸载还原 | 管理器中移除模块即可（停止守护并还原安装前电源键值，助手键保持现状） |

## 备选/加固方案（LSPosed 路线）

已装 LSPosed 的话，可用 hook 级方案（软重启天然免疫，直接在 system_server 内拦截 `Settings.Secure.putStringForUser` 阻止写回）：

- [GeminiMi](https://github.com/SherlockChiang/Gemini-mi)：长按电源键 → Gemini Overlay（3 秒 Gemini / 5 秒电源菜单）
- [hyperGPT](https://modules.lsposed.org/module/io.github.ziyuw_plank.hypergpt)：同思路换 ChatGPT

两者可与本模块共存。

## 来源与致谢

- [GeminiMi](https://github.com/SherlockChiang/Gemini-mi)（确认了设置键与重置时机）
- [hyperGPT - LSPosed 模块仓库](https://modules.lsposed.org/module/io.github.ziyuw_plank.hypergpt)

## 免责声明

本模块仅修改系统 `settings` 提供者中的助手相关键，不修改任何系统文件。使用风险自负；卸载时会自动还原安装前记录的 `power_button_long_press` 原始值。
