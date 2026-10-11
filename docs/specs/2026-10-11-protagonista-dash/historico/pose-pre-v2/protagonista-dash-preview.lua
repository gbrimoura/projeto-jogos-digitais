-- Gera uma prévia demonstrativa do deslocamento horizontal do dash.
-- Este arquivo é separado da fonte de runtime: não altera as poses nem o atlas
-- usados pelo Godot, onde a física já move a raiz do personagem.
-- Aseprite 1.3.18.6; passe --script-param antes de --script.
--
-- Exemplo:
--   Aseprite.exe -b --script-param "out=<pasta>" \
--     --script-param "source_sheet=<protagonista-dash-v1-spritesheet.png>" \
--     --script protagonista-dash-preview.lua

local p = app.params or {}
local FRAME_W, FRAME_H = 64, 64
local CANVAS_W, CANVAS_H = 136, 64
local OUT_DIR = app.fs.normalizePath(p.out or ".")
local SOURCE_SHEET = app.fs.normalizePath(p.source_sheet or
  app.fs.joinPath(OUT_DIR, "protagonista-dash-v1-spritesheet.png"))
local BASE = p.base or "protagonista-dash-horizontal-v1"
local pc = app.pixelColor

local function out(name)
  return app.fs.joinPath(OUT_DIR, name)
end

local sourceSprite = assert(app.open(SOURCE_SHEET),
  "Não foi possível abrir o atlas aprovado: " .. SOURCE_SHEET)
assert(sourceSprite.width == 960 and sourceSprite.height == FRAME_H,
  string.format("Atlas esperado 960x64; recebido %dx%d",
    sourceSprite.width, sourceSprite.height))
assert(#sourceSprite.frames == 1,
  "O spritesheet-fonte deve ser uma imagem estática de um quadro")
assert(sourceSprite.colorMode == ColorMode.RGB,
  "O atlas-fonte deve usar modo RGB/RGBA para validar alpha binário")

-- A exportação PNG do atlas é achatada. Ainda assim, compomos as camadas
-- visíveis para não depender da posição interna do cel ao abrir o PNG.
local sheetImage = Image(sourceSprite.width, sourceSprite.height)
local visibleCelCount = 0
for _, layer in ipairs(sourceSprite.layers) do
  if layer.isVisible and not layer.isGroup then
    local cel = layer:cel(1)
    if cel then
      assert(cel.opacity == 255 and layer.opacity == 255,
        "O atlas precisa manter opacidade integral para preservar alpha binário")
      sheetImage:drawImage(cel.image, cel.position.x, cel.position.y)
      visibleCelCount = visibleCelCount + 1
    end
  end
end
assert(visibleCelCount >= 1, "O atlas não contém cels visíveis")

local function extractFrame(frameIndex)
  local image = Image(FRAME_W, FRAME_H)
  local xOffset = frameIndex * FRAME_W
  for y = 0, FRAME_H - 1 do
    for x = 0, FRAME_W - 1 do
      local raw = sheetImage:getPixel(xOffset + x, y)
      local alpha = pc.rgbaA(raw)
      assert(alpha == 0 or alpha == 255,
        string.format("Alpha parcial no frame %d em (%d,%d)", frameIndex, x, y))
      if alpha == 255 then image:drawPixel(x, y, raw) end
    end
  end
  return image
end

local idleImage = extractFrame(0)
local dashImages = {extractFrame(12), extractFrame(13), extractFrame(14)}

local function flipped(image)
  local result = Image(FRAME_W, FRAME_H)
  for y = 0, FRAME_H - 1 do
    for x = 0, FRAME_W - 1 do
      local raw = image:getPixel(x, y)
      if pc.rgbaA(raw) > 0 then result:drawPixel(FRAME_W - 1 - x, y, raw) end
    end
  end
  return result
end

local reverseDashImages = {
  flipped(dashImages[1]), flipped(dashImages[2]), flipped(dashImages[3]),
}
local leftFacingIdleImage = flipped(idleImage)

local function place(image, x)
  assert(x == math.floor(x), "O deslocamento deve permanecer alinhado à grade de pixels")
  assert(x >= 0 and x + FRAME_W <= CANVAS_W,
    string.format("Frame sairia do canvas na posição x=%d", x))
  local canvas = Image(CANVAS_W, CANVAS_H)
  canvas:drawImage(image, x, 0)
  return canvas
end

local preview = Sprite(CANVAS_W, CANVAS_H)
while #preview.layers > 1 do preview:deleteLayer(preview.layers[#preview.layers]) end
local layer = preview.layers[1]
layer.name = "Prévia · deslocamento horizontal demonstrativo"

local addedFrameCount = 0
local function addFrame(image, x, durationMs)
  addedFrameCount = addedFrameCount + 1
  local frameNumber = addedFrameCount
  local frame = (frameNumber == 1) and preview.frames[1] or preview:newEmptyFrame()
  frame.duration = durationMs / 1000
  local cel = preview:newCel(layer, frameNumber)
  cel.image = place(image, x)
  cel.position = Point(0, 0)
end

-- A duração e o espaçamento representam 720 px/s por 0,14 s em escala 2:
-- 50 px nativos. A última pose termina na mesma posição do hold seguinte.
local HOLD_MS, DASH_STEP_MS = 300, 20
local DASH_POSE = {1, 1, 2, 2, 3, 3, 3}
local RIGHT_X = {15, 22, 29, 37, 44, 51, 58}
local LEFT_X = {51, 44, 37, 29, 22, 15, 8}

-- O hold esquerdo é espelhado para que a orientação também coincida no loop:
-- a mudança de direção ocorre no começo de cada dash, não na emenda do GIF.
addFrame(leftFacingIdleImage, 8, HOLD_MS)
for i = 1, #DASH_POSE do
  addFrame(dashImages[DASH_POSE[i]], RIGHT_X[i], DASH_STEP_MS)
end
addFrame(idleImage, 58, HOLD_MS)
for i = 1, #DASH_POSE do
  addFrame(reverseDashImages[DASH_POSE[i]], LEFT_X[i], DASH_STEP_MS)
end
assert(#preview.frames == 16,
  string.format("A prévia deve ter 16 quadros; recebeu %d", #preview.frames))

local outputPath = out(BASE .. ".aseprite")
preview:saveAs(outputPath)

print(string.format(
  "Prévia horizontal salva: %s | canvas %dx%d | %d quadros | dash 50 px em cada direção | holds de %d ms",
  outputPath, CANVAS_W, CANVAS_H, #preview.frames, HOLD_MS))
