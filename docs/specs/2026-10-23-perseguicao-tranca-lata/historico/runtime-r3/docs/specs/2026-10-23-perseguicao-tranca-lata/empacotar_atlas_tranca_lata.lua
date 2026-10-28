-- Empacota os dois PNG autorais atuais como ImageTexture nativo do Godot.
-- Executar a partir da raiz do repositório com Aseprite --batch --script <este-arquivo>.
local sources = {
  {
    input = "assets/enemy/training_target/jump/tranca-lata-jump-atlas-v1.png",
    output = "resources/enemy/tranca_lata_jump_texture.tres",
    width = 384,
    height = 64,
    image_id = "Image_jump_atlas",
  },
  {
    input = "assets/enemy/training_target/shockwave/tranca-lata-shockwave-atlas.png",
    output = "resources/enemy/tranca_lata_shockwave_texture.tres",
    width = 960,
    height = 160,
    image_id = "Image_shockwave_atlas",
  },
}

local pixel = app.pixelColor

local function write_atlas(spec)
  local image = Image{ fromFile = spec.input }
  assert(image.width == spec.width and image.height == spec.height,
    "Dimensões inesperadas: " .. spec.input)
  assert(image.colorMode == ColorMode.RGB,
    "Esperado PNG RGBA/RGB de 8 bits sem indexação: " .. spec.input)

  local output = assert(io.open(spec.output, "w"), "Não foi possível gravar " .. spec.output)
  output:write("[gd_resource type=\"ImageTexture\" load_steps=2 format=3]\n\n")
  output:write("[sub_resource type=\"Image\" id=\"" .. spec.image_id .. "\"]\n")
  output:write("data = { \"data\": PackedByteArray(\n")

  local chunk = {}
  local emitted = 0
  local total = spec.width * spec.height * 4
  local function flush()
    if #chunk == 0 then return end
    local text = table.concat(chunk, ", ")
    if emitted + #chunk < total then text = text .. "," end
    output:write(text, "\n")
    emitted = emitted + #chunk
    chunk = {}
  end

  for y = 0, spec.height - 1 do
    for x = 0, spec.width - 1 do
      local value = image:getPixel(x, y)
      chunk[#chunk + 1] = tostring(pixel.rgbaR(value))
      chunk[#chunk + 1] = tostring(pixel.rgbaG(value))
      chunk[#chunk + 1] = tostring(pixel.rgbaB(value))
      chunk[#chunk + 1] = tostring(pixel.rgbaA(value))
      if #chunk >= 4096 then flush() end
    end
  end
  flush()

  output:write("), \"format\": \"RGBA8\", \"height\": ", tostring(spec.height),
    ", \"mipmaps\": false, \"width\": ", tostring(spec.width), " }\n\n")
  output:write("[resource]\nimage = SubResource(\"", spec.image_id, "\")\n")
  output:close()
  print(string.format("Empacotado: %s (%dx%d RGBA8; %d bytes)",
    spec.output, spec.width, spec.height, total))
end

for _, spec in ipairs(sources) do write_atlas(spec) end