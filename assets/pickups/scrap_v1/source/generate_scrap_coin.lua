-- Factory palette from assets/environment/factory_v2/palette-fabrica-v2.json.
-- SNES-style shading, with four 16x16 spin frames in runtime order.
local CELL = 16
local OUT = app.params.out or "assets/pickups/scrap_v1"
local NAME = "scrap-coin"
local palette = {
  ["#"] = 0x0E0D0E, u = 0x4A2D21, r = 0x70432C, c = 0x925A36,
  t = 0xB37949, p = 0xC68D58, a = 0xB78342, g = 0xD2A75C, l = 0xE7CFAD,
}

-- Stamped face, rolled edge with milling marks, and warm wear on the bevel.
-- The stamp compresses with the face and disappears as the rim faces the viewer.
local frames = {
  { name = "Face", left = 2, rows = {
    "...######...",
    "..#tgggllg#.",
    ".#cglggaggp#",
    "#tggpaapggt#",
    "#ctgurraggt#",
    "#ttgrgggggt#",
    "#ctgurraagt#",
    "#ttgggarggt#",
    "#ctgrrraggt#",
    ".#ctgagggp#",
    "..#ctappt#",
    "...######",
  }},
  { name = "Turn left", left = 3, rows = {
    "...#####",
    "..#cggll#",
    ".#rtgagp#",
    ".#ttpaagp#",
    "#rcturgpt#",
    "#tttrggpt#",
    "#rcturapt#",
    "#tttggrpt#",
    "#rctrrapt#",
    ".#ctaggp#",
    "..#ctpp#",
    "...#####",
  }},
  { name = "Edge", left = 5, rows = {
    "..###",
    ".#ctg#",
    ".#rtg#",
    ".#ctg#",
    "#rcpgl#",
    "#ctpgg#",
    "#rcpgg#",
    "#ctpgg#",
    "#rcpgg#",
    ".#ctp#",
    ".#rtt#",
    "..###",
  }},
  { name = "Turn right", left = 3, rows = {
    "..#####",
    ".#tgglg#",
    ".#cggagp#",
    "#tgpgaapc#",
    "#tgurrgpr#",
    "#tgrgggpt#",
    "#tgurrapr#",
    "#tgggrgpt#",
    "#tgrrrgpr#",
    ".#cagppt#",
    "..#ctpp#",
    "..#####",
  }},
}

local sprite = Sprite(CELL * #frames, CELL, ColorMode.RGB)
local atlas = Image(sprite.width, sprite.height)
for index, frame in ipairs(frames) do
  local image = Image(CELL, CELL)
  for rowIndex, row in ipairs(frame.rows) do
    assert(frame.left + #row <= CELL and rowIndex + 1 < CELL, "Artwork outside cell")
    for column = 1, #row do
      local symbol = row:sub(column, column)
      if symbol ~= "." then
        local hex = assert(palette[symbol], "Unknown palette symbol " .. symbol)
        image:drawPixel(frame.left + column - 1, rowIndex + 1,
          app.pixelColor.rgba((hex >> 16) & 255, (hex >> 8) & 255, hex & 255, 255))
      end
    end
  end
  local layer = index == 1 and sprite.layers[1] or sprite:newLayer()
  layer.name = frame.name
  local position = Point((index - 1) * CELL, 0)
  sprite:newCel(layer, 1, image, position)
  atlas:drawImage(image, position)
end

sprite.gridBounds = Rectangle(0, 0, CELL, CELL)
local scale = 8
local preview = Image(atlas.width * scale, atlas.height * scale)
for pixel in preview:pixels() do
  pixel(atlas:getPixel(pixel.x // scale, pixel.y // scale))
end

sprite:saveAs(app.fs.joinPath(OUT, NAME .. ".aseprite"))
sprite:saveCopyAs(app.fs.joinPath(OUT, NAME .. ".png"))
preview:saveAs(app.fs.joinPath(OUT, "preview", NAME .. "-8x.png"))
print("Wrote scrap coin atlas: 4 x 16x16 spin frames")

