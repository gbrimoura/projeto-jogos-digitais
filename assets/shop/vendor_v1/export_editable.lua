-- Run with Aseprite -b --script assets/shop/vendor_v1/export_editable.lua
-- Regenerate the PNGs with generate_shop.py before rebuilding these sources.
local dir = app.fs.filePath(debug.getinfo(1, "S").source:sub(2))
local palettePath = app.fs.joinPath(dir, "../../environment/factory_v2/palette-fabrica-v2.json")
local file = assert(io.open(palettePath, "r"))
local paletteJson = file:read("*a")
file:close()
local swatches = {}
for hex in paletteJson:gmatch("#(%x%x%x%x%x%x)") do
  local packed = tonumber(hex, 16)
  swatches[#swatches + 1] = Color{
    r=(packed >> 16) & 255, g=(packed >> 8) & 255, b=packed & 255
  }
end
assert(#swatches == 20, "Expected the 20 Factory v2 swatches")
local palette = Palette(#swatches)
for i, color in ipairs(swatches) do
  palette:setColor(i - 1, color)
end

local function path(name)
  return app.fs.joinPath(dir, name)
end

local assets = {
  {name="vendor-idle", layer="Vendedor", width=64, height=64, frames=4},
  {name="shop-counter", layer="Balcão", width=104, height=32, frames=1},
  {name="shop-sign", layer="Letreiro", width=48, height=32, frames=1},
  {name="shop-merchandise", layer="Mercadorias", width=72, height=24, frames=1},
}

for _, asset in ipairs(assets) do
  local source = Image{fromFile=path(asset.name .. ".png")}
  assert(source.width == asset.width * asset.frames and source.height == asset.height)
  local sprite = Sprite(asset.width, asset.height, ColorMode.RGB)
  sprite:setPalette(palette)
  local layer = sprite.layers[1]
  layer.name = asset.layer
  local durations = {0.45, 0.22, 0.12, 0.21}
  for index = 1, asset.frames do
    if index > 1 then sprite:newEmptyFrame(index) end
    local region = Rectangle((index - 1) * asset.width, 0, asset.width, asset.height)
    local cel = sprite:newCel(layer, index, Image(source, region), Point(0, 0))
    if asset.frames > 1 then sprite.frames[index].duration = durations[index] end
    assert(cel.image:isEqual(Image(source, region)))
  end
  if asset.frames > 1 then
    local tag = sprite:newTag(1, asset.frames)
    tag.name = "idle"
  end
  local filename = path(asset.name .. ".aseprite")
  sprite:saveAs(filename)
  sprite:close()

  local persisted = assert(app.open(filename))
  assert(#persisted.frames == asset.frames)
  for index, frame in ipairs(persisted.frames) do
    local cel = persisted.layers[1]:cel(index)
    local celPosition = cel.position
    local region = Rectangle((index - 1) * asset.width, 0, asset.width, asset.height)
    local rendered = Image(asset.width, asset.height)
    rendered:drawImage(cel.image, celPosition)
    assert(rendered:isEqual(Image(source, region)), "Export pixel mismatch: " .. asset.name)
    if asset.frames > 1 then assert(math.abs(frame.duration - durations[index]) < 0.001) end
  end
  persisted:close()
  print("Verified " .. filename)
end
