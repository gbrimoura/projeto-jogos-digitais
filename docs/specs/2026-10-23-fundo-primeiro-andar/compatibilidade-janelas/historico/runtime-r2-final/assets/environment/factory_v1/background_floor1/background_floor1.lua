-- First-floor factory backgrounds, hand-authored as crisp native pixels in Aseprite Lua.
-- Re-run from the repository root; parameters must precede --script:
-- Aseprite.exe -b --script-param "root=<repo>" --script-param "mode=bases-only" --script "assets/environment/factory_v1/background_floor1/background_floor1.lua"
-- Use mode=full to regenerate the studies, modular assets, and all eight static contexts.
local p = app.params or {}
local ROOT = p.root or "C:/Users/danie/Documents/ChatGPT/TEC - Jogos/projeto-jogos-digitais"
local MODE = p.mode or "full"
local OUT = ROOT .. "/assets/environment/factory_v1/background_floor1"
local ATLAS_PATH = ROOT .. "/assets/environment/factory_v1/tileset-fabrica-v1-atlas.png"
local PLAYER_PATH = ROOT .. "/assets/player/player-animations.png"
local W, H = 576, 324
local pc = app.pixelColor

-- Local background palette from the spec. It is not the final GDD palette.
local HEX = {
  "0E0D0E", "171719", "1D1B1A", "25292A", "302D2A", "353B3B",
  "433E39", "4A2D21", "563829", "5B5249", "70432C", "756957",
  "925A36", "90816A", "8F7059", "B78342", "D2A75C"
}
local function rgba(hex)
  return pc.rgba(tonumber(hex:sub(1,2),16), tonumber(hex:sub(3,4),16), tonumber(hex:sub(5,6),16), 255)
end
local C = {}
for i, hex in ipairs(HEX) do C[i] = rgba(hex) end
local K = {
  ink=C[1], void=C[2], coal=C[3], wall=C[4], iron=C[5], iron2=C[6],
  steel=C[7], rust0=C[8], rust1=C[9], steelDark=C[10], copper=C[11],
  stone=C[12], rust2=C[13], paper=C[14], patina=C[15], amber=C[16], lamp=C[17]
}
local function image() return Image(W, H) end
local function pix(img,x,y,c)
  if x>=0 and y>=0 and x<img.width and y<img.height then img:drawPixel(x,y,c) end
end
local function rect(img,x,y,w,h,c)
  if w<=0 or h<=0 then return end
  local x0,y0=math.max(0,x),math.max(0,y)
  local x1,y1=math.min(img.width-1,x+w-1),math.min(img.height-1,y+h-1)
  for py=y0,y1 do for px=x0,x1 do img:drawPixel(px,py,c) end end
end
local function line(img,x0,y0,x1,y1,c,width)
  width=width or 1
  local dx,sx=math.abs(x1-x0),x0<x1 and 1 or -1
  local dy,sy=-math.abs(y1-y0),y0<y1 and 1 or -1
  local err=dx+dy
  while true do
    local a=math.floor((width-1)/2)
    rect(img,x0-a,y0-a,width,width,c)
    if x0==x1 and y0==y1 then break end
    local e2=2*err
    if e2>=dy then err=err+dy; x0=x0+sx end
    if e2<=dx then err=err+dx; y0=y0+sy end
  end
end
local function disk(img,cx,cy,r,c)
  for y=-r,r do
    local lim=math.floor(math.sqrt(math.max(0,r*r-y*y)))
    rect(img,cx-lim,cy+y,lim*2+1,1,c)
  end
end
local function ring(img,cx,cy,outer,inner,c)
  local o2,i2=outer*outer,inner*inner
  for y=-outer,outer do for x=-outer,outer do
    local d=x*x+y*y
    if d<=o2 and d>=i2 then pix(img,cx+x,cy+y,c) end
  end end
end
local function arc(img,cx,cy,outer,inner,startDeg,endDeg,c)
  local o2,i2=outer*outer,inner*inner
  for y=-outer,outer do for x=-outer,outer do
    local d=x*x+y*y
    if d<=o2 and d>=i2 then
      local a=math.deg(math.atan(y,x))
      if a>=startDeg and a<=endDeg then pix(img,cx+x,cy+y,c) end
    end
  end end
end
local function bolt(img,x,y,c)
  rect(img,x-1,y-1,3,3,K.ink); pix(img,x,y,c or K.stone); pix(img,x-1,y+1,K.steelDark)
end
local function pipeH(img,x1,x2,y,thick,base)
  base=base or K.copper
  local h=math.floor(thick/2)
  rect(img,x1,y-h-2,x2-x1+1,thick+4,K.ink)
  rect(img,x1,y-h-1,x2-x1+1,thick+2,K.steelDark)
  rect(img,x1+1,y-h,x2-x1-1,thick,base)
  rect(img,x1+2,y-h,x2-x1-3,1,K.rust2)
  rect(img,x1+2,y+h+thick%2-1,x2-x1-3,1,K.rust0)
end
local function pipeV(img,x,y1,y2,thick,base)
  base=base or K.copper
  local h=math.floor(thick/2)
  rect(img,x-h-2,y1,thick+4,y2-y1+1,K.ink)
  rect(img,x-h-1,y1,thick+2,y2-y1+1,K.steelDark)
  rect(img,x-h,y1+1,thick,y2-y1-1,base)
  rect(img,x-h,y1+2,1,y2-y1-3,K.rust2)
  rect(img,x+h+thick%2-1,y1+2,1,y2-y1-3,K.rust0)
end
local function flangeH(img,x,y,thick)
  local h=math.floor(thick/2)
  rect(img,x-4,y-h-3,8,thick+6,K.ink)
  rect(img,x-3,y-h-2,6,thick+4,K.steel)
  rect(img,x-2,y-h-1,4,thick+2,K.steelDark)
  bolt(img,x-2,y-2,K.stone); bolt(img,x+2,y+2,K.stone)
end
local function flangeV(img,x,y,thick)
  local h=math.floor(thick/2)
  rect(img,x-h-3,y-4,thick+6,8,K.ink)
  rect(img,x-h-2,y-3,thick+4,6,K.steel)
  rect(img,x-h-1,y-2,thick+2,4,K.steelDark)
  bolt(img,x-2,y-2,K.stone); bolt(img,x+2,y+2,K.stone)
end
local function pipeDimH(img,x1,x2,y,thick)
  local h=math.floor(thick/2)
  rect(img,x1,y-h-2,x2-x1+1,thick+4,K.ink)
  rect(img,x1+1,y-h-1,x2-x1-1,thick+2,K.void)
  rect(img,x1+2,y-h,x2-x1-3,thick,K.coal)
