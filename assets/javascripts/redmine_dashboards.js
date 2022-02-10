function reloadOnCurrentPosition() {
  document.addEventListener("DOMContentLoaded", function (event) {
    var scrollpos = localStorage.getItem('scrollpos');
    if (scrollpos) window.scrollTo(0, scrollpos);
  });
  localStorage.setItem('scrollpos', window.scrollY);
  location.reload();
}