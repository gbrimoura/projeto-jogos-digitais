local function main()
  local P = app.params or {}
  local ROOT = assert(P.root, "missing root parameter")
  local KIT = ROOT .. "/assets/ui/upgrade_cards_v1"
  local SRC, OUT, PRE = KIT .. "/source", KIT .. "/export", KIT .. "/preview"
  local PAL = ROOT .. "/assets/ui/hud_caldeira_v1/export/palette.json"
  local FONTJSON = ROOT .. "/assets/ui/hud_caldeira_v1/export/font.json"
  local FONTPNG = OUT .. "/card-font-atlas.png"
  local pc = app.pixelColor
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
      steel = colors[7], steelLight = colors[8], silver = colors[9],
      copper = colors[12], amber = colors[13], cream = colors[14],
      ivory = colors[15], red = colors[16], cyan = colors[18], white = colors[19]
    }
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
  local function poly(im, points, fill, outline)
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
      { name = "01 Dark outlines", image = image(64, 40) },
      { name = "02 Flat color", image = image(64, 40) },
      { name = "03 Single signal", image = image(64, 40) }
    }
    draw(layers[1].image, layers[2].image, layers[3].image, K)
    local scaled = {}
    for _, layer in ipairs(layers) do
      scaled[#scaled + 1] = { name = layer.name, image = scale2(layer.image) }
    end
    local final = composite(128, 80, scaled)
    assert(final:saveAs(OUT .. "/" .. id .. "_128x80.png"), "PNG export failed: " .. id)
    save_ase(SRC .. "/" .. id .. "_128x80.aseprite", scaled, colors)
    arts[id] = final
    print("ART_OK " .. id .. " 64x40 base, 128x80 export")
  end

  make_art("impacto_reforcado", function(o, f, s, K)
    disk(o, 36, 20, 11, K.ink)
    disk(f, 36, 20, 9, K.cream)
    disk(s, 33, 16, 2, K.white)
    line(s, 8, 10, 17, 10, K.amber, 2)
    line(s, 5, 20, 16, 20, K.amber, 2)
    line(s, 8, 30, 17, 30, K.amber, 2)
  end)
  make_art("motor_acelerado", function(o, f, s, K)
    poly(o, {{x=27,y=8},{x=40,y=12},{x=40,y=28},{x=27,y=32},{x=22,y=25},{x=22,y=15}}, K.ink, K.ink)
    poly(f, {{x=28,y=11},{x=38,y=14},{x=38,y=26},{x=28,y=29},{x=25,y=24},{x=25,y=16}}, K.steel, nil)
    line(s, 29, 12, 36, 14, K.steelLight, 1)
    disk(o, 33, 20, 5, K.ink)
    disk(s, 33, 20, 3, K.amber)
    line(s, 5, 14, 15, 14, K.cyan, 2)
    line(s, 5, 26, 15, 26, K.cyan, 2)
  end)
  make_art("carga_reativa", function(o, f, s, K)
    disk(o, 27, 21, 12, K.ink)
    disk(f, 27, 21, 10, K.ivory)
    disk(s, 24, 17, 2, K.white)
    poly(s, {{x=39,y=7},{x=32,y=20},{x=38,y=20},{x=31,y=34},{x=47,y=17},{x=40,y=17}}, K.amber, K.ink)
  end)
  make_art("ricochete_pressao", function(o, f, s, K)
    disk(o, 25, 20, 9, K.ink)
    disk(f, 25, 20, 7, K.cream)
    rect(o, 45, 6, 8, 28, K.ink)
    rect(f, 47, 8, 4, 24, K.steel)
    rect(s, 48, 9, 1, 22, K.steelLight)
    line(s, 36, 15, 40, 19, K.amber, 2)
    line(s, 40, 19, 36, 23, K.amber, 2)
  end)
  make_art("mola_retorno", function(o, f, s, K)
    line(o, 9, 28, 16, 15, K.ink, 6)
    line(o, 16, 15, 23, 28, K.ink, 6)
    line(o, 23, 28, 30, 15, K.ink, 6)
    line(o, 30, 15, 37, 28, K.ink, 6)
    line(o, 37, 28, 44, 15, K.ink, 6)
    line(o, 44, 15, 49, 24, K.ink, 6)
    line(f, 9, 28, 16, 15, K.copper, 3)
    line(f, 16, 15, 23, 28, K.copper, 3)
    line(f, 23, 28, 30, 15, K.copper, 3)
    line(f, 30, 15, 37, 28, K.copper, 3)
    line(f, 37, 28, 44, 15, K.copper, 3)
    line(f, 44, 15, 49, 24, K.copper, 3)
    disk(o, 50, 9, 7, K.ink)
    disk(f, 50, 9, 5, K.cream)
    disk(s, 48, 7, 1, K.white)
  end)
  make_art("dinamo_defesa", function(o, f, s, K)
    disk(o, 18, 15, 8, K.ink)
    disk(f, 18, 15, 6, K.red)
    line(o, 20, 21, 27, 31, K.ink, 5)
    line(f, 20, 21, 27, 31, K.copper, 3)
    disk(o, 44, 20, 13, K.ink)
    disk(f, 44, 20, 10, K.steel)
    disk(s, 44, 20, 8, K.cyan)
    disk(f, 44, 20, 6, K.steel)
    line(s, 44, 20, 44, 12, K.cream, 2)
    line(s, 44, 20, 50, 20, K.cream, 2)
  end)
  make_art("chassi_reforcado", function(o, f, s, K)
    poly(o, {{x=12,y=7},{x=52,y=7},{x=57,y=12},{x=57,y=28},{x=52,y=33},{x=12,y=33},{x=7,y=28},{x=7,y=12}}, K.ink, K.ink)
    poly(f, {{x=14,y=10},{x=50,y=10},{x=54,y=13},{x=54,y=27},{x=50,y=30},{x=14,y=30},{x=10,y=27},{x=10,y=13}}, K.steel, nil)
    line(s, 15, 12, 49, 12, K.steelLight, 2)
    poly(o, {{x=32,y=27},{x=20,y=19},{x=20,y=15},{x=23,y=12},{x=28,y=12},{x=32,y=16},{x=36,y=12},{x=41,y=12},{x=44,y=15},{x=44,y=19}}, K.ink, K.ink)
    poly(s, {{x=32,y=25},{x=22,y=18},{x=22,y=15},{x=24,y=14},{x=28,y=14},{x=32,y=18},{x=36,y=14},{x=40,y=14},{x=42,y=15},{x=42,y=18}}, K.red, nil)
  end)

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
  local function draw_text(im, x, y, value, color, atlas, glyphs)
    local cursor = x
    for _, ch in ipairs(chars(value)) do
      if ch == "+" then
        for xx = 1, 3 do pixel(im, cursor + xx, y + 5, color) end
        for yy = 3, 7 do pixel(im, cursor + 2, y + yy, color) end
        cursor = cursor + 6
      else
        local g = assert(glyphs[ch], "preview glyph missing: " .. ch)
        for yy = 0, g.h - 1 do
          for xx = 0, g.w - 1 do
            if pc.rgbaA(atlas:getPixel(g.x + xx, g.y + yy)) > 0 then
              pixel(im, cursor + xx, y + yy, color)
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
    local atlas, glyphs = load_font()
    local canvas = image(576, 324)
    rect(canvas, 0, 0, 576, 324, K.navy)
    rect(canvas, 0, 0, 576, 36, K.blue)
    rect(canvas, 0, 0, 576, 2, K.copper)
    rect(canvas, 0, 34, 576, 2, K.ink)
    rect(canvas, 18, 17, 42, 1, K.steel)
    rect(canvas, 516, 17, 42, 1, K.steel)
    center_text(canvas, 288, 10, "OFICINA - UPGRADES", K.ivory, atlas, glyphs)
    center_text(canvas, 288, 39, "3 CARTAS - ESTUDO DE APRESENTAÇÃO", K.cream, atlas, glyphs)
    local cards = {
      {
        id = "carga_reativa", title = "CARGA REATIVA",
        desc = { "REBATA SUA BOLA PARA", "CAUSAR MAIS DANO." },
        topics = { "DANO EXTRA: +2", "VALE PARA 1 ACERTO" }, state = "normal"
      },
      {
        id = "mola_retorno", title = "MOLA DE RETORNO",
        desc = { "A BOLA DURA MAIS TEMPO", "E REBATE MAIS VEZES." },
        topics = { "+1 REBOTE DA BOLA", "+0,35S DE DURAÇÃO" }, state = "focus"
      },
      {
        id = "dinamo_defesa", title = "DÍNAMO DE DEFESA",
        desc = { "REBATER ADIANTA A", "RECARGA DO DASH." },
        topics = { "RECARGA: -0,15S", "UMA VEZ POR REBATIDA" }, state = "normal"
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
      draw_text(canvas, x + 12, y + 118, card.desc[1], K.cream, atlas, glyphs)
      draw_text(canvas, x + 12, y + 130, card.desc[2], K.cream, atlas, glyphs)
      for topic_index, topic in ipairs(card.topics) do
        assert(#chars(topic) <= 24, "card line exceeds 24 glyphs")
        draw_text(canvas, x + 20, y + 144 + (topic_index - 1) * 14, topic, K.silver, atlas, glyphs)
      end
      center_text(canvas, x + 80, y + 210, "NOVO", K.cyan, atlas, glyphs)
    end
    center_text(canvas, 288, 307, "ESTUDO VISUAL - NÃO É SCREENSHOT GODOT", K.silver, atlas, glyphs)
    assert(canvas:saveAs(PRE .. "/upgrade-cards-study-576x324.png"), "study preview export failed")
    save_integer_scale(canvas, PRE .. "/upgrade-cards-study-1728x972.png", 3)
    print("PREVIEW_OK 3 cards, descriptions and 2 labeled topics")
  end

  local function make_contact()
    local _, K = lock_palette()
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
    print("ART_CONTACT_OK 7 simplified illustrations")
  end

  make_preview()
  make_contact()
  write(OUT .. "/manifest.json", [[
{"asset_set":"upgrade_cards_v1","card":{"w":160,"h":240},"illustration":{"w":128,"h":80,"source_canvas":{"w":64,"h":40},"scale":2,"max_colors_per_icon":6,"style":"flat front-facing forms, large silhouette, one clear signal"},"palette":"assets/ui/hud_caldeira_v1/export/palette.json","palette_colors":19,"alpha":[0,255],"font":"assets/ui/upgrade_cards_v1/export/card-font-atlas.png","card_font":{"base_bundle":"assets/ui/hud_caldeira_v1/export/font.json","replacement_atlas":"card-font-atlas.png","additions":"card-font-additions.json","canvas":{"w":84,"h":105},"glyphs":[{"character":"+","codepoint":43},{"character":">","codepoint":62}]},"illustrations":["impacto_reforcado_128x80.png","motor_acelerado_128x80.png","carga_reativa_128x80.png","ricochete_pressao_128x80.png","mola_retorno_128x80.png","dinamo_defesa_128x80.png","chassi_reforcado_128x80.png"],"frames":["frame_normal_160x240.png","frame_focus_160x240.png","frame_pressed_160x240.png"],"previews":["preview/upgrade-cards-study-576x324.png","preview/upgrade-cards-study-1728x972.png","preview/upgrade-illustrations-contact-864x704.png"],"notes":["illustrations regenerated from the 64x40 source grid at integer scale 2","frame and font assets are reused unchanged","preview is a visual study, not a Godot screenshot","no engine or tests run"]}
]])
  print("UPGRADE_CARDS_ART_ONLY_OK " .. KIT)
end

local ok, err = xpcall(main, debug.traceback)
if not ok then
  print("UPGRADE_CARDS_GENERATION_ERROR: " .. tostring(err))
  error(err)
end
