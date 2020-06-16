import loadPolyfills from '../mastodon/load_polyfills';
import { start } from '../mastodon/common';
import ahoy from 'ahoy.js';

start();

loadPolyfills().then(() => {
  require('../mastodon/main').default();
}).catch(e => {
  console.error(e);
});
