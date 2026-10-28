-- Pixel art door wall panel, hand-authored in Aseprite Lua.
-- Closed and Open are adjacent 160x80 modules in a 320x80 runtime sheet.
local p = app.params or {}
local root = p.root or "C:/Users/danie/Documents/ChatGPT/TEC - Jogos/projeto-jogos-digitais"
local out = p.out or (root .. "/assets/environment/factory_v1/door/porta-fabrica-horizontal-v2")
local atlasPath = root .. "/assets/environment/factory_v1/tileset-fabrica-v1-atlas.png"
local playerPath = root .. "/assets/player/player-animations.png"

local pc = app.pixelColor
local PALETTE_HEX = {
  "0E0D0E", "1D1B1A", "302D2A", "433E39", "5B5249",
  "756957", "90816A", "BAAA8B", "D3C3A7", "E7CFAD",
  "4A2D21", "563829", "70432C", "925A36", "B37949",
  "C68D58", "8F7059", "A68266", "B78342", "D2A75C"
}
local function rgba(hex)
  return pc.rgba(tonumber(hex:sub(1, 2), 16), tonumber(hex:sub(3, 4), 16), tonumber(hex:sub(5, 6), 16), 255)
end
local C = {
  outline = rgba(PALETTE_HEX[1]),
  shadow = rgba(PALETTE_HEX[2]),
  deep = rgba(PALETTE_HEX[3]),
  wall = rgba(PALETTE_HEX[4]),
  steel_dark = rgba(PALETTE_HEX[5]),
  steel = rgba(PALETTE_HEX[6]),
  steel_light = rgba(PALETTE_HEX[7]),
  steel_high = rgba(PALETTE_HEX[8]),
  cream = rgba(PALETTE_HEX[9]),
  cream_high = rgba(PALETTE_HEX[10]),
  rust_dark = rgba(PALETTE_HEX[11]),
  rust = rgba(PALETTE_HEX[12]),
  copper_dark = rgba(PALETTE_HEX[13]),
  copper = rgba(PALETTE_HEX[14]),
  copper_light = rgba(PALETTE_HEX[15]),
  copper_high = rgba(PALETTE_HEX[16]),
  muted_copper = rgba(PALETTE_HEX[17]),
  copper_mid = rgba(PALETTE_HEX[18]),
  amber = rgba(PALETTE_HEX[19]),
  amber_light = rgba(PALETTE_HEX[20])
}

local function rect(img, x, y, w, h, color)
  for py = y, y + h - 1 do
    for px = x, x + w - 1 do
      if px >= 0 and py >= 0 and px < img.width and py < img.height then
        img:drawPixel(px, py, color)
      end
    end
  end
end

local function rivet(img, x, y, bright)
  rect(img, x - 1, y - 1, 3, 3, C.outline)
  rect(img, x, y, 1, 1, bright or C.steel_light)
  if x > 0 then rect(img, x - 1, y, 1, 1, C.steel_dark) end
end

