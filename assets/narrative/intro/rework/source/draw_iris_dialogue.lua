local out=assert(app.params.out)
local size=56
local pixel=app.pixelColor
local colors={
  ink=0x15131B, hair=0x251C26, curl=0x392831, hair_light=0x573941, hair_rim=0x76504E,
  skin_shadow=0x8D4A37, skin_mid=0xB36B4B, skin=0xD38B61, peach=0xEAA274,
  light=0xF6BA87, glint=0xFFD3A5, blush=0xCD7757,
  mouth=0x74362F, lip=0xA45B4A, tongue=0xC57262, teeth=0xF5DFBC,
  green0=0x253332, green1=0x364B41, green2=0x527063, green3=0x758875,
  brass0=0x74442E, brass1=0xAE6F43, brass2=0xDCA662, metal=0x738780,
  lens0=0x334B55, lens1=0x547783, lens2=0xA4C6BF, white=0xF4DEB1,
  scarf0=0x773F2D, scarf1=0xB85536, scarf2=0xE1874B,
}
for name,c in pairs(colors) do
  colors[name]=pixel.rgba((c>>16)&255,(c>>8)&255,c&255,255)
end

local function box(im,c,x,y,w,h)
  for yy=y,y+h-1 do
    for xx=x,x+w-1 do im:drawPixel(xx,yy,colors[c]) end
  end
end

