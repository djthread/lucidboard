// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.scss"

import hamburger from "./hamburger"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
// import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative paths, for example:
// import socket from "./socket"

import LiveSocket from "phoenix_live_view"

let liveSocket = new LiveSocket("/live")
liveSocket.connect()

var cardLabel = document.getElementsByClassName('c-Card__label');

for (var i = 0; i < cardLabel.length; i++){
  cardLabel[i].addEventListener("click", function(e) {
      var targetedLabel = e.target;
      targetedLabel.classList.toggle('c-Card__label--active');
  });
};

var inlineEdit = document.querySelector('.is-size-5');

inlineEdit.addEventListener('click', function() {
  setTimeout(function(){
    var tx = document.getElementsByTagName('textarea');
    for (var i = 0; i < tx.length; i++) {
      tx[i].setAttribute('style', 'height:' + (tx[i].scrollHeight) + 'px;overflow-y:hidden;');
      tx[i].addEventListener("input", OnInput, false);
    }

    function OnInput(e) {
      this.style.height = 'auto';
      this.style.height = (this.scrollHeight) + 'px';
    }
  }, 100);
})
