import type { TaroAny, HarmonyStyle, TaroElement, TaroStyleType } from '../runtime'
import { isUndefined } from '../shared'
import { computeBackgroundPosition } from './utils'
import { getNormalAttributes } from './utils/helper'
import { isMaxWidthView } from './utils/styles'

class CommonStyleModify implements AttributeModifier<CommonAttribute> {
  initStyle?: TaroStyleType
  node: TaroElement | null = null
  style: TaroStyleType | null = null
  overwriteStyle: Record<string, TaroAny> = {}
  
  setAnimationStyle (overwriteStyle: Record<string, TaroAny>) {
    this.overwriteStyle = overwriteStyle

    return this
  }

  setNode (node: TaroElement, initStyle?: TaroStyleType) {
    this.node = node
    this.style = getNormalAttributes(this.node)
    this.initStyle = initStyle
    // 覆盖初始化样式
    if (initStyle) {
      Object.keys(initStyle).forEach(key => {
        if (this.style && !this.style[key]) {
          this.style[key] = initStyle[key]
        }
      })
    }
    return this
  }

  applyNormalAttribute(instance: CommonAttribute): void {
    if (this.node && this.style) {
      setNormalAttributeIntoInstance(instance, this.style, this.node)
    }

    setAnimationAttributeIntoInstance(instance, this.overwriteStyle, this.style || {})
  }
}

class PseudoStyleModify implements AttributeModifier<CommonAttribute> {
  style: TaroStyleType | null = null

  setStyle (style: HarmonyStyle) {
    this.style = style
    return this
  }

  applyNormalAttribute(instance: CommonAttribute): void {
    if (this.style) {
      setNormalAttributeIntoInstance(instance, this.style)
    }
  }
}


class RowStyleModify extends CommonStyleModify {

  applyNormalAttribute(instance: CommonAttribute): void {
    if (this.style) {
      setNormalAttributeIntoInstance(instance, this.style, this.node)
      instance.constraintSize({
        minWidth: this.style.minWidth || this.style.width,
        maxWidth: this.style.maxWidth,
        minHeight: this.style.minHeight,
        maxHeight: this.style.maxHeight
      })
    }

    setAnimationAttributeIntoInstance(instance, this.overwriteStyle, this.style || {})
  }
}

class ColumnStyleModify extends CommonStyleModify {
  applyNormalAttribute(instance: CommonAttribute): void {
    if (this.style) {
      setNormalAttributeIntoInstance(instance, this.style, this.node)
      instance.constraintSize({
        minWidth: this.style.minWidth,
        maxWidth: this.style.maxWidth,
        minHeight: this.style.minHeight || this.style.height,
        maxHeight: this.style.maxHeight
      })
    }

    setAnimationAttributeIntoInstance(instance, this.overwriteStyle, this.style || {})
  }
}

function setAnimationAttributeIntoInstance(instance: CommonAttribute, overwriteStyle: Record<string, TaroAny>, style: TaroStyleType) {
  // Animation 需要提前和 @State 变量绑定才能产生动画效果，因此不能做 if else 判断
  instance.translate({
    x: overwriteStyle.translate?.x || style.transform?.Translate?.x,
    y: overwriteStyle.translate?.y || style.transform?.Translate?.y,
    z: overwriteStyle.translate?.z || style.transform?.Translate?.z,
  })
  instance.scale({
    x: overwriteStyle.scale?.x || style.transform?.Scale?.x,
    y: overwriteStyle.scale?.y || style.transform?.Scale?.y,
    z: overwriteStyle.scale?.z || style.transform?.Scale?.z,
    centerX: overwriteStyle.transformOrigin?.x || style.transformOrigin?.x || 0,
    centerY: overwriteStyle.transformOrigin?.y || style.transformOrigin?.y || 0,
  })
  instance.rotate({
    x: overwriteStyle.rotate?.x || style.transform?.Rotate?.x,
    y: overwriteStyle.rotate?.y || style.transform?.Rotate?.y,
    z: overwriteStyle.rotate?.z || style.transform?.Rotate?.z,
    centerX: overwriteStyle.transformOrigin?.x || style.transformOrigin?.x || 0,
    centerY: overwriteStyle.transformOrigin?.y || style.transformOrigin?.y || 0,
    angle: overwriteStyle.rotate?.angle || style.transform?.Rotate?.angle || 0,
  })
}

