-- Caminhada frontal v2 do protagonista, derivada do quadro 0 do idle v2 aprovado.
-- As pernas articulam por linhas de pixels, com quadris e solas ancorados.
-- Aseprite 1.3.18.6; todos os --script-param devem preceder --script.
--
-- Exemplo:
--   Aseprite.exe -b --script-param "out=<pasta>" \
--     --script-param "idle_sheet=<protagonista-idle-v2-spritesheet.png>" \
--     --script protagonista-walk.lua

local p = app.params or {}
local W, H, FRAME = 64, 64, 64
local OUT_DIR = app.fs.normalizePath(p.out or ".")
local IDLE_SHEET = app.fs.normalizePath(p.idle_sheet or
  app.fs.joinPath(OUT_DIR, "../protagonista-idle/protagonista-idle-v2-spritesheet.png"))
local BASE = p.base or "protagonista-walk-v2"
local function out(name) return app.fs.joinPath(OUT_DIR, name) end

-- Spec lock: pose frontal aprovada, 24x50px, em x=20/y=7 do frame 64x64;
-- paleta extraída da própria pose no idle v2 (27 amostras, alpha binário).
local POSE_X, POSE_Y, POSE_W, POSE_H = 20, 7, 24, 50
local paletteRGB = {
  {245,233,216}, {252,194,3}, {0,17,35}, {0,0,13}, {55,63,77},
  {46,101,176}, {1,0,14}, {207,195,183}, {0,0,16}, {0,0,15},
  {0,0,0}, {48,105,181}, {0,0,12}, {1,0,11}, {2,2,19},
  {1,1,17}, {1,1,13}, {246,236,221}, {243,177,0}, {19,49,86},
  {25,32,49}, {255,252,240}, {6,4,25}, {0,236,253}, {3,23,39},
  {26,66,118}, {137,124,118},
}

-- As janelas selecionam somente pixels opacos já existentes no sprite. Os
-- cels ficam em camadas separadas no Aseprite; não há polígonos nem cores novas.
local limbMasks = {
  left_arm  = {x1=POSE_X,    x2=POSE_X+4,  y1=POSE_Y+26, y2=POSE_Y+38},
  right_arm = {x1=POSE_X+19, x2=POSE_X+23, y1=POSE_Y+26, y2=POSE_Y+38},
  left_leg  = {x1=POSE_X,    x2=POSE_X+10, y1=POSE_Y+40, y2=POSE_Y+49},
  right_leg = {x1=POSE_X+13, x2=POSE_X+23, y1=POSE_Y+40, y2=POSE_Y+49},
}
local BOOT_START_Y = POSE_Y + 47 -- linhas y=54..56 do sprite-base

local idleDurations = {420, 140, 180, 140, 540, 80}
local walkFrames = {
  {left_arm=0, right_arm=0, left_knee=0, right_knee=0, left_ankle=0, right_ankle=0, left_foot=0, right_foot=0, left_lift=0, right_lift=0, bob=0},
  {left_arm=1, right_arm=-1,left_knee=1, right_knee=0, left_ankle=0, right_ankle=0, left_foot=0, right_foot=0, left_lift=0, right_lift=0, bob=0},
  {left_arm=1, right_arm=-1,left_knee=1, right_knee=0, left_ankle=1, right_ankle=0, left_foot=1, right_foot=0, left_lift=1, right_lift=0, bob=1},
  {left_arm=0, right_arm=0, left_knee=0, right_knee=0, left_ankle=0, right_ankle=0, left_foot=0, right_foot=0, left_lift=0, right_lift=0, bob=0},
  {left_arm=-1,right_arm=1, left_knee=0, right_knee=-1,left_ankle=0, right_ankle=0,left_foot=0, right_foot=0, left_lift=0, right_lift=0,bob=0},
  {left_arm=-1,right_arm=1, left_knee=0, right_knee=-1,left_ankle=0, right_ankle=-1,left_foot=0, right_foot=-1,left_lift=0, right_lift=1,bob=1},
}
local WALK_DURATION_MS = 100

