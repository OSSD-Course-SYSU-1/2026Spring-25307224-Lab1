import { VideoData } from "../module/VideoData"
import { VideoType } from "../module/VideoType"

@Component
export struct VideoList {
  @Link currentVideoIndex: number;
  @Link videoSrc: ResourceStr;
  @Link previewUri: ResourceStr;
  @Link isAutoPlay: boolean;
  @Link curSource: VideoType;
  // @Prop videoController: VideoController = new VideoController();

  build() {
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
          // this.videoController?.reset();
        })
        .width('100%')
        .height(100)
      }, (item: VideoType) => JSON.stringify(item.index))
    }
    .width('100%')
    .height('100%')
    .padding({
      left: 16,
      right: 16
    })
  }
}