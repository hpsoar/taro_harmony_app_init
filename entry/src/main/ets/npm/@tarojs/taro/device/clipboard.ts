// @ts-nocheck
// 从 API Version 6 开始支持
import pasteboard from '@ohos.pasteboard'
import { isString } from '../../shared'

import { callAsyncFail, getParameterError, object2String } from '../utils'
import { MethodHandler } from '../utils/handler'

import type Taro from '../types'

/**
 * 设置系统剪贴板的内容
 */
export const setClipboardData: typeof Taro.setClipboardData = function (options) {
  const { data, success, fail, complete } = options
  const handle = new MethodHandler<{ data: string }>({ name: 'setClipboardData', success, fail, complete })
  let res = {}

  if (!isString(data)) {
    return handle.fail({
      errMsg: getParameterError({
        para: 'data',
        correct: 'String',
        wrong: data
      })
    })
  }

  return new Promise((resolve, reject) => {
    const systemPasteboard = pasteboard.getSystemPasteboard()
    const pasteData = pasteboard.createPlainTextData(data)

    systemPasteboard.setPasteData(pasteData, (error, data) => { // callback形式调用异步接口
      if (error) {
        console.error('Failed to set PasteData. Cause: ' + JSON.stringify(error))
        res = {
          errMsg: 'setClipboardData:fail,error: ' + object2String(error),
          error: error
        }
        callAsyncFail(reject, res, options)
      } else {
        return handle.success({
          data,
        }, { resolve, reject })
      }
    })
  })
}

/**
 * 获取系统剪贴板的内容
 */
export const getClipboardData: typeof Taro.getClipboardData = function (options) {
  const { success, fail, complete } = options || {}
  const handle = new MethodHandler({ name: 'getClipboardData', success, fail, complete })
  return new Promise((resolve, reject) => {
    const systemPasteboard = pasteboard.getSystemPasteboard()
    systemPasteboard.getPasteData((error, pasteData) => { // callback 形式调用异步接口
      if (error) {
        console.error('Failed to obtain PasteData. Cause: ' + JSON.stringify(error))
        return handle.fail({
          errMsg: object2String(error),
        }, { resolve, reject })
      } else {
        return handle.success({
          data: pasteData.getPrimaryText(),
        }, { resolve, reject })
      }
    })
  })
}
