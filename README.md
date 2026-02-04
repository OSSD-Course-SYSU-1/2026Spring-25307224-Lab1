# 基于Video组件实播放长视频

## 项目简介
本示例基于Video组件实现了播放长视频功能，指导开发者如何通过Video组件实现视频播放控制，如：基础播控、视频首帧率显示、自定义播放进度条、前台小窗播放、循环播放、视频全屏播放、视频音量设置、静音播放、长按倍速播放、点击选择倍速播放、接入播控中心等场景。

## 效果预览

## 使用说明
1. 安装进入应用。
2. 点击按钮播放本地视频，点击视频列表内容切换视频。
3. 点击Slider实现视频跳转播放。
4. 点击右下角按钮，进入全屏播放。
5. 进入全屏后：
   1. 滑动视频左侧区域，实现音量调节。
   2. 点击播放速度按钮，选择视频播放倍速。
   3. 长按视频区域，实现视频倍速播放。
   4. 点击右下角静音按钮，实现静音播放。
6. 视频播放时，通过播控中心控制视频的播放、暂停、跳转播放、点击播放上一个/下一个视频。

## 工程目录
```
├──entry/src/main/ets
│  ├──constants
│  │  └──CommonConstants.ets            // Video状态常量
│  ├──controller
│  │  └──AVSessionController.ets        // AVSession类
│  ├──entryability
│  │  └──EntryAbility.ets               // 程序入口
│  ├──entrybackupability
│  │  └──EntryBackupAbility.ets         // 备份恢复类
│  ├──module
│  │  ├──VideoData.ets                  // Video数据
│  │  └──VideoType.ets                  // Video类型接口
│  ├──pages
│  │  └──Index.ets                      // Video视频播放页
│  └──utils
│  │  ├──BackgroundTaskManager.ets      // 后台任务管理类
│  │  ├──FotmatTime.ets                 // 时间格式转换工具类
│  │  ├──Logger.ets                     // 日志打印类
│  │  └──WindowUtil.ets                 // 窗口类
│  └──view
│     └──VolumeAndBrightnessView.ets    // 音量亮度调节组件
└──src/main/resources                   // 应用资源目录
```
## 具体实现

## 相关权限

- ohos.permission.KEEP_BACKGROUND_RUNNING：允许Service Ability在后台持续运行。

## 约束与限制

本示例仅支持标准系统上运行，支持设备：直板机。

1. HarmonyOS系统：HarmonyOS 6.0.1 Release及以上。
2. DevEco Studio版本：DevEco Studio 6.0.1 Release及以上。
3. HarmonyOS SDK版本：HarmonyOS 6.0.1 Release SDK及以上。