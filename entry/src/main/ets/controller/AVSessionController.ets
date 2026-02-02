import { common, WantAgent, wantAgent } from "@kit.AbilityKit";
import { avSession } from "@kit.AVSessionKit";
import { VideoType } from "../module/VideoType";
import { BackgroundTaskManager } from "../utils/BackgroundTaskManager";
import Logger from '../utils/Logger';

const TAG = '[AVSessionController]';

export class AVSessionController {
  private static instance: AVSessionController | undefined = undefined;
  private context: common.UIAbilityContext | undefined = AppStorage.get('context');
  private avSession: avSession.AVSession | undefined = undefined;
  private avSessionMetaData: avSession.AVMetadata | undefined = undefined;

  constructor() {
    this.initAVSession();
  }

  public static getInstance(): AVSessionController {
    if (!AVSessionController.instance) {
      AVSessionController.instance = new AVSessionController();
    }
    return AVSessionController.instance;
  }

  public initAVSession() {
    if (!this.context) {
      return;
    }
    // 创建视频类型的会话对象
    avSession.createAVSession(this.context, 'LONG_VIDEO_SESSION', 'video')
      .then((data: avSession.AVSession) => {
        this.avSession = data;
        this.setLaunchAbility();
        BackgroundTaskManager.startContinuousTask(this.context);
        // 激活会话
        this.avSession.activate()
          .then(() => {
            Logger.info(TAG, `AVSession activate successed`);
          })
          .catch((err: BusinessError) => {
            Logger.warn(TAG, `AVSession activate failed. code: ${err.code}, message: ${err.message}`);
          })
      })
      .catch((err: BusinessError) => {
        Logger.warn(TAG, `Create AVSession failed. code: ${err.code}, message: ${err.message}`);
      })
  }

  public getAVSession() {
    return this.avSession;
  }

  public getAVSessionMetadata() {
    return this.avSessionMetaData;
  }

  public setAVMetadata(curSource: VideoType, duration: number) {
    if (!curSource) {
      return;
    }
    // 设置会话元数据
    let metadata: avSession.AVMetadata = {
      assetId: `${curSource.index}`, // 媒体ID
      title: curSource.name, // 标题
      duration: duration, // 媒体时长
    }
    if (this.avSession) {
      this.avSession.setAVMetadata(metadata)
        .then(() => {
          this.avSessionMetaData = metadata;
        })
        .catch((err: BusinessError) => {
          Logger.warn(TAG, `Set AVMetadata failed. code: ${err.code}, message: ${err.message}`);
        })
    }
  }

  public setLaunchAbility() {
    if (!this.context) {
      return;
    }
    const wantAgentInfo: wantAgent.WantAgentInfo = {
      wants: [
        {
          bundleName: this.context.abilityInfo.bundleName,
          abilityName: this.context.abilityInfo.name
        }
      ],
      actionType: wantAgent.OperationType.START_ABILITIES, // 动作类型，开启多个有页面的Ability
      requestCode: 0, // 自定义的请求码，用于标识将被执行的动作
      actionFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG] // 动作执行属性
    }
    // 创建WantAgent
    wantAgent.getWantAgent(wantAgentInfo)
      .then((agent: WantAgent) => {
        if (this.avSession) {
          // 设置一个WantAgent用于拉起会话的Ability
          this.avSession.setLaunchAbility(agent)
            .catch((err: BusinessError) => {
              Logger.warn(TAG, `SetLaunchAbility failed. code: ${err.code}, message: ${err.message}`);
            })
        }
      })
      .catch((err: BusinessError) => {
        Logger.warn(TAG, `Get wantAgent failed. code: ${err.code}, message: ${err.message}`);
      })
  }

  public setAVSessionPlayState(playbackState: avSession.AVPlaybackState) {
    if (!this.avSession) {
      return;
    }
    // 设置会话播放状态
    this.avSession.setAVPlaybackState(playbackState, (err: BusinessError) => {
      if (err) {
        Logger.warn(TAG, `SetAVPlaybackState failed. code: ${err.code}, message: ${err.message}`);
      }
      Logger.info('SetAVPlaybackState successfully');
    })
  }

  public unregisterSessionListener() {
    if (!this.avSession) {
      return;
    }
    try {
      this.avSession.off('play');
      this.avSession.off('pause');
      this.avSession.off('playPrevious');
      this.avSession.off('playNext');
      this.avSession.off('setLoopMode');
      this.avSession.off('seek');
      BackgroundTaskManager.stopContinuousTask(this.context);
    } catch (error) {
      let err = error as BusinessError;
      Logger.warn(TAG, `Unregister sessionListener failed. code: ${err.code}, message: ${err.message}`);
    }
  }
}