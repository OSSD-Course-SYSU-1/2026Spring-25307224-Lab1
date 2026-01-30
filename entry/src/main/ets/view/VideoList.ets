@Component
export struct VideoList {
  private videoList: string[] = ['1', '2', '3', '4', '5','1', '2', '3', '4', '5'];

  build() {
    Column() {
      ForEach(this.videoList, (item: string, index: number) => {
        Text(item)
          .width('100%')
          .height(100)
          .backgroundColor(Color.Gray)
      }, (index: number) => JSON.stringify(index))
    }
    .width('100%')
    .height('100%')
  }
}