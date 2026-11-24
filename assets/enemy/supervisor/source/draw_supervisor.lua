local out = assert(app.params.out, "Specify --script-param out=<directory>")
local pc = app.pixelColor
-- Base colors sampled from Tranca-Lata and Cospe-Rebite. Cyan is reserved for the open core.
local rgb = {
  ink=0x00000D, shadow=0x192031, steel=0x373F4D, gray=0x738291,
  shade=0xCFC3B7, ivory=0xF5E9D8, light=0xFFFCF0,
  rust=0x70432C, copper=0x925A36, bronze=0xB37949, gold=0xF5A84F,
  maroon=0x8B303A, red=0xD94B4B, coral=0xFF7256, heat=0xFE5B01,
  amber=0xFFD277, teal=0x247D97, cyan=0x00ECFD, mint=0xB6FFEB,
}
local colors, allowed = {}, {}
for name, value in pairs(rgb) do
  colors[name] = pc.rgba((value >> 16) & 255, (value >> 8) & 255, value & 255, 255)
  allowed[colors[name]] = true
end

local image
local function box(color, x, y, w, h)
  assert(x >= 0 and y >= 0 and x+w <= 96 and y+h <= 96, "frame overflow")
  for yy=y,y+h-1 do
    for xx=x,x+w-1 do
      image:drawPixel(xx, yy, colors[color])
    end
  end
end

