-- Native 32x16 Cospe-Rebite projectile, authored as a pixel map.
-- Run from the repository root:
--   Aseprite.exe -b --script assets/projectile/cospe_rebite/generate_cospe_rebite.lua
local W, H = 32, 16
local pc = app.pixelColor
local function rgba(hex)
  return pc.rgba(
    tonumber(hex:sub(2, 3), 16),
    tonumber(hex:sub(4, 5), 16),
    tonumber(hex:sub(6, 7), 16),
    255
  )
end

local HEX = {
  n = "#00000D", k = "#192031", s = "#373F4D",
  h = "#F5E9D8", u = "#CFC3B7", w = "#FFFCF0",
  b = "#70432C", c = "#925A36", o = "#B37949",
  d = "#D94B4B", R = "#D94B4B", r = "#F0524E", L = "#FF7256", a = "#F5A84F", A = "#F5A84F",
}
local COLORS = {}
for key, value in pairs(HEX) do COLORS[key] = rgba(value) end
local TRANSPARENT = pc.rgba(0, 0, 0, 0)

-- Hand-drawn map: cream rounded head points right; copper shank, red collar,
-- dark steel rear and two small red speed marks. No filtered or painted source.
local ROWS = {
  "................................",
  "................................",
  "................................",
  "......................nn........",
  "......RrL...........nnhwnn......",
  "....RrRrLA........nRrRhhhnn.....",
  "...dR..........nsaoRdhhwhhn.....",
  "..............nkkoorrhhhhhn.....",
  "..............nkkoorrhhhhhn.....",
  "...............nsboRdhuuuhn.....",
  ".......dRrRrL.....nRrRuuunn.....",
  "........RrL.........nnuunn......",
  "..........dR..........nn........",
  "................................",
  "................................",
  "................................",
}
assert(#ROWS == H, "sprite row count mismatch")
for y, row in ipairs(ROWS) do assert(#row == W, "sprite row width mismatch at " .. y) end

local img = Image(W, H)
for y, row in ipairs(ROWS) do
  for x = 1, W do
    local symbol = row:sub(x, x)
    local color = symbol == "." and TRANSPARENT or COLORS[symbol]
    assert(color ~= nil, "unknown palette symbol " .. symbol)
    img:drawPixel(x - 1, y - 1, color)
  end
end

local function nearestScale(src, scale)
  local dst = Image(src.width * scale, src.height * scale)
  for y = 0, src.height - 1 do
    for x = 0, src.width - 1 do
      local pixel = src:getPixel(x, y)
      for dy = 0, scale - 1 do
        for dx = 0, scale - 1 do dst:drawPixel(x * scale + dx, y * scale + dy, pixel) end
      end
    end
  end
  return dst
end

local function extract(src, sx, sy, width, height)
  local dst = Image(width, height)
  for y = 0, height - 1 do
    for x = 0, width - 1 do dst:drawPixel(x, y, src:getPixel(sx + x, sy + y)) end
  end
  return dst
end

local function fillRect(dst, x, y, width, height, color)
  for py = y, y + height - 1 do
    for px = x, x + width - 1 do dst:drawPixel(px, py, color) end
  end
end

local sprite = Sprite(W, H)
while #sprite.layers > 1 do sprite:deleteLayer(sprite.layers[#sprite.layers]) end
local layer = sprite.layers[1]
layer.name = "Cospe-Rebite · 32x16 · facing +X"
sprite:newCel(layer, 1).image = img
sprite.filename = "assets/projectile/cospe_rebite/cospe_rebite.aseprite"
sprite:saveAs(sprite.filename)
sprite:saveCopyAs("assets/projectile/cospe_rebite/cospe_rebite.png")

-- Pack the same authored map as an import-free Godot ImageTexture (RGBA8).
local packedRows = {}
for y, row in ipairs(ROWS) do
  local bytes = {}
  for x = 1, W do
    local symbol = row:sub(x, x)
    if symbol == "." then
      bytes[#bytes + 1] = "0"
      bytes[#bytes + 1] = "0"
      bytes[#bytes + 1] = "0"
      bytes[#bytes + 1] = "0"
    else
      local hex = HEX[symbol]
      assert(hex ~= nil, "missing packed palette symbol " .. symbol)
      bytes[#bytes + 1] = tostring(tonumber(hex:sub(2, 3), 16))
      bytes[#bytes + 1] = tostring(tonumber(hex:sub(4, 5), 16))
      bytes[#bytes + 1] = tostring(tonumber(hex:sub(6, 7), 16))
      bytes[#bytes + 1] = "255"
    end
  end
  packedRows[#packedRows + 1] = table.concat(bytes, ", ")
end
local textureResource = '[gd_resource type="ImageTexture" load_steps=2 format=3]\n\n'
  .. '[sub_resource type="Image" id="Image_cospe_rebite"]\n'
  .. 'data = { "data": PackedByteArray(\n'
  .. table.concat(packedRows, ",\n")
  .. '\n), "format": "RGBA8", "height": 16, "mipmaps": false, "width": 32 }\n\n'
  .. '[resource]\nimage = SubResource("Image_cospe_rebite")\n'
local textureFile = assert(io.open("resources/enemy/cospe_rebite_projectile_texture.tres", "wb"))
textureFile:write(textureResource)
textureFile:close()
nearestScale(img, 8):saveAs("assets/projectile/cospe_rebite/cospe_rebite-preview-8x.png")

-- Static scale comparison with the existing worker pose and the projectile at 2x.
local workerPath = "assets/enemy/rivet_worker/rivet_worker-atlas.png"
local workerAtlas = Image{fromFile = workerPath}
local workerFrame = nearestScale(extract(workerAtlas, 0, 0, 64, 64), 2)
local projectile2x = nearestScale(img, 2)
local board = Image(256, 144)
fillRect(board, 0, 0, 256, 144, rgba("#192031"))
fillRect(board, 8, 8, 120, 120, rgba("#373F4D"))
fillRect(board, 136, 8, 112, 120, rgba("#373F4D"))
board:drawImage(workerFrame, 8, 8)
board:drawImage(projectile2x, 160, 42)
fillRect(board, 0, 118, 256, 2, rgba("#B37949"))
fillRect(board, 0, 120, 256, 24, rgba("#192031"))
board:saveAs("assets/projectile/cospe_rebite/cospe_rebite-contact-preview.png")
print("Rendered native 32x16 PNG/ASE, nearest 8x preview, and worker/projectile 2x contact preview.")