var nav = document.getElementById("links");

function toggleNav() {
  if (nav.style.display === "") nav.style.display = "flex";
  else nav.style.display = "";
}

function windowResizeHandler() {
  if (screen.width > 500) nav.style.display = "";
}

window.addEventListener("resize", windowResizeHandler);
