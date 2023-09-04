// CONSTANTS
const SCROLLING_ABOVE = 0;
const SCROLLING_WITHIN = 1;
const SCROLLING_BELOW = 2;

// HELPERS
/**
 * isElementInViewport
 * @param {*} el the element that whould be checked
 * @returns SCROLLING_ABOVE | SCROLLING_WITHIN | SCROLLING_BELOW
 */
function isElementInViewport(el) {
  var rect = el.getBoundingClientRect();
  if (rect.top <= 0 && rect.bottom < window.innerHeight) {
    return SCROLLING_BELOW;
  } else if (rect.top <= 0 && rect.bottom >= window.innerHeight) {
    return SCROLLING_WITHIN;
  } else {
    return SCROLLING_ABOVE;
  }
}

// SCROLLING
const canvas = document.querySelector('.canvas');
const canvasContainer = document.querySelector('.canvas-container');
const context = canvas.getContext('2d');

const frameCount = 120;
const currentFrame = (index) =>
  `./assets/out${index.toString().padStart(1, '0')}.png`;

const preloadImages = () => {
  for (let i = 1; i < frameCount; i++) {
    const img = new Image();
    img.src = currentFrame(i);
  }
};

const img = new Image();
img.src = currentFrame(1);
canvas.width = 1024;
canvas.height = 576;
img.onload = function () {
  context.drawImage(img, 0, 0);
};

const updateImage = (index) => {
  img.src = currentFrame(index);
  context.drawImage(img, 0, 0);
};

window.addEventListener('scroll', () => {
  // POSITIONING

  switch (isElementInViewport(canvasContainer)) {
    case SCROLLING_ABOVE:
      canvas.classList.remove('canvas--active');
      canvasContainer.classList.remove('canvas-container--end');
      break;

    case SCROLLING_WITHIN:
      canvas.classList.add('canvas--active');
      canvasContainer.classList.remove('canvas-container--end');

      // animate
      const canvasContainerRect = canvasContainer.getBoundingClientRect();
      const canvasContainerYPos = canvasContainerRect.top + window.scrollY;
      const windowScrollPos =
        document.documentElement.scrollTop - canvasContainerYPos;
      const maxScrollTop = canvasContainer.clientHeight - window.innerHeight;
      const scrollFraction = windowScrollPos / maxScrollTop;
      const frameIndex = Math.min(
        frameCount - 1,
        Math.ceil(scrollFraction * frameCount)
      );
      requestAnimationFrame(() => updateImage(frameIndex + 1));

      break;

    case SCROLLING_BELOW:
      canvas.classList.remove('canvas--active');
      canvasContainer.classList.add('canvas-container--end');
      break;
  }
});

preloadImages();
