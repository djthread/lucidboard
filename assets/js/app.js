// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from '../css/app.scss';

import hamburger from './hamburger';
import dnd from './dnd';
import {datalistHelper} from './datalist_helper';

window.dnd = dnd;
window.datalistHelper = datalistHelper;

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in 'webpack.config.js'.
//
// Import dependencies
//
// import 'phoenix_html'

// Import local files
//
// Local files can be imported directly using relative paths, for example:
// import socket from './socket'

import LiveSocket from 'phoenix_live_view';

let liveSocket = new LiveSocket('/live');
liveSocket.connect();

document.body.addEventListener('click', function(e) {
  let target = e.target;

  // Focus and alter height of textarea if they click in the card or add a card
  if (target.classList.contains('js-inlineEdit') || target.classList.contains('js-addCard')) {
    setTimeout(() => {
      const textarea = document.getElementById('txtarea');

      textarea.focus();
      textarea.setSelectionRange(textarea.value.length, textarea.value.length);
      textarea.setAttribute('style', 'height:' + (textarea.scrollHeight) + 'px; overflow-y: hidden;');
      textarea.addEventListener('input', OnInput, false);

      function OnInput(e) {
        this.style.height = 'auto';
        this.style.height = (this.scrollHeight - 15) + 'px';
      }
    }, 300);
  }

  // Focus and alter height of textarea if they click on card modal 
  if (target.classList.contains('js-cardModal')) {
    setTimeout(() => {
      const modalTextarea = document.querySelector('.lb-modal-card-textarea');

      modalTextarea.focus();
      modalTextarea.setSelectionRange(modalTextarea.value.length, modalTextarea.value.length);
      modalTextarea.setAttribute('style', 'height:' + (modalTextarea.scrollHeight) + 'px; overflow-y: hidden;');
      modalTextarea.addEventListener('input', OnInput, false);

      function OnInput(e) {
        this.style.height = '1px';
        this.style.height = (this.scrollHeight) + 'px';
      }
    }, 300);
  }
});
