// 当前视频状态
export default class VideoStatus {
  static readonly PLAY_PREPARED: string = 'prepared'; // 视频准备
  static readonly PLAY_STARTED: string = 'started'; // 开始播放
  static readonly PLAY_PAUSED: string = 'paused'; // 暂停播放
  static readonly PLAY_FINISH: string = 'finished'; // 播放完成
  static readonly PLAY_STOPPED: string = 'stopped'; // 停止播放
  // static readonly PLAY_CONTINUED: string = 'continued'; // 继续播放
}