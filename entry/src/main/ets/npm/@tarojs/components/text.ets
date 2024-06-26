import { isString } from '../shared'
import { eventHandler, convertNumber2VP, getComponentEventCallback, AREA_CHANGE_EVENT_NAME, VISIBLE_CHANGE_EVENT_NAME, NodeType } from '../runtime'

import commonStyleModify from './style'
import { getButtonColor } from './button'
import { BUTTON_THEME_COLOR } from './utils/constant/style'
import { getNodeThresholds, getStyleAttr, getFontAttributes, shouldBindEvent, getNormalAttributes } from './utils/helper'

import type { TaroButtonElement, TaroElement, TaroTextElement, TaroAny, TaroTextStyleType, TaroStyleType } from '../runtime'

@Extend(Text)
function textNormalFontStyle (style: TaroStyleType) {
  .id(style.id)
  .key(style.id)
  .opacity(style.opacity)
  .fontColor(style.color)
  .fontSize(style.fontSize)
  .fontWeight(style.fontWeight)
  .fontStyle(style.fontStyle)
  .fontFamily(style.fontFamily)
  .decoration({
    type: style.textDecoration,
    color: style.color
  })
}

@Extend(Text)
function textSpecialFontStyle(attr: TaroTextStyleType) {
  .textAlign(attr.textAlign)
  .align(attr.verticalAlign)
  .textOverflow(attr.textOverflow)
  .maxLines(attr.WebkitLineClamp)
  .letterSpacing(attr.letterSpacing)
  .lineHeight(attr.lineHeight)
}

function getButtonFontSize (node: TaroButtonElement): string | number {
  const isMini = node._attrs.size === 'mini'

  return isMini ? convertNumber2VP(26) : convertNumber2VP(36)
}

function getTextInViewWidth (node: TaroElement | null): TaroAny {
  if (node) {
    const hmStyle = node.hmStyle || {}
    const isFlexView = hmStyle.display === 'flex'
    const width: TaroAny = getStyleAttr(node, 'width')
    const isPercentWidth = isString(width) && width.includes('%')

    return isFlexView || isPercentWidth ? null : getStyleAttr(node, 'width')
  }
}

@Component
export default struct TaroText {
  @Builder customBuilder() {}
  @BuilderParam createLazyChildren: (node: TaroTextElement) => void = this.customBuilder
  @ObjectLink node: TaroTextElement
  @State overwriteStyle: Record<string, TaroAny> = {}

  aboutToAppear(): void {
    if (this.node) {
      this.node._instance = this
    }
  }

  build () {
    if (this.node.nodeType === NodeType.TEXT_NODE) {
      if (this.node.parentNode) {
        if ((this.node.parentNode as TaroElement).tagName === 'BUTTON') {
          Text(this.node.textContent)
            .textNormalFontStyle(getNormalAttributes(this.node.parentElement!, {
              fontSize: getButtonFontSize(this.node.parentNode as TaroButtonElement),
              color: getButtonColor(this.node.parentNode as TaroButtonElement, BUTTON_THEME_COLOR.get((this.node.parentNode as TaroButtonElement)._attrs.type || '').text)
            }))
            .textSpecialFontStyle(getFontAttributes(this.node.parentElement as TaroElement))
        } else {
          Text(this.node.textContent)
            .textNormalFontStyle(getNormalAttributes(this.node.parentElement!))
            .textSpecialFontStyle(getFontAttributes(this.node.parentElement as TaroElement))
            .width(getTextInViewWidth(this.node.parentElement))
        }
      }
    } else {
      if (this.node.hmStyle?.display !== 'none') {
        Text(this.node.textContent)
        .onClick(shouldBindEvent((e: ClickEvent) => eventHandler(e, 'click', this.node), this.node, ['click']))
        .attributeModifier(commonStyleModify.setNode(this.node).setAnimationStyle(this.overwriteStyle))
        .textNormalFontStyle(getNormalAttributes(this.node))
        .textSpecialFontStyle(getFontAttributes(this.node))
        .onVisibleAreaChange(getNodeThresholds(this.node) || [0.0, 1.0], getComponentEventCallback(this.node, VISIBLE_CHANGE_EVENT_NAME))
        .onAreaChange(getComponentEventCallback(this.node, AREA_CHANGE_EVENT_NAME, (res: TaroAny) => {
          this.node._nodeInfo.areaInfo = res[1]
        }))
      }
    }
  }
}
