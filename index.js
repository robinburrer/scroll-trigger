// CONSTANTS
const SCROLLING_ABOVE = 0;
const SCROLLING_WITHIN = 1;
const SCROLLING_BELOW = 2;
const frameCount = 81;

// DOM Elements
const canvas = document.querySelector('.canvas');
const canvasContainer = document.querySelector('.canvas-container');
const context = canvas.getContext('2d');

canvas.width = 1080;
canvas.height = 1920;
canvas.style.willChange = 'transform'; // iOS GPU boost

// Frame Utility
const currentFrame = (index) =>
  `./assets/${index.toString().padStart(3, '0')}.webp`;

const images = new Array(frameCount);
let currentFrameIndex = -1;
let ticking = false;

// Preload first few images eagerly (e.g., first 10)
const preloadInitialImages = () => {
  for (let i = 1; i <= frameCount; i++) {
    const img = new Image();
    img.src = currentFrame(i);
    images[i] = img;
  }
};

// Lazy load when needed
const ensureImageLoaded = (index) => {
  if (!images[index]) {
    const img = new Image();
    img.src = currentFrame(index);
    images[index] = img;
  }
};

// Draw image only if it's new
const drawFrame = (index) => {
  if (index === currentFrameIndex || !images[index]) return;
  currentFrameIndex = index;
  context.clearRect(0, 0, canvas.width, canvas.height);
  context.drawImage(images[index], 0, 0);
};

// Helper: Scroll state
const isElementInViewport = (el) => {
  const rect = el.getBoundingClientRect();
  if (rect.top <= 0 && rect.bottom < window.innerHeight) {
    return SCROLLING_BELOW;
  } else if (rect.top <= 0 && rect.bottom >= window.innerHeight) {
    return SCROLLING_WITHIN;
  } else {
    return SCROLLING_ABOVE;
  }
};

// Scroll logic wrapped in rAF
const handleScroll = () => {
  const state = isElementInViewport(canvasContainer);
  const containerRect = canvasContainer.getBoundingClientRect();
  const containerTop = containerRect.top + window.scrollY;

  switch (state) {
    case SCROLLING_ABOVE:
      canvas.classList.remove('canvas--active');
      canvasContainer.classList.remove('canvas-container--end');
      break;

    case SCROLLING_WITHIN:
      canvas.classList.add('canvas--active');
      canvasContainer.classList.remove('canvas-container--end');

      const scrollTop = window.scrollY - containerTop;
      const maxScroll = canvasContainer.clientHeight - window.innerHeight;
      const scrollFraction = Math.min(Math.max(scrollTop / maxScroll, 0), 1);
      const frameIndex = Math.min(
        frameCount - 1,
        Math.ceil(scrollFraction * (frameCount - 1))
      );

     // ensureImageLoaded(frameIndex);
      drawFrame(frameIndex);
      break;

    case SCROLLING_BELOW:
      canvas.classList.remove('canvas--active');
      canvasContainer.classList.add('canvas-container--end');
      break;
  }
  ticking = false;
};

// Scroll listener
window.addEventListener(
  'scroll',
  () => {
    if (!ticking) {
      requestAnimationFrame(handleScroll);
      ticking = true;
    }
  },
  { passive: true }
);

// Init
preloadInitialImages();

// Ensure first image is drawn after it's loaded
images[1] = new Image();
images[1].src = currentFrame(1);
images[1].onload = () => {
  drawFrame(1);
};