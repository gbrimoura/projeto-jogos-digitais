local W, H = 14, 14
local pc = app.pixelColor
local colors = {
  outline = pc.rgba(0x00, 0x11, 0x23, 0xff),
  red = pc.rgba(0xc4, 0x3d, 0x43, 0xff),
  shade = pc.rgba(0x7e, 0x25, 0x2d, 0xff),
  shine = pc.rgba(0xef, 0x6b, 0x5e, 0xff),
}
local rows = {
  "......##......", "....######....", "...########...", "..##########..",
  ".############.", ".############.", "##############", "##############",
  ".############.", ".############.", "..##########..", "...########...",
  "....######....", "......##......",
}
local img = Image(W, H)
local inside = {}
for y, row in ipairs(rows) do
  assert(#row == W, "sprite row width mismatch")
  for x = 1, W do
    if row:sub(x, x) == "#" then inside[(y - 1) * W + x] = true end
  end
end
local function inside_xy(x, y)
  if x < 1 or x > W or y < 1 or y > H then return false end
  return inside[(y - 1) * W + x] == true
end
for y, row in ipairs(rows) do
  for x = 1, W do
    if row:sub(x, x) == "#" then
      local edge = not inside_xy(x - 1, y)
        or not inside_xy(x + 1, y)
        or not inside_xy(x, y - 1)
        or not inside_xy(x, y + 1)
      local color = colors.red
      if edge then
        color = colors.outline
      elseif y >= 9 and (x >= 4 and x <= 11) then
        color = colors.shade
      elseif y == 5 and x == 5 then
        color = colors.shine
      end
      img:drawPixel(x - 1, y - 1, color)
    end
  end
end
local sprite = Sprite(W, H)

local layer = sprite.layers[1]
layer.name = "Cabeça V4 · disco vermelho 14×14"
local cel = sprite:newCel(layer, 1)
cel.image = img
sprite.filename = "assets/player/racket/racket_head_v4.aseprite"
sprite:saveAs(sprite.filename)
sprite:saveCopyAs("assets/player/racket/racket_head_v4.png")
print("STATUS=done; size=14x14; alpha=binary; palette=4; source=V4-approved-palette")


