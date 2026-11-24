local out=assert(app.params.out)
local pc=app.pixelColor
local colors={
  black=0x10131C, ink=0x141A24, navy=0x18212C, dark=0x1C2935,
  plate=0x243340, edge=0x344654, dusty=0x405261, iron=0x2B3037,
  copper=0x594037, brass=0x7A5A41, light=0xB18751, darkgold=0x463831,
  glass=0x1C3540, glassDark=0x162C37, shine=0x2B4750, lowshine=0x233D47,
  warning=0xA36145, off=0x46404A, rivet=0x5A6064,
}
local p={}
for k,c in pairs(colors) do p[k]=pc.rgba(c>>16,(c>>8)&255,c&255,255) end
local image=Image(576,280)
local function rect(c,x,y,w,h)
  for py=math.max(y,0),math.min(y+h-1,279) do
    for px=math.max(x,0),math.min(x+w-1,575) do image:drawPixel(px,py,p[c]) end
  end
end
local function disc(c,x,y,r)
  for dy=-r,r do
    local dx=math.floor(math.sqrt(r*r-dy*dy))
    rect(c,x-dx,y+dy,dx*2+1,1)
  end
end
local function diag(c,x,y,dx,dy,n,w)
  for i=0,n-1 do rect(c,x+dx*i,y+dy*i,w,w) end
end
local function frame(x,y,w,h)
  rect('black',x,y,w,h)
  rect('edge',x+2,y+2,w-4,2)
  rect('dark',x+2,y+4,w-4,h-6)
  rect('plate',x+4,y+6,w-8,h-9)
  rect('black',x+6,y+8,w-12,h-13)
end
local function bolt(x,y)
  rect('black',x,y,3,3)
  rect('rivet',x,y,2,1)
  rect('iron',x+1,y+2,2,1)
end
local function bracket(x,y,w)
  rect('black',x,y,w,14)
  rect('iron',x+2,y+2,w-4,10)
  rect('dusty',x+3,y+2,w-6,2)
  rect('navy',x+3,y+9,w-6,2)
  for i=7,w-7,15 do bolt(x+i,y+6) end
end

rect('ink',0,0,576,280)
for row=0,6 do
  local y=16+row*40
  rect('black',0,y,576,1)
  rect('navy',0,y+1,576,2)
  for x=(row%2)*37,575,74 do
    rect('navy',x,y+4,1,35)
    rect('black',x-1,y+8,1,31)
  end
end

-- Two tall inspection bays. Reflections and distant silhouettes stay behind the mullions.
for _,x in ipairs({53,373}) do
  frame(x,61,150,127)
  rect('glassDark',x+9,70,132,107)
  for i=0,2 do
    local left=x+10+i*44
    rect('glass',left,71,41,69)
    rect('lowshine',left+3,75,35,2)
    diag('lowshine',left+2,104,1,-1,29,2)
    diag('shine',left+4,104,1,-1,27,1)
    rect('navy',left+10,137+i%2*10,9,38)
    rect('plate',left+22,147-i%2*12,5,29)
    rect('black',left+41,70,3,107)
    rect('edge',left+41,71,1,105)
  end
  rect('black',x+7,120,136,5)
  rect('edge',x+7,120,136,1)
  rect('copper',x+5,181,140,2)
  bolt(x+4,65)
  bolt(x+142,65)
  bolt(x+4,182)
  bolt(x+142,182)
end

-- Pressure tower, metal uprights, gauge surround and a suspended carriage.
frame(224,0,128,260)
rect('navy',232,11,112,221)
for _,x in ipairs({239,329}) do
  rect('black',x,0,8,250)
  rect('edge',x+1,2,2,246)
end
rect('iron',246,36,84,7)
rect('plate',248,36,80,2)
for _,y in ipairs({67,96,126,159,195,225}) do
  rect('dark',249,y,78,3)
  bolt(251,y)
  bolt(321,y)
end
disc('black',288,109,48)
disc('iron',288,109,45)
disc('darkgold',288,109,42)
disc('navy',288,109,40)
for tick=0,11 do
  local a=(0.85+tick*0.115)*math.pi
  local x=288+math.floor(math.cos(a)*35+0.5)
  local y=109+math.floor(math.sin(a)*35+0.5)
  rect(tick>8 and 'copper' or 'dusty',x-1,y-1,3,3)
end
rect('black',282,33,12,58)
rect('iron',284,33,8,53)
rect('brass',286,34,2,46)
bracket(232,32,112)

-- Symmetric air pipes outside the inspection windows and inset floor channels.
for _,x in ipairs({18,539}) do
  rect('black',x,0,13,263)
  rect('copper',x+2,1,8,254)
  rect('brass',x+3,1,2,254)
  for _,y in ipairs({43,101,156,212}) do bracket(x-4,y,21) end
end
for _,x in ipairs({56,226,397}) do
  frame(x,221,122,41)
  for slot=0,13 do
    rect('navy',x+9+slot*8,230,5,23)
    rect('edge',x+9+slot*8,231,1,20)
  end
  rect('darkgold',x+7,254,108,2)
end

rect('black',0,266,576,14)
rect('iron',0,268,576,4)
rect('copper',0,269,576,1)
for x=10,560,25 do bolt(x,274) end
for _,x in ipairs({83,281,479}) do
  rect('black',x,262,15,8)
  rect('brass',x+2,264,11,3)
  rect('light',x+3,264,7,1)
end

assert(image:saveAs(out .. "/pressure-hall.png"))

