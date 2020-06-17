import loadPolyfills from '../mastodon/load_polyfills';
import { start } from '../mastodon/common';
import ahoy from 'ahoy.js';
// import chartkick from 'chartkick';
// import 'chart.js';
// import 'highcharts';
// require('chartkick')

start();

loadPolyfills().then(() => {
  require('../mastodon/main').default();
}).catch(e => {
  console.error(e);
});
