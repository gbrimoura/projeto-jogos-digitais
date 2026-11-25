-- Source: the shipped 96x96 pose from the introduction. Reference parameter
-- accepts assets/narrative/intro/rework/iris.png.
local out = assert(app.params.out)
local reference = Image{fromFile=assert(app.params.reference)}
local pixel = app.pixelColor
local size = 96
local standing = 4 * size
local function color(hex)
  return pixel.rgba((hex>>16)&255,(hex>>8)&255,hex&255,255)
end
local function box(img, x, y, w, h, hex)
  local value = color(hex)
  for yy=y,y+h-1 do
    for xx=x,x+w-1 do
      img:drawPixel(xx,yy,value)
    end
  end
end
local function make_idle()
  local img=Image(64,64,ColorMode.RGB)
  -- Keep the original costume and silhouette. Re-register the boots at y58
  -- and widen just enough for the in-game pixel grid.
  for y=8,58 do
    local ry=6+math.floor((y-8)*75/50+0.5)
    for x=19,44 do
      local rx=34+math.floor((x-19)*31/25+0.5)
      img:drawPixel(x,y,reference:getPixel(standing+rx,ry))
    end
  end
  -- Reinforce the lens, cheek and sleeve clusters after resampling.
  box(img,34,9,2,1,0xADC3BF)
  box(img,34,10,3,1,0x627783)
  box(img,38,13,1,1,0xF7DFB4)
  box(img,39,13,1,1,0x231C25)
  box(img,37,16,3,1,0xE29868)
  return img
end
local first = make_idle()
local function build(index)
  if index==0 then return first end
  local img=Image(64,64,ColorMode.RGB)
  img:drawImage(first,Point(0,0))
  if index==1 then
    -- A single-pixel shift in the chest and head keeps planted boots still.
    for y=7,29 do for x=19,44 do
      img:drawPixel(x,y,first:getPixel(x,y+1))
    end end
  elseif index==2 then
    box(img,38,13,2,1,0x50373A)
  else
    -- The far hand checks a small open-end spanner.
    box(img,40,34,4,6,0x293931)
    box(img,42,34,7,4,0x293931)
    box(img,43,35,5,2,0x495849)
    box(img,47,34,4,4,0xA35C3E)
    box(img,47,34,3,1,0xE29868)
    box(img,51,29,2,8,0x363646)
    box(img,51,31,1,4,0x627783)
    box(img,50,29,4,3,0x627783)
    box(img,50,28,1,2,0xADC3BF)
    box(img,53,28,1,2,0xADC3BF)
  end
  return img
end
local source=Sprite(64,64,ColorMode.RGB)
source.layers[1].name="Íris — oficina"
local sheet=Image(256,64,ColorMode.RGB)
local names={"Bancada","Respira","Pisca","Ferramenta"}
for i=1,4 do
  if i>1 then source:newEmptyFrame() end
  local frame=build(i-1)
  source:newCel(source.layers[1],i,frame,Point(0,0))
  source.frames[i].duration=({0.9,0.25,0.12,0.35})[i]
  source:newTag(i,i).name=names[i]
  sheet:drawImage(frame,Point((i-1)*64,0))
end
assert(source:saveAs(out.."/iris-workshop.aseprite"))
assert(sheet:saveAs(out.."/iris-workshop.png"))

local portrait=Image(48,48,ColorMode.RGB)
for y=0,47 do for x=0,47 do
  local rx=36+(x*2//3)
  local ry=3+(y*2//3)
  portrait:drawPixel(x,y,reference:getPixel(standing+rx,ry))
end end
assert(portrait:saveAs(out.."/iris-portrait.png"))
