-- Pulo frontal: três poses estáticas escolhidas pela velocidade vertical real do Player.
-- A entrada congelada contém idle 0–5, walk 6–13 e dash 14–16.
-- A fonte preserva esses 17 quadros pixel a pixel e acrescenta ascent, apex e fall.
-- Aseprite 1.3.18.6; parâmetros --script-param devem vir antes de --script.
local p = app.params or {}
local W,H = 64,64
local OUT = app.fs.normalizePath(p.out or "C:/Users/danie/Documents/ChatGPT/TEC - Jogos/GDD_Dieselpunk_Noir/pitch-assets/protagonista-pulo")
local ATLAS = app.fs.normalizePath(p.atlas or app.fs.joinPath(OUT, "protagonista-pulo-input-atlas-1088x64.png"))
local BASE = p.base or "protagonista-pulo"
local function out(name) return app.fs.joinPath(OUT,name) end
local pc = app.pixelColor
local paletteRGB = {
 {245,233,216},{252,194,3},{0,17,35},{0,0,13},{55,63,77},
 {46,101,176},{1,0,14},{207,195,183},{0,0,16},{0,0,15},
 {0,0,0},{48,105,181},{0,0,12},{1,0,11},{2,2,19},
 {1,1,17},{1,1,13},{246,236,221},{243,177,0},{19,49,86},
 {25,32,49},{255,252,240},{6,4,25},{0,236,253},{3,23,39},
 {26,66,118},{137,124,118},
}
local masks = {
 leftArm={x1=20,x2=27,y1=40,y2=44},
 rightArm={x1=37,x2=44,y1=40,y2=44},
 leftLeg={x1=20,x2=33,y1=46,y2=56},
 rightLeg={x1=34,x2=45,y1=46,y2=56},
}
local function inside(mask,x,y)
 return x>=mask.x1 and x<=mask.x2 and y>=mask.y1 and y<=mask.y2
