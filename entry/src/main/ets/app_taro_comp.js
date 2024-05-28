import { createReactApp } from './npm/@tarojs/plugin-framework-react/dist/runtime';
import Taro from './npm/@tarojs/taro';
import * as React from './npm/react';
import ReactDOM from './npm/@tarojs/react';

const app_scss = '';

class App extends React.Component {
  taroGlobalData = {
    'hello': 'world'
  }
  render() {
    return this.props.children;
  }
}

// function App(_ref) {
//   let {
//     children
//   } = _ref;
//   Taro.useLaunch(() => {
//     console.log("App launched.");
//   });
//   return children;
// }
//
const config = {
  "pages": ["pages/index/index"],
  "window": {
    "backgroundTextStyle": "light",
    "navigationBarBackgroundColor": "#fff",
    "navigationBarTitleText": "WeChat",
    "navigationBarTextStyle": "black"
  }
};
const app = (() => createReactApp(App, React, ReactDOM, config));

export { config, app as default };
