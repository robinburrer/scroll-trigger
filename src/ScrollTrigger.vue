<script setup lang="ts">
import { onMounted, onBeforeUnmount, ref } from 'vue';

const SCROLLING_ABOVE = 0;
const SCROLLING_WITHIN = 1;
const SCROLLING_BELOW = 2;
const frameCount = 72;

const canvas = ref<HTMLCanvasElement | null>(null);
const canvasContainer = ref<HTMLDivElement | null>(null);
const images: (HTMLImageElement | undefined)[] = new Array(frameCount);
let currentFrameIndex = -1;
let ticking = false;

const currentFrame = (index: number): string => {

  return new URL(`/assets/${index.toString().padStart(3, '0')}.webp`, import.meta.url).href;
};

const preloadInitialImages = () => {
  for (let i = 1; i <= frameCount; i++) {

    const img = new Image();
    const cf = currentFrame(i);
    console.log(cf)
    img.src = cf
    images[i] = img;
  }
};

const drawFrame = (index: number) => {
  if (index === currentFrameIndex || !images[index] || !canvas.value) return;

  const context = canvas.value.getContext('2d');
  if (!context) return;

  currentFrameIndex = index;
  context.clearRect(0, 0, canvas.value.width, canvas.value.height);
  context.drawImage(images[index] as HTMLImageElement, 0, 0);
};

const isElementInViewport = (el: HTMLElement): number => {
  const rect = el.getBoundingClientRect();
  if (rect.top <= 0 && rect.bottom < window.innerHeight) {
    return SCROLLING_BELOW;
  } else if (rect.top <= 0 && rect.bottom >= window.innerHeight) {
    return SCROLLING_WITHIN;
  } else {
    return SCROLLING_ABOVE;
  }
};

const handleScroll = () => {
  if (!canvasContainer.value || !canvas.value) return;

  const state = isElementInViewport(canvasContainer.value);
  const containerRect = canvasContainer.value.getBoundingClientRect();
  const containerTop = containerRect.top + window.scrollY;

  switch (state) {
    case SCROLLING_ABOVE:
      canvas.value.classList.remove('canvas--active');
      canvasContainer.value.classList.remove('canvas-container--end');
      break;

    case SCROLLING_WITHIN:
      canvas.value.classList.add('canvas--active');
      canvasContainer.value.classList.remove('canvas-container--end');

      const scrollTop = window.scrollY - containerTop;
      const maxScroll = canvasContainer.value.clientHeight - window.innerHeight;
      const scrollFraction = Math.min(Math.max(scrollTop / maxScroll, 0), 1);
      const frameIndex = Math.min(
        frameCount - 1,
        Math.ceil(scrollFraction * (frameCount - 1))
      );

      drawFrame(frameIndex);
      break;

    case SCROLLING_BELOW:
      canvas.value.classList.remove('canvas--active');
      canvasContainer.value.classList.add('canvas-container--end');
      break;
  }

  ticking = false;
};

const onScroll = () => {
  if (!ticking) {
    requestAnimationFrame(handleScroll);
    ticking = true;
  }
};

onMounted(() => {
  if (canvas.value) {
    canvas.value.width = 1080;
    canvas.value.height = 1920;
    canvas.value.style.willChange = 'transform';
  }

  preloadInitialImages();

  // Ensure first image is drawn after it's loaded
  const firstImage = new Image();
  firstImage.src = currentFrame(1);
  firstImage.onload = () => {
    images[1] = firstImage;
    drawFrame(1);
  };

  window.addEventListener('scroll', onScroll, { passive: true });
});

onBeforeUnmount(() => {
  window.removeEventListener('scroll', onScroll);
});
</script>

<template>
    <h2>hello</h2>
    <div ref="canvasContainer" class="canvas-container">
        <canvas ref="canvas" class="canvas"></canvas>
    </div>
</template>

<style scoped>
.canvas {
    width: 100%;
    display: block;
}

.canvas--active {
    /* Optional active state styling */
}

.canvas-container--end {
    /* Optional end state styling */
}
</style>
