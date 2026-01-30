import { FormatTime } from "../utils/FotmatTime";
import { WindowUtil } from "../utils/WindowUtil";
import { LengthMetrics, window } from "@kit.ArkUI";

@Component
export struct VideoPlayer {
  private videoController: VideoController = new VideoController();
  private windowUtil: WindowUtil = WindowUtil.getInstance();
  // 初始化当前时间为0
  @State currentTime: number = 0;
  // 初始化持续时间为0
  @State durationTime: number = 0;
  @State playbackSpeed: string = '1.0X';
  @State curRate: PlaybackSpeed = PlaybackSpeed.Speed_Forward_1_00_X;
  @State isFullScreen: boolean = false;
  @Prop @Watch('onFullScreenChange') isFullLandscapeScreen: boolean = false;

  onFullScreenChange() {

  }

  // 播放倍速设置
  @Builder
  SpeedMenu() {
    Menu() {
      MenuItem({ content: '2X' })
        .width('64vp')
        .onClick(() => {
          this.playbackSpeed = '2X';
          this.curRate = PlaybackSpeed.Speed_Forward_2_00_X;
        })
      MenuItem({ content: '1.75X' })
        .width('64vp')
        .onClick(() => {
          this.playbackSpeed = '1.75X';
          this.curRate = PlaybackSpeed.Speed_Forward_1_75_X;
        })
      MenuItem({ content: '1.25X' })
        .width('64vp')
        .onClick(() => {
          this.playbackSpeed = '1.25X';
          this.curRate = PlaybackSpeed.Speed_Forward_1_25_X;
        })
      MenuItem({ content: '1.0X' })
        .width('64vp')
        .onClick(() => {
          this.playbackSpeed = '1.0X';
          this.curRate = PlaybackSpeed.Speed_Forward_1_00_X;
        })
    }
    .font({
      size: 12
    })
    .menuItemDivider({
      strokeWidth: LengthMetrics.vp(0.5),
      color: '#d5d5d5',
      mode: DividerMode.EMBEDDED_IN_MENU
    })
    .backgroundColor($r('app.color.slider_color'))
  }

  // 自定义进度条
  @Builder
  VideoControllerBuilder() {
    Row({ space: 4 }) {
      // 当前播放时间
      Text(FormatTime.getTimesBySecond(this.currentTime))
        .fontSize(12)
        .fontColor(Color.White)
      Slider({
        value: this.currentTime,
        max: this.durationTime,
        step: 1
      })
        .width('50%')
        .trackColor($r('app.color.slider_color'))
        .onChange((value) => {
          // 跳转播放
          this.videoController.setCurrentTime(value, SeekMode.Accurate);
        })
      // 视频总时长
      Text(FormatTime.getTimesBySecond(this.durationTime))
        .fontSize(12)
        .fontColor(Color.White)
      // 播放倍速
      Column() {
        Text(this.playbackSpeed)
          .fontSize(12)
          .fontColor(Color.White)
      }
      .width(48)
      .height(24)
      .padding(4)
      .border({
        width: 2,
        color: Color.White,
        radius: 12
      })
      .bindMenu(this.SpeedMenu)

      // 全屏播放
      Image($r(this.isFullScreen ? 'app.media.reduce_fullscreen' : 'app.media.fullscreen'))
        .width('24vp')
        .height('24vp')
        .onClick(() => {
          this.isFullScreen = !this.isFullScreen;
          // this.videoController.requestFullscreen(this.isFullScreen);
          if (this.isFullScreen) {
            this.windowUtil.setMainWindowOrientation(window.Orientation.USER_ROTATION_LANDSCAPE);
            // this.setOrientation(window.Orientation.USER_ROTATION_LANDSCAPE);
            // this.windowUtil.disableWindowSystemBar();
            // this.windowUtil.setLandscapeMutiWindow(true);
          }
        })
    }
    .width('100%')
    .position({ y: 160 }) // 设置垂直偏移量
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Center)
  }

  build() {
    Stack() {
      this.VideoControllerBuilder();
    }
    .width('100%')
    // .height('100%')
  }
}