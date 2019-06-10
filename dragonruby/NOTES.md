## Output Primitives

Output primitives are all collections of arrays. They typically follow the format `[x, y, w, h, r, g, b, a]`. You can add a new output to be rendered by calling (for example):

```ruby
def tick args
  x = 680
  y = 380
  text = "Hello World"
  args.outputs.labels << [x, y, text]
end
```

### `args.outputs.borders`
Renders a border with a given color.

```[x, y, w, h, r, g, b, a]```

- _x_: x coordinate
- _y_: y coordinate
- _w_: width
- _h_: height
- _r,b,g,a_: RGBA colors (0-255)

### `args.outputs.labels`
Render some text of a given size, alignment, and color.

```[x, y, text, size, align, r, g, b, a]```

- _x_: x coordinate
- _y_: y coordinate
- _text_: text to display
- _size_: -2 [smaller], -1 [small], 0 [medium], 1 [large], 2 [larger]
- _align_: 0 [right], 1 [center], 2 [left]
- _r,b,g,a_: RGBA colors (0-255)

### `args.outputs.lines`
Render a line from one x/y coordinate to another with a given color.

```[x, y, x2, y2, r, g, b, a]```
- _x1_: starting x coordinate
- _y1_: starting y coordinate
- _x2_: ending x coordinate
- _y2_: ending y coordinate
- _r,b,g,a_: RGBA colors (0-255)


### `args.outputs.solids`
Renders a solid rectangle with a given color.

```[x, y, w, h, r, g, b, a]```

- _x_: x coordinate
- _y_: y coordinate
- _w_: width
- _h_: height
- _r,b,g,a_: RGBA colors (0-255)

### `args.outputs.sounds`
Plays sound file (.wav or .ogg)

```"filename.wav"```

### `args.outputs.sprites`
Renders an image sprite (png only?)

```[x, y, w, h, path, angle, a]```

- _x_: x coordinate
- _y_: y coordinate
- _w_: width
- _h_: height
- _path_: directory and filename for image
- _angle_: angle of rotation (0-360)
- _a_: alpha channel for transparency (0-255)

## Output Methods

### `args.outputs.clear`
Clear all the outputs (empties the outputs arrays).
