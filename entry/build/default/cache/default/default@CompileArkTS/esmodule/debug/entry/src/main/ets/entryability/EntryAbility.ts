import AbilityConstant from "@ohos:app.ability.AbilityConstant";
import ConfigurationConstant from "@ohos:app.ability.ConfigurationConstant";
import UIAbility from "@ohos:app.ability.UIAbility";
import type Want from "@ohos:app.ability.Want";
import hilog from "@ohos:hilog";
import type window from "@ohos:window";
import JSON from "@ohos:util.json";
import { WindowUtil } from "@normalized:N&&&entry/src/main/ets/utils/WindowUtil&";
const DOMAIN = 0x0000;
export default class EntryAbility extends UIAbility {
    onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
        try {
            AppStorage.setOrCreate('context', this.context);
            this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_DARK);
        }
        catch (err) {
            hilog.error(DOMAIN, 'testTag', 'Failed to set colorMode. Cause: %{public}s', JSON.stringify(err));
        }
        hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
    }
    onDestroy(): void {
        hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
    }
    onWindowStageCreate(windowStage: window.WindowStage): void {
        try {
            AppStorage.setOrCreate('windowStage', windowStage);
            WindowUtil.getInstance().setWindowStage(windowStage);
            let windowClass: window.Window = windowStage.getMainWindowSync();
            windowClass.setWindowLayoutFullScreen(true)
                .catch(() => {
                hilog.error(DOMAIN, 'testTag', 'setWindowLayoutFullScreen is failed.');
            });
            // Main window is created, set main page for this ability
            hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');
            windowStage.loadContent('pages/Index', (err) => {
                if (err.code) {
                    hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
                    return;
                }
                hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
            });
        }
        catch (err) {
            hilog.error(DOMAIN, 'testTag', 'getMainWindowSync failed.');
        }
    }
    onWindowStageDestroy(): void {
        // Main window is destroyed, release UI related resources
        hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
    }
    onForeground(): void {
        // Ability has brought to foreground
        hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
    }
    onBackground(): void {
        // Ability has back to background
        hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
    }
    // 实现跨端迁移回调
    onContinue(wantParam: Record<string, Object>): AbilityConstant.OnContinueResult {
        hilog.info(DOMAIN, 'testTag', 'onContinue called');
        // 保存当前播放状态到wantParam中
        try {
            // 获取当前播放状态（从AppStorage中获取）
            const currentVideoIndex = AppStorage.get<number>('currentVideoIndex') || 0;
            const playbackPosition = AppStorage.get<number>('playbackPosition') || 0;
            const isPlaying = AppStorage.get<boolean>('isPlaying') || false;
            // 将状态数据保存到wantParam中
            wantParam['currentVideoIndex'] = currentVideoIndex;
            wantParam['playbackPosition'] = playbackPosition;
            wantParam['isPlaying'] = isPlaying;
            hilog.info(DOMAIN, 'testTag', 'Migration data saved: index=%{public}d, position=%{public}d', currentVideoIndex, playbackPosition);
            return AbilityConstant.OnContinueResult.AGREE;
        }
        catch (err) {
            hilog.error(DOMAIN, 'testTag', 'Failed to save migration data: %{public}s', JSON.stringify(err));
            return AbilityConstant.OnContinueResult.REJECT;
        }
    }
    // 处理新设备上的迁移数据
    onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
        hilog.info(DOMAIN, 'testTag', 'onNewWant called');
        try {
            // 从want中恢复播放状态
            if (want.parameters) {
                const currentVideoIndex = want.parameters['currentVideoIndex'] as number;
                const playbackPosition = want.parameters['playbackPosition'] as number;
                const isPlaying = want.parameters['isPlaying'] as boolean;
                // 恢复状态到AppStorage
                if (currentVideoIndex !== undefined) {
                    AppStorage.setOrCreate('currentVideoIndex', currentVideoIndex);
                }
                if (playbackPosition !== undefined) {
                    AppStorage.setOrCreate('playbackPosition', playbackPosition);
                }
                if (isPlaying !== undefined) {
                    AppStorage.setOrCreate('isPlaying', isPlaying);
                }
                hilog.info(DOMAIN, 'testTag', 'Migration data restored: index=%{public}d, position=%{public}d', currentVideoIndex, playbackPosition);
            }
        }
        catch (err) {
            hilog.error(DOMAIN, 'testTag', 'Failed to restore migration data: %{public}s', JSON.stringify(err));
        }
    }
}
