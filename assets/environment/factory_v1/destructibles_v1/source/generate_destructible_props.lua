-- Factory palette from assets/environment/factory_v2/palette-fabrica-v2.json.
-- SNES-style shading, with six 24x24 cells in runtime order.
local CELL = 24
local OUT = app.params.out or "assets/environment/factory_v1/destructibles_v1"
local NAME = "destructible-props"
local palette = {
  ["#"] = 0x0E0D0E, k = 0x1D1B1A, d = 0x302D2A, s = 0x433E39,
  m = 0x5B5249, n = 0x756957, b = 0x90816A, h = 0xBAAA8B, l = 0xD3C3A7,
  u = 0x4A2D21, v = 0x563829, r = 0x70432C, c = 0x925A36,
  t = 0xB37949, p = 0xC68D58, a = 0xB78342, g = 0xD2A75C,
}

local function paint(image, left, top, rows)
  for rowIndex, row in ipairs(rows) do
    local y = top + rowIndex - 1
    assert(y < CELL and left + #row <= CELL, "Artwork outside cell")
    for index = 1, #row do
      local symbol = row:sub(index, index)
      if symbol == "." then
        image:drawPixel(left + index - 1, y, 0)
      elseif symbol ~= " " then
        local hex = assert(palette[symbol], "Unknown palette symbol " .. symbol)
        image:drawPixel(left + index - 1, y,
          app.pixelColor.rgba((hex >> 16) & 255, (hex >> 8) & 255, hex & 255, 255))
      end
    end
  end
end

-- Crate with inset rolled-steel panels, iron corner plates and a brass latch.
local crate = Image(CELL, CELL)
paint(crate, 1, 3, {
  ".....##############",
  "....#mmmnnnbbbhhhhl#",
  "...#smmnnbbbssnbhhl#",
  "..#smnnbbhs##nnhhlb#",
  ".#dsmnnbhhnnnnhhhm#",
  "#ddssssssmmbhhhhhhm#",
  "#dmb#hhhmmmmmmmmm#h#",
  "#snn#nkdkkkkdkknm#b#",
  "#sdm#nmsmmmmmsmnm#n#",
  "#sdm#nmsmmm###msm#m#",
  "#sdk#nmsmmm#gh#sm#s#",
  "#sdk#nmsmmm#ar#sm#s#",
  "#sdm#nmsmmm####sm#s#",
  "#sdm#nmmsmmsmmmsm#m#",
  "#sdm#sssssdsdddsm#m#",
  "#skb#bnnnnnnnnnmn#h#",
  "#sdm#mmmmsmmmmmms#b#",
  ".##dddssdddddssss##",
  "...##............##",
})

-- The lid and upper right corner have folded inward. Bare edges catch the light.
local crateDamaged = Image(crate)
paint(crateDamaged, 9, 3, {
  "#######....",
  "nbbhhl#####.",
  "bssnnhhnrh#.",
  "s#nnhhhrpd#.",
  "nnhhhrp#sm#",
  "hhbrc###ss#",
  "nrc#kkds#m#",
  "###kkdsn#n#",
  "mkdksnmm#n#",
  "mk#d###s#m#",
  "msk#gh#s#s#",
  "mss#ar#s#s#",
  "mmm####s#s#",
})
paint(crateDamaged, 5, 12, {
  "t",
  "#t",
  "k#t",
  "dk#bn",
  "  dks",
})

-- Splayed lid, twisted face frame and a detached corner plate.
local crateBroken = Image(CELL, CELL)
paint(crateBroken, 1, 10, {
  "........#####",
  ".......#nbhhl##",
  "......#ssmnntnh##",
  ".....#dmmrnnnrnnh#",
  "....#dnmmdsnmsmn##.##",
  "...#kmmddskdss##..#bh#",
  "..#ssmddskdk##...#nm#",
  ".#bmdksmsdss#...##ms#",
  "#bnd#bbnnnss####nhm##",
  "#sd#knmmmdsskkksm##",
  ".#####ddddd#####",
  "...###.......##",
})

-- Copper pressure vessel with swaged ends and an offset stop valve.
local canister = Image(CELL, CELL)
paint(canister, 4, 1, {
  ".........####",
  "........#mhhb#",
  ".........#a#",
  ".......###m#",
  "......#snbh#",
  "....###ddss###",
  "...#urcctppcuv#",
  "..#uvrcttppctcv#",
  ".#uvrccttppctcvu#",
  ".#dmsmnnbbhhnmbs#",
  ".#kdsmmngbnnsmnd#",
  ".#uvrcttppctcvu#",
  ".#uvrctppppccvu#",
  ".#uvrctgppcctvu#",
  ".#uvrrttppccrvu#",
  ".#uvrrctpcctrvu#",
  ".#dssmnnbbhnmns#",
  ".#kdsmmmmnnsmsd#",
  "..#uvrrccttcru#",
  "...#uurdrrrcv#",
  "....###d####",
  "....##....##",
})

-- The valve tilts left and a ruptured strip opens through the shell and band.
local canisterDamaged = Image(canister)
paint(canisterDamaged, 9, 1, {
  ".####....",
  "#bmh##...",
  ".#a#.....",
  ".#m####..",
  ".#dmbhn#.",
  "#dssdbb##",
  "urcctppcu",
})
paint(canisterDamaged, 11, 9, {
  " b###",
  "ng#k#t",
  "t#k#p",
  "#kd#pp",
  "d#t#pc",
  "#t###c",
  "kt#d#c",
  "kt#mns",
  "#k#sms",
  "##tr",
})

-- A split cylinder lying on its side with the mouth and ribs still visible.
local canisterBroken = Image(CELL, CELL)
paint(canisterBroken, 1, 11, {
  "...............###",
  ".............##hnb#",
  "............#dmbm#",
  ".....##....#r##k#",
  "...##th#####c###...##",
  "..#ctpkdnsnnppt#..#hb#",
  ".#uttr#dmhbptc#...#nd#",
  "#utrkk#bsbctr#..##m##",
  "#vrkds#nmtcru#.#rtp#",
  ".#udmsnsctru###cvv#",
  "..####d#######kk##",
})

-- Each state is a named, independently editable layer in the atlas source.
local cells = {
  { "Crate - intact", crate }, { "Crate - damaged", crateDamaged },
  { "Crate - broken", crateBroken }, { "Canister - intact", canister },
  { "Canister - damaged", canisterDamaged }, { "Canister - broken", canisterBroken },
}

local sprite = Sprite(CELL * #cells, CELL, ColorMode.RGB)
local atlas = Image(sprite.width, sprite.height)
for index, cell in ipairs(cells) do
  local layer = index == 1 and sprite.layers[1] or sprite:newLayer()
  layer.name = cell[1]
  local position = Point((index - 1) * CELL, 0)
  sprite:newCel(layer, 1, cell[2], position)
  atlas:drawImage(cell[2], position)
end

sprite.gridBounds = Rectangle(0, 0, CELL, CELL)
local scale = 4
local preview = Image(atlas.width * scale, atlas.height * scale)
for pixel in preview:pixels() do
  pixel(atlas:getPixel(pixel.x // scale, pixel.y // scale))
end

sprite:saveAs(app.fs.joinPath(OUT, NAME .. ".aseprite"))
sprite:saveCopyAs(app.fs.joinPath(OUT, NAME .. ".png"))
preview:saveAs(app.fs.joinPath(OUT, "preview", NAME .. "-4x.png"))
print("Wrote destructible prop atlas: 6 x 24x24 cells")