local function drawWallBase(img, ox)
  -- Opaque wall plate ties into the existing warm steel wall, with seams rather than a floating box outline.
  rect(img, ox, 0, 160, 80, C.wall)
  rect(img, ox, 0, 160, 4, C.steel_dark)
  rect(img, ox, 0, 160, 1, C.steel_light)
  rect(img, ox, 4, 160, 3, C.deep)
  rect(img, ox, 73, 160, 7, C.steel_dark)
  rect(img, ox, 74, 160, 1, C.steel_light)
  rect(img, ox, 79, 160, 1, C.outline)

  -- Segmented wall plates and side seams carry the same riveted construction around the recess.
  rect(img, ox + 2, 8, 12, 64, C.steel_dark)
  rect(img, ox + 3, 9, 1, 62, C.steel_light)
  rect(img, ox + 144, 8, 14, 64, C.deep)
  rect(img, ox + 145, 9, 1, 62, C.steel)
  rect(img, ox + 9, 8, 6, 64, C.wall)
  rect(img, ox + 144, 8, 6, 64, C.wall)
  rect(img, ox + 8, 26, 8, 1, C.shadow)
  rect(img, ox + 144, 51, 8, 1, C.shadow)
  rect(img, ox + 8, 52, 8, 1, C.steel_light)
  rect(img, ox + 144, 25, 8, 1, C.steel_dark)

  -- Copper service rails are inset into the wall margins.
  rect(img, ox + 5, 12, 3, 56, C.outline)
  rect(img, ox + 6, 13, 1, 54, C.copper_dark)
  rect(img, ox + 7, 13, 1, 54, C.copper)
  rect(img, ox + 151, 14, 3, 50, C.outline)
  rect(img, ox + 152, 15, 1, 48, C.copper_dark)
  rect(img, ox + 153, 15, 1, 48, C.copper_light)
  rect(img, ox + 4, 24, 5, 4, C.steel_dark)
  rect(img, ox + 151, 48, 5, 4, C.steel_dark)
  rivet(img, ox + 6, 26, C.steel_light)
  rivet(img, ox + 153, 50, C.steel_light)

  -- Wall panel studs are sparse and deliberately offset.
  rivet(img, ox + 18, 3, C.steel_light)
  rivet(img, ox + 51, 3, C.copper_light)
  rivet(img, ox + 107, 3, C.steel_light)
  rivet(img, ox + 140, 3, C.copper_light)
  rivet(img, ox + 20, 76, C.steel_light)
  rivet(img, ox + 72, 76, C.copper_light)
  rivet(img, ox + 138, 76, C.steel_light)

  -- Recessed portal: fixed frame, open throat (48 px), and an integrated telescoping pocket.
  rect(img, ox + 16, 8, 128, 64, C.outline)
  rect(img, ox + 17, 9, 126, 62, C.deep)
  rect(img, ox + 18, 10, 124, 6, C.steel)
  rect(img, ox + 18, 10, 124, 1, C.steel_high)
  rect(img, ox + 18, 15, 124, 1, C.outline)
  rect(img, ox + 18, 16, 7, 48, C.steel_dark)
  rect(img, ox + 18, 16, 1, 48, C.steel_high)
  rect(img, ox + 135, 16, 7, 48, C.steel_dark)
  rect(img, ox + 141, 16, 1, 48, C.outline)
  rect(img, ox + 18, 64, 124, 7, C.steel_dark)
  rect(img, ox + 18, 64, 124, 1, C.steel_light)
  rect(img, ox + 18, 70, 124, 1, C.outline)

  -- Corner gussets, short copper fasteners, and the small amber indicator on the sensor-facing jamb.
  rect(img, ox + 19, 11, 5, 4, C.copper_dark)
  rect(img, ox + 20, 11, 3, 1, C.copper_light)
  rect(img, ox + 136, 11, 5, 4, C.copper_dark)
  rect(img, ox + 137, 11, 3, 1, C.copper_light)
  rect(img, ox + 19, 66, 5, 3, C.copper_dark)
  rect(img, ox + 20, 66, 3, 1, C.copper_light)
  rect(img, ox + 136, 66, 5, 3, C.copper_dark)
  rect(img, ox + 137, 66, 3, 1, C.copper_light)
  rivet(img, ox + 21, 13, C.cream)
  rivet(img, ox + 138, 13, C.cream)
  rivet(img, ox + 21, 67, C.cream)
  rivet(img, ox + 138, 67, C.cream)
  rect(img, ox + 137, 26, 6, 13, C.outline)
  rect(img, ox + 138, 27, 4, 11, C.steel)
  rect(img, ox + 139, 29, 2, 5, C.amber)
  rect(img, ox + 139, 29, 1, 2, C.amber_light)

  -- Dark, stepped throat and channel. Open aperture is y=16..63: exactly 48 native pixels.
  rect(img, ox + 24, 16, 111, 48, C.shadow)
  rect(img, ox + 26, 16, 84, 48, C.outline)
  rect(img, ox + 28, 16, 80, 48, C.outline)
  rect(img, ox + 110, 16, 25, 48, C.shadow)
  rect(img, ox + 111, 17, 1, 46, C.outline)
  rect(img, ox + 133, 17, 1, 46, C.steel)
  rect(img, ox + 110, 16, 25, 1, C.steel_light)
  rect(img, ox + 110, 63, 25, 1, C.outline)
  rect(img, ox + 25, 17, 1, 46, C.steel_high)
end

local function drawClosedLeaf(img, ox)
  -- Door leaf is broad and horizontally articulated; it closes both the opening and pocket.
  rect(img, ox + 24, 16, 111, 48, C.deep)
  rect(img, ox + 26, 17, 107, 46, C.steel_dark)
  rect(img, ox + 27, 18, 105, 44, C.wall)
  rect(img, ox + 27, 18, 105, 2, C.steel)
  rect(img, ox + 27, 61, 105, 2, C.deep)
  rect(img, ox + 28, 20, 2, 41, C.steel_dark)
  rect(img, ox + 130, 20, 2, 41, C.shadow)

  for row = 0, 5 do
    local y = 20 + row * 7
    rect(img, ox + 30, y, 99, 1, row == 0 and C.steel_high or C.steel)
    rect(img, ox + 30, y + 1, 99, 4, row % 2 == 0 and C.steel_dark or C.wall)
    rect(img, ox + 30, y + 5, 99, 1, C.deep)
  end
  rect(img, ox + 75, 21, 1, 39, C.shadow)
  rect(img, ox + 77, 21, 1, 39, C.steel)
  for row = 0, 5 do
    local y = 22 + row * 7
    rivet(img, ox + 34, y, C.steel_light)
    rivet(img, ox + 125, y, C.copper_light)
  end
  rect(img, ox + 27, 25, 2, 9, C.copper_dark)
  rect(img, ox + 28, 26, 1, 6, C.copper)
  rect(img, ox + 27, 44, 2, 9, C.copper_dark)
  rect(img, ox + 28, 45, 1, 6, C.copper)