local sourceSprite = assert(app.open(IDLE_SHEET), "Não foi possível abrir o spritesheet idle v2: " .. IDLE_SHEET)
assert(sourceSprite.width == FRAME * 6 and sourceSprite.height == FRAME,
  string.format("Spritesheet base mudou de tamanho: esperado %dx%d, recebido %dx%d",
    FRAME * 6, FRAME, sourceSprite.width, sourceSprite.height))
local sourceCel = assert(sourceSprite.cels[1], "O spritesheet base não contém cel")
local sheetImage = sourceCel.image
local baseImage = Image(W, H)
for y=0,H-1 do
  for x=0,W-1 do
    local raw = sheetImage:getPixel(x, y)
    if app.pixelColor.rgbaA(raw) > 0 then baseImage:drawPixel(x, y, raw) end
  end
end

local function contains(mask, x, y)
  return x >= mask.x1 and x <= mask.x2 and y >= mask.y1 and y <= mask.y2
end

local function inAnyMask(x, y)
  for _, mask in pairs(limbMasks) do
    if contains(mask, x, y) then return true end
  end
  return false
end

local function extractMask(mask)
  local img = Image(W, H)
  for y=mask.y1,mask.y2 do
    for x=mask.x1,mask.x2 do
      local raw = baseImage:getPixel(x, y)
      if app.pixelColor.rgbaA(raw) > 0 then img:drawPixel(x, y, raw) end
    end
  end
  return img
end

local function makeBody()
  local img = Image(W, H)
  for y=0,H-1 do
    for x=0,W-1 do
      local raw = baseImage:getPixel(x, y)
      if app.pixelColor.rgbaA(raw) > 0 and not inAnyMask(x, y) then
        img:drawPixel(x, y, raw)
      end
    end
  end
  return img
end

-- Faixa real da junção da cintura (linha 46) fica fixa durante o bob.
-- Ela usa os próprios pixels da arte-base como ponte para as pernas.
local function makeJointBridge()
  local img = Image(W, H)
  local y = POSE_Y + 39
  for x=0,W-1 do
    local raw = baseImage:getPixel(x, y)
    if app.pixelColor.rgbaA(raw) > 0 and not inAnyMask(x, y) then
      img:drawPixel(x, y, raw)
    end
  end
  return img
end

local function translate(src, dx, dy)
  local img = Image(W, H)
  for y=0,H-1 do
    for x=0,W-1 do
      local raw = src:getPixel(x, y)
      local nx, ny = x + dx, y + dy
      if app.pixelColor.rgbaA(raw) > 0 and nx >= 0 and nx < W and ny >= 0 and ny < H then
        img:drawPixel(nx, ny, raw)
      end
    end
  end
  return img
end

-- Os quadris não se movem. Joelho e tornozelo articulam por linhas; nos dois
-- quadros de passagem, toda a máscara da bota sobe 1px e sobrepõe o tornozelo
-- na linha de junção, mantendo a perna ligada sem criar uma ponte adicional.
local function articulateLeg(src, mask, kneeDx, ankleDx, footDx, footLift)
  local img = Image(W, H)
  for y=mask.y1,mask.y2 do
    local localY = y - mask.y1
    local isBoot = y >= BOOT_START_Y
    local dx = isBoot and footDx or (localY >= 4 and localY <= 5 and kneeDx or
      (localY >= 6 and ankleDx or 0))
    local ny = y - (isBoot and footLift or 0)
    for x=mask.x1,mask.x2 do
      local raw = src:getPixel(x, y)
      local nx = x + dx
      if app.pixelColor.rgbaA(raw) > 0 and nx >= 0 and nx < W and ny >= 0 and ny < H then
        img:drawPixel(nx, ny, raw)
      end
    end
  end
  return img
end