end
local function pipeDimV(img,x,y1,y2,thick)
  local h=math.floor(thick/2)
  rect(img,x-h-2,y1,thick+4,y2-y1+1,K.ink)
  rect(img,x-h-1,y1+1,thick+2,y2-y1-1,K.void)
  rect(img,x-h,y1+2,thick,y2-y1-3,K.coal)
end
local function steppedWindow(img,x,y,w,h)
  local cx,ay=x+math.floor(w/2),y+math.floor(w/2)
  disk(img,cx,ay,math.floor(w/2),K.ink)
  rect(img,x,ay,w,h-math.floor(w/2),K.ink)
  disk(img,cx,ay,math.floor(w/2)-3,K.void)
  rect(img,x+3,ay,w-6,h-math.floor(w/2)-3,K.void)
  rect(img,x+5,y+8,w-10,h-13,K.wall)
  rect(img,cx-1,y+7,2,h-12,K.coal)
  rect(img,x+5,y+27,w-10,2,K.coal)
  rect(img,x+5,y+51,w-10,2,K.coal)
  rect(img,x+1,y+h-3,w-2,3,K.steelDark)
end
local function topFrame(img)
  -- Narrow ceiling lintel; no foreground band across the playable field.
  rect(img,0,0,W,5,K.ink); rect(img,0,5,W,2,K.steelDark)
  rect(img,0,7,W,5,K.void); rect(img,0,12,W,1,K.coal)
  for x=13,555,54 do
    rect(img,x,1,18,11,K.wall); rect(img,x+2,2,14,2,K.steelDark)
    rect(img,x+3,5,1,5,K.coal); rect(img,x+14,5,1,5,K.coal)
    bolt(img,x+4,9,K.steelDark); bolt(img,x+13,9,K.steelDark)
  end
end
local function distantBuilding(arch,windows,variant,sharedWindowBay)
  rect(arch,0,0,W,H,K.ink)
  rect(arch,0,0,W,18,K.void); rect(arch,0,3,W,2,K.coal)
  rect(arch,0,15,W,3,K.ink)
  for x=17,559,68 do
    rect(arch,x,5,3,13,K.steelDark); rect(arch,x+4,7,1,8,K.coal)
    bolt(arch,x+1,8,K.steel)
  end
  rect(arch,0,20,W,2,K.void)
  local cols
  if sharedWindowBay then
    cols=variant==1 and {20,177,420,548} or {28,139,300,548}
  else
    cols=variant==1 and {20,177,354,548} or {28,139,300,548}
  end
  for _,x in ipairs(cols) do
    rect(arch,x,24,5,130,K.void); rect(arch,x+1,27,1,118,K.wall)
    rect(arch,x+5,31,3,118,K.ink)
    rect(arch,x-3,28,12,4,K.void); rect(arch,x-1,29,8,1,K.coal)
    bolt(arch,x+1,35,K.steelDark); bolt(arch,x+1,145,K.steelDark)
  end
  local ws
  if sharedWindowBay then
    ws={{344,56,38,78}}
  else
    ws=variant==1 and {{178,40,38,96},{260,44,38,92},{345,39,38,97},{430,48,34,88}}
      or {{92,45,38,91},{203,41,38,95},{311,47,38,89},{492,44,32,92}}
  end
  for _,v in ipairs(ws) do steppedWindow(windows,v[1],v[2],v[3],v[4]) end
  rect(arch,166,140,247,2,K.void)
  rect(arch,181,145,2,11,K.void); rect(arch,401,145,2,11,K.void)
end
local function drawTruss(img)
  local x1,x2=226,546
  rect(img,x1,26,x2-x1,3,K.ink); rect(img,x1+2,27,x2-x1-4,1,K.steelDark)
  rect(img,x1,46,x2-x1,3,K.ink); rect(img,x1+2,47,x2-x1-4,1,K.coal)
  for x=x1+4,x2-28,28 do
    line(img,x,29,x+26,46,K.void,3); line(img,x+26,29,x,46,K.void,2)
    bolt(img,x+2,29,K.steelDark)
  end
  rect(img,x1-3,25,5,26,K.void); rect(img,x2-2,25,5,26,K.void)
end
local function poster(img,x,y)
  rect(img,x-3,y-3,43,56,K.ink); rect(img,x-1,y-1,39,52,K.rust0)
  rect(img,x,y,37,49,K.paper); rect(img,x+2,y+2,33,45,K.stone)
  rect(img,x+3,y+3,31,3,K.paper)
  local glyphs={M={"101","111","111","101","101"},E={"111","100","110","100","111"},
    T={"111","010","010","010","010"},A={"010","101","111","101","101"}}
  for i,ch in ipairs({"M","E","T","A"}) do
    for yy,row in ipairs(glyphs[ch]) do for xx=1,3 do
      if row:sub(xx,xx)=="1" then rect(img,x+5+(i-1)*7+(xx-1)*2,y+9+(yy-1)*2,2,2,K.rust0) end
    end end
  end
  rect(img,x+5,y+24,27,1,K.paper)
  rect(img,x+6,y+27,3,12,K.rust0); rect(img,x+12,y+32,3,7,K.copper)
  rect(img,x+18,y+29,3,10,K.rust0); rect(img,x+24,y+26,3,13,K.copper)
  rect(img,x+5,y+42,24,1,K.paper); rect(img,x+7,y+44,20,1,K.stone)
  rect(img,x-3,y+4,2,34,K.steelDark)
  bolt(img,x+1,y+1,K.steelDark); bolt(img,x+34,y+1,K.steelDark)
end
local function lamp(img,x,y)
  -- Suspended bell shade with a wire and only three amber pixels.
  pipeV(img,x,y-22,y-5,2,K.steelDark)
  rect(img,x-3,y-7,6,2,K.ink)
  rect(img,x-6,y-5,12,2,K.ink)
  rect(img,x-5,y-3,10,2,K.steelDark)
  rect(img,x-4,y-1,8,2,K.copper)
  rect(img,x-3,y+1,6,4,K.rust0)
  pix(img,x-1,y+2,K.amber); pix(img,x,y+2,K.lamp); pix(img,x+1,y+2,K.amber)
