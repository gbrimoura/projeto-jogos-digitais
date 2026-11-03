local function main()
  local P = app.params or {}
  local PREVIEW_ONLY = string.lower(tostring(P.preview_only or "")) == "true"
  local CLEAN_FRAMES = string.lower(tostring(P.clean_frames or "")) == "true"
  local ROOT = assert(P.root, "missing root parameter")
  assert(not CLEAN_FRAMES or PREVIEW_ONLY, "clean_frames requires preview_only=true")
  local KIT = ROOT .. "/assets/ui/upgrade_cards_v1"
  local SRC, OUT, PRE = KIT .. "/source", KIT .. "/export", KIT .. "/preview"
  local PAL = ROOT .. "/assets/ui/hud_caldeira_v1/export/palette.json"
  local FONTJSON = ROOT .. "/assets/ui/hud_caldeira_v1/export/font.json"
  local FONTPNG = OUT .. "/card-font-atlas.png"
  local pc = app.pixelColor
  local PREVIEW_COLORS = nil
  local EXPECT = {
    "0E0D0E", "0C1B29", "142C40", "203E50", "353B3B", "4B555D",
    "59636B", "879198", "B6BEC3", "70432C", "925A36", "B78342",
    "D2A75C", "E8D8B5", "F4ECD8", "B84B42", "7D302E", "52BAC7", "FFFFFF"
  }
  local function read(path)
    local f = assert(io.open(path, "rb"), "cannot read " .. path)
    local s = f:read("*a")
    f:close()
    return s
  end
  local function write(path, value)
    local f = assert(io.open(path, "wb"), "cannot write " .. path)
    f:write(value)
    f:close()
  end
  local function lock_palette()
    local raw = read(PAL)
    assert(raw:find('"alpha":[0,255]', 1, true), "alpha lock changed")
    local rows = assert(raw:match('"colors":%[([^%]]+)%]'), "palette colors missing")
    local found = {}
    for hex in rows:gmatch("#([0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f])") do
      found[#found + 1] = hex:upper()
    end
    assert(#found == #EXPECT, "palette size changed")
    local colors = {}
    for i, hex in ipairs(EXPECT) do
      assert(found[i] == hex, "palette/order drift at " .. i)
      colors[i] = pc.rgba(
        tonumber(hex:sub(1, 2), 16),
        tonumber(hex:sub(3, 4), 16),
        tonumber(hex:sub(5, 6), 16),
        255
      )
    end
    return colors, {
      ink = colors[1], navy = colors[2], blue = colors[3],
      gunmetal = colors[5], iron = colors[6], steel = colors[7],
      steelLight = colors[8], silver = colors[9], copperDark = colors[10],
      copper = colors[11], brass = colors[12], amber = colors[13],
      cream = colors[14], ivory = colors[15], red = colors[16],
      redDark = colors[17], cyan = colors[18], white = colors[19]
    }
  end
  local function clean_frame_assets()
    local _, K = lock_palette()
    local source_path = SRC .. "/upgrade-card-frame-states.aseprite"
    local sprite = assert(app.open(source_path), "cannot open frame source: " .. source_path)
    assert(sprite.width == 160 and sprite.height == 240 and #sprite.frames == 3, "frame source geometry/state count changed")
    local frame_layer = assert(sprite.layers[2], "copper frame layer missing")
    assert(frame_layer.name == "02 Copper and steel frame", "frame layer order/name changed")
    local markers = { { x = 14, y = 144 }, { x = 14, y = 158 }, { x = 14, y = 172 } }
    for frame_index, frame in ipairs(sprite.frames) do
      local cel = assert(frame_layer:cel(frame), "frame cel missing: " .. frame_index)
      local cel_image = cel.image
      for _, marker in ipairs(markers) do
        for dy = 0, 1 do
          for dx = 0, 1 do
            local x, y = marker.x + dx, marker.y + dy
            local local_x, local_y = x - cel.position.x, y - cel.position.y
            assert(local_x >= 0 and local_y >= 0 and local_x < cel_image.width and local_y < cel_image.height, "marker outside frame cel")
            local source_pixel = cel_image:getPixel(local_x, local_y)
            if source_pixel == K.brass then
              cel_image:drawPixel(local_x, local_y, pc.rgba(0, 0, 0, 0))
            else
              assert(pc.rgbaA(source_pixel) == 0, "unexpected source pixel in marker region at frame " .. frame_index .. " pixel " .. x .. "," .. y)
            end
          end
        end
      end
    end
    assert(sprite:saveAs(source_path), "could not save cleaned Aseprite frame source")
    local frame_names = { "normal", "focus", "pressed" }
    for _, state in ipairs(frame_names) do
      local path = OUT .. "/frame_" .. state .. "_160x240.png"
      local frame_image = Image { fromFile = path }
      assert(frame_image.width == 160 and frame_image.height == 240, "frame PNG dimensions changed: " .. state)
      for _, marker in ipairs(markers) do
        for dy = 0, 1 do
          for dx = 0, 1 do
            local x, y = marker.x + dx, marker.y + dy
            local frame_pixel = frame_image:getPixel(x, y)
            if frame_pixel == K.brass then
              frame_image:drawPixel(x, y, K.navy)
            else
              assert(frame_pixel == K.navy, "unexpected frame PNG pixel in marker region: " .. state .. " at " .. x .. "," .. y)
            end
          end
        end
      end
      assert(frame_image:saveAs(path), "could not save cleaned frame PNG: " .. state)
    end
    print("FRAME_CLEAN_OK source 3 states; isolated copper markers removed at y=144,158,172")
  end
  local function set_palette(sprite, colors)
    local palette = Palette(#colors)
    for i, value in ipairs(colors) do
      palette:setColor(i - 1, Color(pc.rgbaR(value), pc.rgbaG(value), pc.rgbaB(value), 255))
    end
    sprite:setPalette(palette)
  end
  local function image(w, h) return Image(w, h) end
  local function pixel(im, x, y, color)
    if x >= 0 and y >= 0 and x < im.width and y < im.height then im:drawPixel(x, y, color) end
  end
  local function rect(im, x, y, w, h, color)
    if w <= 0 or h <= 0 then return end
    for yy = math.max(0, y), math.min(im.height - 1, y + h - 1) do
      for xx = math.max(0, x), math.min(im.width - 1, x + w - 1) do im:drawPixel(xx, yy, color) end
    end
  end
  local function line(im, x0, y0, x1, y1, color, width)
    width = width or 1
    local dx, sx = math.abs(x1 - x0), x0 < x1 and 1 or -1
    local dy, sy = -math.abs(y1 - y0), y0 < y1 and 1 or -1
    local err = dx + dy
    while true do
      local inset = math.floor((width - 1) / 2)
      rect(im, x0 - inset, y0 - inset, width, width, color)
      if x0 == x1 and y0 == y1 then break end
      local e2 = 2 * err
      if e2 >= dy then err = err + dy; x0 = x0 + sx end
      if e2 <= dx then err = err + dx; y0 = y0 + sy end
    end
  end
  local function disk(im, cx, cy, radius, color)
    for y = -radius, radius do
      local half = math.floor(math.sqrt(math.max(0, radius * radius - y * y)))
      rect(im, cx - half, cy + y, half * 2 + 1, 1, color)
    end
  end
  local function oval_fill(im, cx, cy, rx, ry, color)
    for y = -ry, ry do
      local ratio = ry == 0 and 0 or (y * y) / (ry * ry)
      local half = math.floor(rx * math.sqrt(math.max(0, 1 - ratio)))
      rect(im, cx - half, cy + y, half * 2 + 1, 1, color)
    end
  end
  local function oval_outline(im, cx, cy, rx, ry, color)
    for y = -ry, ry do
      local ratio = ry == 0 and 0 or (y * y) / (ry * ry)
      local half = math.floor(rx * math.sqrt(math.max(0, 1 - ratio)))
      pixel(im, cx - half, cy + y, color)
      pixel(im, cx + half, cy + y, color)
    end
    for x = -rx, rx do
      local ratio = rx == 0 and 0 or (x * x) / (rx * rx)
      local half = math.floor(ry * math.sqrt(math.max(0, 1 - ratio)))
      pixel(im, cx + x, cy - half, color)
      pixel(im, cx + x, cy + half, color)
    end
  end
  local function oval_band(im, cx, cy, rx, ry, inner_rx, inner_ry, color)
    for y = -ry, ry do
      local outer_ratio = ry == 0 and 0 or (y * y) / (ry * ry)
      local outer_half = math.floor(rx * math.sqrt(math.max(0, 1 - outer_ratio)))
      if math.abs(y) <= inner_ry then
        local inner_ratio = (y * y) / (inner_ry * inner_ry)
        local inner_half = math.floor(inner_rx * math.sqrt(math.max(0, 1 - inner_ratio)))
        local left_width = outer_half - inner_half
        local right_width = outer_half - inner_half
        if left_width > 0 then rect(im, cx - outer_half, cy + y, left_width, 1, color) end
        if right_width > 0 then rect(im, cx + inner_half + 1, cy + y, right_width, 1, color) end
      else
        rect(im, cx - outer_half, cy + y, outer_half * 2 + 1, 1, color)
      end
    end
  end
  local function oval_arc(im, cx, cy, rx, ry, upper, color)
    local first, last = upper and -ry or 0, upper and 0 or ry
    for y = first, last do
      local ratio = ry == 0 and 0 or (y * y) / (ry * ry)
      local half = math.floor(rx * math.sqrt(math.max(0, 1 - ratio)))
      pixel(im, cx - half, cy + y, color)
      pixel(im, cx + half, cy + y, color)
    end
  end  local function round_rect(im, x, y, w, h, radius, color)
    if w <= 0 or h <= 0 then return end
    radius = math.max(0, math.min(radius, math.floor(math.min(w, h) / 2)))
    if radius == 0 then rect(im, x, y, w, h, color); return end
    rect(im, x + radius, y, w - radius * 2, h, color)
    rect(im, x, y + radius, w, h - radius * 2, color)
    disk(im, x + radius, y + radius, radius, color)
    disk(im, x + w - radius - 1, y + radius, radius, color)
    disk(im, x + radius, y + h - radius - 1, radius, color)
    disk(im, x + w - radius - 1, y + h - radius - 1, radius, color)
  end  local function poly(im, points, fill, outline)
    local low, high = points[1].y, points[1].y
    for _, p in ipairs(points) do low, high = math.min(low, p.y), math.max(high, p.y) end
    for y = low, high do
      local hits = {}
      for i = 1, #points do
        local a, b = points[i], points[i % #points + 1]
        if (a.y <= y and b.y > y) or (b.y <= y and a.y > y) then
          hits[#hits + 1] = a.x + (y - a.y) * (b.x - a.x) / (b.y - a.y)
        end
      end
      table.sort(hits)
      for i = 1, #hits - 1, 2 do
        for x = math.ceil(hits[i]), math.floor(hits[i + 1]) do pixel(im, x, y, fill) end
      end
    end
    if outline then
      for i = 1, #points do
        local a, b = points[i], points[i % #points + 1]
        line(im, a.x, a.y, b.x, b.y, outline, 1)
      end
    end
  end
  local function paste(dst, src, x, y) dst:drawImage(src, x, y) end
  local function composite(w, h, layers)
    local result = image(w, h)
    for _, layer in ipairs(layers) do paste(result, layer.image, 0, 0) end
    return result
  end
  local function scale2(source)
    local result = image(source.width * 2, source.height * 2)
    for y = 0, source.height - 1 do
      for x = 0, source.width - 1 do
        local value = source:getPixel(x, y)
        result:drawPixel(x * 2, y * 2, value)
        result:drawPixel(x * 2 + 1, y * 2, value)
        result:drawPixel(x * 2, y * 2 + 1, value)
        result:drawPixel(x * 2 + 1, y * 2 + 1, value)
      end
    end
    return result
  end
  local function save_ase(path, layers, colors)
    local sprite = Sprite(128, 80)
    while #sprite.layers > 1 do sprite:deleteLayer(sprite.layers[#sprite.layers]) end
    for i, entry in ipairs(layers) do
      local layer = i == 1 and sprite.layers[1] or sprite:newLayer()
      layer.name, layer.opacity, layer.isVisible = entry.name, 255, true
      local full = image(128, 80)
      paste(full, entry.image, 0, 0)
      sprite:newCel(layer, 1).image = full
    end
    set_palette(sprite, colors)
    assert(sprite:saveAs(path), "ASE save failed: " .. path)
  end
  local arts = {}
  local function make_art(id, draw)
    local colors, K = lock_palette()
    local layers = {
      { name = "01 One-pixel contour", image = image(64, 40) },
      { name = "02 Base materials", image = image(64, 40) },
      { name = "03 Volume shadows", image = image(64, 40) },
      { name = "04 Top-right light", image = image(64, 40) },
      { name = "05 Hardware and signal", image = image(64, 40) }
    }
    draw(layers[1].image, layers[2].image, layers[3].image, layers[4].image, layers[5].image, K)
    local scaled = {}
    for _, layer in ipairs(layers) do
      scaled[#scaled + 1] = { name = layer.name, image = scale2(layer.image) }
    end
    local final = composite(128, 80, scaled)
    assert(final:saveAs(OUT .. "/" .. id .. "_128x80.png"), "PNG export failed: " .. id)
    save_ase(SRC .. "/" .. id .. "_128x80.aseprite", scaled, colors)
    arts[id] = final
    print("ART_OK " .. id .. " 64x40 mechanical object, 128x80 export")
  end
  local function bolt(a, K, cx, cy, radius)
    disk(a, cx, cy, radius + 1, K.ink)
    disk(a, cx, cy, radius, K.copper)
    pixel(a, cx + 1, cy - 1, K.amber)
    pixel(a, cx, cy - 1, K.cream)
  end

  if not PREVIEW_ONLY then
  make_art("impacto_reforcado", function(o, f, sh, hi, a, K)
    oval_fill(o, 32, 20, 15, 15, K.ink)
    oval_fill(f, 32, 20, 14, 14, K.steel)
    poly(sh, {{x=19,y=23},{x=23,y=31},{x=29,y=34},{x=36,y=34},{x=33,y=27},{x=28,y=22}}, K.iron, nil)
    poly(hi, {{x=25,y=8},{x=31,y=6},{x=37,y=7},{x=42,y=11},{x=44,y=15},{x=38,y=15},{x=34,y=12},{x=29,y=11}}, K.silver, nil)
    poly(hi, {{x=27,y=9},{x=31,y=8},{x=35,y=9}}, K.steelLight, nil)
    bolt(a, K, 23, 12, 2)
    bolt(a, K, 41, 12, 2)
    bolt(a, K, 23, 28, 2)
    bolt(a, K, 41, 28, 2)
  end)

  make_art("motor_acelerado", function(o, f, sh, hi, a, K)
    round_rect(o, 22, 3, 20, 23, 6, K.ink)
    round_rect(f, 23, 4, 18, 21, 5, K.steel)
    poly(o, {{x=22,y=20},{x=42,y=20},{x=48,y=28},{x=43,y=34},{x=21,y=34},{x=16,y=28}}, K.ink, K.ink)
    poly(f, {{x=23,y=22},{x=41,y=22},{x=45,y=28},{x=42,y=32},{x=22,y=32},{x=19,y=28}}, K.iron, nil)
    poly(sh, {{x=25,y=26},{x=40,y=26},{x=42,y=30},{x=24,y=30}}, K.gunmetal, nil)
    poly(hi, {{x=24,y=7},{x=29,y=5},{x=37,y=5},{x=39,y=7},{x=38,y=10},{x=27,y=10}}, K.steelLight, nil)
    round_rect(o, 16, 11, 8, 6, 2, K.ink)
    round_rect(f, 17, 12, 6, 4, 1, K.steelLight)
    round_rect(o, 40, 11, 8, 6, 2, K.ink)
    round_rect(f, 41, 12, 6, 4, 1, K.silver)
    for _, y in ipairs({11, 15, 19}) do
      round_rect(sh, 26, y, 12, 3, 1, K.navy)
      rect(sh, 27, y + 1, 10, 1, K.ink)
    end
    line(hi, 39, 11, 39, 21, K.silver, 1)
    line(hi, 25, 8, 35, 8, K.silver, 1)
    poly(a, {{x=22,y=29},{x=42,y=29},{x=39,y=35},{x=32,y=39},{x=25,y=35}}, K.amber, nil)
    poly(a, {{x=28,y=30},{x=36,y=30},{x=34,y=35},{x=32,y=37},{x=30,y=35}}, K.ivory, nil)
  end)
  make_art("carga_reativa", function(o, f, sh, hi, a, K)
    round_rect(o, 14, 11, 36, 19, 6, K.ink)
    round_rect(f, 15, 12, 34, 17, 5, K.steel)
    round_rect(sh, 18, 17, 28, 8, 3, K.ink)
    round_rect(hi, 19, 18, 26, 6, 2, K.cyan)
    poly(sh, {{x=18,y=26},{x=45,y=26},{x=42,y=29},{x=21,y=29}}, K.iron, nil)
    round_rect(o, 11, 14, 7, 13, 2, K.ink)
    round_rect(f, 12, 15, 5, 11, 1, K.silver)
    round_rect(o, 46, 14, 7, 13, 2, K.ink)
    round_rect(f, 47, 15, 5, 11, 1, K.steelLight)
    for _, x in ipairs({19, 26, 33, 40, 47}) do
      round_rect(a, x - 1, 10, 5, 21, 2, K.ink)
      round_rect(a, x, 11, 3, 19, 1, K.copper)
      rect(a, x, 12, 1, 16, K.amber)
    end
    line(a, 49, 12, 53, 7, K.amber, 2)
    line(a, 50, 10, 56, 10, K.ivory, 1)
    line(a, 51, 11, 55, 14, K.cyan, 1)
    pixel(a, 50, 10, K.white)
  end)

  make_art("ricochete_pressao", function(o, f, sh, hi, a, K)
    round_rect(o, 7, 25, 15, 9, 3, K.ink)
    round_rect(f, 8, 26, 13, 7, 2, K.steel)
    round_rect(o, 42, 25, 15, 9, 3, K.ink)
    round_rect(f, 43, 26, 13, 7, 2, K.steelLight)
    poly(o, {{x=18,y=23},{x=23,y=19},{x=41,y=19},{x=46,y=23},{x=46,y=31},{x=41,y=36},{x=23,y=36},{x=18,y=31}}, K.ink, K.ink)
    poly(f, {{x=20,y=24},{x=24,y=21},{x=40,y=21},{x=44,y=24},{x=44,y=30},{x=40,y=34},{x=24,y=34},{x=20,y=30}}, K.copper, nil)
    poly(sh, {{x=21,y=29},{x=43,y=29},{x=40,y=33},{x=24,y=33}}, K.copperDark, nil)
    poly(hi, {{x=23,y=24},{x=27,y=22},{x=39,y=22},{x=42,y=24},{x=37,y=25},{x=27,y=25}}, K.amber, nil)
    round_rect(o, 28, 15, 8, 10, 2, K.ink)
    round_rect(f, 29, 16, 6, 8, 1, K.iron)
    oval_fill(o, 32, 9, 9, 9, K.ink)
    oval_fill(f, 32, 9, 8, 8, K.brass)
    oval_fill(sh, 32, 9, 6, 6, K.ivory)
    oval_outline(hi, 32, 9, 5, 5, K.ivory)
    line(a, 28, 8, 29, 8, K.iron, 1)
    line(a, 35, 8, 36, 8, K.iron, 1)
    line(a, 31, 4, 31, 5, K.iron, 1)
    line(a, 32, 10, 36, 5, K.red, 2)
    oval_fill(a, 32, 10, 1, 1, K.red)
  end)

  make_art("mola_retorno", function(o, f, sh, hi, a, K)
    round_rect(o, 14, 3, 36, 8, 3, K.ink)
    round_rect(f, 15, 4, 34, 6, 2, K.iron)
    round_rect(hi, 18, 5, 27, 2, 1, K.steelLight)
    round_rect(o, 14, 29, 36, 8, 3, K.ink)
    round_rect(f, 15, 30, 34, 6, 2, K.iron)
    round_rect(sh, 18, 33, 27, 2, 1, K.gunmetal)
    line(hi, 20, 6, 43, 6, K.silver, 1)
    line(hi, 20, 31, 43, 31, K.steelLight, 1)
    for _, y in ipairs({11, 17, 23, 29}) do
      oval_band(o, 32, y, 13, 4, 9, 2, K.ink)
      oval_band(f, 32, y, 12, 3, 8, 1, K.steel)
      oval_arc(sh, 32, y, 10, 2, false, K.iron)
      oval_arc(hi, 32, y - 1, 10, 2, true, K.silver)
    end
  end)
  make_art("dinamo_defesa", function(o, f, sh, hi, a, K)
    round_rect(o, 9, 12, 34, 21, 5, K.ink)
    round_rect(f, 10, 13, 32, 19, 4, K.iron)
    poly(sh, {{x=12,y=25},{x=39,y=25},{x=37,y=31},{x=14,y=31}}, K.navy, nil)
    poly(hi, {{x=14,y=15},{x=21,y=13},{x=35,y=13},{x=39,y=16},{x=36,y=18},{x=18,y=18}}, K.steelLight, nil)
    round_rect(o, 14, 30, 24, 6, 2, K.ink)
    round_rect(f, 15, 31, 22, 4, 1, K.steel)
    rect(a, 20, 18, 16, 3, K.copper)
    oval_fill(o, 45, 20, 12, 12, K.ink)
    oval_fill(f, 45, 20, 10, 10, K.copperDark)
    oval_fill(sh, 45, 20, 7, 7, K.gunmetal)
    line(a, 45, 20, 45, 12, K.brass, 3)
    line(a, 45, 20, 38, 24, K.brass, 3)
    line(a, 45, 20, 51, 25, K.brass, 3)
    oval_fill(a, 45, 20, 4, 4, K.ink)
    oval_fill(a, 45, 20, 2, 2, K.amber)
    line(hi, 41, 11, 47, 10, K.amber, 1)
  end)

  make_art("chassi_reforcado", function(o, f, sh, hi, a, K)
    local plate = {{x=14,y=4},{x=50,y=4},{x=58,y=12},{x=58,y=28},{x=50,y=36},{x=14,y=36},{x=6,y=28},{x=6,y=12}}
    local inset = {{x=14,y=6},{x=49,y=6},{x=56,y=13},{x=56,y=27},{x=49,y=34},{x=14,y=34},{x=8,y=27},{x=8,y=13}}
    poly(o, plate, K.ink, K.ink)
    poly(f, inset, K.steel, nil)
    poly(sh, {{x=10,y=25},{x=54,y=25},{x=50,y=32},{x=14,y=32}}, K.iron, nil)
    poly(hi, {{x=15,y=7},{x=48,y=7},{x=53,y=12},{x=46,y=13},{x=20,y=13},{x=11,y=17}}, K.steelLight, nil)
    line(hi, 17, 8, 46, 8, K.silver, 1)
    poly(a, {{x=25,y=14},{x=39,y=14},{x=42,y=17},{x=42,y=23},{x=39,y=26},{x=25,y=26},{x=22,y=23},{x=22,y=17}}, K.ink, K.ink)
    poly(a, {{x=25,y=16},{x=38,y=16},{x=40,y=18},{x=40,y=22},{x=38,y=24},{x=25,y=24},{x=24,y=22},{x=24,y=18}}, K.gunmetal, nil)
    poly(a, {{x=26,y=16},{x=37,y=16},{x=39,y=18},{x=35,y=18},{x=27,y=18},{x=25,y=19}}, K.steelLight, nil)
    bolt(a, K, 17, 13, 2)
    bolt(a, K, 47, 13, 2)
    bolt(a, K, 17, 27, 2)
    bolt(a, K, 47, 27, 2)
  end)
  else
    local ids = {
      "impacto_reforcado", "motor_acelerado", "carga_reativa",
      "ricochete_pressao", "mola_retorno", "dinamo_defesa", "chassi_reforcado"
    }
    for _, id in ipairs(ids) do
      local existing = Image { fromFile = OUT .. "/" .. id .. "_128x80.png" }
      assert(existing.width == 128 and existing.height == 80, "preview icon dimensions changed: " .. id)
      arts[id] = existing
    end
  end
  if CLEAN_FRAMES then clean_frame_assets() end
  local function load_font()
    lock_palette()
    local raw = read(FONTJSON)
    assert(raw:find('"cell":{"w":5,"h":11}', 1, true), "font cell changed")
    assert(raw:find('"advance":6', 1, true), "font advance changed")
    local atlas = Image { fromFile = FONTPNG }
    assert(atlas.width == 84 and atlas.height == 105, "card font atlas dimensions changed")
    local glyphs = {}
    local pattern = '"character":"([^"]*)","codepoint":(%d+),"rect":{"x":(%d+),"y":(%d+),"w":(%d+),"h":(%d+)},"advance":(%d+)'
    for ch, _, x, y, w, h, advance in raw:gmatch(pattern) do
      glyphs[ch] = { x = tonumber(x), y = tonumber(y), w = tonumber(w), h = tonumber(h), advance = tonumber(advance) }
    end
    local additions_raw = read(OUT .. "/card-font-additions.json")
    local addition_pattern = '"character":%s*"([^"]*)"%s*,%s*"codepoint":%s*(%d+)%s*,%s*"rect":%s*{%s*"x":%s*(%d+)%s*,%s*"y":%s*(%d+)%s*,%s*"w":%s*(%d+)%s*,%s*"h":%s*(%d+)%s*}%s*,%s*"advance":%s*(%d+)'
    for ch, _, x, y, w, h, advance in additions_raw:gmatch(addition_pattern) do
      glyphs[ch] = { x = tonumber(x), y = tonumber(y), w = tonumber(w), h = tonumber(h), advance = tonumber(advance) }
    end
    assert(glyphs.A and glyphs["-"] and glyphs[" "], "font glyphs missing")
    return atlas, glyphs
  end
  local function chars(value)
    local out, i = {}, 1
    while i <= #value do
      local b = value:byte(i)
      local n = (b < 128 and 1) or (b < 224 and 2) or (b < 240 and 3) or 4
      out[#out + 1] = value:sub(i, i + n - 1)
      i = i + n
    end
    return out
  end
  local function draw_text(im, x, y, value, color, atlas, glyphs, char_colors)
    local cursor = x
    for index, ch in ipairs(chars(value)) do
      local glyph_color = char_colors and char_colors[index] or color
      if ch == "+" then
        for xx = 1, 3 do pixel(im, cursor + xx, y + 5, glyph_color) end
        for yy = 3, 7 do pixel(im, cursor + 2, y + yy, glyph_color) end
        cursor = cursor + 6
      else
        local g = assert(glyphs[ch], "preview glyph missing: " .. ch)
        for yy = 0, g.h - 1 do
          for xx = 0, g.w - 1 do
            if pc.rgbaA(atlas:getPixel(g.x + xx, g.y + yy)) > 0 then
              pixel(im, cursor + xx, y + yy, glyph_color)
            end
          end
        end
        cursor = cursor + g.advance
      end
    end
  end
  local function center_text(im, center, y, value, color, atlas, glyphs)
    local width = 0
    for _, ch in ipairs(chars(value)) do width = width + (ch == "+" and 6 or assert(glyphs[ch], "preview glyph missing: " .. ch).advance) end
    draw_text(im, center - math.floor(width / 2), y, value, color, atlas, glyphs)
  end
  local function center_colored_text(im, center, y, value, color, atlas, glyphs, char_colors)
    local width = 0
    for _, ch in ipairs(chars(value)) do width = width + (ch == "+" and 6 or assert(glyphs[ch], "preview glyph missing: " .. ch).advance) end
    draw_text(im, center - math.floor(width / 2), y, value, color, atlas, glyphs, char_colors)
  end
  local function is_digit(ch)
    return ch ~= nil and ch >= "0" and ch <= "9"
  end
  local function is_sign(ch)
    return ch == "+" or ch == "-"
  end
  local function topic_colors(topic)
    local topic_chars = chars(topic)
    local colors = {}
    for i = 1, #topic_chars do colors[i] = PREVIEW_COLORS.silver end
    if topic:sub(1, #"ATÉ ") == "ATÉ " or topic:sub(1, #"UMA VEZ") == "UMA VEZ" then return colors end
    local arrow_index
    for i, ch in ipairs(topic_chars) do
      if ch == ">" then arrow_index = i; break end
    end
    local number_start, digit_start
    if arrow_index then
      digit_start = arrow_index + 1
      while topic_chars[digit_start] == " " do digit_start = digit_start + 1 end
      number_start = digit_start
      if is_sign(topic_chars[digit_start]) then digit_start = digit_start + 1 end
      if not is_digit(topic_chars[digit_start]) then return colors end
    else
      for i, ch in ipairs(topic_chars) do
        if is_digit(ch) then
          digit_start = i
          number_start = i
          if i > 1 and is_sign(topic_chars[i - 1]) then number_start = i - 1 end
          break
        end
      end
      if not digit_start then return colors end
    end
    local number_end = digit_start
    while is_digit(topic_chars[number_end]) or topic_chars[number_end] == "," or topic_chars[number_end] == "." do
      number_end = number_end + 1
    end
    if number_end == digit_start then return colors end
    if topic_chars[number_end] == "S" or topic_chars[number_end] == "s" then number_end = number_end + 1 end
    for i = number_start, number_end - 1 do colors[i] = PREVIEW_COLORS.amber end
    return colors
  end
  local function make_topic_line(content, content_colors, first_line)
    local prefix = first_line and "- " or "  "
    local colors = first_line and { PREVIEW_COLORS.cyan, PREVIEW_COLORS.silver } or { PREVIEW_COLORS.silver, PREVIEW_COLORS.silver }
    for _, color in ipairs(content_colors) do colors[#colors + 1] = color end
    return { text = prefix .. content, colors = colors }
  end
  local function wrap_topic(topic)
    local result = {}
    local topic_chars = chars(topic)
    local source_colors = topic_colors(topic)
    local words, word, word_start = {}, "", nil
    local function save_word(last_index)
      if word ~= "" then
        words[#words + 1] = { text = word, start_index = word_start, end_index = last_index }
        word, word_start = "", nil
      end
    end
    for i, ch in ipairs(topic_chars) do
      if ch == " " then
        save_word(i - 1)
      else
        if word_start == nil then word_start = i end
        word = word .. ch
      end
    end
    save_word(#topic_chars)
    local content, content_colors, content_width = "", {}, 0
    for _, item in ipairs(words) do
      local word_width = #chars(item.text)
      if word_width > 22 then return {} end
      local needs_space = content ~= ""
      if needs_space and content_width + 1 + word_width > 22 then
        result[#result + 1] = make_topic_line(content, content_colors, #result == 0)
        content, content_colors, content_width = item.text, {}, word_width
      else
        if needs_space then
          content = content .. " "
          content_colors[#content_colors + 1] = PREVIEW_COLORS.silver
          content_width = content_width + 1
        end
        content = content .. item.text
        for i = item.start_index, item.end_index do content_colors[#content_colors + 1] = source_colors[i] end
        content_width = content_width + word_width
      end
      if needs_space and content == item.text then
        for i = item.start_index, item.end_index do content_colors[#content_colors + 1] = source_colors[i] end
      end
    end
    if content ~= "" then result[#result + 1] = make_topic_line(content, content_colors, #result == 0) end
    return result
  end
  local function save_integer_scale(source, path, scale)
    local result = image(source.width * scale, source.height * scale)
    for y = 0, source.height - 1 do
      for x = 0, source.width - 1 do
        local value = source:getPixel(x, y)
        for dy = 0, scale - 1 do
          for dx = 0, scale - 1 do result:drawPixel(x * scale + dx, y * scale + dy, value) end
        end
      end
    end
    assert(result:saveAs(path), "preview export failed: " .. path)
  end

  local function make_preview()
    local _, K = lock_palette()
    PREVIEW_COLORS = K
    local atlas, glyphs = load_font()
    local canvas = image(576, 324)
    rect(canvas, 0, 0, 576, 324, K.navy)
    rect(canvas, 0, 0, 576, 36, K.blue)
    rect(canvas, 0, 0, 576, 2, K.copper)
    rect(canvas, 0, 34, 576, 2, K.ink)
    rect(canvas, 18, 17, 42, 1, K.steel)
    rect(canvas, 516, 17, 42, 1, K.steel)
    center_text(canvas, 288, 10, "ESCOLHA UMA MELHORIA", K.ivory, atlas, glyphs)
    center_text(canvas, 288, 39, "UMA ESCOLHA POR SALA", K.cream, atlas, glyphs)
    local cards = {
      {
        id = "carga_reativa", title = "CARGA REATIVA",
        desc = { "REBATA SUA BOLA PARA", "CARREGÁ-LA." },
        topics = { "DANO EXTRA: +2", "NO PRÓXIMO ACERTO" },
        status = "NOVO", rank_before = 0, rank_after = 1, rank_max = 220, state = "normal"
      },
      {
        id = "mola_retorno", title = "MOLA DE RETORNO",
        desc = { "A BOLA DURA MAIS E", "REBATE MAIS VEZES." },
        topics = { "REBOTES: 4 > 5", "DURAÇÃO: 2,55S > 2,9S" },
        status = "EVOLUIR", rank_before = 1, rank_after = 2, rank_max = 3, state = "focus"
      },
      {
        id = "dinamo_defesa", title = "DÍNAMO DE DEFESA",
        desc = { "REBATER REDUZ A", "RECARGA DO DASH." },
        topics = { "REDUÇÃO: 0,3S > 0,45S", "UMA VEZ POR REBATIDA" },
        status = "EVOLUIR", rank_before = 2, rank_after = 3, rank_max = 3, state = "normal"
      }
    }
    local origins = { 36, 208, 380 }
    local frames = {}
    for _, state in ipairs({ "normal", "focus", "pressed" }) do
      frames[state] = Image { fromFile = OUT .. "/frame_" .. state .. "_160x240.png" }
    end
    for index, card in ipairs(cards) do
      local x, y = origins[index], 60
      paste(canvas, frames[card.state], x, y)
      paste(canvas, arts[card.id], x + 16, y + 34)
      rect(canvas, x + 8, y + 118, 144, 24, K.navy)
      center_text(canvas, x + 80, y + 9, card.title, K.ivory, atlas, glyphs)
      center_text(canvas, x + 80, y + 118, card.desc[1], K.cyan, atlas, glyphs)
      center_text(canvas, x + 80, y + 130, card.desc[2], K.cyan, atlas, glyphs)
      local topic_line_index = 0
      for _, topic in ipairs(card.topics) do
        for _, topic_line in ipairs(wrap_topic(topic)) do
          assert(#chars(topic_line.text) <= 24, "card line exceeds 24 glyphs")
          topic_line_index = topic_line_index + 1
          draw_text(canvas, x + 8, y + 146 + (topic_line_index - 1) * 14, topic_line.text, K.silver, atlas, glyphs, topic_line.colors)
        end
      end
      assert(topic_line_index > 0 and topic_line_index <= 3, "preview topics exceed three lines")
      local is_maximum = card.rank_after == card.rank_max
      local status = card.status
      if is_maximum then status = status .. " - MÁXIMO" end
      local status_color = is_maximum and K.amber or K.cyan
      center_text(canvas, x + 80, y + 205, status, status_color, atlas, glyphs)
      local rank_prefix = "NÍVEL " .. card.rank_before .. " > "
      local rank_target = tostring(card.rank_after)
      local rank_suffix = " / " .. card.rank_max
      local counter = rank_prefix .. rank_target .. rank_suffix
      local counter_colors = {}
      for _, _ch in ipairs(chars(rank_prefix)) do counter_colors[#counter_colors + 1] = K.silver end
      for _, _ch in ipairs(chars(rank_target)) do counter_colors[#counter_colors + 1] = K.amber end
      for _, _ch in ipairs(chars(rank_suffix)) do counter_colors[#counter_colors + 1] = K.silver end
      center_colored_text(canvas, x + 80, y + 217, counter, K.silver, atlas, glyphs, counter_colors)
    end
    center_text(canvas, 288, 307, "ESTUDO VISUAL - NÃO É SCREENSHOT GODOT", K.silver, atlas, glyphs)
    assert(canvas:saveAs(PRE .. "/upgrade-cards-study-576x324.png"), "study preview export failed")
    save_integer_scale(canvas, PRE .. "/upgrade-cards-study-1728x972.png", 3)
    print("PREVIEW_OK 3 cards, dashed topics and highlighted gain spans")
  end
  local function make_contact()
    local _, K = lock_palette()
    PREVIEW_COLORS = K
    local atlas, glyphs = load_font()
    local canvas = image(432, 352)
    rect(canvas, 0, 0, 432, 352, K.navy)
    rect(canvas, 0, 0, 432, 2, K.copper)
    local names = {
      { "impacto_reforcado", "IMPACTO REFORCADO" },
      { "motor_acelerado", "MOTOR ACELERADO" },
      { "carga_reativa", "CARGA REATIVA" },
      { "ricochete_pressao", "RIC. DE PRESSAO" },
      { "mola_retorno", "MOLA DE RETORNO" },
      { "dinamo_defesa", "DÍNAMO DE DEFESA" },
      { "chassi_reforcado", "CHASSI REFORCADO" }
    }
    for index, item in ipairs(names) do
      local column = (index - 1) % 3
      local row = math.floor((index - 1) / 3)
      local x, y = 8 + column * 140, 8 + row * 112
      rect(canvas, x, y, 136, 104, K.ink)
      rect(canvas, x + 1, y + 1, 134, 102, K.blue)
      rect(canvas, x + 3, y + 3, 130, 82, K.navy)
      paste(canvas, arts[item[1]], x + 4, y + 4)
      center_text(canvas, x + 68, y + 88, item[2], K.cream, atlas, glyphs)
    end
    assert(canvas:saveAs(PRE .. "/upgrade-illustrations-contact-432x352.png"), "contact export failed")
    save_integer_scale(canvas, PRE .. "/upgrade-illustrations-contact-864x704.png", 2)
    print("ART_CONTACT_OK 7 mechanical illustrations")
  end

  make_preview()
  if not PREVIEW_ONLY then
    make_contact()
  write(OUT .. "/manifest.json", [[
{"asset_set":"upgrade_cards_v1","card":{"w":160,"h":240},"illustration":{"w":128,"h":80,"source_canvas":{"w":64,"h":40},"scale":2,"max_colors_per_icon":10,"style":"cartoon mechanical objects, rounded volume, bold silhouettes, 2-3 tones per material, 1px outline"},"palette":"assets/ui/hud_caldeira_v1/export/palette.json","palette_colors":19,"alpha":[0,255],"font":"assets/ui/upgrade_cards_v1/export/card-font-atlas.png","card_font":{"base_bundle":"assets/ui/hud_caldeira_v1/export/font.json","replacement_atlas":"card-font-atlas.png","additions":"card-font-additions.json","canvas":{"w":84,"h":105},"glyphs":[{"character":"+","codepoint":43},{"character":">","codepoint":62}]},"illustrations":["impacto_reforcado_128x80.png","motor_acelerado_128x80.png","carga_reativa_128x80.png","ricochete_pressao_128x80.png","mola_retorno_128x80.png","dinamo_defesa_128x80.png","chassi_reforcado_128x80.png"],"frames":["frame_normal_160x240.png","frame_focus_160x240.png","frame_pressed_160x240.png"],"previews":["preview/upgrade-cards-study-576x324.png","preview/upgrade-cards-study-1728x972.png","preview/upgrade-illustrations-contact-432x352.png","preview/upgrade-illustrations-contact-864x704.png"],"notes":["illustrations regenerated from the 64x40 source grid at integer scale 2","frame and font assets are reused unchanged","preview is a visual study, not a Godot screenshot","no engine or tests run"]}
]])
  print("UPGRADE_CARDS_ART_ONLY_OK " .. KIT)
  else
    print("UPGRADE_CARDS_PREVIEW_ONLY_OK " .. KIT)
  end
end

local ok, err = xpcall(main, debug.traceback)
if not ok then
  print("UPGRADE_CARDS_GENERATION_ERROR: " .. tostring(err))
  error(err)
end
