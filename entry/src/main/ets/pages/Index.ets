/*
 * Copyright (c) 2026 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { LengthMetrics, window } from '@kit.ArkUI';
import { avSession } from '@kit.AVSessionKit';
import { VideoData } from '../module/VideoData';
import { VideoInfo } from '../module/VideoInfo';
import { WindowUtil } from '../utils/WindowUtil';
import { FormatTime } from '../utils/FotmatTime';
import { VolumeAndBrightness } from '../view/VolumeAndBrightness';
import { AVSessionController } from '../controller/AVSessionController';
import { SmallWidnowVideo } from '../view/SmallWidnowVideo';
import { VideoListPage } from '../view/VideoListPage';
import { VideoStatus } from '../constants/VideoStatus';
import Logger from '../utils/Logger';

const TAG = '[IndexPage]';

@Entry
@Component
struct Index {
  private screenWidth: number = 0; // Screen width.
  private screenHeight: number = 0; // Screen height.
  private windowUtil: WindowUtil = WindowUtil.getInstance();
  private videoController: VideoController = new VideoController();
  private avSessionController: AVSessionController = AVSessionController.getInstance();
  private timeoutID: number = 0;
  @State currentVideoStatus: string = 'init';
  @State videoSrc: Resource = $rawfile('mountaineer.mp4');
  @State previewUri: Resource = $r('app.media.mountaineer');
  @State isAutoPlay: boolean = false; // Whether to play automatically.
  @State currentVideoIndex: number = 0;
  @State isFullScreen: boolean = false; // Whether to play in full screen.
  @State currentTime: number = 0; // Initialize the current time to 0.
  @State durationTime: number = 0; // Initialize the total video duration to 0.
  @State playbackSpeed: string = '1.0X';
  @State curRate: PlaybackSpeed = PlaybackSpeed.Speed_Forward_1_00_X; // Playback speed.
  @State isMute: boolean = false; // Play with mute or not.
  @State visible: boolean = false; // Whether to display the brightness adjustment icon and slider.
  @State volume: number = 5;
  @State screenBrightness: number = 0;
  @State curSource: VideoInfo | undefined = undefined;
  @State isPlaying: boolean = false;
  @State scrollVal: number = 0;

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
      // Get the width and height of the window.
      window.getLastWindow(this.getUIContext().getHostContext(), (err: BusinessError, data: window.Window) => {
        if (err.code) {
          Logger.error(TAG, `getLastWindow failed. code: ${err.code}, message: ${err.message}`);
          return;
        }
        this.screenWidth = data.getWindowProperties().windowRect.width;
        this.screenHeight = data.getWindowProperties().windowRect.height;
      })
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `getWindowProperties failed. code: ${err.code}, message: ${err.message}`);
    }
    this.timeoutID = setTimeout(() => {
      this.setAVSessionListener();
    }, 100);
  }

  aboutToDisappear() {
    clearTimeout(this.timeoutID);
    this.windowUtil.registerOffWindowSizeChange();
    this.avSessionController.unregisterSessionListener();
  }

  onPageShow() {
    this.sessionPlay();
  }

  onPageHide() {
    this.sessionPause();
  }

  // Set AVSession to listen.
  public async setAVSessionListener() {
    if (!this.avSessionController) {
      return;
    }
    try {
      this.avSessionController.getAVSession()?.on('play', () => this.sessionPlay());
      this.avSessionController.getAVSession()?.on('pause', () => this.sessionPause());
      this.avSessionController.getAVSession()?.on('seek', (msTime: number) => {
        this.sessionSeek(msTime);
      });
      this.avSessionController.getAVSession()?.on('setLoopMode', () => {
      });
      this.avSessionController.getAVSession()?.on('playPrevious', () => this.changePlayVideo(true));
      this.avSessionController.getAVSession()?.on('playNext', () => this.changePlayVideo(false));
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `Set AVSession listener failed. code: ${err.code}, message: ${err.message}`);
    }
  }

  // AVSession video playback.
  sessionPlay() {
    if (this.curSource) {
      this.avSessionController.setAVMetadata(this.curSource, this.durationTime * 1000);
    }
    this.videoController.start();
    this.isPlaying = true;
    this.updateIsPlay();
  }

  // AVSession video paused.
  sessionPause() {
    if (this.curSource) {
      this.avSessionController.setAVMetadata(this.curSource, this.durationTime * 1000);
    }
    this.videoController.pause();
    this.isPlaying = false;
    this.updateIsPlay();
  }

  // AVSession video jump playback.
  sessionSeek(msTime: number) {
    if (this.curSource) {
      this.avSessionController.setAVMetadata(this.curSource, this.durationTime * 1000);
    }
    this.isPlaying = true;
    this.updateIsPlay();
    this.videoController.setCurrentTime(msTime / 1000, SeekMode.Accurate);
    this.videoController.start();
  }

  // AVSession switches to the previous/next video.
  changePlayVideo(isPrevious: boolean) {
    if (!VideoData.length) {
      return;
    }
    if (isPrevious) {
      this.currentVideoIndex = (this.currentVideoIndex - 1 + VideoData.length) % VideoData.length;
    } else {
      this.currentVideoIndex = (this.currentVideoIndex + 1) % VideoData.length;
    }
    this.curSource = VideoData[this.currentVideoIndex];
    if (!this.curSource) {
      return;
    }
    this.videoSrc = this.curSource.videoSrc;
    this.previewUri = this.curSource.previewUri;

    // Stop the current playback and reset the status.
    this.videoController.stop();
    this.currentTime = 0;
    this.isPlaying = false;

    // Update metadata.
    this.avSessionController.setAVMetadata(this.curSource, this.durationTime * 1000);
    this.currentVideoStatus = VideoStatus.PLAY_STARTED;
    this.updateIsPlay();
    this.videoController.start();
    this.isAutoPlay = true;
  }

  // Update AVSession playback status.
  updateIsPlay() {
    this.avSessionController.setAVSessionPlayState({
      state: this.isPlaying ? avSession.PlaybackState.PLAYBACK_STATE_PLAY :
        avSession.PlaybackState.PLAYBACK_STATE_PAUSE, // Playback status.
      position: {
        elapsedTime: this.currentTime * 1000, // Elapsed time.
        updateTime: new Date().getTime() // Update time.
      },
      duration: this.durationTime * 1000 // The duration of current media resources.
    })
  }

  // Playback speed setting.
  @Builder
  SpeedMenu() {
    Menu() {
      MenuItem({ content: '2X' })
        .width('100%')
        .onClick(() => {
          this.playbackSpeed = '2.0X';
          this.curRate = PlaybackSpeed.Speed_Forward_2_00_X;
        })
      MenuItem({ content: '1.75X' })
        .width('100%')
        .onClick(() => {
          this.playbackSpeed = '1.75X';
          this.curRate = PlaybackSpeed.Speed_Forward_1_75_X;
        })
      MenuItem({ content: '1.25X' })
        .width('100%')
        .onClick(() => {
          this.playbackSpeed = '1.25X';
          this.curRate = PlaybackSpeed.Speed_Forward_1_25_X;
        })
      MenuItem({ content: '1.0X' })
        .width('100%')
        .onClick(() => {
          this.playbackSpeed = '1.0X';
          this.curRate = PlaybackSpeed.Speed_Forward_1_00_X;
        })
    }
    .width(80)
    .font({
      size: 12
    })
    .fontColor(Color.White)
    .menuItemDivider({
      strokeWidth: LengthMetrics.vp(0.5),
      color: '#d5d5d5',
      mode: DividerMode.EMBEDDED_IN_MENU
    })
    .backgroundColor('#80000000')
  }

  // Non-full screen playback.
  @Builder
  VideoControllerBuilder() {
    Row({ space: 4 }) {
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
          this.videoController.setCurrentTime(value, SeekMode.Accurate);
        })
      Text(FormatTime.getTimesBySecond(this.durationTime))
        .fontSize(12)
        .fontColor(Color.White)
      Image($r('app.media.fullscreen'))
        .width('24vp')
        .height('24vp')
        .onClick(() => {
          this.isFullScreen = !this.isFullScreen;
          if (this.isFullScreen) {
            this.windowUtil.setLandscapeMultiWindow(true);
            this.windowUtil.disableWindowSystemBar();
            this.windowUtil.setMainWindowOrientation(window.Orientation.USER_ROTATION_LANDSCAPE);
          }
        })
    }
    .width('100%')
    .position({ y: 160 })
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Center)
  }

  // Full screen playback.
  @Builder
  FullScreenVideoControllerBuilder() {
    Row({ space: 8 }) {
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
          this.videoController.setCurrentTime(value, SeekMode.Accurate);
        })
      Text(FormatTime.getTimesBySecond(this.durationTime))
        .fontSize(12)
        .fontColor(Color.White)
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

      Image(this.isMute || this.volume === 0.0 ? $r('app.media.mute') : $r('app.media.with_audio'))
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
      Image($r('app.media.reduce_fullscreen'))
        .width('24vp')
        .height('24vp')
        .onClick(() => {
          this.isFullScreen = !this.isFullScreen;
          if (!this.isFullScreen) {
            this.windowUtil.setLandscapeMultiWindow(false);
            this.windowUtil.enableWindowSystemBar();
            this.windowUtil.setMainWindowOrientation(window.Orientation.USER_ROTATION_PORTRAIT);
          }
        })
    }
    .width('100%')
    .height('40%')
    .position({ y: '73%' })
    .justifyContent(FlexAlign.Center)
  }

  // Range limit for input values.
  private getValidValue(inputVal: number, minVal: number, maxVal: number): number {
    // When the input value exceeds the maximum value, take the maximum value.
    inputVal = Math.min(inputVal, maxVal);
    // Lower limit limit: When the input value is less than the minimum value, take the minimum value.
    inputVal = Math.max(inputVal, minVal);
    return inputVal;
  }

  // Set screen brightness.
  private setScreenBrightness(brightness: number) {
    if (!AppStorage.has('windowStage')) {
      return;
    }
    let windowStage: window.WindowStage = AppStorage.get('windowStage') as window.WindowStage;
    try {
      let mainWin: window.Window = windowStage.getMainWindowSync();
      mainWin.setWindowBrightness(brightness, (err: BusinessError) => {
        Logger.error(TAG, `Set window brightness failed. code: ${err.code}, message: ${err.message}`);
      })
    } catch (e) {
      let err = e as BusinessError;
      Logger.error(TAG, `Get main window failed. code: ${err.code}, message: ${err.message}`);
    }
  }

  build() {
    Column() {
      Scroll() {
        Column({ space: 12 }) {
          Stack() {
            Video({
              src: this.videoSrc,
              previewUri: this.previewUri,
              controller: this.videoController,
              currentProgressRate: this.curRate, // Set playback speed.
            })
              .width(this.isFullScreen ? '80%' : '100%')
              .height(this.isFullScreen ? '90%' : 200)
              .muted(this.isMute)
              .autoPlay(this.isAutoPlay)
              .loop(true)
              .controls(false)
              .onPrepared((event) => {
                this.currentVideoStatus = VideoStatus.PLAY_PREPARED;
                if (event) {
                  this.durationTime = event.duration;
                  if (this.curSource) {
                    this.avSessionController.setAVMetadata(this.curSource, event.duration * 1000);
                  }
                }
              })
              .onStart(() => {
                this.isPlaying = true;
                this.currentVideoStatus = VideoStatus.PLAY_STARTED;
                this.updateIsPlay();
              })
              .onPause(() => {
                this.currentVideoStatus = VideoStatus.PLAY_PAUSED;
                this.updateIsPlay();
              })
              .onFinish(() => {
                this.currentVideoStatus = VideoStatus.PLAY_FINISHED;
              })
              .onStop(() => {
                this.currentVideoStatus = VideoStatus.PLAY_STOPPED;
              })
              .onUpdate((event) => {
                if (event) {
                  this.currentTime = event.time;
                  this.updateIsPlay();
                }
              })
            if (this.isFullScreen) {
              Stack() {
                VolumeAndBrightness({
                  visible: this.visible,
                  volume: this.volume,
                  screenBrightness: this.screenBrightness
                })
                this.FullScreenVideoControllerBuilder();
              }
              // Bind gesture event.
              .gesture(
                GestureGroup(
                  GestureMode.Exclusive,
                  // Bind the swipe gesture event.
                  PanGesture({ direction: PanDirection.Vertical })
                    .onActionStart(() => {
                    })
                    .onActionUpdate((event: GestureEvent) => {
                      if (event.fingerList.length === 0) {
                        return;
                      }
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
                      }, 1500)
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
              this.VideoControllerBuilder();
            }

            if (this.currentVideoStatus !== VideoStatus.PLAY_STARTED) {
              Image($r('app.media.play_pause'))
                .width(36)
            }
          }
          .onClick(() => {
            if (this.currentVideoStatus === VideoStatus.PLAY_STARTED) {
              this.videoController.pause();
              this.isPlaying = false;
              this.updateIsPlay();
            } else {
              this.videoController.start();
              this.isPlaying = true;
              this.updateIsPlay();
            }
          })

          // Video list area.
          if (!this.isFullScreen) {
            VideoListPage({
              currentVideoIndex: this.currentVideoIndex,
              videoSrc: this.videoSrc,
              previewUri: this.previewUri,
              isAutoPlay: this.isAutoPlay,
              curSource: this.curSource,
            })
          }
        }
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
      .onWillScroll((_xOffset: number, yOffset: number) => {
        this.scrollVal += yOffset;
      })

      // Play in a small window.
      if (this.scrollVal >= 240 && this.isPlaying) {
        SmallWidnowVideo({
          videoSrc: this.videoSrc,
          previewUri: this.previewUri,
          curRate: this.curRate,
          isMute: this.isMute,
          currentTime: this.currentTime,
          isPlaying: this.isPlaying,
          videoController: this.videoController,
        })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.isFullScreen ? Color.Black : Color.White)
  }
}