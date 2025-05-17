# Apple like img sequence animation

This is a basic scroll image sequence animation triggered by scrolling.
Inspired by: https://css-tricks.com/lets-make-one-of-those-fancy-scrolling-animations-used-on-apple-product-pages/.

This example however, takes the animation one step further, so it can be integrated nicely in your existing HTML content.

## script for converting to .webp
for f in *.png; do
  cwebp -q 01 "$f" -o "webp-output/${f%.png}.webp"
done


https://scrumultra.com/scroll-trigger/
