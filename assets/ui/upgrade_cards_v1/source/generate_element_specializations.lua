local root = assert(app.params.root, "root is required")
local id = assert(app.params.id, "id is required")
local kit = root .. "/assets/ui/upgrade_cards_v1"
local pixel = app.pixelColor

-- Caldeira metals plus the warm and cool ramps used by the elemental cards.
local palette = {
  ink = 0x0E0D0E, navy = 0x142C40, blue = 0x203E50,
  steel = 0x59636B, silver = 0xB6BEC3, cyan = 0x52BAC7, ice = 0xA2E1DB,
  copper = 0x925A36, brass = 0xB78342, gold = 0xD2A75C,
  ember = 0x7D302E, red = 0xB84B42, orange = 0xEF8748,
  honey = 0xFFD58A, ivory = 0xF4ECD8,
}
local colors = {}
local allowed = {}
for name, hex in pairs(palette) do
  colors[name] = pixel.rgba((hex >> 16) & 255, (hex >> 8) & 255, hex & 255, 255)
  allowed[colors[name]] = true
end

local image = Image(64, 40)
local function rectangle(name, x, y, width, height)
  for py = y, y + height - 1 do
    for px = x, x + width - 1 do
      image:drawPixel(px, py, colors[name])
    end
  end
end

local function polygon(name, points)
  for y = 0, image.height - 1 do
    local crossings = {}
    local y_center = y + 0.5
    for i, a in ipairs(points) do
      local b = points[i % #points + 1]
      if (a[2] > y_center) ~= (b[2] > y_center) then
        local t = (y_center - a[2]) / (b[2] - a[2])
        crossings[#crossings + 1] = a[1] + t * (b[1] - a[1])
      end
    end
    table.sort(crossings)
    for i = 1, #crossings, 2 do
      local left = math.ceil(crossings[i] - 0.5)
      local right = math.ceil(crossings[i + 1] - 0.5)
      rectangle(name, left, y, right - left, 1)
    end
  end
end

local function spark(x, y, name)
  rectangle("ink", x - 1, y - 2, 3, 5)
  rectangle("ink", x - 2, y - 1, 5, 3)
  rectangle(name, x, y - 1, 1, 3)
  rectangle(name, x - 1, y, 3, 1)
end

local function shard(x, y, base, light)
  polygon("ink", {{x-7,y+4},{x-3,y-4},{x+5,y-7},{x+8,y-2},{x+5,y+5},{x-3,y+7}})
  polygon(base, {{x-5,y+3},{x-2,y-3},{x+4,y-5},{x+6,y-2},{x+3,y+4},{x-3,y+5}})
  polygon(light, {{x-2,y-3},{x+4,y-5},{x+6,y-2},{x+1,y+1},{x-4,y+2}})
end

local cards = {}

function cards.brasa_persistente()
  -- A long, low trail curls back into a bed of embers.
  polygon("ink", {{3,27},{11,24},{20,25},{26,19},{35,21},{42,13},{43,6},{51,4},{58,10},{60,20},{55,28},{47,31},{34,29},{28,34},{12,35},{6,32}})
  polygon("ember", {{5,28},{14,26},{21,27},{28,21},{35,23},{44,15},{47,24},{39,29},{32,27},{26,32},{13,33}})
  polygon("red", {{10,29},{22,28},{29,23},{36,25},{46,16},{47,22},{39,27},{29,26},{23,30}})
  polygon("orange", {{16,30},{25,27},{31,25},{39,25},{48,20},{44,25},{39,28},{29,27},{23,31}})
  polygon("red", {{43,18},{46,14},{47,7},{51,6},{53,13},{57,12},{58,19},{54,25},{48,27},{43,24}})
  polygon("orange", {{46,20},{50,15},{51,10},{52,16},{56,15},{56,20},{53,24},{48,25}})
  polygon("honey", {{49,22},{52,17},{54,19},{53,22},{51,24},{48,24}})
  spark(19, 20, "gold")
  spark(33, 15, "orange")
  rectangle("gold", 9, 30, 3, 1)
end

function cards.fornalha()
  -- A riveted furnace door with a much hotter center.
  polygon("ink", {{9,32},{9,22},{13,22},{13,12},{23,4},{47,4},{54,10},{54,21},{58,21},{58,32},{54,36},{13,36}})
  polygon("copper", {{11,31},{11,24},{15,24},{15,13},{24,6},{46,6},{52,11},{52,23},{56,23},{56,31},{53,34},{14,34}})
  polygon("brass", {{15,13},{24,6},{46,6},{52,11},{52,14},{45,9},{25,9},{18,15}})
  polygon("ink", {{19,29},{19,17},{25,11},{45,11},{50,16},{50,29}})
  polygon("ember", {{21,27},{21,18},{26,13},{44,13},{48,17},{48,27}})
  polygon("red", {{22,27},{22,22},{27,17},{29,21},{34,14},{39,19},{44,16},{47,23},{47,27}})
  polygon("orange", {{24,27},{25,23},{30,24},{35,17},{39,23},{43,21},{46,27}})
  polygon("honey", {{29,27},{35,21},{39,26},{43,24},{44,27}})
  rectangle("ink", 19, 29, 31, 2)
  rectangle("gold", 23, 31, 20, 1)
  for _, x in ipairs({14, 53}) do
    rectangle("ink", x, 26, 3, 4)
    rectangle("silver", x+1, 26, 2, 2)
  end
  rectangle("honey", 35, 24, 2, 2)
end

function cards.leque_estilhacos()
  -- Two outgoing paths form a wide fan with an open middle.
  polygon("navy", {{12,20},{46,5},{51,11},{24,20},{53,28},{48,35}})
  polygon("blue", {{15,19},{43,8},{46,10},{22,20},{46,29},{43,31},{15,22}})
  polygon("cyan", {{17,18},{46,8},{48,10},{20,20}})
  polygon("brass", {{17,23},{20,21},{49,31},{48,33}})
  shard(49, 9, "cyan", "ice")
  shard(51, 30, "gold", "honey")
  polygon("ink", {{5,20},{9,13},{16,12},{22,16},{24,22},{19,28},{11,28},{6,24}})
  polygon("silver", {{7,20},{10,15},{16,14},{21,17},{22,22},{18,26},{12,26},{8,23}})
  polygon("steel", {{8,20},{13,23},{20,22},{17,26},{12,26},{8,23}})
  rectangle("ivory", 14, 16, 4, 2)
end

function cards.nucleo_estilhacos()
  -- A single heavy fracture exposes a luminous core.
  polygon("ink", {{10,28},{14,19},{20,13},{25,5},{39,4},{53,11},{57,22},{49,33},{38,36},{24,33}})
  polygon("navy", {{12,27},{16,20},{22,14},{27,7},{39,6},{51,12},{55,22},{48,31},{38,34},{25,31}})
  polygon("steel", {{16,20},{22,14},{27,7},{38,7},{31,14},{25,24},{13,27}})
  polygon("silver", {{26,8},{37,6},{49,12},{42,15},{32,13},{23,17}})
  polygon("cyan", {{20,26},{31,15},{42,13},{50,17},{49,24},{40,31},{29,31}})
  polygon("ice", {{24,24},{32,16},{41,15},{47,18},{39,24},{28,27}})
  polygon("ivory", {{30,21},{35,16},{42,16},{45,18},{38,22}})
  polygon("blue", {{42,25},{54,20},{50,29},{42,32},{29,32}})
  rectangle("silver", 17, 28, 5, 1)
  spark(53, 7, "ice")
end

local function flaming_shard(x, y, base, light)
  polygon("ink", {{x-18,y+10},{x-13,y+5},{x-14,y+3},{x-7,y+1},{x-4,y-4},{x+3,y-6},{x+4,y+2},{x-1,y+8},{x-10,y+11}})
  polygon("ember", {{x-15,y+9},{x-10,y+5},{x-12,y+4},{x-6,y+3},{x-2,y-3},{x+2,y-4},{x+2,y+2},{x-2,y+7},{x-10,y+9}})
  polygon("orange", {{x-13,y+8},{x-7,y+6},{x-9,y+4},{x-3,y+3},{x+2,y-3},{x+1,y+2},{x-3,y+6}})
  shard(x, y, base, light)
end

function cards.chuva_de_brasas()
  -- Two fragments, each with its own flame tail.
  flaming_shard(29, 13, "gold", "honey")
  flaming_shard(49, 25, "cyan", "ivory")
  spark(45, 10, "orange")
  spark(13, 29, "gold")
end

assert(cards[id], "unknown card: " .. id)()
local export = Image(128, 80)
local used = {}
for source in image:pixels() do
  local color = source()
  if pixel.rgbaA(color) ~= 0 then
    assert(allowed[color] and pixel.rgbaA(color) == 255, "palette or alpha violation")
    used[color] = true
    for dy = 0, 1 do
      for dx = 0, 1 do
        export:drawPixel(source.x * 2 + dx, source.y * 2 + dy, color)
      end
    end
  end
end
local count = 0
for _ in pairs(used) do count = count + 1 end
assert(count >= 5 and count <= 15, "color count out of range")
local sprite = Sprite(128, 80)
local layer = sprite.layers[1]
layer.name = "Ilustração"
sprite:newCel(layer, 1, export, Point(0, 0))
assert(sprite:saveAs(kit .. "/source/" .. id .. "_128x80.aseprite"))
assert(sprite:saveCopyAs(kit .. "/export/" .. id .. "_128x80.png"))
print(id .. ": 128x80, " .. count .. " opaque colors")

