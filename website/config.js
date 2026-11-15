// Keep all play links pointed at the same itch.io project.
const ITCH_URL = "https://quentin-drucker.itch.io/claus-for-alarm";
document.querySelectorAll("[data-itch]").forEach((link) => {
  link.href = ITCH_URL;
});
// Links still open the original image if JavaScript is disabled.
const lightbox = document.querySelector(".lightbox");
if (lightbox && typeof lightbox.showModal === "function") {
  const image = lightbox.querySelector("img");
  document.querySelectorAll("[data-lightbox]").forEach((link) => {
    link.addEventListener("click", (event) => {
      if (event.ctrlKey || event.metaKey || event.shiftKey || event.altKey)
        return;
      event.preventDefault();
      image.src = link.href;
      image.alt = link.querySelector("img").alt;
      lightbox.querySelector("p").textContent = image.alt;
      lightbox.showModal();
    });
  });
  lightbox
    .querySelector("button")
    .addEventListener("click", () => lightbox.close());
  lightbox.addEventListener("click", (event) => {
    if (event.target !== lightbox) return;
    const rect = lightbox.getBoundingClientRect();
    if (
      event.clientX < rect.left ||
      event.clientX > rect.right ||
      event.clientY < rect.top ||
      event.clientY > rect.bottom
    )
      lightbox.close();
  });
}
