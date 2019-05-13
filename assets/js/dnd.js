/**
 * For drag and dropping of cards and piles
 */

const bodyClassWhenDragging = "dnd-dragging";

const drag = function drag(ev) {
  console.log('drag');
  ev.dataTransfer.setData("text", ev.target.id);
  ev.dataTransfer.dropEffect = "copy";
  document.body.classList.add(bodyClassWhenDragging);
};

const allowDrop = function allowDrop(ev) {
  console.log('allowDrop');
  ev.preventDefault();
};

const drop = function drop(ev) {
  console.log('drop');
  ev.preventDefault();
  document.body.classList.remove(bodyClassWhenDragging);
  const board_id = document.querySelector('meta[name=board_id]').getAttribute('content');
  const card_id = ev.dataTransfer.getData('text').replace('card-', '');

  const [x, column_id, pos] = ev.target.id.split('_');

  var request = new XMLHttpRequest();
  request.open('POST', `/boards/${board_id}/dnd`, true);
  request.setRequestHeader('Content-Type', 'application/json; charset=UTF-8');
  request.setRequestHeader('X-CSRF-Token', document.querySelector('meta[name=csrf]').content);
  request.send(JSON.stringify({
    card_id: card_id,
    column_id: column_id,
    pos: pos
  }));
};

module.exports = { drag, allowDrop, drop };