// @ts-nocheck
import { eventCenter } from '../../runtime/dist/runtime.esm'

import { ICallbackResult, MethodHandler } from './handler'

import type { FunctionType, IAsyncParams } from './types'

export * from './validate'
export { noop } from '../../shared'

export function object2String (obj) {
  let str = ''
  for (const item in obj) {
    str = str + item + ':' + obj[item] + ' \n'
  }
  return str
}

export function temporarilyNotSupport (name: string, recommended?: string) {
  return (option = {}, ...args) => {
    const { success, fail, complete } = option as any
    const handle = new MethodHandler({ name, success, fail, complete })
    let errMsg = `暂时不支持 API ${name}`
    if (recommended) {
      errMsg += `, 请使用 ${recommended}`
    }
    eventCenter.trigger('__taroNotSupport', {
      name,
      args: [option, ...args],
      type: 'method',
      category: 'temporarily',
    })
    if ("production" === 'production') {
      console.warn(errMsg)
      return handle.success({ errMsg })
    } else {
      return handle.fail({ errMsg })
    }
  }
}

export function permanentlyNotSupport (name = '') {
  return (option = {}, ...args: any[]) => {
    const { success, fail, complete } = option as any
    const handle = new MethodHandler<ICallbackResult>({ name, success, fail, complete })
    const errMsg = '不支持 API'
    eventCenter.trigger('__taroNotSupport', {
      name,
      args: [option, ...args],
      type: 'method',
      category: 'permanently',
    })
    if ("production" === 'production') {
      console.warn(errMsg)
      return handle.success({ errMsg })
    } else {
      return handle.fail({ errMsg })
    }
  }
}

/** @deprecated */
export function callCallbackSuccess<T extends FunctionType> (res, options?: IAsyncParams<T>) {
  options?.success?.(res)
  options?.complete?.(res)
}

/** @deprecated */
export function callCallbackFail<T extends FunctionType> (res, options?: IAsyncParams<T>) {
  options?.fail?.(res)
  options?.complete?.(res)
}

/** @deprecated */
export function callAsyncSuccess<T extends FunctionType> (resolve, res, options?: IAsyncParams<T>) {
  options?.success?.(res)
  options?.complete?.(res)
  resolve(res)
}

/** @deprecated */
export function callAsyncFail<T extends FunctionType> (reject, res, options?: IAsyncParams<T>) {
  options?.fail?.(res)
  options?.complete?.(res)
  reject(res)
}
