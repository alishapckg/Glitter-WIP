# y2k-zones

An interactive macOS terminal command that applies Y2K glam effects to a
video through a zone-based, click-and-paint interface.

## Features

- **Blur zone** - freehand-painted blur with an optional pink/lilac/mint/gold
  color tint (not a plain gaussian blur), plus an **edge softness** slider
  that controls how feathered/soft the transition at the mask border is
  (0 = hard edge, 100 = very soft/gradual).
- **Glitter zone** - animated, twinkling sparkles (white / pink / gold /
  rainbow) with adjustable density and glow.
- **Glass zone** - frosted, matte Y2K-style glass (soft blur + desaturation +
  a light rim highlight along the zone edge), with an opacity slider so the
  original image shows through.
- **Global dust** - film grain + slight desaturation + vignette for a dusty,
  vintage feel.
- **Global color filter** - a full-video color wash (pink, lilac, emerald,
  baby blue, warm gold, or a custom color) with adjustable intensity.
- Original audio is preserved in the output.

## Download

**Option A - with git:**

```bash
cd ~/Desktop
git clone https://github.com/alishapckg/Glitter-WIP.git
cd Glitter-WIP
```

**Option B - without git:**

1. On the repository's GitHub page, click the green **Code** button →
   **Download ZIP**.
2. Unzip it (double-click the downloaded file).
3. In Terminal, `cd` into the unzipped folder:
   ```bash
   cd ~/Downloads/Glitter-WIP-main
   ```

Then run the installer:

```bash
chmod +x install.sh
./install.sh
```

This installs the Python dependencies (`opencv-contrib-python`, `numpy`),
`ffmpeg`, and registers the `y2k-zones` command on your system. Verify it
worked with:

```bash
which y2k-zones
```

To get updates later, pull the latest changes (or download the ZIP again)
and re-run `./install.sh`.

## Requirements

- macOS (Apple Silicon or Intel)
- Python 3.9+
- `opencv-contrib-python`, `numpy`
- `ffmpeg` on your `PATH` (used only to copy the audio track)

Install the Python dependencies:

```bash
pip3 install opencv-contrib-python numpy
```

Install ffmpeg (if you don't already have it):

```bash
brew install ffmpeg
```

## Usage

```bash
y2k-zones input.mov
# or with a custom output name
y2k-zones input.mov output.mp4
```

An OpenCV window opens showing the first frame of your video plus a control
panel on the right. Walk through 5 steps in order:

1. **Blur zone** - paint the area(s) to blur, pick strength, edge softness,
   a color tint, and optionally turn on "Track motion".
2. **Glitter zone** - paint where sparkles should appear, pick density, glow,
   color, and optionally "Track motion".
3. **Glass zone** - paint the frosted-glass area, pick strength, opacity,
   and optionally "Track motion".
4. **Global dust** - no painting needed, applies to the whole frame.
5. **Global color filter** - pick a color wash and intensity for the whole
   video.

Controls:

- **Left mouse drag** - paint the current zone (freehand brush, not a
  rectangle).
- **Mouse wheel** - change brush size (while hovering over the video).
- **Sliders / toggles / color swatches** - click and drag directly with the
  mouse, right in the window.
- **Enter** - confirm the current step and move to the next one.
- **Esc** - cancel and quit without processing.

Any step can be left at its defaults or turned off with its toggle - you are
not required to paint every zone.

After step 5, processing starts automatically. Progress is printed to the
terminal, and the final video (with audio) is written next to your input
file as `<input>_y2k.mp4` unless you specified a different output path.

## Notes

- Masks are static by default: whatever you paint on the first frame is
  reused for every frame in the video. Turn on "Track motion" on a given
  zone if you want it to follow a moving subject instead (see the feature
  list above for how it works and its limitations).
- If `ffmpeg` isn't found, the tool still produces a video, but without
  audio, and prints a warning.
- Pure OpenCV/NumPy pipeline - no PyTorch, no ML models, nothing GPU-bound.
  "Track motion" uses OpenCV's classical CSRT tracker (appearance-based,
  not object recognition).
