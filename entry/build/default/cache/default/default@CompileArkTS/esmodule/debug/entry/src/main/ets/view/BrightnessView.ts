if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
interface BrightnessView_Params {
    brightnessValue?: number;
    visible?: boolean;
}
import CommonConstants from "@normalized:N&&&entry/src/main/ets/constants/CommonConstants&";
export class BrightnessView extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.__brightnessValue = new SynchedPropertySimpleOneWayPU(params.brightnessValue, this, "brightnessValue");
        this.__visible = new SynchedPropertySimpleOneWayPU(params.visible, this, "visible");
        this.setInitiallyProvidedValue(params);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: BrightnessView_Params) {
    }
    updateStateVars(params: BrightnessView_Params) {
        this.__brightnessValue.reset(params.brightnessValue);
        this.__visible.reset(params.visible);
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
        this.__brightnessValue.purgeDependencyOnElmtId(rmElmtId);
        this.__visible.purgeDependencyOnElmtId(rmElmtId);
    }
    aboutToBeDeleted() {
        this.__brightnessValue.aboutToBeDeleted();
        this.__visible.aboutToBeDeleted();
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    private __brightnessValue: SynchedPropertySimpleOneWayPU<number>;
    get brightnessValue() {
        return this.__brightnessValue.get();
    }
    set brightnessValue(newValue: number) {
        this.__brightnessValue.set(newValue);
    }
    private __visible: SynchedPropertySimpleOneWayPU<boolean>;
    get visible() {
        return this.__visible.get();
    }
    set visible(newValue: boolean) {
        this.__visible.set(newValue);
    }
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.width('100%');
            Row.height('100%');
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // Brightness adjustment panel
            Column.create({ space: 8 });
            // Brightness adjustment panel
            Column.width('50%');
            // Brightness adjustment panel
            Column.justifyContent(FlexAlign.Start);
            // Brightness adjustment panel
            Column.alignItems(HorizontalAlign.Start);
            // Brightness adjustment panel
            Column.padding({ left: 16, right: 16, top: 12, bottom: 12 });
            // Brightness adjustment panel
            Column.backgroundColor('#202224');
            // Brightness adjustment panel
            Column.borderRadius(8);
            // Brightness adjustment panel
            Column.opacity(this.visible ? 1 : 0);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // Brightness icon
            Image.create({ "id": 16777235, "type": 20000, params: [], "bundleName": "com.example.PlayLongVideosBasedOnVideo", "moduleName": "entry" });
            // Brightness icon
            Image.width(24);
            // Brightness icon
            Image.height(24);
            // Brightness icon
            Image.fillColor('#FFFFFF');
        }, Image);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // Brightness slider
            Slider.create({
                value: this.brightnessValue,
                min: CommonConstants.MIN_BRIGHTNESS,
                max: CommonConstants.MAX_BRIGHTNESS,
                step: 0.1
            });
            // Brightness slider
            Slider.width(120);
            // Brightness slider
            Slider.height(4);
            // Brightness slider
            Slider.trackColor('#666666');
            // Brightness slider
            Slider.selectedColor('#FFFFFF');
            // Brightness slider
            Slider.blockColor('#FFFFFF');
            // Brightness slider
            Slider.blockSize({ width: 20, height: 20 });
            // Brightness slider
            Slider.showSteps(true);
            // Brightness slider
            Slider.onChange((value: number) => {
                // Brightness value will be updated by parent component
            });
        }, Slider);
        // Brightness adjustment panel
        Column.pop();
        Row.pop();
    }
    rerender() {
        this.updateDirtyElements();
    }
}
