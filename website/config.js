// The itch.io game page; change it here only.
const ITCH_URL = "https://quentin-drucker.itch.io/claus-for-alarm";

document.querySelectorAll("[data-itch]").forEach((a) => { a.href = ITCH_URL; });

// SMIL animations ignore the CSS media query, so stop the rolling snowballs here.
if (matchMedia("(prefers-reduced-motion: reduce)").matches) {
  document.querySelectorAll("svg").forEach((s) => s.pauseAnimations && s.pauseAnimations());
}