end
local function drawBoiler(machine,pipe,detail,includeWallService)
  local cx,cy=82,103
  -- One pressure-vessel rim surrounds an off-centre service hatch; avoid a target-like stack of rings.
  disk(machine,cx,cy,62,K.ink); disk(machine,cx,cy-1,59,K.iron)
  arc(machine,cx,cy,58,54,-155,-18,K.steel)
  arc(machine,cx,cy,57,54,28,145,K.void)
  ring(machine,cx,cy,52,49,K.steelDark); disk(machine,cx,cy,49,K.iron2)
  arc(machine,cx,cy,47,45,-148,-30,K.steel)
  -- Asymmetric bolted access plate and offset pressure nipple give the boiler its own silhouette.
  rect(machine,56,78,39,50,K.ink)
  rect(machine,59,81,33,44,K.steelDark)
  rect(machine,61,83,29,40,K.iron)
  rect(machine,63,84,24,2,K.steel)
  rect(machine,63,119,24,2,K.void)
  rect(machine,57,87,4,9,K.coal); rect(machine,57,108,4,9,K.coal)
  rect(machine,91,88,4,8,K.void); rect(machine,91,108,4,8,K.void)
  bolt(machine,65,87,K.stone); bolt(machine,84,87,K.stone)
  bolt(machine,65,116,K.stone); bolt(machine,84,116,K.stone)
  rect(machine,68,97,13,16,K.ink)
  rect(machine,70,99,9,12,K.steelDark)
  rect(machine,72,101,5,8,K.copper)
  pix(machine,74,103,K.amber)
  rect(machine,86,101,7,4,K.stone); rect(machine,90,99,3,8,K.void)
  bolt(machine,71,91,K.steel); bolt(machine,80,112,K.steelDark)
  rect(machine,cx-52,cy-11,105,4,K.void)
  rect(machine,cx-50,cy-10,101,2,K.steelDark); rect(machine,cx-48,cy-10,96,1,K.steel)
  rect(machine,cx-55,cy-22,9,25,K.ink); rect(machine,cx-53,cy-20,5,21,K.steelDark)
  rect(machine,cx+46,cy-22,9,25,K.ink); rect(machine,cx+48,cy-20,5,21,K.steelDark)
  for deg=0,315,45 do
    local a=math.rad(deg)
    bolt(machine,cx+math.floor(math.cos(a)*44),cy+math.floor(math.sin(a)*44),K.stone)
  end
  for _,pt in ipairs({{-31,-29},{30,-29},{-31,30},{30,30}}) do bolt(machine,cx+pt[1],cy+pt[2],K.steel) end
  rect(machine,45,155,18,8,K.ink); rect(machine,48,158,12,6,K.steelDark)
  rect(machine,103,155,18,8,K.ink); rect(machine,106,158,12,6,K.steelDark)
  rect(machine,51,163,9,6,K.void); rect(machine,109,163,9,6,K.void)
  rect(machine,20,77,17,52,K.ink); rect(machine,23,80,12,46,K.steelDark)
  rect(machine,24,81,3,44,K.steel)
  rect(machine,26,42,54,12,K.ink); rect(machine,30,45,47,7,K.iron)
  rect(machine,35,43,37,2,K.steelDark)
  for x=34,66,16 do bolt(machine,x,49,K.stone) end
  -- Connected steam feed branches to a legible gauge and wheel valve.
  pipeH(pipe,129,224,96,6,K.copper); pipeV(pipe,168,34,96,5,K.copper)
  pipeH(pipe,113,168,37,5,K.copper); pipeV(pipe,113,37,60,5,K.copper)
  flangeV(pipe,168,65,5); flangeH(pipe,146,96,6); flangeH(pipe,210,96,6)
  disk(detail,222,76,16,K.ink); disk(detail,222,76,13,K.steelDark)
  disk(detail,222,76,10,K.stone); disk(detail,222,76,7,K.paper)
  ring(detail,222,76,13,11,K.steel)
  line(detail,222,76,226,69,K.rust0,1); disk(detail,222,76,2,K.rust0)
  for _,pt in ipairs({{-6,-5},{6,-5},{-7,4},{7,4}}) do pix(detail,222+pt[1],76+pt[2],K.rust0) end
  pipeV(pipe,222,92,96,4,K.copper); pipeV(pipe,279,96,113,4,K.copper)
  pipeH(pipe,279,311,113,4,K.copper); flangeV(pipe,279,101,4)
  ring(detail,279,126,10,7,K.copper); disk(detail,279,126,3,K.steelDark)
  for deg=0,120,60 do
    local a=math.rad(deg)
    line(detail,279-math.floor(math.cos(a)*7),126-math.floor(math.sin(a)*7),
      279+math.floor(math.cos(a)*7),126+math.floor(math.sin(a)*7),K.steel,2)
  end
  -- Compact steam clusters are stepped silhouettes, never a soft effect.
  disk(detail,148,29,8,K.void); disk(detail,155,23,7,K.void); disk(detail,162,17,5,K.void)
  disk(detail,149,31,5,K.wall); disk(detail,156,25,4,K.wall)
  if includeWallService ~= false then
    rect(machine,313,61,29,90,K.ink); rect(machine,317,66,20,81,K.void)
    rect(machine,320,70,3,74,K.steelDark)
    for y=77,110,11 do rect(machine,326,y,9,2,K.coal) end
    bolt(machine,320,73,K.steelDark); bolt(machine,334,142,K.steelDark)
    pipeH(pipe,311,391,29,4,K.steelDark); pipeV(pipe,391,29,54,4,K.steelDark)
    flangeH(pipe,359,29,4); lamp(detail,390,55); poster(detail,478,75)
  end
  -- Sparse wear marks are attached to joints and edges, never randomized.
  rect(detail,44,57,5,2,K.rust1); rect(detail,124,132,4,2,K.rust0)
  if includeWallService ~= false then rect(detail,320,123,4,2,K.rust1) end
  pix(detail,191,99,K.rust1)
end
local function drawCabinet(img,x,y,w,h,lit)
  rect(img,x-3,y-3,w+6,h+6,K.ink); rect(img,x,y,w,h,K.iron)
  rect(img,x+2,y+2,w-4,3,K.steelDark); rect(img,x+2,y+5,2,h-10,K.steel)
  rect(img,x+5,y+7,w-10,h-14,K.wall); rect(img,x+w-5,y+7,2,h-14,K.void)
  rect(img,x+7,y+11,w-14,1,K.steelDark); rect(img,x+7,y+h-12,w-14,1,K.steelDark)
  for dx=0,2 do rect(img,x+7+dx*4,y+16,2,6,K.coal) end
  bolt(img,x+w-8,y+10,K.stone); bolt(img,x+w-8,y+h-10,K.steelDark)
  rect(img,x+w-8,y+math.floor(h/2),3,7,K.ink)
  rect(img,x+w-7,y+math.floor(h/2)+1,1,4,K.stone)
  if lit then rect(img,x+6,y+7,3,3,K.amber); pix(img,x+7,y+7,K.lamp) end