end

local function drawOpenPocket(img, ox)
  -- The full aperture stays empty; nested slats collect inside the purpose-built jamb pocket.
  rect(img, ox + 28, 16, 80, 48, C.outline)
  rect(img, ox + 110, 16, 25, 48, C.outline)
  rect(img, ox + 112, 18, 21, 44, C.shadow)
  rect(img, ox + 112, 18, 1, 44, C.steel_light)
  rect(img, ox + 132, 18, 1, 44, C.steel)

  -- Telescoping door sections collapse into the 23 px native pocket, not the 16 px outer margin.
  rect(img, ox + 113, 22, 4, 36, C.deep)
  rect(img, ox + 114, 23, 1, 34, C.steel_light)
  rect(img, ox + 118, 20, 4, 40, C.steel_dark)
  rect(img, ox + 119, 21, 1, 38, C.steel)
  rect(img, ox + 123, 24, 4, 32, C.wall)
  rect(img, ox + 124, 25, 1, 30, C.steel_light)
  rect(img, ox + 128, 27, 3, 26, C.steel_dark)
  rect(img, ox + 129, 28, 1, 24, C.steel_light)
  rect(img, ox + 114, 31, 16, 2, C.deep)
  rect(img, ox + 114, 46, 16, 2, C.deep)
  rect(img, ox + 115, 32, 13, 1, C.copper_dark)
  rect(img, ox + 115, 47, 13, 1, C.copper_dark)
  rivet(img, ox + 116, 26, C.copper_light)
  rivet(img, ox + 126, 51, C.steel_light)
end

local function nearestScale(src, scale)
  local dst = Image(src.width * scale, src.height * scale)
  for y = 0, src.height - 1 do
    for x = 0, src.width - 1 do
      local v = src:getPixel(x, y)
      for dy = 0, scale - 1 do
        for dx = 0, scale - 1 do
          dst:drawPixel(x * scale + dx, y * scale + dy, v)
        end
      end
    end
  end
  return dst
end

local function extract(src, sx, sy, w, h)
  local dst = Image(w, h)
  for y = 0, h - 1 do
    for x = 0, w - 1 do
      dst:drawPixel(x, y, src:getPixel(sx + x, sy + y))
    end
  end
  return dst
end

local function flipHorizontal(src)
  local dst = Image(src.width, src.height)
  for y = 0, src.height - 1 do
    for x = 0, src.width - 1 do
      dst:drawPixel(src.width - 1 - x, y, src:getPixel(x, y))
    end
  end
  return dst
end

