import {
  TaroImage,
  TaroText,
  TaroView,
  TaroIcon,
  TaroForm,
  TaroLabel,
  TaroInput,
  TaroVideo,
  TaroButton,
  TaroPicker,
  TaroSlider,
  TaroSwitch,
  TaroSwiper,
  TaroWebView,
  TaroTextArea,
  TaroRichText,
  TaroProgress,
  TaroInnerHtml,
  TaroScrollView,
  TaroMovableArea,
  TaroMovableView,
  TaroRadio,
  TaroCanvas,
  TaroRadioGroup,
  TaroCheckboxGroup,
  TaroCheckbox
} from './npm/@tarojs/components'

import { NodeType } from './npm/@tarojs/runtime'

import type {
  TaroAny,
  TaroViewElement,
  TaroElement,
  TaroImageElement,
  TaroButtonElement,
  TaroTextElement,
  TaroCheckboxElement,
  TaroFormElement,
  TaroIconElement,
  TaroLabelElement,
  TaroPickerElement,
  TaroRadioElement,
  TaroRichTextElement,
  TaroRadioGroupElement,
  TaroInputElement,
  TaroCheckboxGroupElement,
  TaroTextAreaElement,
  TaroVideoElement,
  // TaroSwiperItemElement,
  TaroProgressElement,
  TaroMovableAreaElement,
  TaroMovableViewElement,
  TaroSwiperElement,
  TaroSwitchElement,
  TaroCanvasElement,
  TaroSliderElement,
  TaroScrollViewElement,
  TaroWebViewElement,
  TaroInnerHtmlElement
} from './npm/@tarojs/runtime'

@Builder
function createChildItem (item: TaroElement, createLazyChildren?: (node: TaroElement) => void) {
  if (item.tagName === 'VIEW') {
    TaroView({ node: item as TaroViewElement, createLazyChildren: createLazyChildren })
  } else if (item.tagName === 'TEXT' || item.nodeType === NodeType.TEXT_NODE) {
    TaroText({ node: item as TaroTextElement, createLazyChildren: createLazyChildren })
  } else if (item.tagName === 'IMAGE') {
    TaroImage({ node: item as TaroImageElement, createLazyChildren: createLazyChildren })
  } else if (item.tagName === 'BUTTON') {
    TaroButton({ node: item as TaroButtonElement, createLazyChildren: createLazyChildren })
  } else if (item.tagName === 'SCROLL-VIEW') {
    TaroScrollView({ node: item as TaroScrollViewElement, createLazyChildren: createLazyChildren })
  } else if (item.tagName === 'SLIDER') {
    TaroSlider({ node: item as TaroSliderElement, createLazyChildren: createLazyChildren })
  } else if (item.tagName === 'SWITCH') {
    TaroSwitch({ node: item as TaroSwitchElement, createLazyChildren: createLazyChildren })
  } else if (item.tagName === 'INPUT') {
    TaroInput({ node: item as TaroInputElement, createLazyChildren: createLazyChildren })
  } else if (item.tagName === 'SWIPER') {
    TaroSwiper({ node: item as TaroSwiperElement, createLazyChildren: createLazyChildren })
  } else if (item.tagName === 'SWIPER-ITEM') {
    TaroView({ node: item as TaroViewElement, createLazyChildren: createLazyChildren })
  } else if (item.tagName === 'INNER-HTML') {
    TaroInnerHtml({ node: item as TaroInnerHtmlElement, createChildItem: createChildItem })
  } else if (item.tagName === 'RICH-TEXT') {
    TaroRichText({ node: item as TaroRichTextElement, createLazyChildren: createLazyChildren })
  } else if (item.tagName === 'ICON') {
    TaroIcon({ node: item as TaroIconElement, createLazyChildren: createLazyChildren })
  } else if (item.tagName === 'TEXT-AREA') {
    TaroTextArea({ node: item as TaroTextAreaElement, createLazyChildren: createLazyChildren })
  } else if (item.tagName === 'CHECKBOX-GROUP') {
    TaroCheckboxGroup({ node: item as TaroCheckboxGroupElement, createLazyChildren: createLazyChildren })
  } else if (item.tagName === 'CHECKBOX') {
    TaroCheckbox({ node: item as TaroCheckboxElement, createLazyChildren: createLazyChildren })
  } else if (item.tagName === 'RADIO-GROUP') {
    TaroRadioGroup({ node: item as TaroRadioGroupElement, createLazyChildren: createLazyChildren })
  } else if (item.tagName === 'PROGRESS') {
    TaroProgress({ node: item as  TaroProgressElement, createLazyChildren: createLazyChildren })
  } else if (item.tagName === 'MOVABLE-VIEW') {
    TaroMovableView({ node: item as TaroMovableViewElement, createLazyChildren: createLazyChildren })
  } else if (item.tagName === 'MOVABLE-AREA') {
    TaroMovableArea({ node: item as TaroMovableAreaElement, createLazyChildren: createLazyChildren })
  } else if (item.tagName === 'CANVAS') {
    TaroCanvas({ node: item as TaroAny as TaroCanvasElement })
  } else if (item.tagName === 'RADIO') {
    TaroRadio({ node: item as TaroRadioElement, createLazyChildren: createLazyChildren })
  } else if (item.tagName === 'LABEL') {
    TaroLabel({ node: item as TaroLabelElement, createLazyChildren: createLazyChildren })
  } else if (item.tagName === 'PICKER') {
    TaroPicker({ node: item as TaroPickerElement, createLazyChildren: createLazyChildren })
  } else if (item.tagName === 'FORM') {
    TaroForm({ node: item as TaroFormElement, createLazyChildren: createLazyChildren })
  } else if (item.tagName === 'VIDEO') {
    TaroVideo({ node: item as TaroVideoElement, createLazyChildren: createLazyChildren })
  } else if (item.tagName === 'WEB-VIEW') {
    TaroWebView({ node: item as TaroWebViewElement, createLazyChildren: createLazyChildren })
  } else {
    TaroView({ node: item as TaroViewElement, createLazyChildren: createLazyChildren })
  }
}

@Builder
function createLazyChildren (node: TaroElement, layer = 0) {
  LazyForEach(node, (item: TaroElement) => {
    if (!item._nodeInfo || item._nodeInfo.layer === layer) {
      createChildItem(item, createLazyChildren)
    }
  }, (item: TaroElement) => `${item._nid}-${item._nodeInfo?.layer || 0}`)
}

export { createChildItem, createLazyChildren }
