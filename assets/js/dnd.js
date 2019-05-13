/**
 * For drag and dropping of cards and piles
 */

const bodyClassWhenDragging = 'dnd-dragging';

// Utility (non-exported) function for finding a data attribute in a parent element
const findDataFromParent = function findDataFromParent(el, dataKey) {
    console.log('ds', dataKey, el.dataset);
  if (el.dataset[dataKey]) {
    console.log('win', el.dataset[dataKey]);
    return el.dataset[dataKey];
  } else if (el.parentElement) {
    console.log('par');
    return findDataFromParent(el.parentElement, dataKey)
  } else {
    console.log('nah');
    return null;
  }
};

const drag = function drag(ev) {
  console.log('drag');
  ev.dataTransfer.setData('text', ev.target.id);
  ev.dataTransfer.dropEffect = 'copy';
  document.body.classList.add(bodyClassWhenDragging);
};

const allowDrop = function allowDrop(ev) {
  console.log('allowDrop');
  ev.preventDefault();
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

// const dropIntoPile = function dropIntoPile(ev) {
//   console.log('drop');
//   ev.preventDefault();
//   document.body.classList.remove(bodyClassWhenDragging);
//   const board_id = document.querySelector('meta[name=board_id]').getAttribute('content');
//   const card_id = ev.dataTransfer.getData('text').replace('card-', '');

//   const [x, column_id, pos] = ev.target.id.split('_');

//   const request = new XMLHttpRequest();
//   request.open('POST', `/boards/${board_id}/dnd-into-pile`, true);
//   request.setRequestHeader('Content-Type', 'application/json; charset=UTF-8');
//   request.setRequestHeader('X-CSRF-Token', document.querySelector('meta[name=csrf]').content);
//   request.send(JSON.stringify({
//     card_id: card_id,
//     column_id: column_id,
//     pos: pos
//   }));
// };

module.exports = { drag, allowDrop, dropIntoPile };