end
local function drawPress(machine,pipe,detail)
  rect(machine,407,70,17,148,K.ink); rect(machine,410,73,10,141,K.iron)
  rect(machine,412,74,2,135,K.steelDark)
  rect(machine,504,70,17,148,K.ink); rect(machine,507,73,10,141,K.iron)
  rect(machine,509,74,2,135,K.steelDark)
  rect(machine,405,88,118,26,K.ink); rect(machine,409,91,110,18,K.iron)
  rect(machine,414,93,100,4,K.steelDark); rect(machine,419,99,90,8,K.wall)
  rect(machine,416,110,96,5,K.void)
  for x=420,500,20 do bolt(machine,x,103,K.steelDark) end
  disk(machine,464,67,19,K.ink); disk(machine,464,67,15,K.steelDark)
  rect(machine,450,54,29,14,K.iron); rect(machine,453,56,21,2,K.steel)
  rect(machine,458,68,12,39,K.void); rect(machine,461,70,6,37,K.steel)
  rect(machine,462,72,2,32,K.iron2)
  rect(machine,447,114,34,10,K.ink); rect(machine,451,116,26,5,K.steelDark)
  rect(machine,439,145,50,40,K.ink); rect(machine,443,149,42,31,K.iron)
  rect(machine,446,151,36,5,K.steelDark); rect(machine,448,158,32,18,K.wall)
  for x=451,472,7 do rect(machine,x,161,3,12,K.steelDark) end
  rect(machine,435,185,58,13,K.ink); rect(machine,440,188,48,8,K.steelDark)
  rect(machine,450,198,28,11,K.ink); rect(machine,453,201,22,7,K.iron)
  for x=417,511,94 do bolt(machine,x,80,K.steelDark); bolt(machine,x,205,K.steelDark) end
  pipeV(pipe,397,40,120,4,K.copper); pipeH(pipe,397,452,40,4,K.copper)
  pipeV(pipe,451,40,55,4,K.copper); flangeH(pipe,429,40,4)
  disk(detail,397,128,8,K.ink); disk(detail,397,128,6,K.stone)
  disk(detail,397,128,4,K.paper); line(detail,397,128,399,125,K.rust0,1)
  rect(detail,416,128,3,5,K.amber); pix(detail,417,129,K.lamp)
  rect(detail,510,126,3,4,K.amber)
  pipeH(pipe,482,520,69,3,K.steelDark); flangeH(pipe,494,69,3)
  rect(detail,485,134,5,2,K.rust0); rect(detail,431,172,4,2,K.rust1)
end
local function drawBoilerRoom(layers)
  distantBuilding(layers.arch,layers.windows,1); topFrame(layers.arch)
  -- Quiet rear wall machinery only occupies the far corners and the bottom edge.
  rect(layers.arch,0,219,66,2,K.ink); rect(layers.arch,0,221,62,45,K.void)
  rect(layers.arch,4,226,53,2,K.coal); rect(layers.arch,10,231,2,24,K.coal)
  rect(layers.arch,18,232,31,20,K.void); rect(layers.arch,22,236,21,12,K.coal)
  rect(layers.arch,487,213,89,2,K.ink); rect(layers.arch,492,215,84,58,K.void)
  rect(layers.arch,500,221,3,36,K.coal); rect(layers.arch,509,220,56,3,K.coal)
  rect(layers.arch,508,231,52,23,K.void); rect(layers.arch,513,235,41,2,K.coal)
  rect(layers.arch,0,291,576,33,K.void)
  rect(layers.arch,0,290,74,1,K.coal); rect(layers.arch,396,290,180,1,K.coal)
  drawBoiler(layers.machine,layers.pipes,layers.details)
  -- Side service run joins the boiler casing at x20 and the low machine foot.
  pipeDimH(layers.pipes,15,22,128,3); pipeDimV(layers.pipes,15,128,204,3)
  pipeDimH(layers.pipes,15,59,204,3); pipeDimV(layers.pipes,59,163,204,3)
  -- The right branch enters from the room edge and drops into a shadowed wall cabinet.
  pipeDimH(layers.pipes,527,580,142,3); pipeDimV(layers.pipes,563,142,196,3)
  pipeDimH(layers.pipes,550,580,183,3); pipeDimV(layers.pipes,563,183,260,3)
  pipeDimH(layers.pipes,542,563,260,3)
  rect(layers.machine,25,174,24,8,K.ink); rect(layers.machine,27,176,20,3,K.void)
  rect(layers.machine,532,177,21,7,K.ink); rect(layers.machine,534,179,17,2,K.void)
end
local function drawMaintenanceRoom(layers)
  distantBuilding(layers.arch,layers.windows,2); topFrame(layers.arch); drawTruss(layers.arch)
  -- Low-value wall bases stay behind machinery and leave the combat lane quiet.
  rect(layers.arch,0,242,27,2,K.ink); rect(layers.arch,0,244,25,45,K.void)
  rect(layers.arch,4,251,18,2,K.coal); rect(layers.arch,10,258,2,19,K.coal)
  rect(layers.arch,131,231,69,2,K.ink); rect(layers.arch,136,233,62,51,K.void)
  rect(layers.arch,143,240,49,2,K.coal); rect(layers.arch,143,250,3,22,K.coal)
  rect(layers.arch,518,258,58,2,K.ink); rect(layers.arch,523,260,53,31,K.void)
  rect(layers.arch,531,267,38,2,K.coal); rect(layers.arch,535,275,3,10,K.coal)
  rect(layers.arch,0,297,576,27,K.void)
  rect(layers.arch,0,296,207,1,K.coal); rect(layers.arch,518,296,58,1,K.coal)
  drawCabinet(layers.machine,31,134,45,65,true)
  drawCabinet(layers.machine,91,167,40,49,false)
  drawCabinet(layers.machine,145,184,28,33,false)
  rect(layers.machine,44,116,31,14,K.ink); rect(layers.machine,47,119,25,8,K.iron)
  rect(layers.machine,50,121,3,3,K.amber); rect(layers.machine,57,121,12,2,K.steelDark)
  pipeV(layers.pipes,22,68,184,3,K.steelDark); pipeH(layers.pipes,22,53,68,3,K.steelDark)
  pipeV(layers.pipes,53,68,126,3,K.steelDark); pipeH(layers.pipes,53,83,126,3,K.steelDark)
  pipeV(layers.pipes,83,126,177,3,K.copper); pipeH(layers.pipes,76,104,177,3,K.copper)
  pipeV(layers.pipes,104,177,207,3,K.copper); pipeH(layers.pipes,104,159,207,3,K.steelDark)
  pipeV(layers.pipes,159,152,207,3,K.steelDark)
  flangeV(layers.pipes,22,102,3); flangeH(layers.pipes,68,126,3); flangeV(layers.pipes,159,176,3)
  rect(layers.machine,176,154,18,25,K.ink); rect(layers.machine,179,157,12,19,K.iron)
  rect(layers.machine,181,160,8,2,K.steelDark); bolt(layers.machine,181,173,K.steelDark)
  line(layers.pipes,174,176,168,180,K.void,3); line(layers.pipes,168,180,168,196,K.void,3)
  line(layers.pipes,168,196,182,203,K.void,3)
  poster(layers.details,43,74); lamp(layers.details,71,58)
  drawPress(layers.machine,layers.pipes,layers.details)
  rect(layers.machine,535,147,28,50,K.ink); rect(layers.machine,538,150,22,43,K.iron)
  rect(layers.machine,541,153,2,36,K.steelDark)
  rect(layers.machine,546,158,10,2,K.void); rect(layers.machine,546,164,10,2,K.void)
  bolt(layers.machine,555,153,K.steelDark); bolt(layers.machine,555,190,K.steelDark)
  pipeH(layers.pipes,521,538,167,3,K.steelDark); flangeH(layers.pipes,531,167,3)
