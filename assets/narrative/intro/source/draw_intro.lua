local out = assert(app.params.out)
local kind = assert(app.params.art)
local pc = app.pixelColor
-- Shared factory palette, with a warm work lamp and a cold access light.
local palette = {
  ink=0x0D1420, deep=0x151D2A, navy=0x1C2938, blue=0x263B4A,
  steel=0x354552, light=0x59636A, pale=0xB3AA94, ivory=0xF2E4C9,
  soil=0x272B34, rust=0x603C34, brown=0x865844, copper=0xAC784E,
  amber=0xE8AA59, glow=0xFFDE92, lamp=0x875A38, shadow=0x453738,
  sea=0x264C4F, teal=0x448680, mint=0x82C9B5, ice=0xC3EEE0,
  canvas=0x405F59, fine=0x607B69, red=0xBA5648, scarf=0xDA7953,
}
local colors = {}
for name,rgb in pairs(palette) do
  colors[name] = pc.rgba((rgb >> 16)&255,(rgb >> 8)&255,rgb&255,255)
end

local image
local function box(c,x,y,w,h)
  for yy=math.max(0,y),math.min(image.height-1,y+h-1) do
    for xx=math.max(0,x),math.min(image.width-1,x+w-1) do
      image:drawPixel(xx,yy,colors[c])
    end
  end
end

