import { eventHandler, getComponentEventCallback, AREA_CHANGE_EVENT_NAME, VISIBLE_CHANGE_EVENT_NAME, createTaroEvent } from '../runtime'

import commonStyleModify from './style'
import { parseStyles, shouldBindEvent, getNodeThresholds } from './utils/helper'
import { INPUT_TYPE_MAP, INPUT_CONFIRM_MAP } from './utils/constant/style'

import type { TaroStyleType, TaroAny, TaroInputElement, TaroEvent } from '../runtime'

interface InputAttrs {
  textAlign?: TextAlign
}

@Extend(TextInput)
function styles (style: TaroStyleType) {
  .fontColor(style.color)
  .fontSize(style.fontSize)
  .fontWeight(style.fontWeight)
  .fontStyle(style.fontStyle)
  .fontFamily(style.fontFamily)
}

@Extend(TextInput)
function attrs(attr: InputAttrs) {
  .textAlign(attr.textAlign)
}


function getAttributes(node: TaroInputElement): InputAttrs {
  return {
    textAlign: node.hmStyle.textAlign,
  }
}

function getInputType (node: TaroInputElement) {
  if (node._attrs?.password) return InputType.Password

  return INPUT_TYPE_MAP.get(node._attrs?.type || '') || InputType.Normal
}

function getPlaceholderColor (node: TaroInputElement): string {
  const placeholderTextColor: string = node._attrs.placeholderTextColor || ''
  const placeholderStyle: string = node._attrs.placeholderStyle || ''

  return placeholderTextColor || parseStyles(placeholderStyle)?.color
}

@Component
export default struct TaroInput {
  @State value: string = ''

  @Builder customBuilder() {}
  @BuilderParam createLazyChildren: (node: TaroInputElement) => void = this.customBuilder
  @ObjectLink node: TaroInputElement
  @State overwriteStyle: Record<string, TaroAny> = {}

  aboutToAppear () {
    if (this.node) {
      this.value = this.node.value
      this.node._instance = this

      if (!this.node._isInit) {
        this.node._isInit = true
        this.node._reset = this.node.value || ''
      }
    }
  }

  build () {
    if (this.node && this.node?.hmStyle?.display !== 'none') {
      TextInput({ text: this.value, placeholder: this.node._attrs?.placeholder || '', controller: this.node.controller })
      .key(this.node._nid)
      .type(getInputType(this.node))
      .maxLength(Number(this.node._attrs?.maxlength) || null)
      .placeholderColor(getPlaceholderColor(this.node))
      .enterKeyType(INPUT_CONFIRM_MAP.get(this.node._attrs?.confirmType) || EnterKeyType.Done)
      .attributeModifier(commonStyleModify.setNode(this.node).setAnimationStyle(this.overwriteStyle))
      .styles(this.node?.hmStyle)
      .attrs(getAttributes(this.node))
      .onChange((value: string) => {
        const event: TaroEvent = createTaroEvent('input', { detail: { value } }, this.node)

        this.value = value
        this.node?.updateFormWidgetValue(value)
        eventHandler(event, 'input', this.node)
      })
      .onSubmit(() => {
        const event: TaroEvent = createTaroEvent('confirm', { detail: { value: this.value } }, this.node)
        eventHandler(event, 'confirm', this.node)
      })
      .onClick(shouldBindEvent((e: ClickEvent) => eventHandler(e, 'click', this.node), this.node, ['click']))
      .onBlur(() => {
        const event: TaroEvent = createTaroEvent('blur', { detail: { value: this.value } }, this.node)
        eventHandler(event, 'blur', this.node)
      })
      .onFocus(() => {
        const event: TaroEvent = createTaroEvent('focus', { detail: { value: this.value, height: this.node?._height } }, this.node)

        eventHandler(event, 'focus', this.node)
      })
      .onAreaChange(getComponentEventCallback(this.node, AREA_CHANGE_EVENT_NAME, (res: TaroAny) => {
        if (this.node) {
          this.node._nodeInfo.areaInfo = res[1]
        }
      }))
      .onVisibleAreaChange(getNodeThresholds(this.node) || [0.0, 1.0], getComponentEventCallback(this.node, VISIBLE_CHANGE_EVENT_NAME))
    }
  }
}
