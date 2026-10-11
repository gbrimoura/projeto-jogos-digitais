-- Acrescenta três poses de dash ao Aseprite da caminhada v3.
-- Os doze quadros existentes são abertos como fonte e não são reeditados.
-- A arte nova usa apenas pixels da pose aprovada, sem cores ou alpha novos.
-- Aseprite 1.3.18.6; passe --script-param antes de --script.
--
-- Exemplo:
--   Aseprite.exe -b --script-param "out=<pasta>" \
--     --script-param "source_aseprite=<protagonista-walk-v3.aseprite>" \
--     --script protagonista-dash.lua

local p = app.params or {}
local W, H = 64, 64
local OUT_DIR = app.fs.normalizePath(p.out or ".")
local SOURCE_ASEPRITE = app.fs.normalizePath(p.source_aseprite or
  app.fs.joinPath(OUT_DIR, "../protagonista-walk/protagonista-walk-v3.aseprite"))
local BASE = p.base or "protagonista-dash-v1"

local function out(name)
  return app.fs.joinPath(OUT_DIR, name)
end

-- Paleta de 27 cores herdada do idle v2. As poses são somente translações
-- inteiras desses pixels, portanto não há interpolação ou cores intermediárias.
local paletteRGB = {
  {245,233,216}, {252,194,3}, {0,17,35}, {0,0,13}, {55,63,77},
  {46,101,176}, {1,0,14}, {207,195,183}, {0,0,16}, {0,0,15},
  {0,0,0}, {48,105,181}, {0,0,12}, {1,0,11}, {2,2,19},
  {1,1,17}, {1,1,13}, {246,236,221}, {243,177,0}, {19,49,86},
  {25,32,49}, {255,252,240}, {6,4,25}, {0,236,253}, {3,23,39},
  {26,66,118}, {137,124,118},
}
assert(#paletteRGB == 27, "A paleta travada do protagonista deve conter 27 cores")

local paletteSet = {}
for _, rgb in ipairs(paletteRGB) do
  paletteSet[string.format("%02X%02X%02X", rgb[1], rgb[2], rgb[3])] = true
end

local sourceSprite = assert(app.open(SOURCE_ASEPRITE),
  "Não foi possível abrir a fonte walk v3: " .. SOURCE_ASEPRITE)
assert(sourceSprite.width == W and sourceSprite.height == H,
  string.format("Canvas da fonte mudou: esperado %dx%d, recebido %dx%d",
    W, H, sourceSprite.width, sourceSprite.height))
assert(#sourceSprite.frames == 12,
  "A fonte walk v3 deve conter exatamente os 12 quadros aprovados de idle e walk")
assert(sourceSprite.colorMode == ColorMode.RGB,
  "A fonte walk v3 deve continuar em modo RGB/RGBA")

local sourceTags = {}
for _, tag in ipairs(sourceSprite.tags) do
  sourceTags[tag.name] = {
    tag = tag,
    first = tag.fromFrame.frameNumber,
    last = tag.toFrame.frameNumber,
  }
end
assert(sourceTags.idle and sourceTags.idle.first == 1 and sourceTags.idle.last == 6,
  "A tag idle da fonte deve continuar nos quadros 0–5")
assert(sourceTags.walk and sourceTags.walk.first == 7 and sourceTags.walk.last == 12,
  "A tag walk da fonte deve continuar nos quadros 6–11")
assert(sourceTags.dash == nil, "A fonte de entrada já contém uma tag dash")

local originalDurations = {}
local expectedIdleMs = {420, 140, 180, 140, 540, 80}
for frameNumber, frame in ipairs(sourceSprite.frames) do
  originalDurations[frameNumber] = frame.duration
  if frameNumber <= 6 then
    assert(math.abs(frame.duration - expectedIdleMs[frameNumber] / 1000) < 0.001,
      string.format("A duração do idle no quadro %d mudou", frameNumber - 1))
  else
    assert(math.abs(frame.duration - 0.1) < 0.001,
      string.format("A duração da caminhada no quadro %d mudou", frameNumber - 1))
  end
end

-- A v3 armazena a pose de idle no primeiro quadro em um cel integral. Clonamos
-- a composição desse quadro para a arte nova, sem achatar nem salvar a fonte.
local function compositeFrame(sprite, frameNumber)
  local image = Image(W, H)
  local celCount = 0
  for _, layer in ipairs(sprite.layers) do
    if layer.isVisible and not layer.isGroup then
      local cel = layer:cel(frameNumber)
      if cel then
        assert(cel.opacity == 255 and layer.opacity == 255,
          "A pose-base precisa manter opacidade integral para alpha binário")
        local position = cel.position
        image:drawImage(cel.image, position.x, position.y)
        celCount = celCount + 1
      end
    end
  end
  assert(celCount == 1,
    "O primeiro quadro da fonte deve conter um único cel visível da pose aprovada")
  return image
end

local baseImage = compositeFrame(sourceSprite, 1)
local pc = app.pixelColor

local function colorKey(raw)
  return string.format("%02X%02X%02X", pc.rgbaR(raw), pc.rgbaG(raw), pc.rgbaB(raw))
end

local function validateSourcePixels(image)
  local opaquePixels = 0
  for y=0,H-1 do
    for x=0,W-1 do
      local raw = image:getPixel(x, y)
      local alpha = pc.rgbaA(raw)
      assert(alpha == 0 or alpha == 255,
        string.format("Alpha parcial na pose-base em (%d,%d)", x, y))
      if alpha == 255 then
        assert(paletteSet[colorKey(raw)],
          string.format("Cor fora da paleta de 27 cores na pose-base em (%d,%d)", x, y))
        opaquePixels = opaquePixels + 1
      end
    end
  end
  assert(opaquePixels > 0, "A pose-base ficou vazia")
  return opaquePixels
end

local basePixelCount = validateSourcePixels(baseImage)

-- Máscaras acompanham as áreas já usadas pela caminhada. O centro do torso e
-- da cintura permanece como uma peça contínua; pivôs de ombro/quadril ficam fixos.
local arms = {
  left = {x1=20, x2=24, y1=36, y2=45},
  right = {x1=39, x2=43, y1=36, y2=45},
}
local legs = {
  left = {x1=20, x2=30, y1=47, y2=56},
  right = {x1=33, x2=43, y1=47, y2=56},
}

local function inBox(box, x, y)
  return x >= box.x1 and x <= box.x2 and y >= box.y1 and y <= box.y2
end

local function isLimbPixel(x, y)
  for _, box in pairs(arms) do
    if inBox(box, x, y) then return true end
  end
  for _, box in pairs(legs) do
    if inBox(box, x, y) then return true end
  end
  return false
end

local function rowLean(lean, y)
  local topY, hipY = 7, 46
  local amount = math.max(0, math.min(1, (hipY - y) / (hipY - topY)))
  return math.floor(lean * amount + 0.5)
end

local function armBackAtY(amount, y)
  if y <= 38 then return 0 end
  local amountAlongArm = math.max(0, math.min(1, (y - 38) / (45 - 38)))
  return math.floor(amount * amountAlongArm + 0.5)
end

local function drawMappedPixel(target, x, y, dx, dy, raw)
  if pc.rgbaA(raw) == 0 then return end
  assert(pc.rgbaA(raw) == 255,
    string.format("Alpha parcial no sprite transformado em (%d,%d)", x, y))
  local nx, ny = x + dx, y + dy
  assert(nx >= 0 and nx < W and ny >= 0 and ny < H,
    string.format("A pose dash sairia do canvas em (%d,%d)", nx, ny))
  target:drawPixel(nx, ny, raw)
end

local function drawCore(target, pose)
  for y=0,H-1 do
    for x=0,W-1 do
      local raw = baseImage:getPixel(x, y)
      if pc.rgbaA(raw) > 0 and not isLimbPixel(x, y) then
        local headDrop = (pose.head_drop == 1 and y <= 29) and 1 or 0
        drawMappedPixel(target, x, y, rowLean(pose.lean, y), headDrop, raw)
      end
    end
  end
end

local function drawArm(target, side, pose)
  local mask = arms[side]
  for y=mask.y1,mask.y2 do
    for x=mask.x1,mask.x2 do
      local raw = baseImage:getPixel(x, y)
      local back = armBackAtY(pose.arm_back, y)
      drawMappedPixel(target, x, y, rowLean(pose.lean, y) - back, 0, raw)
    end
  end
end

local function drawLeg(target, side, pose)
  local mask = legs[side]
  local leg = pose[side]
  local direction = side == "left" and -1 or 1
  for y=mask.y1,mask.y2 do
    local dx, dy = 0, 0
    if y >= 49 and y <= 50 then
      dx = direction * leg.knee_dx
      dy = -leg.knee_lift
    elseif y == 51 then
      dx = direction * leg.ankle_dx
      dy = -leg.ankle_lift
    elseif y >= 52 then
      dx = direction * leg.boot_dx
      dy = -leg.foot_lift
    end
    for x=mask.x1,mask.x2 do
      local raw = baseImage:getPixel(x, y)
      drawMappedPixel(target, x, y, dx, dy, raw)
    end
  end
end

local poses = {
  {
    name = "impulso",
    duration_ms = 40,
    lean = 2,
    head_drop = 1,
    arm_back = 1,
    left = {knee_dx=1, ankle_dx=1, boot_dx=1, knee_lift=0, ankle_lift=0, foot_lift=0},
    right = {knee_dx=1, ankle_dx=2, boot_dx=2, knee_lift=0, ankle_lift=1, foot_lift=1},
  },
  {
    name = "avanco",
    duration_ms = 40,
    lean = 4,
    head_drop = 0,
    arm_back = 3,
    left = {knee_dx=1, ankle_dx=2, boot_dx=2, knee_lift=0, ankle_lift=1, foot_lift=2},
    right = {knee_dx=1, ankle_dx=2, boot_dx=2, knee_lift=0, ankle_lift=0, foot_lift=0},
  },
  {
    name = "sustentacao",
    duration_ms = 60,
    lean = 3,
    head_drop = 0,
    arm_back = 2,
    left = {knee_dx=1, ankle_dx=2, boot_dx=2, knee_lift=0, ankle_lift=1, foot_lift=1},
    right = {knee_dx=1, ankle_dx=2, boot_dx=2, knee_lift=0, ankle_lift=0, foot_lift=0},
  },
}

local function renderPose(pose)
  local image = Image(W, H)
  -- Ordem de profundidade: pernas atrás do torso; braços visíveis na frente.
  drawLeg(image, "left", pose)
  drawLeg(image, "right", pose)
  drawCore(image, pose)
  drawArm(image, "left", pose)
  drawArm(image, "right", pose)
  validateSourcePixels(image)
  return image
end

local dashImages = {}
for index, pose in ipairs(poses) do
  dashImages[index] = renderPose(pose)
end

local function imagesDiffer(a, b)
  for y=0,H-1 do
    for x=0,W-1 do
      if a:getPixel(x, y) ~= b:getPixel(x, y) then return true end
    end
  end
  return false
end
assert(imagesDiffer(dashImages[1], dashImages[2]), "As poses impulso e avanço ficaram iguais")
assert(imagesDiffer(dashImages[2], dashImages[3]), "As poses avanço e sustentação ficaram iguais")

-- A nova camada só recebe cels nos quadros adicionados. Idle/walk e suas camadas,
-- durações e tags permanecem no sprite aberto; o arquivo original não é salvo.
local dashLayer = sourceSprite:newLayer()
dashLayer.name = "Dash · pose derivada, editável"
local firstDashFrame = #sourceSprite.frames + 1
for index, pose in ipairs(poses) do
  local frameNumber = firstDashFrame + index - 1
  local frame = sourceSprite:newEmptyFrame()
  frame.duration = pose.duration_ms / 1000
  local cel = sourceSprite:newCel(dashLayer, frameNumber)
  cel.image = dashImages[index]
  cel.position = Point(0, 0)
end

-- Aseprite expande a última tag ao anexar quadros ao fim do sprite. Restaura
-- todos os intervalos originais antes de criar a tag dash para não misturar walk.
for _, original in pairs(sourceTags) do
  original.tag.fromFrame = sourceSprite.frames[original.first]
  original.tag.toFrame = sourceSprite.frames[original.last]
end

local dashTag = sourceSprite:newTag(firstDashFrame, firstDashFrame + #poses - 1)
dashTag.name = "dash"
dashTag.aniDir = AniDir.FORWARD
dashTag.repeats = 1

assert(#sourceSprite.frames == 15, "O sprite final deve conter exatamente 15 quadros")
for name, original in pairs(sourceTags) do
  assert(original.tag.fromFrame.frameNumber == original.first
      and original.tag.toFrame.frameNumber == original.last,
    string.format("O intervalo da tag original %s foi alterado", name))
end
assert(dashTag.fromFrame.frameNumber == 13 and dashTag.toFrame.frameNumber == 15,
  "A tag dash deve cobrir somente os quadros 12–14")
assert(dashTag.repeats == 1, "A tag dash deve tocar uma única vez")
for frameNumber=1,12 do
  assert(sourceSprite.frames[frameNumber].duration == originalDurations[frameNumber],
    string.format("A duração da fonte foi alterada no quadro %d", frameNumber - 1))
end

local outputPath = out(BASE .. ".aseprite")
sourceSprite:saveAs(outputPath)
app.sprite = sourceSprite

print(string.format(
  "STATUS: idle/walk preservados; dash=%d quadros (%d/%d/%d ms), paleta=27, alpha binario, canvas=64x64, tags=idle:1-6/walk:7-12/dash:13-15 uma vez",
  #poses, poses[1].duration_ms, poses[2].duration_ms, poses[3].duration_ms))
print(string.format("BASE_POSE_PIXELS: %d", basePixelCount))
print("SOURCE: " .. SOURCE_ASEPRITE)
print("ASEPRITE: " .. outputPath)
print("SHEET_EXPORT (CLI --sheet-type horizontal): " .. out(BASE .. "-spritesheet.png"))
print("SHEET_DATA (CLI --data): " .. out(BASE .. "-spritesheet.json"))
