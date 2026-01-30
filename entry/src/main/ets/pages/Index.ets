import { VideoData } from '../module/VideoData';
import { VideoType } from "../module/VideoType";
import VideoStatus from '../constants/VideoStatus';
import { WindowUtil } from '../utils/WindowUtil';
import { FormatTime } from '../utils/FotmatTime';
import { LengthMetrics, window } from '@kit.ArkUI';
import { VolumeAndBrightness } from '../view/VolumeAndBrightness';
import { AVSessionController } from '../controller/AVSessionController';
import { avSession } from '@kit.AVSessionKit';

@Entry
@Component
struct Index {
  @Provide('pageInfo') pageInfo: NavPathStack = new NavPathStack();
  private videoController: VideoController = new VideoController();
  private windowUtil: WindowUtil = WindowUtil.getInstance();
  @State currentVideoStatus: string = 'init';
  @State videoSrc: Resource = $rawfile('mountaineer.mp4');
  @State previewUri: Resource = $r('app.media.mountaineer');
  @State isAutoPlay: boolean = false;
  @State currentVideoIndex: number = 0;
  @State isFullScreen: boolean = false;
  // 初始化当前时间为0
  @State currentTime: number = 0;
  // 初始化持续时间为0
  @State durationTime: number = 0;
  @State playbackSpeed: string = '1.0X';
  @State curRate: PlaybackSpeed = PlaybackSpeed.Speed_Forward_1_00_X;
  @State isMute: boolean = false;
  @State visible: boolean = false; // 是否显示亮度调节图标和滑块
  @State volume: number = 5; // 音量值
  @State screenBrightness: number = 0; // 亮度值
  private screenWidth: number = 0; // 屏幕宽度
  private screenHeight: number = 0; // 屏幕高度
  private avSessionController: AVSessionController = AVSessionController.getInstance();
  // private avSessionController: AVSessionController = new AVSessionController();
  @State curSource: VideoType | undefined = undefined;
  @State isPlaying: boolean = false;

  aboutToAppear(): void {
    this.curSource = VideoData[0];

    this.windowUtil.registerOnWindowSizeChange((size) => {
      if (size.width > size.height) {
        this.isFullScreen = true;
        this.windowUtil.disableWindowSystemBar();
      } else {
        this.isFullScreen = false;
        this.windowUtil.enableWindowSystemBar();
      }
    })

    try {
      // 获取窗口宽高
      window.getLastWindow(this.getUIContext().getHostContext(), (err: BusinessError, data: window.Window) => {
        if (err.code) {
          return;
        }
        this.screenWidth = data.getWindowProperties().windowRect.width;
        this.screenHeight = data.getWindowProperties().windowRect.height;
      })
    } catch (e) {

    }
    setTimeout(() => {
      this.setAVSessionListener();
    }, 100);
  }

  public async setAVSessionListener() {
    if (!this.avSessionController) {
      return;
    }
    try {
      this.avSessionController.getAVSession()?.on('play', () => this.sessionPlay());
      this.avSessionController.getAVSession()?.on('pause', () => {
        this.sessionPause();
      });
      this.avSessionController.getAVSession()?.on('seek', () => {
      });
      this.avSessionController.getAVSession()?.on('setLoopMode', () => {
      });
      this.avSessionController.getAVSession()?.on('playPrevious', () => {
      });
      this.avSessionController.getAVSession()?.on('playNext', () => {
      });
    } catch (err) {
    }
  }

  isCurAVSession(): boolean {
    let curAVMetadata = this.avSessionController.getAVSessionMetadata();
    if (curAVMetadata && this.curSource) {
      if (curAVMetadata.assetId === `${this.curSource?.index}`) {
        return true;
      }
    }
    return false;
  }

  sessionPlay() {
    if (!this.isCurAVSession()) {
      return;
    }
    if (this.curSource) {
      this.avSessionController.setAVMetadata(this.curSource, this.durationTime);
    }
    this.videoController.start();
    this.isPlaying = true;
    this.updateIsPlay();
  }

  sessionPause() {
    if (!this.isCurAVSession()) {
      return;
    }
    if (this.curSource) {
      this.avSessionController.setAVMetadata(this.curSource, this.durationTime);
    }
    this.videoController.pause();
    this.isPlaying = false;
    this.updateIsPlay();
  }

  sessionPlayPrevious() {

  }

  sessionPlayNext() {

  }

