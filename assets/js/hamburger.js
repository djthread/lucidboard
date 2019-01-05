/**
 * For the Hamburger menu, per Bulma's docs.
 * https://bulma.io/documentation/components/navbar/
 */
document.addEventListener('DOMContentLoaded', () => {
  const $navbarBurgers =
    Array.prototype.slice.call(document.querySelectorAll('.navbar-burger'), 0);

  const $usermenu = document.getElementById('usermenu');

  // Check if there are any navbar burgers
  if ($navbarBurgers.length > 0) {

    // Add a click event on each of them
    $navbarBurgers.forEach( el => {
      el.addEventListener('click', () => {

        // Get the target from the "data-target" attribute
        const target = el.dataset.target;
        const $target = document.getElementById(target);

        // Toggle the "is-active" class on both the "navbar-burger" and the
        // "navbar-menu"
        el.classList.toggle('is-active');
        $target.classList.toggle('is-active');

        // Swap Lucidboard's dropdown user menu since it opens the other way in
        // the hamburger
        $usermenu.classList.toggle('is-left');
        $usermenu.classList.toggle('is-right');
      });
    });
  }

});