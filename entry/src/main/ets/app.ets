import type Want from "@ohos.app.ability.Want"
import type ohWindow from "@ohos.window"


import UIAbility from "@ohos.app.ability.UIAbility"
import AbilityConstant from "@ohos.app.ability.AbilityConstant"
import { callFn, context, Current, ObjectAssign, TaroAny, window } from "./npm/@tarojs/runtime"
import { AppInstance } from "./npm/@tarojs/runtime/dist/runtime.esm"
import { initHarmonyElement, hooks } from "./npm/@tarojs/runtime"
import { initPxTransform } from "./npm/@tarojs/taro"
import createComponent, { config } from "./app_taro_comp"


window.__taroAppConfig = config
initPxTransform({
  designWidth: 750,
  deviceRatio: ({"375":2,"640":1.17,"750":1,"828":0.905}) as Record<string, number>,
  baseFontSize: undefined,
  unitPrecision: undefined,
  targetUnit: undefined,
} as TaroAny)
export default class EntryAbility extends UIAbility {
  app?: AppInstance

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam) {
    AppStorage.setOrCreate('__TARO_ENTRY_PAGE_PATH', 'pages/index/index')
    AppStorage.setOrCreate('__TARO_PAGE_STACK', [])
    // 引入
    initHarmonyElement()
    this.app = createComponent()
    callFn(this.app?.onLaunch, this, ObjectAssign(want, launchParam))
  }

  onDestroy() {}

  onWindowStageCreate(stage: ohWindow.WindowStage) {
    context.resolver(this.context)

    this.context.getApplicationContext().on('environment', {
      onConfigurationUpdated(config) {
        AppStorage.setOrCreate('__TARO_APP_CONFIG', config)
      },
      onMemoryLevel(level) {
        hooks.call('getMemoryLevel', { level })
      }
    })

    stage.loadContent('pages/index/index', (err, data) => {
      const windowClass = stage.getMainWindowSync()
      Current.uiContext = windowClass.getUIContext()

      if (err.code) {
        return callFn(this.app?.onError, this, err)
      }
    })
  }

  onForeground() {
    callFn(this.app?.onShow, this)
  }

  onBackground() {
    callFn(this.app?.onHide, this)
  }

  onMemoryLevel(level: AbilityConstant.MemoryLevel) {
    let levelRes: number

    switch (level) {
      case AbilityConstant.MemoryLevel.MEMORY_LEVEL_MODERATE:
        levelRes = 5
        break
      case AbilityConstant.MemoryLevel.MEMORY_LEVEL_LOW:
        levelRes = 10
        break
      case AbilityConstant.MemoryLevel.MEMORY_LEVEL_CRITICAL:
        levelRes = 15
        break
    }

    if (levelRes) {
      hooks.call('getMemoryLevel', { level: levelRes })
    }
  }
}
