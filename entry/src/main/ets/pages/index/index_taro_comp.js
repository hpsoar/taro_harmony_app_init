import { createPageConfig } from '../../npm/@tarojs/plugin-framework-react/dist/runtime';
import { TaroViewTagName, TaroTextTagName } from '../../npm/@tarojs/components/tag';
import Taro from '../../npm/@tarojs/taro';
import { __combine_nesting_style__, calcStaticStyle } from '../../npm/@tarojs/runtime';
import { jsx } from '../../npm/react/jsx-runtime';
import '../../npm/react';
import '../../npm/@tarojs/react';

const index_scss = '';

let __inner_style_data__;
function __inner_style__() {
  if (__inner_style_data__) return __inner_style_data__;
  __inner_style_data__ = {};
  return __inner_style_data__;
}
const app = Taro.getApp();
function Index() {
  Taro.useLoad(() => {
    console.log("Page loaded.");
    console.log(`app对象属性：${Object.keys(app)}`);
    console.log(`app对象属性：${app.hello}`);
  });
  return __combine_nesting_style__( /* @__PURE__ */jsx(TaroViewTagName, {
    __hmStyle: calcStaticStyle(__inner_style__(), "index"),
    className: "index",
    children: /* @__PURE__ */jsx(TaroTextTagName, {
      children: "Hello world!"
    })
  }), null);
}

const config = {
  "navigationBarTitleText": "首页"
};
const index = (() => createPageConfig(Index, 'pages/index/index', config));

export { config, index as default };
