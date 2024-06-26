// @ts-nocheck
import {
  useAddToFavorites,
  useDidHide,
  useDidShow,
  useError,
  useLaunch,
  useLoad,
  useOptionMenuClick,
  usePageNotFound,
  usePageScroll,
  usePullDownRefresh,
  usePullIntercept,
  useReachBottom,
  useReady,
  useResize,
  useRouter,
  useSaveExitState,
  useShareAppMessage,
  useShareTimeline,
  useTabItemTap,
  useTitleClick,
  useScope,
  useUnhandledRejection,
  useUnload
} from '../plugin-framework-react/dist/runtime'
import _display from '@ohos.display'
import { Current, hooks } from '../runtime'
import { isFunction, PLATFORM_TYPE } from '../shared'

import * as apis from './apis'
import { permanentlyNotSupport } from './utils'

const taro = Object.assign({}, apis)

const requirePlugin = /* @__PURE__ */ permanentlyNotSupport('requirePlugin')
export function initNativeApi (taro) {
  (Current as any).taro = taro
  taro.requirePlugin = requirePlugin
  taro.getApp = getApp
  taro.pxTransform = pxTransform
  taro.initPxTransform = initPxTransform
  taro.canIUseWebp = canIUseWebp
  taro.getAppInfo = getAppInfo

  if (hooks.isExist('initNativeApi')) {
    hooks.call('initNativeApi', taro)
  }
}

const defaultDesignWidth = 750
const defaultDesignRatio: Record<string | number, number> = {
  640: 2.34 / 2,
  750: 1,
  828: 1.81 / 2
}
const defaultBaseFontSize = 20
const defaultUnitPrecision = 5
const defaultTargetUnit = 'vp'

export function getApp () {
  return Current.app || {}
}

export function initPxTransform ({
  designWidth = defaultDesignWidth,
  deviceRatio = defaultDesignRatio,
  baseFontSize = defaultBaseFontSize,
  unitPrecision = defaultUnitPrecision,
  targetUnit = defaultTargetUnit
}) {
  const taro = (Current as any).taro

  if (taro) {
    taro.config ||= {}
    const config = taro.config
    config.designWidth = designWidth
    config.deviceRatio = deviceRatio
    config.baseFontSize = baseFontSize
    config.targetUnit = targetUnit
    config.unitPrecision = unitPrecision
  }
}

const display = _display.getDefaultDisplaySync()

let displayWidth = display.width
let ratioCache: number | false = false
let designWidthFunc: (input: number) => number
let designWidth = defaultDesignWidth
let deviceRatio = defaultDesignRatio
function getRatio (value: number) {
  // Note: 提前调用 display 可能无法获取正确值
  if (ratioCache === false || displayWidth !== display.width) {
    const config = (Current as any).taro?.config || {}
    if (!isFunction(designWidthFunc)) {
      designWidthFunc = isFunction(config.designWidth)
        ? config.designWidth
        : () => config.designWidth
      designWidth = designWidthFunc(value) || defaultDesignWidth
      deviceRatio = config.deviceRatio || defaultDesignRatio
      if (!(designWidth in deviceRatio)) {
        throw new Error(`deviceRatio 配置中不存在 ${designWidth} 的设置！`)
      }
    }
    displayWidth = display.width
    ratioCache = Math.min(display.width, display.height) / designWidth / deviceRatio[designWidth]
  }

  return ratioCache
}

// Note: 设置为 style 单位时会自动完成设计稿转换，设计开发者调用 API 时也许抹平差异，例如 pageScrollTo[option.offsetTop]
export function pxTransformHelper (size: number, unit?: string, isNumber = false): number | string {
  const config = (Current as any).taro?.config || {}
  const targetUnit = unit || config.targetUnit || defaultTargetUnit

  if (targetUnit === 'PX') {
    return px2vp(size * display.scaledDensity) + 'vp'
  }
  const ratio = getRatio(size)
  let val = size * ratio

  switch (targetUnit) {
    case 'vp':
      // Note: 在应用创建前调用无效
      val = px2vp(val)
      break
    default:
  }
  return isNumber ? val : val + targetUnit
}

export function pxTransform (size: number): number | string {
  const config = (Current as any).taro?.config || {}
  const targetUnit = config.targetUnit || defaultTargetUnit

  const val = size
  switch (targetUnit) {
    case 'vp':
      return pxTransformHelper(size, 'px')
    default:
      // NOTE: 鸿蒙环境下 style 会自动完成设计稿转换，无需在方法内二次调整
  }
  return val + targetUnit
}

export function canIUseWebp () {
  return true
}

export function getAppInfo () {
  const config = (Current as any).taro?.config
  return {
    platform: "harmony" || PLATFORM_TYPE.HARMONY,
    taroVersion: "\"4.0.0-canary.11\"" || 'unknown',
    designWidth: config?.designWidth,
  }
}

initNativeApi(taro)

export * from './apis'
export default taro


taro.useAddToFavorites = useAddToFavorites
taro.useDidHide = useDidHide
taro.useDidShow = useDidShow
taro.useError = useError
taro.useLaunch = useLaunch
taro.useLoad = useLoad
taro.useOptionMenuClick = useOptionMenuClick
taro.usePageNotFound = usePageNotFound
taro.usePageScroll = usePageScroll
taro.usePullDownRefresh = usePullDownRefresh
taro.usePullIntercept = usePullIntercept
taro.useReachBottom = useReachBottom
taro.useReady = useReady
taro.useResize = useResize
taro.useRouter = useRouter
taro.useSaveExitState = useSaveExitState
taro.useShareAppMessage = useShareAppMessage
taro.useShareTimeline = useShareTimeline
taro.useTabItemTap = useTabItemTap
taro.useTitleClick = useTitleClick
taro.useScope = useScope
taro.useUnhandledRejection = useUnhandledRejection
taro.useUnload = useUnload

export {
  useAddToFavorites,
  useDidHide,
  useDidShow,
  useError,
  useLaunch,
  useLoad,
  useOptionMenuClick,
  usePageNotFound,
  usePageScroll,
  usePullDownRefresh,
  usePullIntercept,
  useReachBottom,
  useReady,
  useResize,
  useRouter,
  useSaveExitState,
  useShareAppMessage,
  useShareTimeline,
  useTabItemTap,
  useTitleClick,
  useScope,
  useUnhandledRejection,
  useUnload
}