end
local source = assert(app.open(ATLAS), "Não foi possível abrir o atlas congelado: "..ATLAS)
assert(source.width == 1088 and source.height == 64, "Entrada congelada deve medir 1088x64")
assert(#source.frames == 1, "PNG congelado deve conter uma imagem")
local sourceSheet = assert(source.cels[1], "Entrada congelada sem cel").image
local function extract(index)
 local img=Image(W,H)
 for y=0,H-1 do for x=0,W-1 do
  local raw=sourceSheet:getPixel(index*W+x,y)
  if pc.rgbaA(raw)>0 then img:drawPixel(x,y,raw) end
 end end
 return img
end
local original={}
for i=0,16 do original[i+1]=extract(i) end
local base=original[1]
local body=Image(W,H)
for y=0,H-1 do for x=0,W-1 do
 local raw=base:getPixel(x,y)
 local limb=false
 for _,mask in pairs(masks) do if inside(mask,x,y) then limb=true; break end end
 if pc.rgbaA(raw)>0 and not limb then body:drawPixel(x,y,raw) end
end end

-- Cada tabela move os membros por articulação; cabeça e torso vêm do idle sem transformação.
-- dx é lateral relativo à perna (positivo = centro para a perna esquerda).
local jumpLegs = {
 ascent = {
  left={hip=0,knee=1,ankle=2,foot=2,dyKnee=-1,dyAnkle=-1,dyFoot=-2},
  right={hip=0,knee=-1,ankle=-2,foot=-2,dyKnee=-1,dyAnkle=-1,dyFoot=-2},
 },
 apex = {
  left={hip=0,knee=1,ankle=2,foot=2,dyKnee=-2,dyAnkle=-3,dyFoot=-4},
  right={hip=0,knee=-1,ankle=-2,foot=-2,dyKnee=-2,dyAnkle=-3,dyFoot=-4},
 },
 fall = {
  left={hip=0,knee=-1,ankle=-1,foot=-1,dyKnee=-1,dyAnkle=0,dyFoot=0},
  right={hip=0,knee=1,ankle=1,foot=1,dyKnee=-1,dyAnkle=0,dyFoot=0},
 },
}
-- O braço conserva ombro/cotovelo; antebraço e luva formam um cluster compacto.
local jumpArms = {
 ascent={left={dx=-1,y=-1},right={dx=1,y=-1}},
 apex={left={dx=-2,y=-2},right={dx=2,y=-2}},
 fall={left={dx=-2,y=0},right={dx=2,y=0}},
}
local function transformedLeg(mask,pose)
 local img=Image(W,H)
 for y=mask.y1,mask.y2 do for x=mask.x1,mask.x2 do
  local raw=base:getPixel(x,y)
  if pc.rgbaA(raw)>0 then
   local part
   if y<=47 then part="hip"
   elseif y<=50 then part="knee"
   elseif y==51 then part="ankle"
   else part="foot" end
   local dx=pose[part]
   local dy=0
   if part=="knee" then dy=pose.dyKnee
   elseif part=="ankle" then dy=pose.dyAnkle
   elseif part=="foot" then dy=pose.dyFoot end
   local nx,ny=x+dx,y+dy
   if nx>=0 and nx<W and ny>=0 and ny<H then img:drawPixel(nx,ny,raw) end
  end
 end end
 return img
end
local function transformedArm(mask,pose)
 local img=Image(W,H)
 for y=mask.y1,mask.y2 do for x=mask.x1,mask.x2 do
  local raw=base:getPixel(x,y)
  if pc.rgbaA(raw)>0 then
   local nx,ny=x,y
   if y>=42 then
    local progress=y-41
    local amount=math.min(math.abs(pose.dx),progress)
    local direction=pose.dx<0 and -1 or pose.dx>0 and 1 or 0
    nx=x+direction*amount
    ny=y+pose.y
   end
   if nx>=0 and nx<W and ny>=0 and ny<H then img:drawPixel(nx,ny,raw) end
  end
 end end
 return img
end
local poses={}
for _,name in ipairs({"ascent","apex","fall"}) do
 local img=Image(W,H)
 img:drawImage(body,0,0)
 -- Perna distante primeiro; a perna frontal sobrepõe os pixels de contato.
 img:drawImage(transformedLeg(masks.rightLeg,jumpLegs[name].right),0,0)
 img:drawImage(transformedLeg(masks.leftLeg,jumpLegs[name].left),0,0)
 img:drawImage(transformedArm(masks.rightArm,jumpArms[name].right,"right"),0,0)
 img:drawImage(transformedArm(masks.leftArm,jumpArms[name].left,"left"),0,0)
 poses[#poses+1]=img
end

local paletteSet={}
for _,rgb in ipairs(paletteRGB) do
 paletteSet[string.format("%02X%02X%02X",rgb[1],rgb[2],rgb[3])]=true
end
local function assertBinaryPalette(img,label)
 for y=0,H-1 do for x=0,W-1 do
  local raw=img:getPixel(x,y)
  local alpha=pc.rgbaA(raw)
  assert(alpha==0 or alpha==255,label.." alpha parcial em "..x..","..y)
  if alpha>0 then
   local key=string.format("%02X%02X%02X",pc.rgbaR(raw),pc.rgbaG(raw),pc.rgbaB(raw))
   assert(paletteSet[key],label.." cor fora da paleta em "..x..","..y)
  end
 end end
end
for i,img in ipairs(poses) do assertBinaryPalette(img,"jump "..i) end

-- Fonte combinada: os 17 quadros de runtime são clonados sem alteração; jump ocupa 17–19.
local sprite=Sprite(W,H)
while #sprite.layers>1 do sprite:deleteLayer(sprite.layers[#sprite.layers]) end
local layer=sprite.layers[1]
layer.name="Player · idle/walk/dash/jump"
local palette=Palette(#paletteRGB)
for i,rgb in ipairs(paletteRGB) do palette:setColor(i-1,Color(rgb[1],rgb[2],rgb[3])) end
sprite:setPalette(palette)
local idleDurations={420,140,180,140,540,80}
local walkDurations={75,75,75,75,75,75,75,75}
local dashDurations={40,40,60}
local durations={}
for _,v in ipairs(idleDurations) do durations[#durations+1]=v end
for _,v in ipairs(walkDurations) do durations[#durations+1]=v end
for _,v in ipairs(dashDurations) do durations[#durations+1]=v end
for _=1,3 do durations[#durations+1]=100 end
for i=1,20 do
 local frame=(i==1) and sprite.frames[1] or sprite:newEmptyFrame()
 frame.duration=durations[i]/1000
 local image=(i<=17) and original[i] or poses[i-17]
 local cel=sprite:newCel(layer,i)
 cel.image=image
 cel.position=Point(0,0)
end
local idleTag=sprite:newTag(1,6); idleTag.name="idle"
local walkTag=sprite:newTag(7,14); walkTag.name="walk"
local dashTag=sprite:newTag(15,17); dashTag.name="dash"
local jumpTag=sprite:newTag(18,20); jumpTag.name="jump"
sprite:saveAs(out(BASE..".aseprite"))

-- Contact sheet: poses em escala nearest 6x, canvas completo para conferir o envelope 64x64.
local zoom=6
local contact=Image(W*zoom*3,H*zoom)
local bg=Color(25,32,49)
for y=0,contact.height-1 do for x=0,contact.width-1 do contact:drawPixel(x,y,bg) end end
for i,img in ipairs(poses) do
 local ox=(i-1)*W*zoom
 for y=0,H-1 do for x=0,W-1 do
  local raw=img:getPixel(x,y)
  if pc.rgbaA(raw)>0 then
   for sy=0,zoom-1 do for sx=0,zoom-1 do
    contact:drawPixel(ox+x*zoom+sx,y*zoom+sy,raw)
   end end
  end
 end end
end
contact:saveAs(out(BASE.."-contact.png"))

-- Preview separado: a translação vertical demonstra um arco; não é usada nos frames de runtime.
local previewSteps={
 {kind="idle",index=1,y=64,ms=100},{kind="idle",index=1,y=64,ms=100},{kind="idle",index=1,y=64,ms=100},
 {kind="jump",index=1,y=58,ms=80},{kind="jump",index=1,y=52,ms=80},{kind="jump",index=1,y=45,ms=80},{kind="jump",index=1,y=38,ms=80},
 {kind="jump",index=2,y=30,ms=80},{kind="jump",index=2,y=30,ms=80},{kind="jump",index=2,y=30,ms=80},
 {kind="jump",index=3,y=38,ms=80},{kind="jump",index=3,y=49,ms=80},{kind="jump",index=3,y=60,ms=80},
 {kind="idle",index=1,y=64,ms=100},{kind="idle",index=1,y=64,ms=100},{kind="idle",index=1,y=64,ms=100},
}
local function makePreview(right)
 local preview=Sprite(W,128)
 while #preview.layers>1 do preview:deleteLayer(preview.layers[#preview.layers]) end
 preview.layers[1].name=right and "Preview · direita (espelhada)" or "Preview · esquerda (nativa)"
 for i,step in ipairs(previewSteps) do
  local frame=(i==1) and preview.frames[1] or preview:newEmptyFrame()
  frame.duration=step.ms/1000
  local canvas=Image(W,128)
  local sky=Color(11,18,31)
  local floor=Color(25,32,49)
  for y=0,127 do for x=0,W-1 do
   canvas:drawPixel(x,y,(y>=120) and floor or sky)
  end end
  for x=0,W-1 do canvas:drawPixel(x,119,Color(55,63,77)) end
  local img=(step.kind=="idle") and original[1] or poses[step.index]
  for y=0,H-1 do for x=0,W-1 do
   local sx=right and (W-1-x) or x
   local raw=img:getPixel(sx,y)
   if pc.rgbaA(raw)>0 then canvas:drawPixel(x,step.y+y,raw) end
  end end
  local cel=preview:newCel(preview.layers[1],i)
  cel.image=canvas
  cel.position=Point(0,0)
 end
 preview:saveAs(out(BASE..(right and "-preview-direita.aseprite" or "-preview-esquerda.aseprite")))
end
makePreview(false)
makePreview(true)

local meta=assert(io.open(out(BASE.."-metadata.json"),"wb"))
meta:write([[{
 "revision":"jump v1 — três poses frontais selecionadas pela velocidade vertical",
 "status":"arte integrada após aprovação do principal; revisão externa e gameplay pendentes",
 "source_atlas":"protagonista-pulo-input-atlas-1088x64.png",
 "source_atlas_sha256":"eb354cbe5f5b3a4eb4c07fe277f1fb118cc05e809044c8d0269bf795be3bda65",
 "frame_size":{"width":64,"height":64},
 "atlas_size":{"width":1280,"height":64},
 "palette_colors":27,
 "alpha":"binário",
 "native_facing":"left",
 "preserved_frames":{"idle":[0,5],"walk":[6,13],"dash":[14,16]},
 "jump_frames":{"ascent":17,"apex":18,"fall":19},
 "jump_frame_duration_ms":100,
 "phase_selection":{"ascent":"velocity_y < -40 px/s","apex":"abs(velocity_y) <= 40 px/s","fall":"velocity_y > 40 px/s"},
 "art_notes":"cabeça e torso copiados do idle; antebraços articulados e botas recolhidas na subida/ápice; pernas prontas para apoio na queda",
 "preview_notes":"GIF demonstra deslocamento vertical num arco; translação é apenas demonstrativa e não pertence aos frames runtime",
 "preview_canvas":{"width":64,"height":128},
 "contact":"protagonista-pulo-contact.png",
 "previews":["protagonista-pulo-preview-esquerda.gif","protagonista-pulo-preview-direita.gif"]
}]])
meta:close()
print("STATUS: três poses de pulo geradas; atlas de entrada mantido")
print("ASEPRITE: "..out(BASE..".aseprite"))
print("CONTACT: "..out(BASE.."-contact.png"))
print("INPUT: "..ATLAS)
