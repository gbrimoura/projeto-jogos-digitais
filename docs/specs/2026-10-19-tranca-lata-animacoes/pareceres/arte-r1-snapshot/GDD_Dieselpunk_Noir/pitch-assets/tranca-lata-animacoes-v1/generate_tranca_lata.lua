-- Tranca-Lata animation sheet authoring, Aseprite Lua 1.3.
-- Input is the current 3-cel TrainingTarget source; this script saves a new project only.
local sprite = app.activeSprite
assert(sprite and sprite.width == 64 and sprite.height == 64 and #sprite.frames == 3, 'Expected original 64x64 three-frame sprite')
local layer = sprite.layers[1]
local root = 'GDD_Dieselpunk_Noir/pitch-assets/tranca-lata-animacoes-v1/'
local sourceIdle = layer:cel(1).image:clone()
local sourceRefs = {}
local oldDurations = {}
for i=1,3 do
  sourceRefs[i]=layer:cel(i).image:clone()
  oldDurations[i] = sprite.frames[i].duration
end

local C = {
  outline = Color{r=0,g=0,b=13,a=255},
  navy = Color{r=25,g=32,b=49,a=255},
  navy2 = Color{r=25,g=32,b=49,a=255},
  steel = Color{r=55,g=63,b=77,a=255},
  steelHi = Color{r=207,g=195,b=183,a=255},
  cream = Color{r=245,g=233,b=216,a=255},
  creamHi = Color{r=255,g=252,b=240,a=255},
  copperShadow = Color{r=112,g=67,b=44,a=255},
  copper = Color{r=146,g=90,b=54,a=255},
  copperLight = Color{r=179,g=121,b=73,a=255},
  orange = Color{r=254,g=91,b=1,a=255},
  orangeLight = Color{r=245,g=168,b=79,a=255},
  red = Color{r=217,g=75,b=75,a=255},
  redLight = Color{r=240,g=82,b=78,a=255},
  visor = Color{r=255,g=114,b=86,a=255},
}
local transparent = Color{r=0,g=0,b=0,a=0}
local function newRgbImage(width,height)
  return Image(ImageSpec{width=width,height=height,colorMode=ColorMode.RGB})
end
local pixelColorCache={}
local function decodedColor(value)
  if not pixelColorCache[value] then
    local pc=app.pixelColor
    pixelColorCache[value]=Color{r=pc.rgbaR(value),g=pc.rgbaG(value),b=pc.rgbaB(value),a=pc.rgbaA(value)}
  end
  return pixelColorCache[value]
end
local function pixel(img,x,y,col)
  if x>=0 and x<64 and y>=0 and y<64 then img:drawPixel(x,y,col) end
end
local function rect(img,x1,y1,x2,y2,col)
  for y=y1,y2 do for x=x1,x2 do pixel(img,x,y,col) end end
end
local function clearPedestal(img)
  for y=48,63 do for x=0,63 do pixel(img,x,y,transparent) end end
end

-- Shift only the connected head/tube/torso group; the new articulated legs stay planted.
local function upperBody(bodyShift)
  local source=sourceIdle:clone()
  clearPedestal(source)
  local img=newRgbImage(64,64)
  img:drawImage(source,0,bodyShift)
  return img
end

local function drawAngryVisor(img,bodyShift)
  -- Tight inward slants echo the reference glare without changing the screen silhouette.
  pixel(img,28,25+bodyShift,C.outline)
  pixel(img,29,26+bodyShift,C.outline)
  pixel(img,40,25+bodyShift,C.outline)
  pixel(img,39,26+bodyShift,C.outline)
end

-- A hinged piston leg with a broad torso mount and a shaft that follows the boot.
local function drawLeg(img, hipX, footCenterX, bootY, bend)
  rect(img,hipX-3,42,hipX+3,46,C.outline)
  rect(img,hipX-2,43,hipX+2,45,C.steel)
  pixel(img,hipX-1,43,C.creamHi)
  pixel(img,hipX,43,C.copperLight)
  pixel(img,hipX+1,44,C.steelHi)
  pixel(img,hipX,45,C.copper)
  local shaftStart=46
  local shaftEnd=math.max(shaftStart,bootY-1)
  local span=math.max(1,shaftEnd-shaftStart)
  for y=shaftStart,shaftEnd do
    local t=(y-shaftStart)/span
    local center=math.floor(hipX+(footCenterX+bend-hipX)*t+0.5)
    rect(img,center-2,y,center+2,y,C.outline)
    pixel(img,center-1,y,C.cream)
    pixel(img,center,y,C.copperLight)
    pixel(img,center+1,y,C.navy2)
  end
  -- The exposed knee remains readable when a foot is raised in the passing pose.
  local knee=math.floor(hipX+(footCenterX+bend-hipX)*0.55+0.5)
  rect(img,knee-2,46,knee+2,48,C.outline)
  rect(img,knee-1,47,knee+1,47,C.steel)
  pixel(img,knee-1,47,C.creamHi)
  pixel(img,knee,47,C.copperLight)
end

-- A broad diesel boot with stepped outline, copper toe cap and steel sole.
-- The left/right boot details mirror, while the robot face and tube never do.
local function drawBoot(img,x,y,side)
  local function xx(n) return side < 0 and (x+14-n) or (x+n) end
  local function span(row,a,b,col)
    for n=a,b do pixel(img,xx(n),y+row,col) end
  end
  span(0,6,8,C.outline)
  span(1,4,10,C.outline)
  span(2,2,12,C.outline)
  span(3,1,13,C.outline)
  span(4,0,14,C.outline)
  span(5,0,14,C.outline)
  span(0,6,8,C.steelHi)
  span(1,5,9,C.copperLight)
  span(2,3,7,C.copperLight); span(2,8,11,C.steel)
  span(3,2,5,C.orangeLight); span(3,6,12,C.steel)
  span(4,1,5,C.copper); span(4,6,13,C.navy)
  span(5,1,4,C.copperShadow); span(5,5,13,C.steel)
  pixel(img,xx(5),y+1,C.orangeLight)
  pixel(img,xx(2),y+4,C.orange)
  pixel(img,xx(12),y+3,C.steelHi)
end

local function makePose(leftBootX,leftBootY,rightBootX,rightBootY,leftHip,leftBend,rightHip,rightBend,bodyShift,angry)
  bodyShift=bodyShift or 0
  local img=upperBody(bodyShift)
  if angry then drawAngryVisor(img,bodyShift) end
  drawLeg(img,leftHip,leftBootX+7,leftBootY,leftBend)
  drawLeg(img,rightHip,rightBootX+7,rightBootY,rightBend)
  drawBoot(img,leftBootX,leftBootY,-1)
  drawBoot(img,rightBootX,rightBootY,1)
  return img
end

local poses = {
  {name='walk_contact_a',   duration=0.120, img=makePose(14,50,35,50,22,-2,42,2,0,false)},
  {name='walk_pass_left',   duration=0.120, img=makePose(17,48,35,50,22,-2,42,1,0,false)},
  {name='walk_contact_b',   duration=0.120, img=makePose(17,50,32,50,25,2,39,-2,0,false)},
  {name='walk_pass_right',  duration=0.120, img=makePose(14,50,32,48,22,-1,41,2,0,false)},
  {name='windup_anticipate',duration=0.180, img=makePose(15,50,34,50,23,-1,41,1,1,true)},
  {name='windup_compress',  duration=0.220, img=makePose(14,50,35,50,22,-2,42,2,3,true)},
  {name='windup_brace',     duration=0.250, img=makePose(14,50,35,50,22,2,42,-2,5,true)},
  {name='active_stomp',     duration=0.070, img=makePose(14,50,35,50,22,-2,42,2,-3,true)},
  {name='active_followthrough',duration=0.070,img=makePose(15,50,34,50,23,1,41,-1,3,true)},
  {name='recovery_hold',    duration=0.120, img=makePose(14,50,35,50,22,2,42,-2,4,true)},
  {name='recovery_unbrace', duration=0.180, img=makePose(15,50,34,50,23,-1,41,1,1,false)},
  {name='idle_neutral',     duration=1.100, img=makePose(16,50,34,50,23,0,41,0,0,false)},
}

-- Keep the original three cels byte-for-byte at the decoded pixel level and append 12 new poses.
for index,pose in ipairs(poses) do
  local frameNumber=#sprite.frames+1
  sprite:newFrame()
  local cel=layer:cel(frameNumber)
  assert(cel, 'New frame has no cel')
  cel.image=pose.img
  cel.position=Point(0,0)
  sprite.frames[frameNumber].duration=pose.duration
end

local function tag(name,first,last)
  local t=sprite:newTag(first,last)
  t.name=name
  t.aniDir=AniDir.FORWARD
end
tag('legacy_idle',1,1)
tag('legacy_impact',2,2)
tag('legacy_disabled',3,3)
tag('walk',4,7)
tag('windup',8,10)
tag('active',11,12)
tag('recovery',13,15)
tag('attack',8,15)
tag('idle',15,15)

-- Report exact decoded equality for the protected legacy cels.
local legacyEqual=true
for fi=1,3 do
  local c=layer:cel(fi)
  if sprite.frames[fi].duration~=oldDurations[fi] then legacyEqual=false end
  for y=0,63 do for x=0,63 do
    if c.image:getPixel(x,y)~=sourceRefs[fi]:getPixel(x,y) then legacyEqual=false end
  end end
end
print('LEGACY_RGBA_PIXELS_AND_DURATIONS_EQUAL',legacyEqual)
print('LEGACY_DURATIONS_SECONDS',oldDurations[1],oldDurations[2],oldDurations[3])

local function bounds(img)
  local pc=app.pixelColor
  local minx,miny,maxx,maxy=64,64,-1,-1
  for y=0,63 do for x=0,63 do if pc.rgbaA(img:getPixel(x,y))>0 then
    minx=math.min(minx,x); miny=math.min(miny,y); maxx=math.max(maxx,x); maxy=math.max(maxy,y)
  end end end
  return minx,miny,maxx+1,maxy+1
end
local framesMeta={}
for fi=1,#sprite.frames do
  local c=layer:cel(fi)
  local bx,by,ex,ey=bounds(c.image)
  local name
  if fi==1 then name='legacy_idle_old' elseif fi==2 then name='legacy_impact' elseif fi==3 then name='legacy_disabled' else name=poses[fi-3].name end
  framesMeta[#framesMeta+1]=string.format('{"index":%d,"frame":%d,"name":"%s","duration_ms":%d,"bounds":[%d,%d,%d,%d]}',fi-1,fi,name,math.floor(sprite.frames[fi].duration*1000+0.5),bx,by,ex,ey)
end

-- Palette inventory from the actual 15-frame result.
local colorCounts={}
local pc=app.pixelColor
for fi=1,#sprite.frames do
  local im=layer:cel(fi).image
  for it in im:pixels() do local value=it(); if pc.rgbaA(value)>0 then colorCounts[value]=(colorCounts[value] or 0)+1 end end
end
local palette={}
for value,count in pairs(colorCounts) do
  palette[#palette+1]={value=value,count=count,hex=string.format('#%02X%02X%02X',pc.rgbaR(value),pc.rgbaG(value),pc.rgbaB(value))}
end
table.sort(palette,function(a,b) return a.hex<b.hex end)
local paletteJson={}
for _,entry in ipairs(palette) do paletteJson[#paletteJson+1]=string.format('{"hex":"%s","opaque_pixels":%d}',entry.hex,entry.count) end

sprite:saveAs(root..'tranca-lata-animacoes-v1.aseprite')
local atlas=newRgbImage(960,64)
for fi=1,15 do atlas:drawImage(layer:cel(fi).image,(fi-1)*64,0) end
atlas:saveAs(root..'tranca-lata-atlas-v1.png')

-- 4x nearest-neighbor contact sheet, four frame columns by four rows.
local contact=newRgbImage(1024,1024)
local charcoal=Color{r=37,g=38,b=40,a=255}
local grid=Color{r=74,g=76,b=78,a=255}
local label=Color{r=245,g=233,b=216,a=255}
for y=0,1023 do for x=0,1023 do contact:drawPixel(x,y,charcoal) end end
for fi=1,15 do
  local col=(fi-1)%4; local row=math.floor((fi-1)/4)
  local src=layer:cel(fi).image
  for y=0,63 do for x=0,63 do
    local v=src:getPixel(x,y)
    if pc.rgbaA(v)>0 then
      local color=decodedColor(v)
      for sy=0,3 do for sx=0,3 do contact:drawPixel(col*256+x*4+sx,row*256+y*4+sy,color) end end
    end
  end end
end
local digitRows={
  ['0']={'111','101','101','101','111'}, ['1']={'010','110','010','010','111'},
  ['2']={'111','001','111','100','111'}, ['3']={'111','001','111','001','111'},
  ['4']={'101','101','111','001','001'}, ['5']={'111','100','111','001','111'},
  ['6']={'111','100','111','101','111'}, ['7']={'111','001','010','010','010'},
  ['8']={'111','101','111','101','111'}, ['9']={'111','101','111','001','111'}
}
for fi=1,15 do
  local col=(fi-1)%4; local row=math.floor((fi-1)/4)
  local labelText=string.format('%02d',fi-1)
  for digitIndex=1,2 do
    local glyph=digitRows[labelText:sub(digitIndex,digitIndex)]
    for gy=1,5 do for gx=1,3 do
      if glyph[gy]:sub(gx,gx)=='1' then contact:drawPixel(col*256+(digitIndex-1)*4+3+gx-1,row*256+3+gy-1,label) end
    end end
  end
end
for p=255,767,256 do for y=0,1023 do contact:drawPixel(p,y,grid) end end
for p=255,767,256 do for x=0,1023 do contact:drawPixel(x,p,grid) end end
contact:saveAs(root..'contact-15-cels-4x.png')

-- Capture the neutral pose, then compare old idle / new neutral / current player first cel.
local neutral=layer:cel(15).image:clone()
local opened=app.open('projeto-jogos-digitais/assets/player/source/player-animations.aseprite')
local heroSprite=app.activeSprite
local heroCel=heroSprite.layers[1]:cel(1)
local heroImage=heroCel.image:clone()
local compare=newRgbImage(768,256)
local compareBg=Color{r=37,g=38,b=40,a=255}
for y=0,255 do for x=0,767 do compare:drawPixel(x,y,compareBg) end end
local samples={sourceIdle,neutral,heroImage}
for pane=1,3 do
  local src=samples[pane]
  for y=0,63 do for x=0,63 do
    local v=src:getPixel(x,y)
    if pc.rgbaA(v)>0 then
      local color=decodedColor(v)
      for sy=0,3 do for sx=0,3 do compare:drawPixel((pane-1)*256+x*4+sx,y*4+sy,color) end end
    end
  end end
end
compare:saveAs(root..'comparison-old-idle-new-neutral-player-frame1-4x.png')

local json='{'..
  '\n  "asset":"Tranca-Lata",'..
  '\n  "canvas_px":[64,64], "atlas_px":[960,64], "frame_count":15, "display_scale":2,'..
  '\n  "pivot":{"x":32,"base_edge_y":56}, "authored_bounds_constraint":{"x_min_inclusive":14,"x_max_exclusive":50,"y_min_inclusive":8,"y_max_exclusive":56},'..
  '\n  "palette":['..table.concat(paletteJson,',')..'],'..
  '\n  "legacy_rgba":{"frames_0_to_2_pixel_values_and_durations_equal":'..tostring(legacyEqual)..',"legacy_duration_seconds":['..tostring(oldDurations[1])..','..tostring(oldDurations[2])..','..tostring(oldDurations[3])..']},'..
  '\n  "tags":{"legacy_idle":[0,0],"legacy_impact":[1,1],"legacy_disabled":[2,2],"walk":[3,6],"windup":[7,9],"active":[10,11],"recovery":[12,14],"attack":[7,14],"idle":[14,14]},'..
  '\n  "frames":['..table.concat(framesMeta,',')..'],'..
  '\n  "comparison_panel_order":["old target idle","new neutral idle","player source frame 1"],'..
  '\n  "previews":{"contact":"contact-15-cels-4x.png","walk_gif":"walk-4x.gif","attack_gif":"attack-4x.gif"}'..
  '\n}\n'
local f=assert(io.open(root..'metadata.json','w'))
f:write(json); f:close()
print('ARTIFACTS_SAVED',root,'FRAMES',#sprite.frames,'PALETTE_COLORS',#palette)
