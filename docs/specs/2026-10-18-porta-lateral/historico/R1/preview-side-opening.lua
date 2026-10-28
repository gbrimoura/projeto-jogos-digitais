-- Static inspection composition for the side-wall cut. It does not export runtime art.
local p = app.params or {}
local root = p.root or "C:/Users/danie/Documents/ChatGPT/TEC - Jogos/projeto-jogos-digitais"
local out = p.out or (root .. "/assets/environment/factory_v1/door/side-opening/porta-lateral-preview.png")
local atlasPath = root .. "/assets/environment/factory_v1/tileset-fabrica-v1-atlas.png"
local playerPath = root .. "/assets/player/player-animations.png"
local pc = app.pixelColor
local function rgba(hex)
  return pc.rgba(tonumber(hex:sub(1, 2), 16), tonumber(hex:sub(3, 4), 16), tonumber(hex:sub(5, 6), 16), 255)
end
local C = {
  void = rgba("0E0D0E"), depth = rgba("1D1B1A"), shadow = rgba("302D2A"),
  metalDark = rgba("5B5249"), metal = rgba("756957"), metalLight = rgba("90816A"),
  copper = rgba("70432C"), amber = rgba("B78342"), cream = rgba("D3C3A7")
}
local function rect(img, x, y, w, h, color)
  for py = y, y + h - 1 do
    for px = x, x + w - 1 do
      if px >= 0 and py >= 0 and px < img.width and py < img.height then img:drawPixel(px, py, color) end
    end
  end
end
local function extract(src, sx, sy, w, h)
  local dst = Image(w, h)
  for y = 0, h - 1 do for x = 0, w - 1 do dst:drawPixel(x, y, src:getPixel(sx + x, sy + y)) end end
  return dst
end
local function nearestScale(src, scale)
  local dst = Image(src.width * scale, src.height * scale)
  for y = 0, src.height - 1 do
    for x = 0, src.width - 1 do
      local pixel = src:getPixel(x, y)
      for dy = 0, scale - 1 do for dx = 0, scale - 1 do dst:drawPixel(x * scale + dx, y * scale + dy, pixel) end end
    end
  end
  return dst
end
local function flipHorizontal(src)
  local dst = Image(src.width, src.height)
  for y = 0, src.height - 1 do for x = 0, src.width - 1 do dst:drawPixel(src.width - 1 - x, y, src:getPixel(x, y)) end end
  return dst
end
local function makeDoor(open)
  local img = Image(64, 128)
  rect(img, 0, 0, 64, 128, C.void)
  rect(img, 2, 2, 60, 2, C.metalDark)
  rect(img, 2, 122, 60, 2, C.shadow)
  rect(img, 0, 0, 4, 128, C.shadow)
  rect(img, 60, 0, 4, 128, C.depth)
  rect(img, 4, 6, 2, 116, C.copper)
  rect(img, 58, 6, 2, 116, C.metalDark)
  for _, y in ipairs({16, 48, 80, 112}) do
    rect(img, 2, y, 2, 2, C.amber)
    rect(img, 60, y, 2, 2, C.metalLight)
  end
  if not open then
    rect(img, 10, 10, 44, 2, C.metalDark)
    rect(img, 10, 116, 44, 2, C.metalDark)
    for _, x in ipairs({12, 24, 36, 48}) do rect(img, x, 12, 2, 104, C.metal) end
    for _, y in ipairs({36, 64, 92}) do rect(img, 12, y, 38, 2, C.metalDark) end
    rect(img, 48, 60, 4, 8, C.amber)
  else
    rect(img, 8, 10, 48, 108, C.void)
    rect(img, 2, 4, 2, 120, C.metalDark)
    rect(img, 4, 6, 2, 116, C.metalLight)
  end
  return img
end
local function glyph(img, x, y, pattern, color, scale)
  for py, row in ipairs(pattern) do for px = 1, #row do if row:sub(px, px) == "1" then rect(img, x + (px - 1) * scale, y + (py - 1) * scale, scale, scale, color) end end end
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
  for i = 1, #text do glyph(img, cursor, y, FONT[text:sub(i, i)] or FONT[" "], color, scale); cursor = cursor + 4 * scale end
end
local function drawSceneRow(dst, y0, open)
  rect(dst, 0, y0, 1152, 224, C.void)
  local atlas = Image{fromFile = atlasPath}
  local leftWall = flipHorizontal(nearestScale(extract(atlas, 0, 32, 32, 32), 2))
  local rightWall = flipHorizontal(nearestScale(extract(atlas, 64, 32, 32, 32), 2))
  for _, globalY in ipairs({384, 448, 512, 576}) do
    dst:drawImage(leftWall, 0, y0 + globalY - 376)
    dst:drawImage(rightWall, 1088, y0 + globalY - 376)
  end
  -- The cut is painted as a clear through-hole over the tiled wall, at the same 64x128 geometry as runtime.
  local door = makeDoor(open)
  dst:drawImage(flipHorizontal(door), 0, y0 + 56)
  dst:drawImage(door, 1088, y0 + 56)
  for x = 0, 1087, 64 do
    local tileCol = (x == 0) and 0 or 1
    dst:drawImage(nearestScale(extract(atlas, tileCol * 32, 0, 32, 32), 2), x, y0 + 184)
  end
  dst:drawImage(nearestScale(extract(atlas, 64, 0, 32, 32), 2), 1088, y0 + 184)
  local playerAtlas = Image{fromFile = playerPath}
  dst:drawImage(nearestScale(extract(playerAtlas, 0, 0, 64, 64), 2), 920, y0 + 70)
end
local board = Image(1152, 492)
rect(board, 0, 0, 1152, 492, C.void)
rect(board, 0, 0, 1152, 18, C.depth)
drawText(board, 16, 4, "BOTH ENDS CLOSED", C.cream, 2)
drawSceneRow(board, 18, false)
rect(board, 0, 246, 1152, 18, C.depth)
drawText(board, 16, 250, "OPEN SAMPLE - GAME ENTRY STAYS CLOSED", C.cream, 2)
drawSceneRow(board, 268, true)
board:saveAs(out)
print("Static side-wall opening preview saved: " .. out)