local function polygon(color, points)
  for y=0,95 do
    local crossings = {}
    for index,a in ipairs(points) do
      local b = points[index % #points + 1]
      local cy = y + 0.5
      if (a[2] > cy) ~= (b[2] > cy) then
        crossings[#crossings+1] = a[1] + (b[1]-a[1])*(cy-a[2])/(b[2]-a[2])
      end
    end
    table.sort(crossings)
    for index=1,#crossings,2 do
      local left = math.ceil(crossings[index] - 0.5)
      box(color,left,y,math.ceil(crossings[index+1]-0.5)-left,1)
    end
  end
end

local function bolt(x,y)
  box("ink",x-2,y-1,5,3)
  box("gray",x-1,y-1,3,2)
  box("ivory",x-1,y-1,2,1)
end

local function ram(x, y, charging, firing, flip)
  box("ink",x+3,y,12,21)
  box("copper",x+5,y+2,8,19)
  box("gold",x+(flip and 10 or 5),y+2,3,16)
  polygon("ink",{{x+2,y+13},{x+16,y+13},{x+19,y+18},{x+19,y+30},{x+15,y+34},{x+3,y+34},{x,y+30},{x,y+18}})
  box("maroon",x+2,y+19,15,11)
  box("red",x+3,y+16,13,10)
  box("coral",x+4,y+16,11,2)
  box("ink",x+3,y+24,13,5)
  box(charging and "heat" or "steel",x+4,y+25,11,2)
  if firing then
    box("gold",x+3,y+30,13,2)
    box("amber",x+6,y+32,7,2)
  end
end

local function core(pose, damaged)
  polygon("ink",{{38,50},{58,50},{64,56},{64,73},{57,81},{39,81},{32,74},{32,57}})
  polygon("rust",{{38,52},{58,52},{62,57},{62,73},{56,79},{40,79},{34,73},{34,57}})
  polygon("bronze",{{39,53},{57,53},{60,57},{55,59},{40,59},{36,62},{35,58}})
  box("gold",40,53,16,2)
  box("ink",38,58,20,16)
  if pose == 6 then
    polygon("teal",{{42,57},{54,57},{59,62},{59,70},{54,75},{42,75},{37,70},{37,62}})
    polygon("cyan",{{44,59},{53,59},{56,63},{56,68},{52,72},{43,72},{40,68},{40,63}})
    box("mint",44,61,9,6)
    box("light",46,62,4,3)
    box("ivory",33,65,4,3)
    box("ivory",59,65,4,3)
  else
    box("steel",40,59,16,14)
    box("gray",41,59,14,3)
    box("ink",39,65,18,4)
    box((pose == 4 or pose == 5 or damaged) and "heat" or "copper",42,66,12,1)
    if damaged then
      polygon("ink",{{50,59},{53,59},{51,63},{55,67},{52,68},{54,72},{52,73},{49,68},{51,66},{48,64}})
      box("coral",51,63,2,2)
    end
  end
end

local function frame(pose, damaged)
  local charging = pose == 2 or pose == 4
  local firing = pose == 3 or pose == 5
  local lift = pose == 4 and -6 or (pose == 5 and 5 or (pose == 2 and -3 or (pose == 3 and 2 or 0)))
  local hood = pose == 2 and 3 or (pose == 3 and -2 or (pose == 4 and 2 or (pose == 7 and -3 or 0)))
  local spread = pose == 5 and 3 or 0
  -- Carriage socket, exhaust and padded shoulders.
  box("ink",39,5,18,14)
  box("steel",42,6,12,11)
  box("gray",44,6,4,8)
  box("ink",34,12,28,11)
  box("bronze",36,14,24,6)
  box("gold",37,14,18,2)
  -- Split chimney, with a shutter that lifts under pressure.
  local chimney = pose == 4 and 3 or 0
  polygon("ink",{{62,7},{72,7},{72,12},{79,12},{79,5},{87,5},{87,21},{80,28},{65,28},{62,22}})
  box("copper",65,10,5,14)
  box("bronze",66,11,2,11)
  box("steel",75,14,10,8)
  box("gray",79,7,6,12)
  box("ink",77,4+chimney,12,5)
  box("bronze",78,5+chimney,10,2)
  box("ink",61,7,13,4)
  box("gold",62,8,11,2)
  if charging then
    box("heat",68,19,2,4)
    box("amber",70,22,5,1)
  end
  ram(8-spread,39+lift,charging,firing,false)
  ram(69+spread,39+lift,charging,firing,true)
  -- Angular furnace body with a separate rolled top lip.
  polygon("ink",{{29,24},{67,24},{78,35},{78,66},{72,78},{61,85},{35,85},{24,78},{18,66},{18,35}})
  polygon("shadow",{{30,27},{66,27},{75,37},{75,66},{69,76},{60,82},{36,82},{27,76},{21,65},{21,37}})
  polygon("steel",{{29,31},{68,31},{74,40},{74,64},{67,77},{63,77},{65,60},{29,60},{33,77},{28,77},{22,64},{22,40}})
  box("rust",28,72,9,5)
  box("rust",59,72,9,5)
  box("bronze",36,80,24,2)
  bolt(24,58)
  bolt(72,58)
  core(pose,damaged)

  -- Thick bright visor rim, shaped like the rest of the tower's industrial robots.
  polygon("ink",{{31,18+hood},{64,18+hood},{74,24+hood},{78,35+hood},{75,46+hood},{68,54+hood},{29,54+hood},{21,47+hood},{19,35+hood},{23,25+hood}})
  polygon("shade",{{31,22+hood},{63,22+hood},{72,27+hood},{75,35+hood},{72,45+hood},{67,50+hood},{30,50+hood},{24,45+hood},{22,35+hood},{26,27+hood}})
  polygon("ivory",{{34,21+hood},{63,21+hood},{72,27+hood},{74,34+hood},{67,33+hood},{61,28+hood},{33,28+hood},{24,35+hood},{26,27+hood}})
  box("light",33,22+hood,28,2)
  box("red",59,24+hood,7,6)
  box("coral",60,24+hood,4,2)
  polygon("ink",{{33,33+hood},{65,33+hood},{71,37+hood},{69,44+hood},{64,48+hood},{34,48+hood},{29,44+hood},{29,37+hood}})
  local eye = damaged and "coral" or "heat"
  local gleam = charging and "light" or "amber"
  if pose == 1 then
    box("copper",53,40+hood,12,2)
  else
    polygon(eye,{{51,39+hood},{55,35+hood},{64,35+hood},{67,39+hood},{65,44+hood},{55,45+hood},{52,43+hood}})
    box("maroon",55,41+hood,10,3)
    box(gleam,55,36+hood,7,2)
    box("ink",61,38+hood,3,4)
  end
  for slot=0,2 do
    local bar = charging and (slot*2+3) or (slot+2)
    box(charging and "amber" or "rust",35+slot*4,44+hood-bar,2,bar)
  end
  -- Asymmetric handwheel and ring of safety stripes: a working boiler, with a side profile.
  local wheel_y = pose == 4 and 48 or (pose == 5 and 55 or 51)
  polygon("ink",{{5,wheel_y-6},{9,wheel_y-6},{9,wheel_y-10},{17,wheel_y-10},{17,wheel_y-7},{21,wheel_y-7},{21,wheel_y-3},{24,wheel_y-3},{24,wheel_y+4},{20,wheel_y+4},{20,wheel_y+8},{16,wheel_y+8},{16,wheel_y+11},{9,wheel_y+11},{9,wheel_y+8},{5,wheel_y+8},{5,wheel_y+4},{2,wheel_y+4},{2,wheel_y-3},{5,wheel_y-3}})
  polygon("bronze",{{7,wheel_y-5},{10,wheel_y-5},{10,wheel_y-8},{15,wheel_y-8},{15,wheel_y-5},{19,wheel_y-5},{19,wheel_y-1},{22,wheel_y-1},{22,wheel_y+2},{18,wheel_y+2},{18,wheel_y+6},{14,wheel_y+6},{14,wheel_y+9},{11,wheel_y+9},{11,wheel_y+6},{7,wheel_y+6},{7,wheel_y+2},{4,wheel_y+2},{4,wheel_y-1},{7,wheel_y-1}})
  box("ink",8,wheel_y-4,10,9)
  if pose == 4 or pose == 5 then
    polygon("gold",{{8,wheel_y+3},{15,wheel_y-4},{18,wheel_y-4},{18,wheel_y-2},{11,wheel_y+5},{8,wheel_y+5}})
  else
    box("gold",11,wheel_y-5,3,11)
    box("gold",7,wheel_y-1,11,3)
  end
  box("ivory",12,wheel_y,2,2)
  box("ink",70,59,8,15)
  box("amber",71,60,6,13)
  polygon("rust",{{71,63},{77,61},{77,64},{71,66}})
  polygon("rust",{{71,69},{77,67},{77,70},{71,72}})
  if damaged then
    box("maroon",74,68,3,5)
  end

  -- Visible side-mounted pressure dial. Needle rises during attack preparation.
  polygon("ink",{{17,19},{26,19},{31,24},{31,32},{26,37},{17,37},{12,32},{12,24}})
  polygon("bronze",{{18,21},{25,21},{29,25},{29,31},{25,35},{18,35},{14,31},{14,25}})
  box("ivory",17,24,9,8)
  box("rust",18,30,7,2)
  if charging or damaged then
    box("red",22,24,2,6)
    box("maroon",21,27,2,3)
  else
    box("red",18,25,2,3)
    box("maroon",20,27,3,3)
  end
  box("gold",16,23,2,2)

  if damaged then
    polygon("maroon",{{70,23+hood},{73,26+hood},{69,30+hood},{72,36+hood},{69,41+hood},{67,40+hood},{69,35+hood},{66,30+hood}})
    box("coral",70,29+hood,2,3)
    box("coral",65,69,4,2)
    box("red",65,71,2,5)
  end
  if pose == 5 then
    polygon("gold",{{9,81},{22,81},{20,86},{17,86},{14,91},{12,86}})
    polygon("gold",{{74,81},{87,81},{83,87},{81,91},{79,86},{75,86}})
    box("ivory",12,81,7,2)
    box("ivory",77,81,7,2)
  elseif pose == 3 then
    box("amber",39,46+hood,20,2)
    box("gold",44,48+hood,10,3)
  end
end

local sprite = Sprite(96,96,ColorMode.RGB)
sprite.layers[1].name = "Supervisor-Caldeira"
local sheet = Image(96*8,96*2)
local lengths = {180,100,140,80,160,100,200,110}
for index=0,15 do
  local pose = index % 8
  image = Image(96,96)
  frame(pose,index>=8)
  for px in image:pixels() do
    local value = px()
    assert(pc.rgbaA(value)==0 or allowed[value], "palette violation")
  end
  if index>0 then sprite:newEmptyFrame() end
  sprite:newCel(sprite.layers[1],index+1,image,Point(0,0))
  sprite.frames[index+1].duration = lengths[pose+1]/1000
  sheet:drawImage(image,Point(pose*96,math.floor(index/8)*96))
end
local phase_one = sprite:newTag(1,8)
phase_one.name = "Fase 1 - poses"
local phase_two = sprite:newTag(9,16)
phase_two.name = "Fase 2 - poses"
assert(sprite:saveAs(out .. "/supervisor-caldeira.aseprite"))
assert(sheet:saveAs(out .. "/boiler-frames.png"))

local portrait = Image(32,28)
for y=0,27 do
  for x=0,31 do
    portrait:drawPixel(x,y,sheet:getPixel(16+x*2,16+y*2))
  end
end
assert(portrait:saveAs(out .. "/boss-portrait.png"))
