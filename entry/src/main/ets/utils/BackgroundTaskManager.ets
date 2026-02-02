import { common, wantAgent } from '@kit.AbilityKit';
import { backgroundTaskManager } from '@kit.BackgroundTasksKit'
import Logger from './Logger';

const TAG = '[BackgroundTaskManager]';

export class BackgroundTaskManager {
  public static startContinuousTask(context?: common.UIAbilityContext): void {
    if (!context) {
      return;
    }
    let wantAgentInfo: wantAgent.WantAgentInfo = {
      wants: [
        {
          bundleName: context.abilityInfo.bundleName,
          abilityName: context.abilityInfo.name
        }
      ],
      actionType: wantAgent.OperationType.START_ABILITIES,
      requestCode: 0,
      actionFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG]
    };
    wantAgent.getWantAgent(wantAgentInfo)
      .then((agentObj) => {
        backgroundTaskManager.startBackgroundRunning(context, backgroundTaskManager.BackgroundMode.AUDIO_PLAYBACK,
          agentObj)
          .then(() => {
            Logger.info('startBackgroundRunning succeed.');
          })
          .catch((err: BusinessError) => {
            Logger.warn(TAG, `startBackgroundRunning failed. code: ${err.code}, message: ${err.message}`);
          })
      })
      .catch((err: BusinessError) => {
        Logger.warn(TAG, `getWantAgent failed. code: ${err.code}, message: ${err.message}`);
      })
  }

  public static stopContinuousTask(context?: common.UIAbilityContext): void {
    if (!context) {
      return;
    }
    if (canIUse('SystemCapability.ResourceSchedule.BackgroundTaskManager.Core')) {
      backgroundTaskManager.stopBackgroundRunning(context)
        .catch((err: BusinessError) => {
          Logger.warn(TAG, `stopBackgroundRunning failed. code: ${err.code}, message: ${err.message}`);
        })
    }
  }
}