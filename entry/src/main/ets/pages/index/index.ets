import type Taro from "../../npm/@tarojs/taro/types"
import type { TFunc } from "../../npm/@tarojs/runtime/dist/runtime.esm"
import type common from "@ohos.app.ability.common"


import router from "@ohos.router"
import { TaroView } from "../../npm/@tarojs/components"
import { initHarmonyElement, bindFn, callFn, convertNumber2VP, Current, ObjectAssign, TaroAny, TaroElement, TaroObject, TaroNode, TaroViewElement, window, document } from "../../npm/@tarojs/runtime"
import { eventCenter, PageInstance } from "../../npm/@tarojs/runtime/dist/runtime.esm"
import { createLazyChildren } from "../../render"
import createComponent, { config } from "./index_taro_comp"

@Entry
@Component
struct Index {
  scroller: Scroller = new Scroller()
  page?: PageInstance
  onReady?: TaroAny
  @State node: (TaroElement | null) = null
  @State navigationBarHomeBtn: boolean = true
  @State navigationBarLoading: boolean = false
  @State navigationBarBackgroundColor: string = config.navigationBarBackgroundColor
  @State navigationBarTextStyle: string = config.navigationBarTextStyle
  @State navigationBarTitleText: string = config.navigationBarTitleText
  @State pageBackgroundColor: string = config.backgroundColor
  @StorageLink("__TARO_PAGE_STACK") pageStack: router.RouterState[] = []
  @StorageProp("__TARO_ENTRY_PAGE_PATH") entryPagePath: string = ""
  @State appConfig: Taro.AppConfig = window.__taroAppConfig || {}
  @State tabBarList: Taro.TabBarItem[] = this.appConfig.tabBar?.list || []

  getPageState () {
    const state = router.getState()
    state.path ||= 'pages/index/index'
    if (state.path.endsWith('/')) {
    state.path += 'index'
    }
    return state
  }

  aboutToAppear () {
    const state = this.getPageState()
    if (this.pageStack.length >= state.index) {
      this.pageStack.length = state.index - 1
    }
    this.pageStack.push(state)
    this.handlePageAppear()
  }

  aboutToDisappear () {
    callFn(this.page?.onUnload, this)
  }

  handlePageAppear () {
    if (config.navigationStyle === 'custom') {
      Current.contextPromise
        .then((context: common.BaseContext) => {
          const win = window.__ohos.getLastWindow(context)
          win.then(mainWindow => {
            mainWindow.setFullScreen(true)
            mainWindow.setSystemBarEnable(["status", "navigation"])
        })
      })
    }

    const params = router.getParams() as Record<string, string> || {}
    this.page = createComponent()
    this.onReady = this.page?.onReady?.bind(this.page)
    callFn(this.page.onLoad, this, params, (instance: TaroElement) => {
      this.node = instance
    })
    callFn(this.page.onReady, this, params)
  }

  handleNavigationStyle = (option: TaroObject) => {
    if (option.title) this.navigationBarTitleText = option.title
    if (option.backgroundColor) this.navigationBarBackgroundColor = option.backgroundColor || '#000000'
    if (option.frontColor) this.navigationBarTextStyle = option.frontColor || 'white'
    if (typeof option.home === 'boolean') this.navigationBarHomeBtn = option.home
    if (typeof option.loading === 'boolean') this.navigationBarLoading = option.loading
  }

  handlePageStyle = (option: TaroObject) => {
    if (option.backgroundColor) this.pageBackgroundColor = option.backgroundColor || '#FFFFFF'
  }

  bindPageEvent () {
    eventCenter.on('__taroNavigationStyle', this.handleNavigationStyle)
    eventCenter.on('__taroPageStyle', this.handlePageStyle)
  }

  removePageEvent () {
    eventCenter.off('__taroNavigationStyle', this.handleNavigationStyle)
    eventCenter.off('__taroPageStyle', this.handlePageStyle)
  }