local function poly(im,c,points)
  local min_y,max_y=size,0
  for _,p in ipairs(points) do
    min_y=math.min(min_y,p[2])
    max_y=math.max(max_y,p[2])
  end
  for y=min_y,max_y-1 do
    local edges={}
    for i,p in ipairs(points) do
      local q=points[i%#points+1]
      local mid=y+0.5
      if (p[2]>mid)~=(q[2]>mid) then
        edges[#edges+1]=p[1]+(q[1]-p[1])*(mid-p[2])/(q[2]-p[2])
      end
    end
    table.sort(edges)
    for i=1,#edges,2 do
      local x=math.ceil(edges[i]-0.5)
      box(im,c,x,y,math.ceil(edges[i+1]-0.5)-x,1)
    end
  end
end

local function draw(expression)
  local im=Image(size,size,ColorMode.RGB)
  -- Collar and shoulder, lit from the same side as the face.
  poly(im,"ink",{{2,56},{3,50},{9,45},{20,41},{24,35},{34,35},{40,41},{49,46},{53,56}})
  poly(im,"green0",{{4,56},{6,50},{12,46},{21,42},{36,41},{48,47},{51,56}})
  poly(im,"green1",{{6,56},{10,48},{21,44},{30,46},{38,44},{46,47},{50,55},{41,56}})
  poly(im,"green2",{{8,53},{12,48},{21,45},{24,47},{18,51},{12,54}})
  poly(im,"green3",{{9,51},{12,48},{17,47},{16,49},{11,52}})
  box(im,"teeth",7,54,7,1)
  box(im,"white",43,51,2,1)
  box(im,"brass1",44,52,1,2)
  -- Bun and three broad curls with different lengths.
  poly(im,"ink",{{4,21},{6,14},{10,10},{17,9},{21,12},{24,8},{32,7},{40,9},{46,15},{47,23},{51,27},{49,31},{49,36},{46,39},{43,36},{23,40},{18,35},{15,31},{7,31},{5,28}})
  poly(im,"hair",{{6,20},{8,15},{11,12},{17,11},{22,15},{26,9},{33,8},{39,10},{44,15},{45,24},{49,27},{47,31},{48,35},{46,37},{43,34},{25,38},{19,32},{15,29},{8,29},{7,26}})
  poly(im,"curl",{{7,19},{10,15},{14,12},{18,12},{19,14},{16,16},{12,17},{9,22},{8,25}})
  poly(im,"curl",{{10,22},{13,18},{17,17},{20,15},{20,18},{17,20},{14,21},{12,25},{12,27}})
  poly(im,"curl",{{14,24},{18,21},{21,19},{23,16},{24,19},{21,24},{18,26},{17,30},{15,29}})
  box(im,"hair_light",13,14,4,1)
  box(im,"hair_rim",15,13,2,1)
  box(im,"hair_light",10,18,2,1)
  box(im,"hair_light",16,21,3,1)
  box(im,"hair_light",20,23,2,1)
  -- Neck, ear and complexion. The eye nearest the camera has more white.
  poly(im,"skin_shadow",{{22,28},{30,27},{37,31},{39,41},{33,46},{24,43},{23,37},{21,32}})
  poly(im,"skin_mid",{{24,29},{31,29},{35,36},{36,41},{32,43},{26,41},{26,37}})
  poly(im,"ink",{{25,19},{30,15},{39,14},{43,17},{45,23},{45,26},{48,29},{46,32},{44,32},{44,36},{41,40},{35,41},{28,37},{26,34},{22,33},{20,29},{21,25},{25,25}})
  poly(im,"skin_shadow",{{25,22},{31,16},{38,15},{42,18},{44,23},{44,26},{47,29},{45,31},{43,31},{43,36},{40,39},{35,40},{29,36},{27,33},{23,32},{21,29},{22,26},{26,26}})
  poly(im,"skin",{{27,22},{32,16},{38,16},{41,18},{43,22},{43,26},{46,29},{43,30},{42,35},{39,38},{34,38},{29,34},{27,31},{25,32},{23,30},{23,27},{25,27},{27,29}})
  poly(im,"peach",{{30,20},{35,17},{40,18},{42,21},{42,26},{44,29},{42,30},{41,34},{39,37},{35,37},{31,34},{30,29},{28,27}})
  poly(im,"light",{{33,20},{37,18},{40,19},{41,21},{36,22},{32,23}})
  poly(im,"light",{{30,28},{33,27},{38,28},{38,30},{35,32},{31,31}})
  box(im,"skin_mid",24,27,2,1)
  box(im,"skin_shadow",25,28,2,3)
  box(im,"light",23,28,1,2)
  box(im,"glint",24,31,2,1)
  box(im,"blush",29,29,3,2)
  box(im,"blush",32,30,2,1)
  box(im,"glint",36,28,1,1)
  -- Bridge, tip and underside of the nose have independent clusters.
  box(im,"light",41,25,1,3)
  box(im,"glint",42,27,1,1)
  box(im,"light",42,28,3,1)
  box(im,"skin_mid",41,29,3,1)
  box(im,"skin_shadow",42,30,1,1)
  box(im,"light",36,36,4,1)
  -- Forelock and loose tendril keep the same silhouette in every expression.
  poly(im,"hair",{{22,18},{27,12},{34,12},{38,14},{39,17},{37,18},{34,18},{32,21},{29,22},{27,25},{24,25},{23,28},{21,26}})
  poly(im,"curl",{{23,18},{28,14},{33,14},{36,16},{32,17},{29,20},{25,21}})
  box(im,"hair_light",26,17,4,1)
  poly(im,"hair",{{39,12},{43,14},{46,17},{47,21},{45,25},{47,27},{48,30},{47,34},{45,36},{45,33},{46,30},{44,27},{44,23},{43,20},{42,17}})
  poly(im,"curl",{{43,15},{45,17},{46,21},{44,23},{45,27},{46,29},{45,29},{44,26},{44,21},{42,17}})
  -- Copper goggles with cool glass, a bridge, hinge and upper specular shine.
  poly(im,"ink",{{17,15},{23,11},{26,11},{26,8},{29,5},{37,5},{39,6},{41,6},{45,8},{46,12},{43,15},{40,15},{37,16},{28,16},{25,14},{20,18}})
  poly(im,"brass0",{{17,15},{23,12},{29,11},{29,14},{22,15},{19,17}})
  box(im,"brass1",21,13,5,1)
  poly(im,"brass1",{{27,9},{30,6},{36,6},{39,8},{40,12},{37,15},{29,15},{27,12}})
  box(im,"brass2",30,6,6,1)
  poly(im,"lens0",{{28,9},{31,7},{36,7},{38,9},{38,12},{36,14},{29,14},{28,12}})
  poly(im,"lens1",{{29,9},{32,8},{36,8},{37,10},{36,13},{29,12}})
  box(im,"lens2",30,9,3,2)
  box(im,"white",30,9,2,1)
  box(im,"metal",34,12,2,1)
  box(im,"brass2",39,9,2,1)
  poly(im,"brass1",{{40,8},{42,7},{44,8},{45,11},{43,14},{41,13}})
  box(im,"lens0",41,9,3,3)
  box(im,"lens2",42,9,1,1)
  box(im,"white",42,7,1,1)
  -- Neckerchief closes against the jacket, leaving both collar points.
  poly(im,"ink",{{21,38},{25,37},{30,40},{36,39},{40,42},{39,46},{36,47},{34,52},{31,51},{28,47},{24,48},{24,44},{20,42}})
  poly(im,"scarf0",{{22,39},{25,38},{30,41},{36,40},{39,42},{38,45},{35,46},{33,50},{31,49},{27,46},{24,46},{25,43}})
  poly(im,"scarf1",{{23,39},{29,41},{36,41},{38,42},{37,44},{33,43},{31,45},{26,44},{25,42}})
  box(im,"scarf2",26,41,4,1)
  box(im,"scarf2",34,42,3,1)
  box(im,"scarf1",33,46,2,2)

  if expression==1 then
    -- Concern: inner brow raised and lips parted.
    poly(im,"hair",{{29,23},{34,20},{38,20},{38,21},{34,22},{30,24}})
    box(im,"hair",41,22,2,1)
    box(im,"hair",30,24,7,3)
    box(im,"teeth",31,24,5,3)
    box(im,"lens0",34,24,2,3)
    box(im,"lens2",34,24,1,1)
    box(im,"hair",41,24,2,2)
    box(im,"teeth",41,25,1,1)
    box(im,"mouth",36,33,4,2)
    box(im,"lip",37,35,3,1)
  elseif expression==2 then
    -- Reassurance: closed smile in the eyelid and a lifted mouth corner.
    box(im,"hair",31,21,6,1)
    box(im,"hair",40,22,3,1)
    box(im,"hair",30,25,2,1)
    box(im,"hair",32,24,4,1)
    box(im,"hair",36,25,1,1)
    box(im,"hair",41,25,2,1)
    box(im,"mouth",35,34,3,1)
    box(im,"mouth",38,33,3,1)
    box(im,"lip",37,35,3,1)
  elseif expression==3 then
    -- Serious: front of the brow drops and both lids narrow.
    poly(im,"hair",{{29,20},{35,21},{38,22},{37,23},{34,23},{32,22},{29,22}})
    box(im,"hair",40,23,3,1)
    box(im,"hair",31,24,6,1)
    box(im,"hair",30,25,7,1)
    box(im,"hair",31,26,5,1)
    box(im,"teeth",31,25,5,1)
    box(im,"lens0",34,25,2,1)
    box(im,"hair",41,25,2,1)
    box(im,"mouth",35,34,5,1)
    box(im,"lip",35,35,3,1)
  else
    -- Invitation: bright eye and an open smile.
    box(im,"hair",31,21,6,1)
    box(im,"hair",41,21,2,1)
    box(im,"hair",30,24,7,3)
    box(im,"teeth",31,24,5,3)
    box(im,"lens0",34,24,2,3)
    box(im,"lens2",34,24,1,1)
    box(im,"hair",40,24,3,2)
    box(im,"teeth",41,24,1,1)
    poly(im,"mouth",{{34,33},{38,33},{41,31},{41,34},{39,36},{36,36}})
    box(im,"teeth",36,33,4,1)
    box(im,"tongue",37,35,2,1)
  end
  return im
end

local names={"Preocupada","Tranquilizadora","Séria","Convidativa"}
local source=Sprite(size,size,ColorMode.RGB)
source.layers[1].name="Retratos de Íris"
local sheet=Image(#names*size,size,ColorMode.RGB)
for i,name in ipairs(names) do
  if i>1 then source:newEmptyFrame() end
  local image=draw(i)
  source:newCel(source.layers[1],i,image,Point(0,0))
  source:newTag(i,i).name=name
  sheet:drawImage(image,Point((i-1)*size,0))
end
assert(source:saveAs(out.."/iris-dialogue.aseprite"))
assert(sheet:saveAs(out.."/iris-dialogue.png"))
