local directory = assert(app.params.directory, "missing output directory")
local source = Image { fromFile = assert(app.params.atlas, "missing player atlas") }
local pc = app.pixelColor
local palette = {
  K = 0x020213, N = 0x001123, D = 0x133156, B = 0x2e65b0,
  G = 0x373f4d, S = 0x897c76, I = 0xcfc3b7, W = 0xf5e9d8,
  H = 0xfffcf0, Y = 0xfcc203, A = 0xf3b100, C = 0x00ecfd,
}
local colors = {}
for key, value in pairs(palette) do
  colors[key] = pc.rgba((value >> 16) & 255, (value >> 8) & 255, value & 255, 255)
end

local function walk(frame)
  local result = Image(64, 64)
  for y = 0, 63 do
    for x = 0, 63 do
      local color = source:getPixel(384 + frame * 64 + x, y)
      if pc.rgbaA(color) ~= 0 then
        assert(pc.rgbaA(color) == 255, "partial alpha in walk frame")
        result:drawPixel(x, y, color)
      end
    end
  end
  return result
end

local function rows(image, x, y, design)
  for row, line in ipairs(design) do
    for column = 1, #line do
      local color = colors[line:sub(column, column)]
      if color then image:drawPixel(x + column - 1, y + row - 1, color) end
    end
  end
end

local function rear(stride)
  local result = Image(64, 64)
  local feet = { left = stride == 2 and 49 or 53, right = stride == 1 and 49 or 53 }
  local lift = stride == 0 and 0 or 1
  rows(result, 22, 7 - lift, {
    "................KKK", "...............KYYYK", "...............KYYYK",
    "...............KYYYK", "................KKK", "................KDK",
    "......KKKKKKK...KDK", "....KKWWWWWWWKKKKDK", "...KWWWHHHWWWWDDBDK",
    "..KWWWWWWWWWWWDBBDK", ".KDIWWWWWWWWWWDBBDDK", "KDBIWWWWWWWWWIDBBDDK",
    "KDBIWWWWWWWWWIDDBDDK", "KDYIWWWWWWWWIIDDYDDK", "KDYIWWWWWWWIISDDYDDK",
    "KDDIIWWWWWIISSDAADK", ".KDIISGGGGSISDDADK", "..KDDSDDDDDDSDDDK",
    "...KKDDDDDDDDDKK", ".....KKKKKKKKK", ".......KNNNK",
  })
  rows(result, 29, 28 - lift, {
    "KSSSK", "KIIIK", "KIIIK", "KSSSK",
  })
  rows(result, 21, 32 - lift, {
    ".....KKKYKKKKKYKKK", "....KAYYDDDDDDDYYAK", "...KDYYDDIWWIDDDYYDK",
    "...KBDDDBIWWIBDDDBDK", "..KDBDDKDIIISDKDDBBDK", "..KDBDKKDDDDDDKKDBDDK",
    ".KDDDK.KDDDDDK.KDDDK", ".KYDDK.KDBDDDK.KDDYK", ".KAADK.KDDNDDK.KDAAK",
    "..KKK..KDDNDDK..KKK", ".......KDDNDDK", ".......KDK.KDK",
  })
  rows(result, 25, 43 - lift, {"KDBDK","KDBDK","KDDBK","KDDDK","KDDDK"})
  rows(result, 35, 43 - lift, {"KDBDK","KDBDK","KDDBK","KDDDK","KDDDK"})
  local function boot(x, y)
    for fill_y = 47 - lift, y - 1 do rows(result, x + 1, fill_y, {"KDDDK"}) end
    rows(result, x, y, {"KAYYYAK", "KBDDDBK", "KDBBBDK", "KKKKKKK"})
  end
  boot(24, feet.left)
  boot(34, feet.right)
  return result
end

local turn = walk(3)
rows(turn, 23, 19, {
  "..WWWWWWWIDD", ".WWWHWWWWIDDB", ".WWWWWWWWIDDB", ".CNIWWWWIISDD",
  ".NNIWWWIISDDD", ".NNIWWIISDDDD", "..IWWIISDDDD", "..IIIIISDDD",
  "...SSSSSDD",
})
local frames = {walk(0), walk(2), turn, rear(1), rear(2), rear(0)}
local sprite = Sprite(64, 64, ColorMode.RGB)
sprite.layers[1].name = "Embarque"
local sheet = Image(384, 64)
for index, frame in ipairs(frames) do
  if index > 1 then sprite:newEmptyFrame() end
  sprite:newCel(sprite.layers[1], index, frame, Point(0, 0))
  sprite.frames[index].duration = 0.08
  sheet:drawImage(frame, Point((index - 1) * 64, 0))
end
assert(sprite:saveAs(directory .. "/source/boarding.aseprite"))
assert(sheet:saveAs(directory .. "/boarding_6x64.png"))
sprite:resize(192, 192)
if app.params.preview then assert(sprite:saveCopyAs(app.params.preview)) end