local bodyImage = makeBody()
local jointBridgeImage = makeJointBridge()
local armImages = {
  left_arm=extractMask(limbMasks.left_arm),
  right_arm=extractMask(limbMasks.right_arm),
}
local legImages = {
  left_leg=extractMask(limbMasks.left_leg),
  right_leg=extractMask(limbMasks.right_leg),
}

-- O quadro 0 de caminhada é reconstruído sem deslocamento. Falhe em vez de
-- exportar se qualquer pixel do quadro aprovado tiver sido perdido ou alterado.
local reconstructed = bodyImage:clone()
for _, key in ipairs({"left_arm", "right_arm", "left_leg", "right_leg"}) do
  reconstructed:drawImage(key:match("arm") and armImages[key] or legImages[key], 0, 0)
end
for y=0,H-1 do
  for x=0,W-1 do
    assert(reconstructed:getPixel(x, y) == baseImage:getPixel(x, y),
      string.format("A máscara não reconstrói o quadro aprovado em (%d,%d)", x, y))
  end
end

local sprite = Sprite(W, H)
while #sprite.layers > 1 do sprite:deleteLayer(sprite.layers[#sprite.layers]) end
local bodyLayer = sprite.layers[1]
bodyLayer.name = "Corpo · quadro aprovado, sem membros móveis"
local bridgeLayer = sprite:newLayer()
bridgeLayer.name = "Junção da cintura · pixels-base fixos durante o bob"
local leftArmLayer = sprite:newLayer()
leftArmLayer.name = "Braço esquerdo · máscara da arte aprovada"
local rightArmLayer = sprite:newLayer()
rightArmLayer.name = "Braço direito · máscara da arte aprovada"
local leftLegLayer = sprite:newLayer()
leftLegLayer.name = "Perna esquerda · quadril fixo, articulação por linhas"
local rightLegLayer = sprite:newLayer()
rightLegLayer.name = "Perna direita · quadril fixo, articulação por linhas"