local function createSprite(base, closed, open)
  local sprite = Sprite(320, 80)
  while #sprite.layers > 1 do sprite:deleteLayer(sprite.layers[#sprite.layers]) end
  local wall = sprite.layers[1]
  wall.name = "Wall panel and fixed door frame"
  sprite:newCel(wall, 1).image = base
  local closedLayer = sprite:newLayer()
  closedLayer.name = "Closed leaf"
  sprite:newCel(closedLayer, 1).image = closed
  local openLayer = sprite:newLayer()
  openLayer.name = "Open leaf and telescoping pocket"
  sprite:newCel(openLayer, 1).image = open

  local ok, palette = pcall(function()
    local pal = Palette(#PALETTE_HEX)
    for i, hex in ipairs(PALETTE_HEX) do
      local c = Color(tonumber(hex:sub(1, 2), 16), tonumber(hex:sub(3, 4), 16), tonumber(hex:sub(5, 6), 16), 255)
      pal:setColor(i - 1, c)
    end
    return pal
  end)
  if ok then pcall(function() sprite.palette = palette end) end
  return sprite
end

local function glyph(img, x, y, pattern, color, scale)
  for py, row in ipairs(pattern) do
    for px = 1, #row do
      if row:sub(px, px) == "1" then rect(img, x + (px - 1) * scale, y + (py - 1) * scale, scale, scale, color) end
    end
  end
end
local FONT = {
  A={"010","101","111","101","101"}, B={"110","101","110","101","110"}, C={"011","100","100","100","011"},
  D={"110","101","101","101","110"}, E={"111","100","110","100","111"}, G={"011","100","101","101","011"},
  H={"101","101","111","101","101"}, I={"111","010","010","010","111"}, L={"100","100","100","100","111"},
  M={"101","111","111","101","101"}, N={"101","111","111","111","101"}, O={"010","101","101","101","010"},
  P={"110","101","110","100","100"}, R={"110","101","110","101","101"}, S={"011","100","010","001","110"},
  T={"111","010","010","010","010"}, U={"101","101","101","101","111"}, Y={"101","101","010","010","010"},
  ["-"]={"000","000","111","000","000"}, [" "]={"000","000","000","000","000"}
}
local function drawText(img, x, y, text, color, scale)
  local cursor = x
  for i = 1, #text do
    local ch = text:sub(i, i)
    local pat = FONT[ch] or FONT[" "]
    glyph(img, cursor, y, pat, color, scale)
    cursor = cursor + 4 * scale
  end
end

local function drawSceneRow(dst, y0, closedFrame, openFrame, atlas, playerFrame)
  local sceneH = 224
  rect(dst, 0, y0, 1152, sceneH, rgba("15110E"))

  -- Place wall modules behind side-wall strips, as z=-2 in the scenes.
  local closed2
  local open2
  if closedFrame ~= nil then closed2 = nearestScale(closedFrame, 2) end
  if openFrame ~= nil then open2 = nearestScale(openFrame, 2) end
  local leftClosed = closed2 and flipHorizontal(closed2) or nil
  local leftOpen = open2 and flipHorizontal(open2) or nil
  local leftState = closedFrame == nil and leftOpen or leftClosed
  local rightState = openFrame == nil and closed2 or open2
  dst:drawImage(leftState, 32, y0 + 40)
  dst:drawImage(rightState, 800, y0 + 40)

  -- Existing atlas wall visuals: regions (0,1) and (2,1), each drawn at 2x and flipped.
  local leftWall = flipHorizontal(nearestScale(extract(atlas, 0, 32, 32, 32), 2))
  local rightWall = flipHorizontal(nearestScale(extract(atlas, 64, 32, 32, 32), 2))
  for _, globalY in ipairs({384, 448, 512, 576}) do
    dst:drawImage(leftWall, 0, y0 + globalY - 376)
    dst:drawImage(rightWall, 1088, y0 + globalY - 376)
  end

  -- Existing factory block top from atlas row 0 repeated across the actual y=560 floor line.
  for x = 0, 1087, 64 do
    local tileCol = (x == 0) and 0 or 1
    dst:drawImage(nearestScale(extract(atlas, tileCol * 32, 0, 32, 32), 2), x, y0 + 184)
  end
  dst:drawImage(nearestScale(extract(atlas, 64, 0, 32, 32), 2), 1088, y0 + 184)

  -- Current idle frame at the scene scale/offset, in front of wall and door.
  local player2 = nearestScale(playerFrame, 2)
  dst:drawImage(player2, 920, y0 + 70)
end

local wall = Image(320, 80)
local closed = Image(320, 80)
local open = Image(320, 80)
drawWallBase(wall, 0)
drawWallBase(wall, 160)
drawClosedLeaf(closed, 0)
drawOpenPocket(open, 160)

local sheet = wall:clone()
sheet:drawImage(closed, 0, 0)
sheet:drawImage(open, 0, 0)
local sprite = createSprite(wall, closed, open)
sprite:saveAs(out .. ".aseprite")
sprite:saveCopyAs(out .. ".png")
nearestScale(sheet, 4):saveAs(out .. "-preview-4x.png")

local atlas = Image{fromFile = atlasPath}
local playerAtlas = Image{fromFile = playerPath}
local playerFrame = extract(playerAtlas, 0, 0, 64, 64)
local closedFrame = extract(sheet, 0, 0, 160, 80)
local openFrame = extract(sheet, 160, 0, 160, 80)
local board = Image(1152, 492)
rect(board, 0, 0, 1152, 492, C.deep)
rect(board, 0, 0, 1152, 18, C.deep)
drawText(board, 16, 4, "BOTH ENDS CLOSED", C.cream, 2)
drawSceneRow(board, 18, closedFrame, nil, atlas, playerFrame)
rect(board, 0, 246, 1152, 18, C.deep)
drawText(board, 16, 250, "OPEN SAMPLE - GAME ENTRY STAYS CLOSED", C.cream, 2)
drawSceneRow(board, 268, nil, openFrame, atlas, playerFrame)
board:saveAs(out .. "-montagem-estatica.png")
print("Aseprite asset, PNG, 4x preview, and static montage saved from the same pixel-art source.")