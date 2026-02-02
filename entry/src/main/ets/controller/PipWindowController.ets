import { PiPWindow } from "@kit.ArkUI";
import { common } from '@kit.AbilityKit';

export class PipWindowController {
  pipController?: PiPWindow.PiPController;
  private context: common.UIAbilityContext | undefined = AppStorage.get('context');
  private xComponentController?: XComponentController;
  private currentState: string = '';

  async createPipWindow() {
    try {
      this.pipController = await PiPWindow.create({
        context: this.context,
        componentController: this.xComponentController,
        templateType: PiPWindow.PiPTemplateType.VIDEO_PLAY
      })
    } catch (err) {

    }

    this.pipController?.on('stateChange', (state: PiPWindow.PiPState, reson: string) => {

    })

    // this.pipController?.on('controlPanelActionEvent', (event: PiPWindow.PiPActionEventType, status: number) => {
    //
    // })

    this.pipController?.setAutoStartEnabled(true);
  }

  destroyPipController() {
    if (!this.pipController) {
      return;
    }
    this.pipController.setAutoStartEnabled(false);
    this.pipController.off('stateChange');
    this.pipController.off('controlPanelActionEvent');
    this.pipController = undefined;
  }

  onStateChange(state: PiPWindow.PiPState) {
    switch (state) {
      case PiPWindow.PiPState.ABOUT_TO_START:
        this.currentState = 'ABOUT_TO_START';
      case PiPWindow.PiPState.STARTED:
        this.currentState = 'STARTED';
        // let status: PiPWindow.PiPControlStatus =
    }
  }
}