local function poly(c,points)
  local ymin,ymax = image.height,0
  for _,p in ipairs(points) do ymin=math.min(ymin,p[2]) ymax=math.max(ymax,p[2]) end
  for y=math.max(0,ymin),math.min(ymax,image.height-1) do
    local crossings={}
    for i,a in ipairs(points) do
      local b=points[i % #points + 1]
      local j=y+0.5
      if (a[2]>j) ~= (b[2]>j) then
        crossings[#crossings+1]=a[1]+(b[1]-a[1])*(j-a[2])/(b[2]-a[2])
      end
    end
    table.sort(crossings)
    for i=1,#crossings,2 do
      local left=math.ceil(crossings[i]-0.5)
      box(c,left,y,math.ceil(crossings[i+1]-0.5)-left,1)
    end
  end
end

local function save_sprite(w,h,file,name)
  local sprite=Sprite(w,h,ColorMode.RGB)
  sprite.layers[1].name=name
  sprite:newCel(sprite.layers[1], 1, image, Point(0,0))
  assert(sprite:saveAs(out.."/"..file))
end

local function backdrop()
  image=Image(576,324)
  box("ink",0,0,576,324)
  box("deep",0,20,576,215)
  box("navy",70,37,423,194)
  for x=78,480,44 do
    box("deep",x,55,2,170)
    box("blue",x+3,56,1,168)
  end
  for y=60,214,30 do
    box("deep",70,y,422,3)
    box("blue",70,y+4,422,1)
    for x=84,480,88 do box("steel",x,y+8,4,2) end
  end
  for _,x in ipairs({27,105,457,539}) do
    box("ink",x,39,21,194)
    box("deep",x+2,42,17,189)
    box("blue",x+4,45,3,183)
    box("steel",x+6,84,9,4)
    box("steel",x+6,176,9,4)
  end
  -- Closed receiving shutter and offset side entrance.
  box("ink",128,80,102,135)
  box("steel",131,83,96,128)
  box("deep",136,88,86,122)
  for y=92,198,9 do
    box("blue",139,y,80,5)
    box("ink",139,y+5,80,2)
  end
  box("rust",135,182,89,6)
  box("brown",136,182,36,2)
  box("ink",481,112,66,126)
  box("steel",484,115,60,120)
  box("deep",490,123,49,112)
  box("navy",493,126,42,108)
  box("sea",499,136,30,96)
  box("teal",501,137,1,94)
  box("mint",524,152,2,52)
  box("ice",524,175,2,14)
  box("steel",484,213,60,8)
  box("teal",496,118,40,3)
  box("mint",509,117,13,1)
  for i=0,4 do
    poly(i%2==0 and "copper" or "rust",{{492+i*9,222},{499+i*9,222},{494+i*9,229},{487+i*9,229}})
  end
  -- Lit workshop window and a vent bank with service pipes.
  box("ink",52,82,59,82)
  box("rust",55,85,53,76)
  box("lamp",58,88,47,70)
  box("copper",58,88,47,31)
  poly("amber",{{59,89},{103,89},{103,99},{84,102},{63,125},{59,125}})
  poly("shadow",{{60,146},{66,128},{77,121},{83,134},{92,128},{103,127},{103,158},{60,158}})
  box("deep",79,87,4,73)
  box("ink",57,118,48,4)
  box("brown",53,161,58,3)
  box("ink",361,103,72,57)
  box("steel",365,106,64,51)
  box("deep",370,110,54,41)
  for y=115,142,7 do
    box("steel",374,y,46,4)
    box("blue",376,y+1,44,2)
  end
  box("ink",332,133,32,12)
  box("rust",335,136,27,7)
  box("brown",337,136,25,2)
  box("ink",331,98,12,44)
  box("rust",334,100,7,39)
  box("copper",334,100,2,40)
  box("ink",399,157,13,50)
  box("rust",402,159,8,46)
  box("brown",402,159,2,44)
  -- Overhead pipes with a warm work lamp above the scene.
  box("ink",0,35,576,16)
  box("steel",0,38,576,8)
  box("light",0,39,576,2)
  for x=16,565,52 do
    box("ink",x,36,6,14)
    box("rust",x+1,38,4,9)
    box("copper",x+1,38,4,1)
  end
  box("ink",255,46,6,39)
  box("blue",256,48,2,34)
  poly("shadow",{{240,93},{276,93},{350,230},{165,230}})
  poly("lamp",{{251,99},{268,99},{299,148},{222,148}})
  poly("rust",{{244,81},{272,81},{280,89},{277,98},{239,98},{237,90}})
  poly("steel",{{244,81},{271,81},{277,89},{239,89}})
  box("brown",240,91,37,5)
  box("amber",243,95,30,3)
  box("glow",249,96,18,3)
  box("ink",0,232,576,92)
  box("soil",0,237,576,51)
  box("shadow",176,235,191,12)
  box("rust",216,234,116,3)
  box("steel",0,232,576,4)
  box("pale",187,231,44,1)
  box("copper",251,231,83,1)
  box("mint",488,231,54,2)
  for i=0,73 do
    local x=(i*83+19)%576
    local y=240+(i*29)%40
    box(i%4==0 and "shadow" or "deep",x,y,6+i%11,1+i%2)
  end
  local function debris(x,y,w,h)
    poly("ink",{{x,y},{x+3,y-h+4},{x+w-8,y-h},{x+w,y-4},{x+w,y+2}})
    poly("steel",{{x+3,y},{x+6,y-h+5},{x+w-8,y-h+2},{x+w-2,y-4},{x+w-2,y}})
    poly("rust",{{x+3,y-1},{x+w-12,y-2},{x+w-5,y-5},{x+w-2,y-4},{x+w-2,y}})
    box("light",x+7,y-h+5,math.max(3,w-19),2)
    box("ink",x+w-10,y-6,3,2)
  end
  for _,piece in ipairs({{3,231,46,27},{38,233,42,17},{79,234,40,11},{147,233,39,19},{202,235,30,8},{249,235,18,8},{315,236,29,10},{345,236,36,13},{399,232,53,23},{539,231,36,19}}) do
    debris(table.unpack(piece))
  end
  -- The sealed delivery sits beside Ampère in the rubble.
  box("ink",312,213,19,17)
  box("brown",314,215,15,13)
  box("pale",315,215,13,9)
  box("copper",314,224,15,4)
  box("rust",320,215,2,13)
  box("red",319,221,5,4)
  box("scarf",320,222,3,1)
  box("ink",0,288,576,36)
  box("deep",0,286,576,3)
  save_sprite(576,324,"wreckage.aseprite","Passagem da manutenção")
  assert(image:saveAs(out.."/wreckage.png"))
end

local function glove(x,y)
  box("ink",x,y,8,7)
  box("pale",x+1,y+1,6,4)
  box("ivory",x+2,y+1,3,1)
  box("light",x+5,y+4,2,2)
end

local function iris(pose)
  local crouch = pose == 0 and 10 or 0
  local y=8+crouch
  -- Offset cap lamp, goggles, hair-shaped cowl and bandana.
  poly("ink",{{18,y+8},{21,y+2},{38,y},{44,y+3},{47,y+10},{46,y+21},{41,y+26},{23,y+25},{17,y+19}})
  poly("canvas",{{20,y+9},{23,y+3},{37,y+2},{42,y+5},{44,y+12},{42,y+21},{37,y+23},{25,y+23},{20,y+18}})
  poly("fine",{{21,y+8},{24,y+4},{37,y+3},{42,y+7},{39,y+10},{23,y+12}})
  box("ink",23,y+10,20,11)
  box("ivory",26,y+13,15,7)
  box("shadow",24,y+11,20,5)
  box("teal",27,y+12,6,4)
  box("ice",29,y+12,2,2)
  box("teal",36,y+11,6,4)
  box("mint",37,y+11,3,2)
  box("rust",36,y+18,4,1)
  box("ink",34,y+4,9,7)
  box("amber",35,y+5,7,5)
  box("glow",38,y+6,3,2)
  box("ink",19,y+18,7,13)
  box("canvas",21,y+19,4,10)
  box("ink",15,y+6,8,13)
  box("rust",16,y+7,6,10)
  box("brown",17,y+7,4,2)
  -- Coat, scarf, tool belt and asymmetrical sleeves.
  poly("ink",{{23,y+23},{39,y+22},{44,y+27},{43,y+38},{39,y+41},{22,y+41},{19,y+36},{19,y+28}})
  poly("canvas",{{24,y+25},{38,y+24},{42,y+28},{40,y+38},{23,y+39},{21,y+36},{21,y+29}})
  poly("fine",{{24,y+28},{34,y+25},{36,y+29},{34,y+37},{23,y+38},{22,y+31}})
  box("rust",22,y+36,18,4)
  box("amber",29,y+36,5,3)
  poly("red",{{21,y+22},{41,y+22},{42,y+27},{31,y+30},{27,y+34},{24,y+34},{25,y+28},{20,y+27}})
  box("scarf",22,y+23,17,3)
  if pose == 0 then
    poly("ink",{{22,47},{35,48},{37,56},{31,59},{16,59},{15,55}})
    box("blue",19,53,13,4)
    box("light",15,56,12,2)
    poly("ink",{{35,45},{44,47},{47,52},{45,58},{38,58},{36,52}})
    box("steel",40,50,5,5)
    glove(43,49)
  else
    box("ink",22,47,21,13)
    box("blue",24,48,7,10)
    box("steel",35,48,6,10)
    box("light",23,56,8,2)
    box("light",35,56,7,2)
    glove(15,37)
    if pose == 2 then
      box("ink",40,32,14,8)
      box("fine",42,33,11,5)
      glove(52,31)
      box("ivory",59,32,3,2)
      box("ink",59,31,3,1)
    else
      glove(40,40)
    end
  end
end

local function sprite()
  local sheet=Image(192,64)
  local src=Sprite(64,64,ColorMode.RGB)
  src.layers[1].name="Íris"
  for pose=0,2 do
    image=Image(64,64)
    iris(pose)
    sheet:drawImage(image,Point(pose*64,0))
    if pose>0 then src:newEmptyFrame() end
    src:newCel(src.layers[1],pose+1,image,Point(0,0))
  end
  assert(src:saveAs(out.."/iris.aseprite"))
  assert(sheet:saveAs(out.."/guide-atlas.png"))
end

if kind == "background" then backdrop() else sprite() end