end
local function makePalette(sprite)
  local ok,pal=pcall(function()
    local q=Palette(#HEX)
    for i,h in ipairs(HEX) do q:setColor(i-1,Color(tonumber(h:sub(1,2),16),tonumber(h:sub(3,4),16),tonumber(h:sub(5,6),16),255)) end
    return q
  end)
  if ok then pcall(function() sprite.palette=pal end) end
end
local function saveScene(name,layers)
  local spr=Sprite(W,H)
  while #spr.layers>1 do spr:deleteLayer(spr.layers[#spr.layers]) end
  for i,item in ipairs(layers) do
    local layer=i==1 and spr.layers[1] or spr:newLayer()
    layer.name=item.name; layer.opacity=255
    spr:newCel(layer,1).image=item.image
  end
  makePalette(spr)
  spr:saveAs(OUT.."/"..name..".aseprite")
  spr:saveCopyAs(OUT.."/"..name..".png")
end
local function scaled(src,n)
  local dst=Image(src.width*n,src.height*n)
  for y=0,src.height-1 do for x=0,src.width-1 do
    local v=src:getPixel(x,y)
    for dy=0,n-1 do for dx=0,n-1 do dst:drawPixel(x*n+dx,y*n+dy,v) end end
  end end
  return dst
end
local function extract(src,x,y,w,h)
  local dst=Image(w,h)
  for py=0,h-1 do for px=0,w-1 do dst:drawPixel(px,py,src:getPixel(x+px,y+py)) end end
  return dst
end
local function pasteNearest(dst,src,x,y,n) dst:drawImage(scaled(src,n),x,y) end
local function platformStrip(atlas,widthNative,heightNative)
  local strip=Image(widthNative,heightNative)
  local cap=math.min(32,math.floor(widthNative/4))
  strip:drawImage(extract(atlas,0,96,cap,heightNative),0,0)
  local mid=extract(atlas,32,96,32,heightNative)
  local cursor=cap
  while cursor<widthNative-cap do
    local useW=math.min(32,widthNative-cap-cursor)
    strip:drawImage(extract(mid,0,0,useW,heightNative),cursor,0)
    cursor=cursor+useW
  end
  strip:drawImage(extract(atlas,96-cap,96,cap,heightNative),widthNative-cap,0)
  return strip
end
local function contextPreview(bg,outPath,platformLayout)
  local atlas=Image{fromFile=ATLAS_PATH}
  local playerAtlas=Image{fromFile=PLAYER_PATH}
  local canvas=Image(1152,648)
  canvas:drawImage(scaled(bg,2),0,0)
  local top,fill,bottom=extract(atlas,0,0,96,16),extract(atlas,0,32,96,14),extract(atlas,0,80,96,14)
  local floor=Image(576,44)
  for x=0,575 do
    local tx=x%96
    for y=0,15 do floor:drawPixel(x,y,top:getPixel(tx,y)) end
    for y=16,29 do floor:drawPixel(x,y,fill:getPixel(tx,y-16)) end
    for y=30,43 do floor:drawPixel(x,y,bottom:getPixel(tx,y-30)) end
  end
  pasteNearest(canvas,floor,0,560,2)
  platformLayout=platformLayout or {{224,440,200},{504,400,184},{768,376,184}}
  for _,pl in ipairs(platformLayout) do
    pasteNearest(canvas,platformStrip(atlas,math.floor(pl[3]/2),12),pl[1],pl[2],2)
  end
  -- Existing player idle frame added only to a static hierarchy preview.
  pasteNearest(canvas,extract(playerAtlas,0,0,64,64),260,312,2)
  canvas:saveAs(outPath)
end
local MOD = OUT .. "/modular"
local function makeModuleBase(variant)
  local arch,windows=image(),image()
  distantBuilding(arch,windows,variant,true)
  topFrame(arch)
  if variant==1 then
    rect(arch,0,219,66,2,K.ink); rect(arch,0,221,62,45,K.void)
    rect(arch,4,226,53,2,K.coal); rect(arch,10,231,2,24,K.coal)
    rect(arch,18,232,31,20,K.void); rect(arch,22,236,21,12,K.coal)
    rect(arch,487,213,89,2,K.ink); rect(arch,492,215,84,58,K.void)
    rect(arch,500,221,3,36,K.coal); rect(arch,509,220,56,3,K.coal)
    rect(arch,508,231,52,23,K.void); rect(arch,513,235,41,2,K.coal)
    rect(arch,0,291,576,33,K.void)
    rect(arch,0,290,74,1,K.coal); rect(arch,396,290,180,1,K.coal)
  else
    rect(arch,0,242,27,2,K.ink); rect(arch,0,244,25,45,K.void)
    rect(arch,4,251,18,2,K.coal); rect(arch,10,258,2,19,K.coal)
    rect(arch,131,231,69,2,K.ink); rect(arch,136,233,62,51,K.void)
    rect(arch,143,240,49,2,K.coal); rect(arch,143,250,3,22,K.coal)
    rect(arch,518,258,58,2,K.ink); rect(arch,523,260,53,31,K.void)
    rect(arch,531,267,38,2,K.coal); rect(arch,535,275,3,10,K.coal)
    rect(arch,0,297,576,27,K.void)
    rect(arch,0,296,207,1,K.coal); rect(arch,518,296,58,1,K.coal)
  end
  arch:drawImage(windows,0,0)
  return arch
end
local function drawCabinetCluster(layers)
  drawCabinet(layers.machine,31,134,45,65,true)
  drawCabinet(layers.machine,91,167,40,49,false)
  drawCabinet(layers.machine,145,184,28,33,false)
  rect(layers.machine,44,116,31,14,K.ink); rect(layers.machine,47,119,25,8,K.iron)
  rect(layers.machine,50,121,3,3,K.amber); rect(layers.machine,57,121,12,2,K.steelDark)
  pipeV(layers.pipes,22,68,184,3,K.steelDark); pipeH(layers.pipes,22,53,68,3,K.steelDark)
  pipeV(layers.pipes,53,68,126,3,K.steelDark); pipeH(layers.pipes,53,83,126,3,K.steelDark)
  pipeV(layers.pipes,83,126,177,3,K.copper); pipeH(layers.pipes,76,104,177,3,K.copper)
  pipeV(layers.pipes,104,177,207,3,K.copper); pipeH(layers.pipes,104,159,207,3,K.steelDark)
  pipeV(layers.pipes,159,152,207,3,K.steelDark)
  flangeV(layers.pipes,22,102,3); flangeH(layers.pipes,68,126,3); flangeV(layers.pipes,159,176,3)
  rect(layers.machine,176,154,18,25,K.ink); rect(layers.machine,179,157,12,19,K.iron)
  rect(layers.machine,181,160,8,2,K.steelDark); bolt(layers.machine,181,173,K.steelDark)
  line(layers.pipes,174,176,168,180,K.void,3); line(layers.pipes,168,180,168,196,K.void,3)
  line(layers.pipes,168,196,182,203,K.void,3)
  poster(layers.details,43,74); lamp(layers.details,71,58)
end
local function drawWallServiceCluster(layers)
  rect(layers.machine,313,61,29,90,K.ink); rect(layers.machine,317,66,20,81,K.void)
  rect(layers.machine,320,70,3,74,K.steelDark)
  for y=77,110,11 do rect(layers.machine,326,y,9,2,K.coal) end
  bolt(layers.machine,320,73,K.steelDark); bolt(layers.machine,334,142,K.steelDark)
  -- A short overhead branch joins the service column and suspended lamp.
  pipeH(layers.pipes,320,391,29,4,K.steelDark); pipeV(layers.pipes,320,29,61,4,K.steelDark)
  pipeV(layers.pipes,391,29,51,4,K.steelDark); flangeH(layers.pipes,359,29,4)
  lamp(layers.details,390,55); poster(layers.details,478,75)
  rect(layers.details,320,123,4,2,K.rust1)
end
local function drawPressCluster(layers)
  drawTruss(layers.arch)
  drawPress(layers.machine,layers.pipes,layers.details)
  rect(layers.machine,535,147,28,50,K.ink); rect(layers.machine,538,150,22,43,K.iron)
  rect(layers.machine,541,153,2,36,K.steelDark)
  rect(layers.machine,546,158,10,2,K.void); rect(layers.machine,546,164,10,2,K.void)
  bolt(layers.machine,555,153,K.steelDark); bolt(layers.machine,555,190,K.steelDark)
  pipeH(layers.pipes,521,538,167,3,K.steelDark); flangeH(layers.pipes,531,167,3)
end
local function composeImages(images)
  local out=image()
  for _,img in ipairs(images) do out:drawImage(img,0,0) end
  return out
end
local function cropAlpha(src)
  local x0,y0,x1,y1=src.width,src.height,-1,-1
  for y=0,src.height-1 do for x=0,src.width-1 do
    if pc.rgbaA(src:getPixel(x,y))>0 then
      if x<x0 then x0=x end; if y<y0 then y0=y end
      if x>x1 then x1=x end; if y>y1 then y1=y end
    end
  end end
  if x1<x0 or y1<y0 then return Image(1,1),0,0 end
  local out=Image(x1-x0+1,y1-y0+1)
  for y=0,out.height-1 do for x=0,out.width-1 do
    out:drawPixel(x,y,src:getPixel(x+x0,y+y0))
  end end
  return out,x0,y0
end
local function moduleLayers()
  return {arch=image(),pipes=image(),machine=image(),details=image()}
end
local function moduleComposite(layers)
  return composeImages({layers.arch,layers.pipes,layers.machine,layers.details})
end
local function saveBaseSource(base0,base1)
  local spr=Sprite(W,H)
  while #spr.layers>1 do spr:deleteLayer(spr.layers[#spr.layers]) end
  local l0=spr.layers[1]; l0.name="Base 0 - Boiler windows"; l0.opacity=255
  spr:newCel(l0,1).image=base0
  local l1=spr:newLayer(); l1.name="Base 1 - Maintenance windows"; l1.opacity=255; l1.isVisible=false
  spr:newCel(l1,1).image=base1
  makePalette(spr); spr:saveAs(MOD.."/factory-floor1-bases.aseprite")
end
local function saveModuleSource(atlasW,atlasH,mods)
  local spr=Sprite(atlasW,atlasH)
  while #spr.layers>1 do spr:deleteLayer(spr.layers[#spr.layers]) end
  for i,m in ipairs(mods) do
    local layer=i==1 and spr.layers[1] or spr:newLayer()
    layer.name=m.label; layer.opacity=255
    local placed=Image(atlasW,atlasH); placed:drawImage(m.image,m.x,m.y)
    spr:newCel(layer,1).image=placed
  end
  makePalette(spr); spr:saveAs(MOD.."/factory-floor1-modules.aseprite")
end
local function writeImageTextureTres(path,id,img)
  local f=assert(io.open(path,"w"))
  f:write('[gd_resource type="ImageTexture" load_steps=2 format=3]\n\n')
  f:write('[sub_resource type="Image" id="',id,'"]\n')
  f:write('data = { "data": PackedByteArray(\n')
  local total=img.width*img.height
  local n=0
  for y=0,img.height-1 do for x=0,img.width-1 do
    local c=img:getPixel(x,y)
    f:write(tostring(pc.rgbaR(c)),',',tostring(pc.rgbaG(c)),',',tostring(pc.rgbaB(c)),',',tostring(pc.rgbaA(c)))
    n=n+1
    if n<total then f:write(',') end
    if n%32==0 then f:write('\n') end
  end end
  f:write('\n), "format": "RGBA8", "height": ',tostring(img.height),
    ', "mipmaps": false, "width": ',tostring(img.width),' }\n\n')
  f:write('[resource]\nimage = SubResource("',id,'")\n')
  f:close()
end
local function writeAtlasTextureTres(path,atlasPath,rx,ry,rw,rh)
  local f=assert(io.open(path,"w"))
  f:write('[gd_resource type="AtlasTexture" load_steps=2 format=3]\n\n')
  f:write('[ext_resource type="Texture2D" path="res://resources/environment/',atlasPath,'" id="1_atlas"]\n\n')
  f:write('[resource]\natlas = ExtResource("1_atlas")\n')
  f:write('region = Rect2(',tostring(rx),', ',tostring(ry),', ',tostring(rw),', ',tostring(rh),')\n')
  f:close()
end
local function saveMetadataAndTres(base0,base1,baseAtlas,moduleAtlas,mods,atlasW,atlasH)
  writeImageTextureTres(ROOT.."/resources/environment/factory_floor1_base_atlas_texture.tres",
    "Image_floor1_bases",baseAtlas)
  writeImageTextureTres(ROOT.."/resources/environment/factory_floor1_modules_atlas_texture.tres",
    "Image_floor1_modules",moduleAtlas)
  writeAtlasTextureTres(ROOT.."/resources/environment/factory_floor1_base_boiler_texture.tres",
    "factory_floor1_base_atlas_texture.tres",0,0,W,H)
  writeAtlasTextureTres(ROOT.."/resources/environment/factory_floor1_base_maintenance_texture.tres",
    "factory_floor1_base_atlas_texture.tres",0,H,W,H)
  for _,m in ipairs(mods) do
    writeAtlasTextureTres(ROOT.."/resources/environment/factory_floor1_"..m.id.."_texture.tres",
      "factory_floor1_modules_atlas_texture.tres",m.x,m.y,m.image.width,m.image.height)
  end
  local f=assert(io.open(MOD.."/regions-and-anchors.json","w"))
  f:write('{\n  "shared_window_aperture_native_px":[344,56,38,78],\n  "module_atlas": {"file":"factory-floor1-modules-atlas.png","width_px":',tostring(atlasW),
    ',"height_px":',tostring(atlasH),'},\n  "modules": [\n')
  for i,m in ipairs(mods) do
    f:write('    {"id":"',m.id,'","label":"',m.label,'","region_px":[',tostring(m.x),',',tostring(m.y),',',
      tostring(m.image.width),',',tostring(m.image.height),'],"anchor_native_px":[',tostring(m.anchor_x),',',
      tostring(m.anchor_y),']}')
    if i<#mods then f:write(',') end
    f:write('\n')
  end
  f:write('  ],\n  "base_variants": [\n')
  f:write('    {"id":"base_boiler","region_px":[0,0,576,324],"anchor_native_px":[0,0]},\n')
  f:write('    {"id":"base_maintenance","region_px":[0,324,576,324],"anchor_native_px":[0,0]}\n')
  f:write('  ],\n  "selection":"base bit 0, left module bit 1, right module bit 2; all derived from prepared room seed"\n}\n')
  f:close()
end
local function generateModularAssets()
  local base0,base1=makeModuleBase(1),makeModuleBase(2)
  base0:saveAs(MOD.."/factory-floor1-base-boiler.png")
  base1:saveAs(MOD.."/factory-floor1-base-maintenance.png")
  local baseAtlas=Image(W,H*2); baseAtlas:drawImage(base0,0,0); baseAtlas:drawImage(base1,0,H)
  baseAtlas:saveAs(MOD.."/factory-floor1-bases-atlas.png")
  local lb=moduleLayers(); drawBoiler(lb.machine,lb.pipes,lb.details,false)
  local lc=moduleLayers(); drawCabinetCluster(lc)
  local rs=moduleLayers(); drawWallServiceCluster(rs)
  local rp=moduleLayers(); drawPressCluster(rp)
  local specs={}
  local function addModule(id,label,full)
    local crop,ax,ay=cropAlpha(full)
    specs[#specs+1]={id=id,label=label,image=crop,anchor_x=ax,anchor_y=ay}
    crop:saveAs(MOD.."/factory-floor1-module-"..id..".png")
  end
  addModule("left_boiler","Left: boiler and complete steam circuit",moduleComposite(lb))
  addModule("left_cabinets","Left: service cabinets and connected controls",moduleComposite(lc))
  addModule("right_service","Right: service column, lamp and META sign",moduleComposite(rs))
  addModule("right_press","Right: truss, press and complete feed circuit",moduleComposite(rp))
  local press,service,boiler,cabinets=specs[4],specs[3],specs[1],specs[2]
  local row1h=math.max(press.image.height,service.image.height)
  local row2y=2+row1h+4
  press.x,press.y=2,2
  service.x,service.y=press.x+press.image.width+4,2
  boiler.x,boiler.y=2,row2y
  cabinets.x,cabinets.y=boiler.x+boiler.image.width+4,row2y
  local atlasW=math.max(service.x+service.image.width+2,cabinets.x+cabinets.image.width+2)
  local atlasH=row2y+math.max(boiler.image.height,cabinets.image.height)+2
  local moduleAtlas=Image(atlasW,atlasH)
  for _,m in ipairs(specs) do moduleAtlas:drawImage(m.image,m.x,m.y) end
  moduleAtlas:saveAs(MOD.."/factory-floor1-modules-atlas.png")
  saveBaseSource(base0,base1); saveModuleSource(atlasW,atlasH,specs)
  saveMetadataAndTres(base0,base1,baseAtlas,moduleAtlas,specs,atlasW,atlasH)
  local combos={
    {bits="000",base=0,left=0,right=0,layout={{224,440,200},{504,400,184},{768,376,184}}},
    {bits="011",base=0,left=1,right=1,layout={{200,432,176},{456,408,192},{744,376,184}}},
    {bits="101",base=1,left=0,right=1,layout={{216,416,184},{480,440,168},{760,392,200}}},
    {bits="110",base=1,left=1,right=0,layout={{232,440,168},{488,408,200},{760,384,184}}}
  }
  local contact=Image(2304,1296)
  for i,c in ipairs(combos) do
    local bg=Image(W,H); bg:drawImage(c.base==0 and base0 or base1,0,0)
    local left=specs[c.left==0 and 1 or 2]; local right=specs[c.right==0 and 3 or 4]
    bg:drawImage(left.image,left.anchor_x,left.anchor_y)
    bg:drawImage(right.image,right.anchor_x,right.anchor_y)
    local previewPath=MOD.."/context-seed-"..c.bits..".png"
    contextPreview(bg,previewPath,c.layout)
    local preview=Image{fromFile=previewPath}
    local cx=((i-1)%2)*1152; local cy=math.floor((i-1)/2)*648
    contact:drawImage(preview,cx,cy)
  end
  contact:saveAs(MOD.."/factory-floor1-procedural-contact.png")
  local captions=assert(io.open(MOD.."/context-captions.txt","w"))
  captions:write("Factory floor 1 — static hierarchy/contact preview\n")
  captions:write("Sample platforms and character are static context props, not a gameplay capture or a particular generated room layout.\n\n")
  captions:write("Top left: bits 000 — boiler-wall base / left boiler circuit / right service sign (illustrative seed 0).\n")
  captions:write("Top right: bits 011 — boiler-wall base / left cabinet bank / right press (illustrative seed 6).\n")
  captions:write("Bottom left: bits 101 — maintenance-wall base / left boiler circuit / right press (illustrative seed 5).\n")
  captions:write("Bottom right: bits 110 — maintenance-wall base / left cabinet bank / right service sign (illustrative seed 3).\n\n")
  captions:write("Runtime selection uses seed bit 0 for base, bit 1 for left module, and bit 2 for right module.\n")
  captions:close()
  print("Aseprite generated native modular backgrounds, atlas, ImageTexture resources, and four static seed contexts.")
end
local function generateWindowRevisionBases()
  local base0,base1=makeModuleBase(1),makeModuleBase(2)
  base0:saveAs(MOD.."/factory-floor1-base-boiler.png")
  base1:saveAs(MOD.."/factory-floor1-base-maintenance.png")
  local baseAtlas=Image(W,H*2)
  baseAtlas:drawImage(base0,0,0); baseAtlas:drawImage(base1,0,H)
  baseAtlas:saveAs(MOD.."/factory-floor1-bases-atlas.png")
  saveBaseSource(base0,base1)
  writeImageTextureTres(ROOT.."/resources/environment/factory_floor1_base_atlas_texture.tres",
    "Image_floor1_bases",baseAtlas)

  -- Existing transparent module exports and anchors are read-only inputs here.
  local leftBoiler=Image{fromFile=MOD.."/factory-floor1-module-left_boiler.png"}
  local leftCabinets=Image{fromFile=MOD.."/factory-floor1-module-left_cabinets.png"}
  local rightService=Image{fromFile=MOD.."/factory-floor1-module-right_service.png"}
  local rightPress=Image{fromFile=MOD.."/factory-floor1-module-right_press.png"}
  local combos={}
  for seed=0,7 do
    local baseBit=seed%2
    local leftBit=math.floor(seed/2)%2
    local rightBit=math.floor(seed/4)%2
    combos[#combos+1]={
      seed=seed,
      bits=tostring(baseBit)..tostring(leftBit)..tostring(rightBit),
      base=baseBit,
      left=leftBit,
      right=rightBit
    }
  end
  local contact=Image(4608,1296)
  local baseImages={base0,base1}
  local leftImages={leftBoiler,leftCabinets}
  local rightImages={rightService,rightPress}
  local leftAnchors={{20,12},{18,36}}
  local rightAnchors={{313,24},{223,25}}
  for i,c in ipairs(combos) do
    local bg=Image(W,H)
    bg:drawImage(baseImages[c.base+1],0,0)
    local la,ra=leftAnchors[c.left+1],rightAnchors[c.right+1]
    bg:drawImage(leftImages[c.left+1],la[1],la[2])
    bg:drawImage(rightImages[c.right+1],ra[1],ra[2])
    local previewPath=MOD.."/context-seed-"..c.bits..".png"
    contextPreview(bg,previewPath)
    local preview=Image{fromFile=previewPath}
    local cx=((i-1)%4)*1152
    local cy=math.floor((i-1)/4)*648
    contact:drawImage(preview,cx,cy)
  end
  contact:saveAs(MOD.."/factory-floor1-procedural-contact.png")
  local captions=assert(io.open(MOD.."/context-captions.txt","w"))
  captions:write("Factory floor 1 — static hierarchy/contact preview, shared clear window bay\n")
  captions:write("Every cell is a fixed 1152x648 composition; sample platforms and character are static context props, not runtime captures.\n")
  captions:write("Bit order is base-left-right. Seed = base + 2*left + 4*right; this sheet enumerates the eight cosmetic combinations.\n\n")
  for _,c in ipairs(combos) do
    local baseName=c.base==0 and "boiler wall" or "maintenance wall"
    local leftName=c.left==0 and "boiler circuit" or "service cabinets"
    local rightName=c.right==0 and "service sign" or "press"
    local column=(c.seed%4)+1
    local row=math.floor(c.seed/4)+1
    captions:write("Seed ",tostring(c.seed)," / ",c.bits," — contact row ",tostring(row),", column ",tostring(column),": ",
      baseName," / ",leftName," / ",rightName,".\n")
  end
  captions:write("All seeds keep the shared recessed window at native Rect2(344,56,38,78); modules stay complete and unmirrored.\n")
  captions:close()
  print("Aseprite bases-only mode updated the two wall bases, native base ImageTexture, and eight static contexts; modules were read without modification.")
end
local function makeLayerSet()
  return {
    {name="Far wall and ceiling structure",image=image()},
    {name="Recessed windows and bays",image=image()},
    {name="Connected service pipework",image=image()},
    {name="Boiler and machinery silhouettes",image=image()},
    {name="Wear, gauges, signage and lamps",image=image()}
  }
end
if MODE=="bases-only" then
  generateWindowRevisionBases()
elseif MODE=="full" then
  local a,b=makeLayerSet(),makeLayerSet()
  drawBoilerRoom({arch=a[1].image,windows=a[2].image,pipes=a[3].image,machine=a[4].image,details=a[5].image})
  drawMaintenanceRoom({arch=b[1].image,windows=b[2].image,pipes=b[3].image,machine=b[4].image,details=b[5].image})
  saveScene("factory-floor1-boiler-room",a)
  saveScene("factory-floor1-maintenance-room",b)
  local room1=Image{fromFile=OUT.."/factory-floor1-boiler-room.png"}
  local room2=Image{fromFile=OUT.."/factory-floor1-maintenance-room.png"}
  scaled(room1,2):saveAs(OUT.."/factory-floor1-boiler-room-preview-2x.png")
  scaled(room1,4):saveAs(OUT.."/factory-floor1-boiler-room-preview-4x.png")
  scaled(room2,2):saveAs(OUT.."/factory-floor1-maintenance-room-preview-2x.png")
  scaled(room2,4):saveAs(OUT.."/factory-floor1-maintenance-room-preview-4x.png")
  contextPreview(room1,OUT.."/factory-floor1-boiler-room-context-v2.png")
  contextPreview(room2,OUT.."/factory-floor1-maintenance-room-context-v2.png")
  generateModularAssets()
  generateWindowRevisionBases()
  print("Generated V2 studies, procedural modular resources, and all eight static contexts.")
else
  error("Unsupported mode: "..tostring(MODE))
end