function setNormalAttributeIntoInstance(instance: CommonAttribute, style: TaroStyleType, node?: TaroElement | null) {
  if (!isUndefined(style.id)) {
    instance.id(style.id)
    instance.key(style.id)
  }
  if (!isUndefined(style.flexGrow)) {
    instance.flexGrow(style.flexGrow)
  }
  if (!isUndefined(style.flexShrink)) {
    instance.flexShrink(style.flexShrink)
  }
  if (!isUndefined(style.flexBasis)) {
    instance.flexBasis(style.flexBasis)
  }
  if (!isUndefined(style.alignSelf)) {
    instance.alignSelf(style.alignSelf)
  }
  if (!isUndefined(style.paddingTop) || !isUndefined(style.paddingRight) || !isUndefined(style.paddingBottom) || !isUndefined(style.paddingLeft)) {
    instance.padding({
      top: style.paddingTop,
      right: style.paddingRight,
      bottom: style.paddingBottom,
      left: style.paddingLeft
    })
  }
  if (!isUndefined(style.marginTop) || !isUndefined(style.marginRight) || !isUndefined(style.marginBottom) || !isUndefined(style.marginLeft)) {
    instance.margin({
      top: style.marginTop,
      right: style.marginRight,
      bottom: style.marginBottom,
      left: style.marginLeft
    })
  }
  if (node) {
    instance.width(isMaxWidthView(node as TaroElement) && isUndefined(style.width) ? '100%' : style.width)
  } else {
    if (!isUndefined(style.width)) {
      instance.width(style.width)
    }
  }
  if (!isUndefined(style.height)) {
    instance.height(style.height)
  }
  if (!isUndefined(style.minWidth) || !isUndefined(style.maxWidth) || !isUndefined(style.minHeight) || !isUndefined(style.maxHeight)) {
    instance.constraintSize({
      minWidth: style.minWidth,
      maxWidth: style.maxWidth,
      minHeight: style.minHeight,
      maxHeight: style.maxHeight
    })
  }
  if (!isUndefined(style.backgroundColor)) {
    instance.backgroundColor(style.backgroundColor)
  }
  if (!isUndefined(style.backgroundImage)) {
    if (style.backgroundImage.center) {
      // radialGradient
      instance.radialGradient(style.backgroundImage)
    } else if (style.backgroundImage.colors) {
      // linearGradient
      instance.linearGradient(style.backgroundImage)
    } else {
      instance.backgroundImage(style.backgroundImage?.src, style.backgroundRepeat)
    }
  }
  if (!isUndefined(style.backgroundSize)) {
    instance.backgroundImageSize(style.backgroundSize)
  }
  if (!isUndefined(style.backgroundPosition)) {
    if (typeof style.backgroundPosition !== 'number') {
      let pos = computeBackgroundPosition(style)
      instance.backgroundImagePosition({
        x: pos.offsetX,
        y: pos.offsetY,
      })
    } else {
      instance.backgroundImagePosition(style.backgroundPosition)
    }
  }
  if (!isUndefined(style.borderTopStyle) || !isUndefined(style.borderRightStyle) || !isUndefined(style.borderBottomStyle) || !isUndefined(style.borderLeftStyle)) {
    instance.borderStyle({
      top: style.borderTopStyle,
      right: style.borderRightStyle,
      bottom: style.borderBottomStyle,
      left: style.borderLeftStyle
    })
  }
  if (!isUndefined(style.borderTopWidth) || !isUndefined(style.borderRightWidth) || !isUndefined(style.borderBottomWidth) || !isUndefined(style.borderLeftWidth)) {
    instance.borderWidth({
      top: style.borderTopWidth,
      right: style.borderRightWidth,
      bottom: style.borderBottomWidth,
      left: style.borderLeftWidth
    })
  }
  if (!isUndefined(style.borderTopColor) || !isUndefined(style.borderRightColor) || !isUndefined(style.borderBottomColor) || !isUndefined(style.borderLeftColor)) {
    instance.borderColor({
      top: style.borderTopColor,
      right: style.borderRightColor,
      bottom: style.borderBottomColor,
      left: style.borderLeftColor
    })
  }
  if (!isUndefined(style.borderTopLeftRadius) || !isUndefined(style.borderTopRightRadius) || !isUndefined(style.borderBottomLeftRadius) || !isUndefined(style.borderBottomRightRadius)) {
    instance.borderRadius({
      topLeft: style.borderTopLeftRadius,
      topRight: style.borderTopRightRadius,
      bottomLeft: style.borderBottomLeftRadius,
      bottomRight: style.borderBottomRightRadius
    })
  }
  if (!isUndefined(style.opacity)) {
    instance.opacity(style.opacity)
  }
  if (!isUndefined(style.overflow)) {
    instance.clip(style.overflow === 'hidden')
  }
  // if (!isUndefined(style.transformOrigin)) {
  //   instance.rotate({ centerX: style.transformOrigin.x, centerY: style.transformOrigin.y, angle: 0 })
  //   instance.scale({ centerX: style.transformOrigin.x, centerY: style.transformOrigin.y })
  // }
  // // Note: 移植到setAnimationAttributeIntoInstance设置
  // if (!isUndefined(style.transform)) {
  //   if (style.transform.Translate) {
  //     instance.translate({
  //       x: style.transform.Translate.x || 0,
  //       y: style.transform.Translate.y || 0,
  //       z: style.transform.Translate.z || 0,
  //     })
  //   }
  //   if (style.transform.Scale) {
  //     instance.scale({
  //       x: style.transform.Scale.x || 0,
  //       y: style.transform.Scale.y || 0,
  //       z: style.transform.Scale.z || 0,
  //       centerX: style.transformOrigin?.x || 0,
  //       centerY: style.transformOrigin?.y || 0,
  //     })
  //   }
  //   if (style.transform.Rotate) {
  //     instance.rotate({
  //       x: style.transform.Rotate.x || 0,
  //       y: style.transform.Rotate.y || 0,
  //       z: style.transform.Rotate.z || 0,
  //       centerX: style.transformOrigin?.x || 0,
  //       centerY: style.transformOrigin?.y || 0,
  //       angle: 0
  //     })
  //   }
  // }
  if (style.position === 'absolute' || style.position === 'fixed') {
    instance.position({
      x: style.left || 0,
      y: style.top || 0,
    })
    // 绝对定位和固定定位在web上都会脱离文档流，因此需要设置zIndex让它相比正常流的元素更上层
    instance.zIndex(1)
  }
  if (style.position === 'relative') {
    instance.offset({
      x: style.left || 0,
      y: style.top || 0,
    })
    // 绝对定位和固定定位在web上都会脱离文档流，因此需要设置zIndex让它相比正常流的元素更上层
    instance.zIndex(1)
  }
  if (!isUndefined(style.zIndex)) {
    // 为了适应position不设置z-index也能高于同层级组件，估且让设置了z-index的会更高一级
    instance.zIndex(style.zIndex + 1)
  }
}

export const pseudoModify = new PseudoStyleModify()
export const rowModify = new RowStyleModify()
export const columnModify = new ColumnStyleModify()

export default new CommonStyleModify()