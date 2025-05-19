<script setup lang="ts">
import { onMounted, onBeforeUnmount, ref, watch } from 'vue';

const SCROLLING_ABOVE = 0;
const SCROLLING_WITHIN = 1;
const SCROLLING_BELOW = 2;
const frameCount = 72;

const canvas = ref<HTMLCanvasElement | null>(null);
const canvasContainer = ref<HTMLDivElement | null>(null);
const images: (HTMLImageElement | undefined)[] = new Array(frameCount);
let currentFrameIndex = -1;
let ticking = false;

interface ScrollTriggerProps {
  imagePath: string;
  scrollLength?: number; // in pixels or default to 300vh
}

const props = defineProps<ScrollTriggerProps>();

const currentFrame = (index: number): string => {
  return new URL(`${props.imagePath}/${index.toString().padStart(3, '0')}.webp`, import.meta.url).href;
};

const preloadInitialImages = () => {
  for (let i = 1; i <= frameCount; i++) {
    const img = new Image();
    img.src = currentFrame(i);
    images[i] = img;
  }
};

const drawFrame = (index: number) => {
  if (index === currentFrameIndex || !images[index] || !canvas.value) return;

  const context = canvas.value.getContext('2d');
  if (!context) return;

  const image = images[index] as HTMLImageElement;
  const canvasWidth = canvas.value.width;
  const canvasHeight = canvas.value.height;

  // Clear canvas
  context.clearRect(0, 0, canvasWidth, canvasHeight);

  // Scale image to fit ("contain")
  const imageRatio = image.width / image.height;
  const canvasRatio = canvasWidth / canvasHeight;

  let drawWidth: number, drawHeight: number;

  if (imageRatio > canvasRatio) {
    drawWidth = canvasWidth;
    drawHeight = canvasWidth / imageRatio;
  } else {
    drawHeight = canvasHeight;
    drawWidth = canvasHeight * imageRatio;
  }

  const offsetX = (canvasWidth - drawWidth) / 2;
  const offsetY = (canvasHeight - drawHeight) / 2;

  currentFrameIndex = index;
  context.drawImage(image, offsetX, offsetY, drawWidth, drawHeight);
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

  const scrollLen = props.scrollLength ?? window.innerHeight * 3;

  switch (state) {
    case SCROLLING_ABOVE:
      canvas.value.classList.remove('canvas--active');
      canvasContainer.value.classList.remove('canvas-container--end');
      break;

    case SCROLLING_WITHIN:
      canvas.value.classList.add('canvas--active');
      canvasContainer.value.classList.remove('canvas-container--end');

      const scrollTop = window.scrollY - containerTop;
      const scrollFraction = Math.min(Math.max(scrollTop / scrollLen, 0), 1);
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

const setCanvasSize = () => {
  if (canvas.value) {
    canvas.value.width = window.innerWidth;
    canvas.value.height = window.innerHeight;
      const i = currentFrameIndex
      currentFrameIndex = -1;
      drawFrame(i)
  }
};

onMounted(() => {
  setCanvasSize();
  preloadInitialImages();

  const firstImage = new Image();
  firstImage.src = currentFrame(1);
  firstImage.onload = () => {
    images[1] = firstImage;
    drawFrame(1);
  };

  window.addEventListener('scroll', onScroll, { passive: true });
  window.addEventListener('resize', setCanvasSize);

  // Ensure enough scroll space
  if (canvasContainer.value) {
    const scrollLen = props.scrollLength ?? window.innerHeight * 3;
    canvasContainer.value.style.height = `${scrollLen + window.innerHeight}px`;
  }
});

onBeforeUnmount(() => {
  window.removeEventListener('scroll', onScroll);
  window.removeEventListener('resize', setCanvasSize);
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
  height: 100vh;
  display: block;
  position: sticky;
  top: 0;
}

.canvas-container {}


.canvas--active {
  /* Optional active state styling */
}

.canvas-container--end {
  /* Optional end state styling */
}
</style>
