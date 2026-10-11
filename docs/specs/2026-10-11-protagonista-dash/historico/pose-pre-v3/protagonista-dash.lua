-- Acrescenta três desenhos laterais de dash à fonte aprovada walk v3.
-- Idle/walk permanecem intactos; os novos quadros são arte pixel a pixel em
-- perfil +X, sem cisalhar, girar ou reutilizar a pose frontal.
-- Aseprite 1.3.18.6; passe --script-param antes de --script.

local p = app.params or {}
local W, H = 64, 64
local OUT_DIR = app.fs.normalizePath(p.out or ".")
local SOURCE_ASEPRITE = app.fs.normalizePath(p.source_aseprite or
  app.fs.joinPath(OUT_DIR, "../protagonista-walk/protagonista-walk-v3.aseprite"))
local BASE = p.base or "protagonista-dash-v2"
local function out(name) return app.fs.joinPath(OUT_DIR, name) end

local paletteRGB = {
  {245,233,216}, {252,194,3}, {0,17,35}, {0,0,13}, {55,63,77},
  {46,101,176}, {1,0,14}, {207,195,183}, {0,0,16}, {0,0,15},
  {0,0,0}, {48,105,181}, {0,0,12}, {1,0,11}, {2,2,19},
  {1,1,17}, {1,1,13}, {246,236,221}, {243,177,0}, {19,49,86},
  {25,32,49}, {255,252,240}, {6,4,25}, {0,236,253}, {3,23,39},
  {26,66,118}, {137,124,118},
}
assert(#paletteRGB == 27, "A paleta aprovada deve conter 27 cores")
local paletteSet = {}
for _, rgb in ipairs(paletteRGB) do
  paletteSet[string.format("%02X%02X%02X", rgb[1], rgb[2], rgb[3])] = true
end

local sourceSprite = assert(app.open(SOURCE_ASEPRITE),
  "Não foi possível abrir a fonte walk v3: " .. SOURCE_ASEPRITE)
assert(sourceSprite.width == W and sourceSprite.height == H,
  string.format("Canvas esperado 64x64, recebido %dx%d", sourceSprite.width, sourceSprite.height))
assert(#sourceSprite.frames == 12, "A fonte walk v3 deve conter os 12 quadros aprovados")
assert(sourceSprite.colorMode == ColorMode.RGB, "A fonte deve continuar em modo RGB/RGBA")
local sourceTags = {}
for _, tag in ipairs(sourceSprite.tags) do
  sourceTags[tag.name] = {tag=tag, first=tag.fromFrame.frameNumber, last=tag.toFrame.frameNumber}
end
assert(sourceTags.idle and sourceTags.idle.first == 1 and sourceTags.idle.last == 6,
  "A tag idle deve permanecer nos quadros 0–5")
assert(sourceTags.walk and sourceTags.walk.first == 7 and sourceTags.walk.last == 12,
  "A tag walk deve permanecer nos quadros 6–11")
assert(sourceTags.dash == nil, "A fonte já contém uma tag dash")
local originalDurations = {}
for i, frame in ipairs(sourceSprite.frames) do originalDurations[i] = frame.duration end
local expectedIdleMs = {420, 140, 180, 140, 540, 80}
for i, duration in ipairs(expectedIdleMs) do
  assert(math.abs(originalDurations[i] - duration / 1000) < 0.001,
    string.format("Duração do idle mudou no quadro %d", i - 1))
end
for i = 7, 12 do
  assert(math.abs(originalDurations[i] - 0.1) < 0.001,
    string.format("Duração da caminhada mudou no quadro %d", i - 1))
end

local pc = app.pixelColor
local colors = {
  o=Color(0,17,35), D=Color(25,32,49), N=Color(19,49,86),
  B=Color(48,105,181), b=Color(26,66,118),
  Y=Color(252,194,3), y=Color(243,177,0),
  h=Color(245,233,216), H=Color(255,252,240),
  s=Color(207,195,183), S=Color(207,195,183), c=Color(0,236,253),
  k=Color(6,4,25), g=Color(55,63,77),
}
local function colorKey(raw)
  return string.format("%02X%02X%02X", pc.rgbaR(raw), pc.rgbaG(raw), pc.rgbaB(raw))
end
local function put(image, x, y, color)
  assert(x >= 0 and x < W and y >= 0 and y < H,
    string.format("Pixel fora do canvas em (%d,%d)", x, y))
  image:drawPixel(x, y, color)
end
local function drawRows(image, x0, y0, rows)
  for ry, row in ipairs(rows) do
    for rx = 1, #row do
      local symbol = row:sub(rx, rx)
      if symbol ~= "." then
        put(image, x0 + rx - 1, y0 + ry - 1,
          assert(colors[symbol], "Símbolo sem cor na grade: " .. symbol))
      end
    end
  end
end
local function drawRect(image, x1, y1, x2, y2, color)
  for y = y1, y2 do for x = x1, x2 do put(image, x, y, color) end end
end

-- Bresenham em grade inteira; os traços grossos articulam membros sem rotação.
local function drawLine(image, x1, y1, x2, y2, radius, symbol, yOffset)
  local dx, dy = math.abs(x2 - x1), math.abs(y2 - y1)
  local sx, sy = x1 < x2 and 1 or -1, y1 < y2 and 1 or -1
  local err, x, y = dx - dy, x1, y1
  while true do
    for oy = -radius, radius do
      for ox = -radius, radius do
        put(image, x + ox, y + oy + (yOffset or 0), colors[symbol])
      end
    end
    if x == x2 and y == y2 then break end
    local twice = 2 * err
    if twice > -dy then err = err - dy; x = x + sx end
    if twice < dx then err = err + dx; y = y + sy end
  end
end
local function drawPolyline(image, points, radius, symbol, yOffset)
  for i = 1, #points - 1 do
    drawLine(image, points[i][1], points[i][2], points[i+1][1],
      points[i+1][2], radius, symbol, yOffset)
  end
end
local function drawStroke(image, points, fillSymbol)
  drawPolyline(image, points, 3, "o", 0)
  drawPolyline(image, points, 2, fillSymbol, 0)
  drawPolyline(image, points, 0, "B", -1)
end

local bootRows = {
  "....oooo....",
  "..ooYYYYoo..",
  ".oYBBBBBBo..",
  "oYBBBBBBBBBo",
  ".oBBBBBBBBBo.",
  "oNNNNNNNNNo.",
  ".oDDDDDDDo..",
}
local helmetRows = {
  "......ooooooo.....",
  "....ooHHHHHHHoooo.",
  "..ooHHHHHHHHHHHHhoo",
  ".oHHHHHHHHHHHHHHHHhoo",
  "oHHhHHHHHHHHHHHHHHHHoo",
  "oHHhHHHHHHHHHHHHHHHHHoo",
  "oHHhHHHHHHHHHHHHHHHHHoo",
  "oHHhHHHHHHHHHHHHHHHHHoo",
  "oHHhHHHHHHHHHHHHHHHHHoo",
  "oHHhHHHHHHHHHHHHHHHHHoo",
  ".oHHHHHHHHHHHHHHHHHHhoo",
  "..ooHHHHHHHHHHHHHHHoo.",
  "...oooSSSSSSSSSooo...",
  "......oooooooo......",
}
local earRows = {
  "..ooooo", ".oYYYYYo", "oYYBBBYYo", "oYYBBBYYo",
  "oYYBBBYYo", ".oYYYYYo", "..ooooo",
}
local antennaRows = {
  "..YYY..", ".YYYYY.", "..ooo..", "...o...", "...o...", "...o...",
}
local torsoRows = {
  "...........oooooo",
  ".........ooYYYYBo",
  ".......ooBBBBBBBo",
  ".....oBBBBHHBBBBo",
  "...ooBBBBHHBBBBBBo",
  "..oBBBBBBBBBBBBBBo",
  ".oBBBBBBNBBBBBBBBBo",
  "oBBBBBBBNBBBBBBBBBo",
  "oBBBBBBBNBBBBBBBBBo",
  "oBBBBBBBNBBBBBBBBBo",
  ".oBBBBBBBBBBBBBBBBo",
  "..ooBBBBBBBBBBBoo..",
  "....ooBBBBBBBBoo...",
  ".......ooBBBoo.....",
  ".........oooo......",
}
local chestRows = {
  "......ooo",
  ".....oHHHoo",
  "....oHhhhHHo",
  "...oHhhhhHHo",
  "..oHhhHHHHHo",
  ".oHHHHHHHHo.",
  "oHHHHHHHHHHo",
  ".oYYYYYYYoo.",
  "..ooYYYYoo..",
}
local gloveRows = {
  "..ooooo", ".oBBBBBo", "oBBBBBBBo", "oNNNNNNo", ".oYYYYo.", "..oooo..",
}

local poses = {
  {
    name="impulso", duration_ms=40, head={x=29,y=11}, body={x=21,y=28},
    far_arm={{37,32},{28,35},{19,35},{13,33}},
    near_arm={{38,34},{32,38},{26,39},{22,36}},
    rear_leg={{28,43},{18,47},{17,52}},
    front_leg={{32,43},{41,41},{47,47}},
    rear_boot={8,51}, front_boot={43,45},
  },
  {
    name="avanco", duration_ms=40, head={x=31,y=10}, body={x=23,y=27},
    far_arm={{39,31},{29,34},{19,33},{13,30}},
    near_arm={{40,34},{34,37},{28,37},{23,34}},
    rear_leg={{30,42},{19,45},{20,50}},
    front_leg={{34,42},{44,40},{50,46}},
    rear_boot={10,50}, front_boot={46,44},
  },
  {
    name="sustentacao", duration_ms=60, head={x=30,y=11}, body={x=22,y=28},
    far_arm={{38,32},{29,35},{20,35},{14,33}},
    near_arm={{39,35},{33,39},{27,40},{22,37}},
    rear_leg={{29,43},{18,46},{15,50}},
    front_leg={{33,43},{42,47},{47,52}},
    rear_boot={5,49}, front_boot={43,50},
  },
}

local function drawAntenna(image, head)
  drawRows(image, head.x + 8, head.y - 7, antennaRows)
end
local function drawHelmet(image, head)
  drawRows(image, head.x - 3, head.y + 5, earRows)
  drawRows(image, head.x, head.y, helmetRows)
  -- Faixa preta na face que aponta para +X, com uma única lente vertical.
  drawRect(image, head.x + 16, head.y + 4, head.x + 16, head.y + 12, colors.H)
  drawRect(image, head.x + 17, head.y + 5, head.x + 21, head.y + 11, colors.k)
  drawRect(image, head.x + 19, head.y + 7, head.x + 20, head.y + 10, colors.c)
  drawRect(image, head.x + 22, head.y + 6, head.x + 22, head.y + 10, colors.o)
end
local function drawTorso(image, body)
  -- Ombros à direita dos quadris: o tórax está projetado para a frente.
  drawRows(image, body.x, body.y, torsoRows)
  drawRows(image, body.x + 1, body.y + 4, chestRows)
  drawRect(image, body.x + 12, body.y + 2, body.x + 17, body.y + 3, colors.Y)
end
local function drawArm(image, points, gloveX, gloveY)
  drawStroke(image, points, "N")
  local wrist = points[#points]
  drawRect(image, wrist[1] - 1, wrist[2] - 1, wrist[1] + 1, wrist[2] + 1, colors.Y)
  drawRows(image, gloveX, gloveY, gloveRows)
end
local function drawLeg(image, points, boot)
  drawStroke(image, points, "N")
  local knee = points[2]
  drawRect(image, knee[1] - 2, knee[2] - 1, knee[1] + 2, knee[2] + 1, colors.B)
  drawRows(image, boot[1], boot[2], bootRows)
end

local function renderPose(pose)
  local image = Image(W, H)
  -- As juntas distantes recuam atrás do tronco; a bota próxima fica na frente.
  drawStroke(image, pose.far_arm, "N")
  drawStroke(image, pose.rear_leg, "N")
  drawAntenna(image, pose.head)
  drawTorso(image, pose.body)
  drawRect(image, pose.head.x + 9, pose.head.y + 13,
    pose.head.x + 12, pose.head.y + 16, colors.Y)
  drawRect(image, pose.head.x + 10, pose.head.y + 14,
    pose.head.x + 11, pose.head.y + 16, colors.N)
  drawLeg(image, pose.front_leg, pose.front_boot)
  local rearKnee = pose.rear_leg[2]
  drawRect(image, rearKnee[1] - 2, rearKnee[2] - 1,
    rearKnee[1] + 2, rearKnee[2] + 1, colors.N)
  drawRows(image, pose.rear_boot[1], pose.rear_boot[2], bootRows)
  drawArm(image, pose.near_arm, pose.near_arm[#pose.near_arm][1] - 5,
    pose.near_arm[#pose.near_arm][2] - 3)
  drawHelmet(image, pose.head)
  -- Luva distante está atrás do corpo; pinta-se só a extremidade visível.
  local farWrist = pose.far_arm[#pose.far_arm]
  drawRect(image, farWrist[1] - 1, farWrist[2] - 1,
    farWrist[1] + 1, farWrist[2] + 1, colors.Y)
  drawRows(image, farWrist[1] - 5, farWrist[2] - 3, gloveRows)

  local opaquePixels, cyanPixels = 0, 0
  for y = 0, H - 1 do
    for x = 0, W - 1 do
      local raw = image:getPixel(x, y)
      local alpha = pc.rgbaA(raw)
      assert(alpha == 0 or alpha == 255,
        string.format("Alpha parcial em %s (%d,%d)", pose.name, x, y))
      if alpha == 255 then
        assert(paletteSet[colorKey(raw)],
          string.format("Cor fora da paleta em %s (%d,%d)", pose.name, x, y))
        opaquePixels = opaquePixels + 1
        if pc.rgbaR(raw) == 0 and pc.rgbaG(raw) == 236
            and pc.rgbaB(raw) == 253 then cyanPixels = cyanPixels + 1 end
      end
    end
  end
  assert(opaquePixels > 0, "Pose vazia: " .. pose.name)
  assert(cyanPixels == 8,
    string.format("Perfil deve mostrar uma lente vertical única (%s)", pose.name))
  local supportY = math.max(pose.rear_boot[2], pose.front_boot[2]) + #bootRows - 1
  assert(supportY >= 56 and supportY <= 57,
    "Cada pose deve conservar um pé junto ao chão em y56/57")
  return image
end

local dashImages = {}
for i, pose in ipairs(poses) do dashImages[i] = renderPose(pose) end
local function imagesDiffer(a, b)
  for y = 0, H - 1 do
    for x = 0, W - 1 do
      if a:getPixel(x, y) ~= b:getPixel(x, y) then return true end
    end
  end
  return false
end
assert(imagesDiffer(dashImages[1], dashImages[2]), "Impulso e avanço ficaram iguais")
assert(imagesDiffer(dashImages[2], dashImages[3]), "Avanço e sustentação ficaram iguais")

local dashLayer = sourceSprite:newLayer()
dashLayer.name = "Dash · perfil lateral +X"
local firstDashFrame = #sourceSprite.frames + 1
for i, pose in ipairs(poses) do
  local frameNumber = firstDashFrame + i - 1
  local frame = sourceSprite:newEmptyFrame()
  frame.duration = pose.duration_ms / 1000
  local cel = sourceSprite:newCel(dashLayer, frameNumber)
  cel.image = dashImages[i]
  cel.position = Point(0, 0)
end

-- Aseprite expande a última tag ao anexar quadros. Restauramos idle/walk antes
-- de criar dash para impedir que walk absorva os novos frames.
for _, original in pairs(sourceTags) do
  original.tag.fromFrame = sourceSprite.frames[original.first]
  original.tag.toFrame = sourceSprite.frames[original.last]
end
local dashTag = sourceSprite:newTag(firstDashFrame, firstDashFrame + #poses - 1)
dashTag.name = "dash"
dashTag.aniDir = AniDir.FORWARD
dashTag.repeats = 1

assert(#sourceSprite.frames == 15, "O sprite deve conter 15 quadros")
for name, original in pairs(sourceTags) do
  assert(original.tag.fromFrame.frameNumber == original.first
      and original.tag.toFrame.frameNumber == original.last,
    string.format("O intervalo da tag %s foi alterado", name))
end
assert(dashTag.fromFrame.frameNumber == 13 and dashTag.toFrame.frameNumber == 15,
  "A tag dash deve cobrir somente os quadros zero-based 12–14")
assert(dashTag.repeats == 1, "A tag dash deve tocar uma vez")
for i = 1, 12 do
  assert(sourceSprite.frames[i].duration == originalDurations[i],
    string.format("A duração da fonte mudou no quadro %d", i - 1))
end
for i, pose in ipairs(poses) do
  assert(math.abs(sourceSprite.frames[12 + i].duration - pose.duration_ms / 1000) < 0.001,
    string.format("Duração incorreta no dash %s", pose.name))
end

local outputPath = out(BASE .. ".aseprite")
sourceSprite:saveAs(outputPath)
app.sprite = sourceSprite
print("STATUS: dash em perfil +X; 3 quadros 40/40/60 ms; paleta=27; alpha binário; canvas=64x64; tags idle:1-6/walk:7-12/dash:13-15")
print("SOURCE: " .. SOURCE_ASEPRITE)
print("ASEPRITE: " .. outputPath)
print("SHEET_EXPORT (CLI --sheet-type horizontal): " .. out(BASE .. "-spritesheet.png"))
print("SHEET_DATA (CLI --data): " .. out(BASE .. "-spritesheet.json"))
