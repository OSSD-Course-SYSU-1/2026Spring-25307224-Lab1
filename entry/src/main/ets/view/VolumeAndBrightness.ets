import { AVVolumePanel } from "@kit.AudioKit"

@Component
export struct VolumeAndBrightness {
  @Prop volume: number;
  @Prop visible: boolean;
  @Prop screenBrightness: number;

  build() {
    Row() {
      // 音量调节
      Column() {
        AVVolumePanel({
          volumeLevel: this.volume,
          volumeParameter: {
            position: {
              x: 150,
              y: 300
            }
          }
        })
      }
      .width('50%')
      .justifyContent(FlexAlign.Start)
      .alignItems(HorizontalAlign.Start)

      // 亮度调节
      Column() {
        Stack() {
          Slider({
            min: 0,
            max: 1,
            step:0.05,
            value: this.screenBrightness,
            style: SliderStyle.NONE,
            direction: Axis.Vertical,
            reverse: true
          })
            .height(160)
            .trackThickness(40)
            .trackColor(Color.Black)
            .selectedColor(Color.White)
            .visibility(this.visible ? Visibility.Visible : Visibility.None)

          Image($r('app.media.brightness_fill'))
            .width(20)
            .height(20)
            .margin({ top: 120 })
            .visibility(this.visible ? Visibility.Visible : Visibility.None)
        }
      }
      .width('50%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.End)
      .padding({ right: 30, bottom: 20 })
    }
    .width('100%')
    .height('100%')
  }
}