local palette = Palette(#paletteRGB)
for i, rgb in ipairs(paletteRGB) do
  palette:setColor(i-1, Color(rgb[1], rgb[2], rgb[3]))
end
sprite:setPalette(palette)

local totalFrames = #idleDurations + #walkFrames
for frameIndex=1,totalFrames do
  local frame = (frameIndex == 1) and sprite.frames[1] or sprite:newEmptyFrame()
  local idleIndex = frameIndex
  local isIdle = frameIndex <= #idleDurations
  frame.duration = (isIdle and idleDurations[idleIndex] or WALK_DURATION_MS) / 1000

  if isIdle then
    -- Copia os seis quadros aprovados pixel por pixel do PNG de referência.
    local idleFrame = Image(W, H)
    local xOffset = (idleIndex - 1) * FRAME
    for y=0,H-1 do
      for x=0,W-1 do
        local raw = sheetImage:getPixel(x + xOffset, y)
        if app.pixelColor.rgbaA(raw) > 0 then idleFrame:drawPixel(x, y, raw) end
      end
    end
    local cel = sprite:newCel(bodyLayer, frameIndex)
    cel.image = idleFrame
    cel.position = Point(0, 0)
  else
    local step = walkFrames[frameIndex - #idleDurations]
    local bodyCel = sprite:newCel(bodyLayer, frameIndex)
    bodyCel.image = bodyImage
    bodyCel.position = Point(0, -step.bob)

    if step.bob > 0 then
      local bridgeCel = sprite:newCel(bridgeLayer, frameIndex)
      bridgeCel.image = jointBridgeImage
      bridgeCel.position = Point(0, 0)
    end

    local leftArmCel = sprite:newCel(leftArmLayer, frameIndex)
    leftArmCel.image = translate(armImages.left_arm, step.left_arm, -step.bob)
    local rightArmCel = sprite:newCel(rightArmLayer, frameIndex)
    rightArmCel.image = translate(armImages.right_arm, step.right_arm, -step.bob)
    local leftLegCel = sprite:newCel(leftLegLayer, frameIndex)
    leftLegCel.image = articulateLeg(legImages.left_leg, limbMasks.left_leg,
      step.left_knee, step.left_ankle, step.left_foot, step.left_lift)
    local rightLegCel = sprite:newCel(rightLegLayer, frameIndex)
    rightLegCel.image = articulateLeg(legImages.right_leg, limbMasks.right_leg,
      step.right_knee, step.right_ankle, step.right_foot, step.right_lift)
  end
end

local idleTag = sprite:newTag(1, #idleDurations)
idleTag.name = "idle"
idleTag.aniDir = AniDir.FORWARD
local walkTag = sprite:newTag(#idleDurations + 1, totalFrames)
walkTag.name = "walk"
walkTag.aniDir = AniDir.FORWARD

local asepritePath = out(BASE .. ".aseprite")
sprite:saveAs(asepritePath)

local metadataPath = out("protagonista-walk-metadata.json")
local meta = assert(io.open(metadataPath, "wb"), "Não foi possível criar metadata: " .. metadataPath)
meta:write(string.format('{\n  "asset": "protagonista",\n  "revision": "walk v2 — pernas articuladas",\n  "source_animation": "idle v2 aprovado",\n  "source_sheet": "%s",\n', IDLE_SHEET:gsub("\\", "/")))
meta:write(string.format('  "canvas": {"width": %d, "height": %d},\n', W, H))
meta:write(string.format('  "native_pose_box": {"x": %d, "y": %d, "width": %d, "height": %d},\n', POSE_X, POSE_Y, POSE_W, POSE_H))
meta:write(string.format('  "palette_colors": 27,\n  "idle_frames": [420, 140, 180, 140, 540, 80],\n  "walk_frame_duration_ms": 100,\n  "walk_frames": 6,\n  "walk_loop_duration_ms": 600,\n  "max_upper_body_bob_px": 1,\n  "bob_frames_walk_relative_zero_based": [2, 5],\n  "max_hip_lateral_offset_px": 0,\n  "max_knee_lateral_offset_px": 1,\n  "max_ankle_lateral_offset_px": 1,\n  "max_foot_lateral_offset_px": 1,\n  "alternating_foot_lift_px": 1,\n  "swing_boot_start_y": %d,\n  "swing_frames_walk_relative_zero_based": {"left": 2, "right": 5},\n  "ground_contact": "the opposite stance foot remains at its base contact while one entire boot lifts 1px",\n  "leg_articulation": "hip anchored; knee/ankle bend by at most 1px; boot moves as a connected piece",\n  "horizontal_facing": "mirror AnimatedSprite2D.flip_h",\n  "animation_tags": {"idle": {"first_frame": 0, "last_frame": 5}, "walk": {"first_frame": 6, "last_frame": 11}},\n', BOOT_START_Y))
meta:write('  "mask_regions": {\n')
local maskOrder = {"left_arm", "right_arm", "left_leg", "right_leg"}
for i, key in ipairs(maskOrder) do
  local mask = limbMasks[key]
  meta:write(string.format('    "%s": {"x1": %d, "y1": %d, "x2": %d, "y2": %d}%s\n',
    key, mask.x1, mask.y1, mask.x2, mask.y2, i < #maskOrder and "," or ""))
end
meta:write('  },\n  "collision_or_gameplay_changes": false,\n  "generated_layout": "12 frames, 64x64 each, horizontal sheet"\n}\n')
meta:close()

print(string.format("STATUS: exact base preserved; idle=%d frames; walk=%d frames at 10fps; hips fixed; alternating boot lift=1px; leg shifts<=1px; bob<=1px; palette=27; tags=%s/%s",
  #idleDurations, #walkFrames, idleTag.name, walkTag.name))
print("ASEPRITE: " .. asepritePath)
print("METADATA: " .. metadataPath)
print("SHEET: " .. out(BASE .. "-spritesheet.png"))
