/**
 * For drag and dropping of cards and piles
 */

const bodyClassWhenDragging = 'dnd-dragging';

// Utility (non-exported) function for finding a data attribute in a parent element
const findDataFromParent = function findDataFromParent(el, dataKey) {
  if (el.dataset[dataKey]) {
    return el.dataset[dataKey];
  } else if (el.parentElement) {
    return findDataFromParent(el.parentElement, dataKey);
  }
};

const drag = function drag(ev) {
  console.log('drag');
  ev.dataTransfer.setData('text', ev.target.id);
  ev.dataTransfer.dropEffect = 'copy';
  document.body.classList.add(bodyClassWhenDragging);
};

const allowDrop = function allowDrop(ev) {
  ev.target.classList.add('active');
  ev.preventDefault();
};

const dragLeave = function dragLeave(ev) {
  ev.target.classList.remove('active');
};

const dropIntoPile = function dropIntoPile(ev) {
  console.log('drop');
  ev.preventDefault();
  document.body.classList.remove(bodyClassWhenDragging);
  const boardId = document.querySelector('meta[name=board_id]').getAttribute('content');
  const cardId = ev.dataTransfer.getData('text').replace('card-', '');

  const pileId = findDataFromParent(ev.target, 'pileId');

  const request = new XMLHttpRequest();
  request.open('POST', `/boards/${boardId}/dnd-into-pile`, true);
  request.setRequestHeader('Content-Type', 'application/json; charset=UTF-8');
  request.setRequestHeader('X-CSRF-Token', document.querySelector('meta[name=csrf]').content);
  request.send(JSON.stringify({
    card_id: cardId,
    pile_id: pileId
  }));
};

const dropIntoJunction = function dropIntoJunction(ev) {
  console.log('dropIntoJun');
  ev.preventDefault();
  document.body.classList.remove(bodyClassWhenDragging);
  ev.target.classList.remove('active');
  const boardId = document.querySelector('meta[name=board_id]').getAttribute('content');
  const cardId = ev.dataTransfer.getData('text').replace('card-', '');
  const colId = findDataFromParent(ev.target, 'colId');
  const newPos = findDataFromParent(ev.target, 'pos');

  const request = new XMLHttpRequest();
  request.open('POST', `/boards/${boardId}/dnd-into-junction`, true);
  request.setRequestHeader('Content-Type', 'application/json; charset=UTF-8');
  request.setRequestHeader('X-CSRF-Token', document.querySelector('meta[name=csrf]').content);
  request.send(JSON.stringify({
    new_pos: newPos,
    col_id: colId
  }));
};

module.exports = { drag, dragLeave, allowDrop, dropIntoPile, dropIntoJunction };