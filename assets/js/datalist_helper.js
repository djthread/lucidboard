export const datalistHelper = {
  roleUpdate: (event) => {
    const input = event.target;
    const label = input.value;
    const dataListOptionId = input.getAttribute('list');
    const options = document.querySelectorAll(`#${dataListOptionId} option`);

    for (let option in options) {
      if (options[option] && options[option].innerText === label) {
        window.roleValue = options[option].dataset.value;
        break;
      }
    }
  },

  addIdOnSubmit: (event) => {
    document.getElementById('userId').value = window.roleValue;
  }
};
