local out=assert(app.params.out)
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

image=Image(576,324,ColorMode.RGB)
box("ink",0,0,576,324)
box("deep",0,30,576,196)
box("navy",14,66,548,160)
-- Broken clerestory and the rear wall behind the rescue site.
poly("blue",{{8,62},{147,35},{421,44},{566,85},{565,219},{7,219}})
poly("navy",{{9,84},{155,49},{424,58},{557,91},{557,219},{9,219}})
for _,x in ipairs({18,119,446,548}) do
  poly("ink",{{x,32},{x+20,34},{x+9,219},{x-7,221}})
  poly("steel",{{x+2,40},{x+6,40},{x-2,218},{x-5,218}})
end
for _,x in ipairs({29,68,87,107,137,160,393,424,455,535}) do
  box("deep",x,93,1,115)
end
for _,y in ipairs({119,151,183,210}) do
  box("deep",24,y,531,2)
end
-- Reception shutters jammed behind a fallen brace.
box("ink",77,91,102,123)
box("steel",81,94,95,118)
box("deep",85,97,87,111)
for y=101,199,8 do
  box("blue",85,y,86,4)
  box("ink",85,y+4,86,1)
end
box("rust",95,131,65,5)
box("red",119,106,15,3)
box("scarf",123,106,6,1)
-- Teal service entrance, with an open dark passage and lit threshold.
poly("ink",{{456,219},{456,135},{471,119},{533,119},{548,137},{548,219}})
poly("steel",{{461,218},{461,136},{473,123},{530,123},{543,138},{543,218}})
poly("sea",{{469,218},{469,141},{478,131},{524,131},{534,142},{534,218}})
poly("ink",{{474,218},{474,143},{482,135},{519,135},{528,144},{528,218}})
poly("deep",{{483,217},{483,150},{489,142},{512,142},{519,151},{519,217}})
box("mint",471,149,2,49)
box("teal",530,149,2,49)
box("sea",505,163,13,54)
box("teal",511,168,4,43)
box("teal",482,124,42,3)
box("mint",495,124,16,2)
box("mint",476,219,49,2)
for x=466,539,11 do
  poly("copper",{{x,222},{x+6,222},{x+2,226},{x-4,226}})
end
box("ink",447,161,11,18)
box("red",449,164,6,3)
box("amber",449,169,3,2)
-- Amber light pools behind both characters, with its broadest surface at the floor.
poly("shadow",{{255,80},{298,80},{387,218},{162,218}})
poly("lamp",{{259,82},{295,82},{330,151},{222,151}})
poly("shadow",{{264,86},{292,86},{316,136},{244,136}})
poly("rust",{{162,218},{387,218},{407,237},{137,237}})
poly("shadow",{{180,219},{368,219},{394,235},{159,235}})
-- Steel decking and a foreground shadow framing the bottom of the shot.
box("soil",0,220,576,104)
box("ink",0,233,576,2)
box("ink",0,250,576,74)
poly("shadow",{{181,221},{357,221},{389,249},{149,249}})
poly("lamp",{{205,220},{339,220},{351,232},{188,232}})
for _,segment in ipairs({{6,93},{111,150},{167,231},{238,341},{358,421},{432,451},{467,537},{550,575}}) do
  local x,b=table.unpack(segment)
  box("steel",x,218,b-x,2)
  box("ink",x,224,b-x,1)
end
box("amber",233,218,94,1)
box("mint",474,218,61,1)
for _,x in ipairs({37,91,158,230,337,394,464,518}) do
  poly("deep",{{x,222},{x+2,222},{x-17,249},{x-21,249}})
end
-- Buckled beam and twisted support lead the eye inward without covering the actors.
poly("ink",{{-5,24},{21,21},{181,190},{198,206},{185,217},{155,196},{-5,86}})
poly("steel",{{0,31},{16,27},{175,191},{186,205},{173,207},{149,188},{0,69}})
poly("navy",{{0,42},{15,38},{174,200},{164,201},{0,64}})
poly("rust",{{0,65},{4,61},{161,195},{157,201},{0,88}})
poly("ink",{{576,26},{551,19},{396,129},{405,143},{576,69}})
poly("blue",{{576,30},{554,23},{404,130},{409,136},{576,59}})
poly("steel",{{576,35},{559,30},{412,129},{417,130},{576,53}})
-- Overhead lamp and power cable.
box("ink",275,33,7,33)
box("steel",277,36,2,29)
poly("ink",{{252,65},{296,65},{309,76},{303,87},{244,87},{240,76}})
poly("steel",{{255,68},{294,68},{304,76},{246,76}})
box("rust",246,79,55,5)
box("amber",251,84,44,3)
box("glow",262,85,24,2)
local rocks={
  {0,224,49,29},{28,226,58,17},{80,225,38,7},{127,226,65,20},
  {164,228,55,13},{204,229,24,7},{369,228,35,13},{394,231,56,24},
  {425,226,41,13},{541,222,35,18},
}
for i,r in ipairs(rocks) do
  local x,y,w,h=table.unpack(r)
  poly("ink",{{x,y},{x+6,y-h+5},{x+w//3,y-h},{x+w-8,y-h+3},{x+w,y-4},{x+w,y+2},{x+4,y+3}})
  poly(i%3==0 and "blue" or "steel",{{x+2,y-1},{x+8,y-h+6},{x+w//3,y-h+2},{x+w-9,y-h+5},{x+w-3,y-4},{x+w-8,y}})
  poly("navy",{{x+8,y-1},{x+w//3,y-h+5},{x+w-10,y-h+5},{x+w-8,y-3},{x+w-16,y}})
  box("light",x+w//3,y-h+4,math.max(3,w//3),1)
end
-- A few visible clusters of bolts and chips, concentrated near the broken braces.
for _,point in ipairs({{158,229},{192,223},{218,227},{228,231},{266,231},{359,227},{374,223},{384,228},{403,233},{438,235},{61,233},{86,230}}) do
  box("steel",point[1],point[2],5,2)
  box("copper",point[1]+1,point[2],2,1)
end
save_sprite(576,324,"workshop.aseprite","Passagem de serviço")
assert(image:saveAs(out.."/workshop.png"))
