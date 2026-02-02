import window from "@ohos.window";
import Logger from "./Logger";

const TAG = '[WindowUtil]';

export class WindowUtil {
  private static instance: WindowUtil;
  private windowStage: window.WindowStage | undefined = undefined;
  private mainWindowClass: window.Window | undefined = undefined;

  public static getInstance(): WindowUtil {
    if (!WindowUtil.instance) {
      WindowUtil.instance = new WindowUtil();
    }
    return WindowUtil.instance;
  }

  public setWindowStage(windowStage: window.WindowStage): void {
    this.windowStage = windowStage;
    this.windowStage?.getMainWindow((err: BusinessError, windowClass: window.Window) => {
      if (err.code) {
        console.error(`Failed to obtain the main window. Cause code: ${JSON.stringify(err)}, message: ${err.message}`);
        return;
      }
      this.mainWindowClass = windowClass;
    })
  }

  public setMainWindowOrientation(orientation: window.Orientation) {
    if (!this.mainWindowClass) {
      return;
    }
    this.mainWindowClass.setPreferredOrientation(orientation)
      .then(() => {
        Logger.info('setPreferredOrientation succeed.');
      })
      .catch((err: BusinessError) => {
        Logger.warn(TAG, `setPreferredOrientation failed. code: ${err.code}, message: ${err.message}`);
      })
  }


  // 显示主窗口状态栏、底部导航（根据用户设置，可表现为导航条或三键导航栏）
  public enableWindowSystemBar(): void {
    if (!this.mainWindowClass) {
      return;
    }
    this.mainWindowClass.setWindowSystemBarEnable(['status', 'navigation'])
      .catch((err: BusinessError) => {
        Logger.warn(TAG, `setWindowSystemBarEnable failed. code: ${err.code}, message: ${err.message}`);
      })
  }

  // 禁用主窗口状态栏、底部导航
  public disableWindowSystemBar(): void {
    if (!this.mainWindowClass) {
      return;
    }
    this.mainWindowClass.setWindowSystemBarEnable([])
      .catch((err: BusinessError) => {
        Logger.warn(TAG, `setWindowSystemBarEnable failed. code: ${err.code}, message: ${err.message}`);
      })
  }

  public setLandscapeMutiWindow(enable: boolean) {
    if (!this.mainWindowClass) {
      return;
    }
    if (enable) {
      this.mainWindowClass.enableLandscapeMultiWindow() // 应用部分界面支持横向布局时，在进入该界面时使能，使能后可支持进入横向多窗
        .catch((err: BusinessError) => {
          Logger.warn(TAG, `enableLandscapeMultiWindow failed. code: ${err.code}, message: ${err.message}`);
        })
    } else {
      this.mainWindowClass.disableLandscapeMultiWindow() // 应用部分界面支持横向布局时，在退出该界面时去使能，去使能后不支持进入横向多窗
        .catch((err: BusinessError) => {
          Logger.warn(TAG, `disableLandscapeMultiWindow failed. code: ${err.code}, message: ${err.message}`);
        })
    }
  }

  public setLandscapeMultiWindow(enable: boolean) {
    if (!this.mainWindowClass) {
      return;
    }
    if (enable) {
      this.mainWindowClass.enableLandscapeMultiWindow()
        .then(() => {
          Logger.info('enableLandscapeMultiWindow succeed.');
        })
        .catch((err: BusinessError) => {
          Logger.warn(TAG, `enableLandscapeMultiWindow failed. code: ${err.code}, message: ${err.message}`);
        })
    } else {
      this.mainWindowClass.disableLandscapeMultiWindow()
        .then(() => {
          Logger.info('disableLandscapeMultiWindow succeed.');
        })
        .catch((err: BusinessError) => {
          Logger.warn(TAG, `disableLandscapeMultiWindow failed. code: ${err.code}, message: ${err.message}`);
        })
    }
  }

  // 注册监听窗口尺寸变化事件
  registerOnWindowSizeChange(callback?: (size: window.Size) => void) {
    if (!this.mainWindowClass) {
      return;
    }
    this.mainWindowClass.on('windowSizeChange', (size) => {
      AppStorage.setOrCreate('deviceHeight', size.height);
      callback?.(size);
    })
  }

  // 取消监听窗口尺寸变化事件
  registerOffWindowSizeChange() {
    if (!this.mainWindowClass) {
      return;
    }
    this.mainWindowClass.off('windowSizeChange');
  }
}