  @Builder
  renderTitle () {
    Flex({
      direction: FlexDirection.Row,
      justifyContent: FlexAlign.Start,
      alignItems: ItemAlign.Center,
    }) {if (this.pageStack[0].path !== this.entryPagePath && this.navigationBarHomeBtn && this.pageStack.length === 1) {
        Image($r('app.media.taro_home'))
          .height(convertNumber2VP(40))
          .width(convertNumber2VP(40))
          .margin({ left: convertNumber2VP(40), right: convertNumber2VP(-20) })
          .fillColor((this.navigationBarTextStyle || 'black') !== 'black' ? Color.White : Color.Black)
          .objectFit(ImageFit.Contain)
          .onClick(() => {
            router.replaceUrl({
              url: this.tabBarList.find(e => e.pagePath === this.entryPagePath) ? 'taro_tabbar' : this.entryPagePath,
              params: {
                '$page': this.entryPagePath,
              },
            })
          })
      } else if (this.pageStack.length > 1) {
        Image($r('app.media.taro_arrow_left'))
          .height(convertNumber2VP(40))
          .width(convertNumber2VP(40))
          .margin({ left: convertNumber2VP(40), right: convertNumber2VP(-20) })
          .fillColor((this.navigationBarTextStyle || 'black') !== 'black' ? Color.White : Color.Black)
          .objectFit(ImageFit.Contain)
          .onClick(() => {
            router.back()
          })
      }
      Text(this.navigationBarTitleText || 'WeChat')
        .margin({ left: convertNumber2VP(40) })
        .fontSize(convertNumber2VP(32))
        .fontColor((this.navigationBarTextStyle || 'black') !== 'black' ? Color.White : Color.Black)
      if (this.navigationBarLoading) {
        LoadingProgress()
        .margin({ left: convertNumber2VP(10) })
        .height(convertNumber2VP(40))
        .width(convertNumber2VP(40))
        .color((this.navigationBarTextStyle || 'black') !== 'black' ? Color.White : Color.Black)
      }
    }
    .height('100%')
    .backgroundColor(this.navigationBarBackgroundColor || '#fff')
    .zIndex(1)
  }

  build () {
    Navigation() {
      NavDestination() {
        Scroll(this.scroller) {
          Column() {
            if (this.node) {
              TaroView({ node: this.node as TaroViewElement, createLazyChildren: createLazyChildren })
            }
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
          .onAreaChange((_: Area, area: Area) => {
            const node: TaroElement | null = this.node
            if (node) {
              node._nodeInfo._scroll = area
            }
          })
        }
        .clip(false)
        .scrollBar(typeof config.enableScrollBar === 'boolean' ? config.enableScrollBar : false)
        .onAreaChange((_: Area, area: Area) => {
          const node: TaroElement | null = this.node
          if (node) {
            node._nodeInfo._client = area
          }
        })
        .onScroll(() => {
          if (!this.page) return

          const offset: TaroObject = this.scroller?.currentOffset()
          callFn(this.page.onPageScroll, this, {
            scrollTop: offset.xOffset || 0,
            scrollLeft: offset.yOffset || 0,
          })
        })
        .onScrollStop(() => {
          if (!this.page) return

          const offset: TaroObject = this.scroller?.currentOffset()
          const distance: number = config.onReachBottomDistance || 50
          const clientHeight: number = Number(this.node?._nodeInfo?._client?.height) || 0
          const scrollHeight: number = Number(this.node?._nodeInfo?._scroll?.height) || 0
          if (scrollHeight - clientHeight - offset.yOffset <= distance) {
            callFn(this.page.onReachBottom, this)
          }
        })
        Stack() {
          createLazyChildren(document.fixedLayer as TaroElement, 1)
        }
        .position({ x: 0, y: 0 })
      }
      .onShown(() => {
        this.bindPageEvent()
          const state = this.getPageState()
          if (this.pageStack[this.pageStack.length - 1].path !== state.path) {
            this.pageStack.length = state.index
            this.pageStack[state.index - 1] = state
          }
          callFn(this.page?.onShow, this)
      })
      .onHidden(() => {
        this.removePageEvent()
          callFn(this.page?.onHide, this)
      })
      .backgroundColor(this.pageBackgroundColor || "#FFFFFF")
      .hideTitleBar(true)
    }
    .width('100%')
    .height('100%')
    .title(this.renderTitle)
    .titleMode(NavigationTitleMode.Mini)
    .hideTitleBar(config.navigationStyle === 'custom')
    .hideBackButton(true)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}