  updateIsPlay() {
    this.avSessionController.setAVSessionPlayState({
      state: this.isPlaying ? avSession.PlaybackState.PLAYBACK_STATE_PLAY :
        avSession.PlaybackState.PLAYBACK_STATE_PAUSE,
      position: {
        elapsedTime: this.currentTime,
        updateTime: new Date().getTime()
      },
      duration: this.currentTime
    })
  }

  // 播放倍速设置
  @Builder
  SpeedMenu() {
    Menu() {
      MenuItem({ content: '2X' })
        .width('64vp')
        .onClick(() => {
          this.playbackSpeed = '2.0X';
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

  // 非全屏VideoController
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
        .width('60%')
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
      // Column() {
      //   Text(this.playbackSpeed)
      //     .fontSize(12)
      //     .fontColor(Color.White)
      // }
      // .width(48)
      // .height(24)
      // .padding(4)
      // .border({
      //   width: 2,
      //   color: Color.White,
      //   radius: 12
      // })
      // .bindMenu(this.SpeedMenu)

      // 全屏播放
      Image($r('app.media.fullscreen'))
        .width('24vp')
        .height('24vp')
        .onClick(() => {
          this.isFullScreen = !this.isFullScreen;
          // this.videoController.requestFullscreen(this.isFullScreen);
          if (this.isFullScreen) {
            this.windowUtil.disableWindowSystemBar();
            this.windowUtil.setLandscapeMutiWindow(true);
            this.windowUtil.setMainWindowOrientation(window.Orientation.USER_ROTATION_LANDSCAPE);
          }
        })
    }
    .width('100%')
    .position({ y: 160 }) // 设置垂直偏移量
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Center)
  }

  // 全屏VideoController
  @Builder
  FullScreenVideoControllerBuilder() {
    Row({ space: 8 }) {
      // 当前播放时间
      Text(FormatTime.getTimesBySecond(this.currentTime))
        .fontSize(12)
        .fontColor(Color.White)
      Slider({
        value: this.currentTime,
        max: this.durationTime,
        step: 1
      })
        .width('65%')
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

      // 静音
      Image(this.isMute || this.volume === 0 ? $r('app.media.mute') : $r('app.media.with_audio'))
        .width('24vp')
        .height('24vp')
        .onClick(() => {
          this.isMute = !this.isMute;
          if (this.isMute) {
            this.volume = 0.0;
          } else {
            this.volume = 0.5;
          }
        })

      // 全屏播放
      Image($r('app.media.reduce_fullscreen'))
        .width('24vp')
        .height('24vp')
        .onClick(() => {
          this.isFullScreen = !this.isFullScreen;
          // this.videoController.requestFullscreen(this.isFullScreen);
          if (!this.isFullScreen) {
            this.windowUtil.enableWindowSystemBar();
            this.windowUtil.setLandscapeMultiWindow(false);
            this.windowUtil.setMainWindowOrientation(window.Orientation.USER_ROTATION_PORTRAIT);
          }
        })
    }
    .width('100%')
    .height('40%')
    .position({ y: '73%' })
    .justifyContent(FlexAlign.Center)
  }

  private getValidValue(inputVal: number, minVal: number, maxVal: number): number {
    inputVal = inputVal >= maxVal ? maxVal : inputVal;
    inputVal = inputVal <= minVal ? minVal : inputVal;
    return inputVal;
  }

  private setScreenBrightness(brightness: number) {
    let windowStage: window.WindowStage = AppStorage.get('windowStage') as window.WindowStage;
    try {
      let mainWin: window.Window = windowStage.getMainWindowSync();
      mainWin.setWindowBrightness(brightness, (err: BusinessError) => {

      })
    } catch (e) {

    }
  }

  build() {
    Navigation(this.pageInfo) {
      Scroll() {
        Column({ space: 12 }) {
          Stack() {
            Video({
              src: this.videoSrc,
              previewUri: this.previewUri,
              controller: this.videoController,
              currentProgressRate: this.curRate, //设置播放速度
            })
            // .width(this.isFullScreen ? '90%' : '100%')
              .width('100%')
              .height(this.isFullScreen ? '100%' : 200)
              .muted(this.isMute) // 设置是否静音
              .autoPlay(this.isAutoPlay) // 设置是否自动播放
              .loop(true) // 设置是否循环播放
              .controls(false) // 设置控制视频播放的控制栏是否显示
              // this.videoController.requestFullscreen(true) // 设置是否全屏播放
              // 视频准备完成时触发该事件
              .onPrepared((event) => {
                this.currentVideoStatus = VideoStatus.PLAY_PREPARED; // 视频准备
                if (event) {
                  this.durationTime = event.duration; // 视频总时长
                  if (this.curSource) {
                    this.avSessionController.setAVMetadata(this.curSource, event.duration * 1000);
                  }
                }
              })
              // 播放时触发该事件
              .onStart(() => {
                this.isPlaying = true;
                this.currentVideoStatus = VideoStatus.PLAY_STARTED; // 开始播放
              })
              // 暂停时触发该事件
              .onPause(() => {
                this.currentVideoStatus = VideoStatus.PLAY_PAUSED; // 暂停播放
              })
              // 播放结束时触发该事件
              .onFinish(() => {
                this.currentVideoStatus = VideoStatus.PLAY_FINISH; // 播放完成
              })
              // 播放停止时触发该事件(当stop()方法被调用后触发)
              .onStop(() => {
                this.currentVideoStatus = VideoStatus.PLAY_STOPPED; // 播放完成
              })
              // 播放进度变化时触发该事件
              .onUpdate((event) => {
                if (event) {
                  this.currentTime = event.time; // 当前播放时间
                }
              })
            if (this.isFullScreen) {
              Stack() {
                VolumeAndBrightness({
                  visible: this.visible,
                  volume: this.volume,
                  screenBrightness: this.screenBrightness
                })
                this.FullScreenVideoControllerBuilder(); // 全屏
              }
              // 绑定手势事件
              .gesture(
                GestureGroup(
                  GestureMode.Exclusive,
                  // 绑定滑动手势事件
                  PanGesture({ direction: PanDirection.Vertical })
                    .onActionStart(() => {
                    })
                    .onActionUpdate((event: GestureEvent) => {
                      if (event.fingerList[0].globalX > (this.screenWidth / 2)) {
                        this.visible = true;
                        let curBrightness = this.screenBrightness -
                          this.getUIContext().vp2px(event.offsetY) / this.getUIContext().vp2px(this.screenHeight);
                        curBrightness = this.getValidValue(curBrightness, 0.0, 1.0);
                        this.screenBrightness = curBrightness;
                        this.setScreenBrightness(curBrightness);
                      } else {
                        this.visible = false;
                        let curVolume = this.volume - this.getUIContext().vp2px(event.offsetY) / this.screenHeight;
                        curVolume = this.getValidValue(curVolume, 0.0, 15.0);
                        this.volume = curVolume;
                      }
                    })
                    .onActionEnd(() => {
                      setTimeout(() => {
                        this.visible = false;
                      }, 3000)
                    }),
                  LongPressGesture({ repeat: true })
                    .onAction(() => {
                      this.playbackSpeed = '2.0X';
                      this.curRate = PlaybackSpeed.Speed_Forward_2_00_X;
                    })
                    .onActionEnd(() => {
                      this.playbackSpeed = '1.0X';
                      this.curRate = PlaybackSpeed.Speed_Forward_1_00_X;
                    })
                )
              )
            } else {
              this.VideoControllerBuilder(); // 非全屏
            }

            if (this.currentVideoStatus !== VideoStatus.PLAY_STARTED) {
              Image($r('app.media.play_pause'))
                .width('36vp')
            }
          }
          .onClick(() => {
            if (this.currentVideoStatus === VideoStatus.PLAY_STARTED) {
              this.videoController.pause();
            } else {
              this.videoController.start();
            }
          })

          if (!this.isFullScreen) {
            Column({ space: 12 }) {
              Column() {
                Text('视频列表')
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
              }
              .width('100%')
              .alignItems(HorizontalAlign.Start)

              ForEach(VideoData, (item: VideoType, index: number) => {
                Row({ space: 12 }) {
                  Image(item.previewUri)
                    .width(100)
                    .height(100)
                  Text(item.description)
                    .fontColor(this.currentVideoIndex === index ? Color.Blue : Color.Black)
                }
                .onClick(() => {
                  this.videoSrc = item.videoSrc;
                  this.previewUri = this.previewUri;
                  this.isAutoPlay = true;
                  this.currentVideoIndex = index;
                  this.curSource = item;
                })
                .width('100%')
                .height(100)
              }, (item: VideoType) => JSON.stringify(item.index))
            }
            .padding({
              left: 16,
              right: 16
            })
          }
        }
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    }
    .width('100%')
    .height('100%')
    .mode(NavigationMode.Stack)
    .hideToolBar(true)
    .hideTitleBar(true)
    .hideBackButton(true)
  }
}