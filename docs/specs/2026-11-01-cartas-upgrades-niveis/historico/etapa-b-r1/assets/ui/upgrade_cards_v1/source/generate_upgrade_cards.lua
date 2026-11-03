local function main()
  local P=app.params or {}
  local PREVIEW_ONLY=(P.preview_only=="true" or P.preview_only==true)
  local ROOT=assert(P.root,"missing root parameter")
  local KIT=ROOT.."/assets/ui/upgrade_cards_v1"
  local SRC,OUT,PRE=KIT.."/source",KIT.."/export",KIT.."/preview"
  local PAL=ROOT.."/assets/ui/hud_caldeira_v1/export/palette.json"
  local FONTJSON=ROOT.."/assets/ui/hud_caldeira_v1/export/font.json"
  local FONTPNG=ROOT.."/assets/ui/hud_caldeira_v1/export/font-atlas.png"
  local pc=app.pixelColor
  local EXPECT={"0E0D0E","0C1B29","142C40","203E50","353B3B","4B555D","59636B","879198","B6BEC3","70432C","925A36","B78342","D2A75C","E8D8B5","F4ECD8","B84B42","7D302E","52BAC7","FFFFFF"}
  local function read(path) local f=assert(io.open(path,"rb"),"cannot read "..path); local s=f:read("*a"); f:close(); return s end
  local function write(path,s) local f=assert(io.open(path,"wb"),"cannot write "..path); f:write(s); f:close() end
  local function lock()
    local raw=read(PAL); assert(raw:find('"alpha":[0,255]',1,true),"alpha lock changed")
    local paletteRows=assert(raw:match('"colors":%[([^%]]+)%]'),"palette colors missing"); local got={}; for h in paletteRows:gmatch("#([0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f])") do got[#got+1]=h:upper() end
    assert(#got==#EXPECT,"palette size changed")
    local cs={}
    for i,h in ipairs(EXPECT) do assert(got[i]==h,"palette/order drift at "..i); cs[i]=pc.rgba(tonumber(h:sub(1,2),16),tonumber(h:sub(3,4),16),tonumber(h:sub(5,6),16),255) end
    local K={ink=cs[1],navy=cs[2],blue=cs[3],blue2=cs[4],iron=cs[5],steelDark=cs[6],steel=cs[7],steelLight=cs[8],silver=cs[9],rustDark=cs[10],rust=cs[11],copper=cs[12],amber=cs[13],cream=cs[14],ivory=cs[15],red=cs[16],redDark=cs[17],cyan=cs[18],white=cs[19]}
    return cs,K
  end
  local function setPal(spr,cs)
    local p=Palette(#cs)
    for i,c in ipairs(cs) do p:setColor(i-1,Color(pc.rgbaR(c),pc.rgbaG(c),pc.rgbaB(c),255)) end
    spr:setPalette(p)
  end
  local function img(w,h) return Image(w,h) end
  local function px(im,x,y,c) if x>=0 and y>=0 and x<im.width and y<im.height then im:drawPixel(x,y,c) end end
  local function rect(im,x,y,w,h,c)
    if w<=0 or h<=0 then return end
    for yy=math.max(0,y),math.min(im.height-1,y+h-1) do for xx=math.max(0,x),math.min(im.width-1,x+w-1) do im:drawPixel(xx,yy,c) end end
  end
  local function line(im,x0,y0,x1,y1,c,width)
    width=width or 1
    local dx,sx=math.abs(x1-x0),x0<x1 and 1 or -1; local dy,sy=-math.abs(y1-y0),y0<y1 and 1 or -1; local err=dx+dy
    while true do
      local a=math.floor((width-1)/2); rect(im,x0-a,y0-a,width,width,c)
      if x0==x1 and y0==y1 then break end
      local e=2*err; if e>=dy then err=err+dy; x0=x0+sx end; if e<=dx then err=err+dx; y0=y0+sy end
    end
  end
  local function disk(im,cx,cy,r,c)
    for yy=-r,r do local hw=math.floor(math.sqrt(math.max(0,r*r-yy*yy))); rect(im,cx-hw,cy+yy,hw*2+1,1,c) end
  end
  local function ring(im,cx,cy,ro,ri,c)
    for y=-ro,ro do for x=-ro,ro do local d=x*x+y*y; if d<=ro*ro and d>=ri*ri then px(im,cx+x,cy+y,c) end end end
  end
  local function poly(im,pts,fill,outline)
    local y0,y1=pts[1].y,pts[1].y
    for _,p in ipairs(pts) do y0=math.min(y0,p.y); y1=math.max(y1,p.y) end
    for y=y0,y1 do
      local xs={}
      for i=1,#pts do local a,b=pts[i],pts[i%#pts+1]; if (a.y<=y and b.y>y) or (b.y<=y and a.y>y) then xs[#xs+1]=a.x+(y-a.y)*(b.x-a.x)/(b.y-a.y) end end
      table.sort(xs)
      for i=1,#xs-1,2 do for x=math.ceil(xs[i]),math.floor(xs[i+1]) do px(im,x,y,fill) end end
    end
    if outline then for i=1,#pts do local a,b=pts[i],pts[i%#pts+1]; line(im,a.x,a.y,b.x,b.y,outline,1) end end
  end
  local function paste(dst,src,x,y) dst:drawImage(src,x,y) end
  local function compose(w,h,layers) local o=img(w,h); for _,l in ipairs(layers) do paste(o,l.image,0,0) end; return o end
  local function save(im,path) assert(im:saveAs(path),"export failed: "..path) end
  local function saveAse(path,w,h,layers,cs)
    local s=Sprite(w,h); while #s.layers>1 do s:deleteLayer(s.layers[#s.layers]) end
    for i,l in ipairs(layers) do local layer=i==1 and s.layers[1] or s:newLayer(); layer.name=l.name; layer.opacity=255; layer.isVisible=true; local full=img(w,h); paste(full,l.image,0,0); s:newCel(layer,1).image=full end
    setPal(s,cs); assert(s:saveAs(path),"ASE save failed: "..path)
  end
  local function bolt(im,x,y,K)
    rect(im,x-3,y-3,7,7,K.ink); rect(im,x-2,y-2,5,5,K.rustDark); rect(im,x-1,y-1,3,3,K.copper); px(im,x-1,y-1,K.cream); px(im,x+1,y+1,K.rust)
  end
  local function screw(im,x,y,K)
    disk(im,x,y,3,K.ink); disk(im,x,y,2,K.steel); line(im,x-1,y+1,x+1,y-1,K.ink,1); px(im,x-1,y-1,K.silver)
  end

  local arts={}
  local function art(id,draw)
    local cs,K=lock()
    local a,b,c=img(128,80),img(128,80),img(128,80)
    local layers={{name="01 Silhouette and metal",image=a},{name="02 Painted surfaces",image=b},{name="03 Highlights and impact",image=c}}
    draw(a,b,c,K)
    local out=compose(128,80,layers); save(out,OUT.."/"..id.."_128x80.png")
    saveAse(SRC.."/"..id.."_128x80.aseprite",128,80,layers,cs)
    arts[id]=out; print("ART_OK "..id.." 128x80")
  end

  if not PREVIEW_ONLY then
  art("impacto_reforcado",function(s,m,d,K)
    line(s,38,43,68,70,K.ink,10); line(m,39,43,67,68,K.rustDark,7); line(m,39,42,64,64,K.rust,3); line(d,40,41,53,53,K.amber,1)
    poly(s,{{x=16,y=14},{x=39,y=13},{x=53,y=26},{x=50,y=43},{x=38,y=54},{x=19,y=50},{x=11,y=35}},K.ink,K.ink)
    poly(m,{{x=18,y=16},{x=38,y=15},{x=50,y=27},{x=47,y=42},{x=37,y=51},{x=21,y=47},{x=14,y=34}},K.red,K.redDark)
    poly(d,{{x=19,y=17},{x=37,y=16},{x=45,y=24},{x=26,y=24},{x=17,y=31}},K.copper,K.copper); line(d,20,18,36,17,K.cream,1)
    disk(s,82,35,10,K.ink); disk(m,82,35,8,K.cream); disk(m,81,35,6,K.ivory); rect(d,77,29,4,2,K.white); px(d,79,28,K.white); px(d,75,33,K.silver)
    line(s,92,23,105,14,K.ink,3); line(d,93,22,104,15,K.amber,1); line(s,95,35,115,35,K.ink,3); line(d,96,34,115,34,K.cyan,1); line(s,91,46,104,56,K.ink,3); line(d,92,46,103,54,K.amber,1)
    line(d,107,25,116,21,K.cream,1); line(d,109,45,117,49,K.cream,1); bolt(d,26,36,K)
  end)
  art("motor_acelerado",function(s,m,d,K)
    line(s,18,40,39,40,K.ink,8); line(m,19,39,39,39,K.steelDark,4); line(d,19,38,36,38,K.cyan,1)
    poly(s,{{x=33,y=19},{x=75,y=19},{x=91,y=29},{x=91,y=51},{x=75,y=61},{x=33,y=61},{x=25,y=53},{x=25,y=27}},K.iron,K.ink)
    poly(m,{{x=35,y=22},{x=74,y=22},{x=87,y=30},{x=87,y=50},{x=74,y=58},{x=35,y=58},{x=29,y=51},{x=29,y=29}},K.steelDark,K.steel)
    rect(m,37,26,38,7,K.steel); rect(d,39,27,29,2,K.silver); rect(m,38,48,36,6,K.iron); rect(d,41,49,22,2,K.blue2)
    poly(s,{{x=86,y=29},{x=105,y=34},{x=105,y=46},{x=86,y=51}},K.ink,K.ink); poly(m,{{x=87,y=32},{x=103,y=36},{x=103,y=44},{x=87,y=48}},K.copper,K.rustDark); poly(d,{{x=91,y=35},{x=106,y=37},{x=106,y=43},{x=91,y=45}},K.navy,K.navy); rect(d,92,37,11,2,K.cyan)
    rect(m,40,33,21,11,K.blue); rect(d,42,34,17,2,K.steelLight); rect(m,64,33,8,11,K.rustDark); rect(d,66,34,4,8,K.amber)
    line(d,108,31,122,25,K.cyan,2); line(d,108,40,124,40,K.cream,2); line(d,108,49,121,55,K.cyan,2); line(s,112,31,123,26,K.ink,1); line(s,112,49,122,54,K.ink,1)
    bolt(d,34,28,K); bolt(d,34,52,K); screw(d,78,27,K); screw(d,78,53,K)
  end)
  art("carga_reativa",function(s,m,d,K)
    rect(s,19,26,70,32,K.ink); rect(m,22,28,64,28,K.steelDark); rect(m,26,31,55,22,K.rustDark)
    for x=30,70,10 do rect(s,x,29,5,26,K.ink); rect(m,x+1,30,3,24,K.copper); rect(d,x+1,31,1,21,K.amber); rect(s,x+5,30,2,24,K.rustDark) end
    rect(m,26,37,55,7,K.blue); rect(d,28,38,48,2,K.cyan); rect(s,78,35,11,14,K.ink); rect(m,79,37,10,10,K.steel); rect(d,80,38,8,2,K.silver)
    disk(s,98,41,16,K.ink); disk(m,98,41,13,K.cream); disk(m,100,40,10,K.ivory); disk(d,103,36,5,K.white)
    line(d,91,54,101,58,K.cyan,2); line(d,102,55,108,58,K.amber,2); line(d,92,24,102,21,K.cyan,2); line(d,106,25,115,21,K.cream,1)
    bolt(d,25,32,K); bolt(d,25,51,K); screw(d,75,32,K); screw(d,75,50,K)
  end)
  art("ricochete_pressao",function(s,m,d,K)
    rect(s,101,8,20,64,K.ink); rect(m,104,10,14,60,K.steelDark); rect(m,106,12,4,56,K.steel); rect(d,107,13,2,53,K.steelLight); rect(s,118,10,3,60,K.iron)
    for y=19,59,13 do screw(d,113,y,K) end
    for x=14,67,12 do rect(d,x,58-math.floor((x-14)*0.38),7,2,K.amber) end
    for x=54,88,11 do rect(d,x,28-math.floor((x-54)*0.35),6,2,K.cyan) end
    line(s,58,42,84,30,K.ink,3); line(d,60,41,82,31,K.amber,1); disk(s,88,29,11,K.ink); disk(m,88,29,9,K.cream); disk(m,87,28,6,K.ivory); rect(d,83,22,4,2,K.white)
    line(s,96,20,101,16,K.ink,3); line(d,97,20,100,17,K.copper,1); line(s,96,36,101,40,K.ink,3); line(d,97,36,100,39,K.copper,1)
    line(d,64,20,72,13,K.cyan,1); line(d,70,48,79,53,K.amber,1)
  end)
  art("mola_retorno",function(s,m,d,K)
    rect(s,10,26,14,28,K.ink); rect(m,12,28,10,24,K.steelDark); rect(d,14,29,3,5,K.steelLight); rect(d,14,46,3,5,K.steelLight); bolt(d,17,32,K); bolt(d,17,48,K)
    line(s,22,40,34,40,K.ink,7); line(m,22,40,34,40,K.steel,3)
    line(s,32,40,41,25,K.ink,7); line(s,41,25,51,55,K.ink,7); line(s,51,55,61,25,K.ink,7); line(s,61,25,71,55,K.ink,7); line(s,71,55,81,25,K.ink,7); line(s,81,25,91,40,K.ink,7)
    line(m,32,40,41,25,K.copper,4); line(m,41,25,51,55,K.copper,4); line(m,51,55,61,25,K.copper,4); line(m,61,25,71,55,K.copper,4); line(m,71,55,81,25,K.copper,4); line(m,81,25,91,40,K.copper,4)
    line(d,35,37,42,26,K.amber,1); line(d,54,50,61,29,K.amber,1); line(d,74,50,81,29,K.amber,1)
    rect(s,88,32,10,16,K.ink); rect(m,89,34,11,12,K.steelDark); rect(d,90,35,8,2,K.silver)
    disk(s,108,40,16,K.ink); disk(m,108,40,13,K.cream); disk(m,110,39,10,K.ivory); disk(d,113,35,5,K.white); line(d,99,55,107,59,K.cyan,1); bolt(d,95,40,K)
  end)
  art("dinamo_defesa",function(s,m,d,K)
    line(s,37,43,61,66,K.ink,9); line(m,38,43,60,64,K.rustDark,6); line(d,39,42,54,56,K.amber,1)
    poly(s,{{x=14,y=15},{x=36,y=14},{x=51,y=27},{x=48,y=44},{x=36,y=55},{x=18,y=50},{x=10,y=35}},K.ink,K.ink)
    poly(m,{{x=17,y=17},{x=35,y=16},{x=48,y=28},{x=45,y=42},{x=35,y=51},{x=20,y=47},{x=13,y=34}},K.red,K.redDark)
    poly(d,{{x=18,y=18},{x=34,y=17},{x=43,y=25},{x=25,y=24},{x=16,y=31}},K.copper,K.copper); line(d,19,19,34,18,K.cream,1)
    disk(s,68,54,18,K.ink); disk(m,68,54,15,K.steelDark); ring(d,68,54,13,10,K.copper); disk(m,68,54,8,K.blue); disk(d,68,54,4,K.amber); rect(d,66,50,4,2,K.cream)
    disk(s,99,32,18,K.ink); disk(m,99,32,15,K.copper); disk(m,99,32,12,K.navy); ring(d,99,32,11,10,K.steelLight)
    for _,p in ipairs({{99,22},{109,32},{99,42},{89,32},{106,25},{92,25},{106,39},{92,39}}) do px(d,p[1],p[2],K.cream) end
    line(s,99,32,106,26,K.ink,3); line(d,99,32,106,26,K.cyan,1); disk(d,99,32,2,K.ivory); bolt(d,60,43,K); line(d,84,52,95,48,K.cyan,2); line(d,83,57,91,58,K.amber,1)
  end)
  art("chassi_reforcado",function(s,m,d,K)
    poly(s,{{x=19,y=17},{x=99,y=17},{x=109,y=27},{x=109,y=56},{x=99,y=65},{x=19,y=65},{x=12,y=57},{x=12,y=25}},K.ink,K.ink)
    poly(m,{{x=22,y=21},{x=97,y=21},{x=105,y=28},{x=105,y=54},{x=97,y=61},{x=22,y=61},{x=16,y=55},{x=16,y=27}},K.steelDark,K.steel)
    poly(d,{{x=24,y=22},{x=96,y=22},{x=102,y=28},{x=29,y=28},{x=20,y=34}},K.steel,K.steel)
    rect(m,26,34,67,19,K.iron); rect(d,28,35,62,3,K.steel); rect(m,31,44,56,6,K.steelDark)
    poly(s,{{x=22,y=50},{x=29,y=42},{x=98,y=42},{x=91,y=50}},K.ink,K.ink); poly(m,{{x=25,y=49},{x=31,y=44},{x=95,y=44},{x=90,y=49}},K.amber,K.amber)
    for x=34,83,16 do poly(d,{{x=x,y=44},{x=x+6,y=44},{x=x+1,y=49},{x=x-5,y=49}},K.ink,K.ink) end
    for _,p in ipairs({{22,27},{99,27},{22,55},{99,55}}) do bolt(d,p[1],p[2],K) end
    rect(d,46,32,27,2,K.silver); rect(d,50,56,23,2,K.steel); screw(d,93,34,K)
  end)

  else
    for _,id in ipairs({"impacto_reforcado","motor_acelerado","carga_reativa","ricochete_pressao","mola_retorno","dinamo_defesa","chassi_reforcado"}) do arts[id]=Image{fromFile=OUT.."/"..id.."_128x80.png"} end
  end

  local function frame(state)
    local cs,K=lock()
    local base,trim,st=img(160,240),img(160,240),img(160,240)
    rect(base,0,0,160,240,K.ink); rect(base,2,2,156,236,K.navy); rect(base,4,4,152,232,K.blue); rect(base,6,6,148,228,K.navy)
    rect(base,8,7,144,21,K.blue); rect(base,10,8,140,18,K.navy)
    rect(base,14,32,132,84,K.ink); rect(base,15,33,130,82,K.steelDark); rect(base,16,34,128,80,K.navy)
    rect(base,10,119,140,1,K.blue); rect(base,10,138,140,1,K.blue); rect(base,10,188,140,1,K.blue)
    rect(base,12,204,136,24,K.ink); rect(base,13,205,134,22,K.blue); rect(base,14,206,132,20,K.navy); rect(base,14,232,132,2,K.ink)
    rect(trim,2,2,156,1,K.copper); rect(trim,2,2,1,236,K.copper); rect(trim,157,2,1,236,K.iron); rect(trim,2,237,156,1,K.rustDark)
    rect(trim,6,6,148,1,K.steel); rect(trim,6,6,1,228,K.steel); rect(trim,153,6,1,228,K.ink); rect(trim,8,28,144,1,K.copper)
    rect(trim,14,32,132,1,K.copper); rect(trim,14,32,1,84,K.copper); rect(trim,145,32,1,84,K.rustDark); rect(trim,14,115,132,1,K.rustDark)
    rect(trim,10,119,140,1,K.steelDark); rect(trim,10,138,140,1,K.steelDark); rect(trim,10,188,140,1,K.steelDark)
    rect(trim,12,204,136,1,K.copper); rect(trim,12,204,1,24,K.copper); rect(trim,147,204,1,24,K.rustDark); rect(trim,12,227,136,1,K.rustDark)
    rect(trim,14,124,3,3,K.cyan); rect(trim,14,144,2,2,K.copper); rect(trim,14,158,2,2,K.copper); rect(trim,14,172,2,2,K.copper)
    bolt(trim,5,5,K); bolt(trim,154,5,K); bolt(trim,5,234,K); bolt(trim,154,234,K)
    screw(trim,8,42,K); screw(trim,151,42,K); screw(trim,8,109,K); screw(trim,151,109,K)
    if state=="focus" then
      rect(st,1,1,158,1,K.cyan); rect(st,1,1,1,238,K.cyan); rect(st,158,1,1,238,K.cyan); rect(st,1,238,158,1,K.cyan)
      rect(st,12,2,18,2,K.cyan); rect(st,130,236,18,2,K.cyan); rect(st,1,25,2,18,K.cyan); rect(st,157,196,2,18,K.cyan)
    elseif state=="pressed" then
      rect(st,2,2,156,1,K.ink); rect(st,2,2,1,236,K.ink); rect(st,3,237,154,1,K.copper); rect(st,157,4,1,230,K.copper)
      rect(st,10,9,140,1,K.blue2); rect(st,11,10,1,17,K.iron); rect(st,15,33,130,1,K.iron); rect(st,15,115,130,1,K.copper)
    end
    return cs,{{name="01 Panel field",image=base},{name="02 Copper and steel frame",image=trim},{name="03 State bevel",image=st}}
  end
  local function makeFrames()
    local names={"normal","focus","pressed"}; local all={}; local cs0
    for i,name in ipairs(names) do local cs,layers=frame(name); cs0=cs; all[i]=layers; save(compose(160,240,layers),OUT.."/frame_"..name.."_160x240.png"); print("FRAME_OK "..name) end
    local s=Sprite(160,240); while #s.layers>1 do s:deleteLayer(s.layers[#s.layers]) end
    local refs={}
    for i,name in ipairs({"01 Panel field","02 Copper and steel frame","03 State bevel"}) do local l=i==1 and s.layers[1] or s:newLayer(); l.name=name; l.opacity=255; l.isVisible=true; refs[i]=l end
    for fi=1,3 do
      if fi>1 then s:newEmptyFrame(fi) end
      for li,e in ipairs(all[fi]) do local full=img(160,240); paste(full,e.image,0,0); s:newCel(refs[li],fi).image=full end
      local tag=s:newTag(fi,fi); tag.name=names[fi]; tag.aniDir=AniDir.FORWARD
    end
    setPal(s,cs0); assert(s:saveAs(SRC.."/upgrade-card-frame-states.aseprite"),"frame ASE save failed")
  end
  local function loadFont()
    lock()
    local raw=read(FONTJSON); assert(raw:find('"cell":{"w":5,"h":11}',1,true)); assert(raw:find('"advance":6',1,true))
    local atlas=Image{fromFile=FONTPNG}; assert(atlas.width==72 and atlas.height==105,"font atlas dimensions changed")
    local gs={}; local pat='"character":"([^"]*)","codepoint":(%d+),"rect":{"x":(%d+),"y":(%d+),"w":(%d+),"h":(%d+)},"advance":(%d+)'
    for ch,cp,x,y,w,h,a in raw:gmatch(pat) do gs[ch]={x=tonumber(x),y=tonumber(y),w=tonumber(w),h=tonumber(h),advance=tonumber(a)} end
    assert(gs.A and gs["-"] and gs[" "],"font glyphs missing")
    return atlas,gs
  end
  local function chars(s)
    local out,i={},1; while i<=#s do local b=s:byte(i); local n=(b<128 and 1) or (b<224 and 2) or (b<240 and 3) or 4; out[#out+1]=s:sub(i,i+n-1); i=i+n end; return out
  end
  local function text(im,x,y,s,c,atlas,gs)
    local cur=x
    for _,ch in ipairs(chars(s)) do
      if ch=="+" then
        for xx=1,3 do px(im,cur+xx,y+5,c) end
        for yy=3,7 do px(im,cur+2,y+yy,c) end
        cur=cur+6
      else
        local g=assert(gs[ch],"preview glyph missing: "..ch)
        for yy=0,g.h-1 do for xx=0,g.w-1 do if pc.rgbaA(atlas:getPixel(g.x+xx,g.y+yy))>0 then px(im,cur+xx,y+yy,c) end end end
        cur=cur+g.advance
      end
    end
  end
  local function centerText(im,cx,y,s,c,atlas,gs)
    local w=0
    for _,ch in ipairs(chars(s)) do
      if ch=="+" then w=w+6 else w=w+assert(gs[ch],"preview glyph missing: "..ch).advance end
    end
    text(im,cx-math.floor(w/2),y,s,c,atlas,gs)
  end
  local function makePreview()
    local _,K=lock(); local atlas,gs=loadFont()
    local im=img(576,324); rect(im,0,0,576,324,K.navy); rect(im,0,0,576,36,K.blue); rect(im,0,0,576,2,K.copper); rect(im,0,34,576,2,K.ink)
    rect(im,18,17,42,1,K.steel); rect(im,516,17,42,1,K.steel)
    centerText(im,288,10,"OFICINA - UPGRADES",K.ivory,atlas,gs); centerText(im,288,39,"3 CARTAS NOVAS - COMPOSICAO DE ESTUDO",K.cream,atlas,gs)
    local data={
      {id="ricochete_pressao",title="RICOC. DE PRESSAO",desc="DANO SOBE NO RICOCHETE",topics={"+1 DANO POR PAREDE","BÔNUS ATÉ 3 PAREDES","NÍVEL MÁXIMO 3"},state="normal"},
      {id="mola_retorno",title="MOLA DE RETORNO",desc="MAIS TEMPO EM JOGO",topics={"+1 RICOCHETE","+0,35S DE VIDA ATIVA","NÍVEL MÁXIMO 3"},state="focus"},
      {id="dinamo_defesa",title="DINAMO DE DEFESA",desc="PARRY ALIVIA O DASH",topics={"RECARGA -0,15S","1 VEZ POR REBATIDA","NÍVEL MÁXIMO 3"},state="normal"}
    }
    local xs={36,208,380}; local frames={}
    for _,name in ipairs({"normal","focus","pressed"}) do frames[name]=Image{fromFile=OUT.."/frame_"..name.."_160x240.png"} end
    for i,c in ipairs(data) do local x,y=xs[i],60; paste(im,frames[c.state],x,y); paste(im,arts[c.id],x+16,y+34)
      centerText(im,x+80,y+9,c.title,K.ivory,atlas,gs); centerText(im,x+80,y+121,c.desc,K.cream,atlas,gs)
      for ti,t in ipairs(c.topics) do assert(#chars(t)<=24,"card line exceeds 24 glyphs"); text(im,x+20,y+144+(ti-1)*14,t,K.silver,atlas,gs) end
      centerText(im,x+80,y+210,"NOVO",K.cyan,atlas,gs)
    end
    centerText(im,288,307,"ESTUDO DE ARTE - NAO E SCREENSHOT GODOT",K.silver,atlas,gs)
    save(im,PRE.."/upgrade-cards-study-576x324.png")
    local big=img(1728,972); for y=0,323 do for x=0,575 do local v=im:getPixel(x,y); for dy=0,2 do for dx=0,2 do big:drawPixel(x*3+dx,y*3+dy,v) end end end end
    save(big,PRE.."/upgrade-cards-study-1728x972.png")
    print("PREVIEW_OK 576x324 and 3x")
  end
  local function makeContact()
    local _,K=lock(); local atlas,gs=loadFont(); local im=img(432,352)
    rect(im,0,0,432,352,K.navy); rect(im,0,0,432,2,K.copper)
    local names={{"impacto_reforcado","IMPACTO REFORCADO"},{"motor_acelerado","MOTOR ACELERADO"},{"carga_reativa","CARGA REATIVA"},{"ricochete_pressao","RICOCHETE PRESSAO"},{"mola_retorno","MOLA RETORNO"},{"dinamo_defesa","DINAMO DEFESA"},{"chassi_reforcado","CHASSI REFORCADO"}}
    for i,e in ipairs(names) do local col=(i-1)%3; local row=math.floor((i-1)/3); local x,y=8+col*140,8+row*112
      rect(im,x,y,136,104,K.ink); rect(im,x+1,y+1,134,102,K.blue); rect(im,x+3,y+3,130,82,K.navy); paste(im,arts[e[1]],x+4,y+4); centerText(im,x+68,y+88,e[2],K.cream,atlas,gs)
    end
    save(im,PRE.."/upgrade-illustrations-contact-432x352.png")
    local big=img(864,704); for y=0,351 do for x=0,431 do local v=im:getPixel(x,y); for dy=0,1 do for dx=0,1 do big:drawPixel(x*2+dx,y*2+dy,v) end end end end
    save(big,PRE.."/upgrade-illustrations-contact-864x704.png")
    print("ART_CONTACT_OK 864x704")
  end

  if not PREVIEW_ONLY then makeFrames() end
  makePreview()
  if not PREVIEW_ONLY then makeContact()
  write(SRC.."/.gdignore",""); write(PRE.."/.gdignore","")
  write(KIT.."/integration_geometry.json",[[
{
  "card_size":{"w":160,"h":240},
  "illustration":{"x":16,"y":34,"w":128,"h":80,"transparent":true,"draw_order":"after_frame"},
  "text":{"title":{"x":8,"y":8,"w":144,"h":12},"summary":{"x":8,"y":121,"w":144,"h":12},"topics":[{"x":12,"y":144,"w":136,"h":12},{"x":12,"y":158,"w":136,"h":12},{"x":12,"y":172,"w":136,"h":12}],"badge":{"x":12,"y":204,"w":136,"h":24}},
  "preview":{"canvas":{"w":576,"h":324},"cards":[{"x":36,"y":60},{"x":208,"y":60},{"x":380,"y":60}]},
  "palette_source":"assets/ui/hud_caldeira_v1/export/palette.json",
  "font_source":"assets/ui/hud_caldeira_v1/export/font.json",
  "font_atlas":"assets/ui/hud_caldeira_v1/export/font-atlas.png",
  "font":{"base_bundle":"assets/ui/hud_caldeira_v1/export/font.json","base_atlas":"assets/ui/hud_caldeira_v1/export/font-atlas.png","replacement_atlas":"assets/ui/upgrade_cards_v1/export/card-font-atlas.png","additions":"assets/ui/upgrade_cards_v1/export/card-font-additions.json","metrics":{"cell":{"w":5,"h":11},"advance":6,"line_height":12,"baseline_from_top_zero_based":8,"canvas":{"w":84,"h":105}},"integration":"Load base bundle, replace atlas path, append additions.glyphs and call configure_font(bundle) on HudBitmapText."}
}
]])
  write(KIT.."/README.md",[[
# Upgrade Cards v1

Pixel-art assets authored with Aseprite 1.3.18.6 in an industrial cartoon style.
The 19-color palette is reread from assets/ui/hud_caldeira_v1/export/palette.json
before each asset. Alpha uses only 0 or 255. Card text uses a local font bundle
that preserves the HUD base atlas and appends + and > glyphs.

## Integration geometry

- Card frame PNGs are full-frame 160x240 and opaque. Draw the frame, then draw
  the transparent illustration at local x=16, y=34, w=128, h=80.
- Frame states normal/focus/pressed share geometry and do not move text or art.
- Bitmap text zones: title x=8,y=8,w=144; summary x=8,y=121,w=144;
  topics x=20 at y=144/158/172, w=128; badge x=12,y=204,w=136,h=24.
  Recommended topic line limit is 21 glyphs. The HUD font has no plus or greater-than;
  the card font bundle appends both glyphs without changing HUD files.
- Preview canvas is 576x324. Card origins are (36,60), (208,60), (380,60).
  It shows Ricochete de Pressão, Mola de Retorno, and Dínamo de Defesa as
  NOVO. It is a visual study, explicitly not a Godot screenshot.
- Image IDs: impacto_reforcado, motor_acelerado, carga_reativa,
  ricochete_pressao, mola_retorno, dinamo_defesa, chassi_reforcado. Runtime
  definition IDs can map to these names; this art-only front does not impose
  final catalog IDs or effects.

## Files

- export: seven transparent illustration PNGs and three card-frame PNGs.
- source: generation Lua and layered Aseprite sources for each illustration
  and the three frame states.
- preview: native and integer-upscaled studies plus a two-times art contact sheet.
- Card text loads the original font.json bundle, substitutes card-font-atlas.png,
  appends glyph records from card-font-additions.json, then calls
  configure_font(bundle) on HudBitmapText.
- source and preview have .gdignore files.

This front generated art assets only; it did not run Godot, imports, tests,
audits, parser, linter, or simulations.
]])
  local files={}
  for _,id in ipairs({"impacto_reforcado","motor_acelerado","carga_reativa","ricochete_pressao","mola_retorno","dinamo_defesa","chassi_reforcado"}) do files[#files+1]='"'..id..'_128x80.png"' end
  write(OUT.."/manifest.json",'{"asset_set":"upgrade_cards_v1","card":{"w":160,"h":240},"illustration":{"w":128,"h":80},"palette":"assets/ui/hud_caldeira_v1/export/palette.json","palette_colors":19,"alpha":[0,255],"font":"assets/ui/hud_caldeira_v1/export/font-atlas.png","card_font":{"base_bundle":"assets/ui/hud_caldeira_v1/export/font.json","replacement_atlas":"card-font-atlas.png","additions":"card-font-additions.json","canvas":{"w":84,"h":105},"glyphs":[{"character":"+","codepoint":43},{"character":">","codepoint":62}]},"illustrations":['..table.concat(files,",")..'],"frames":["frame_normal_160x240.png","frame_focus_160x240.png","frame_pressed_160x240.png"],"previews":["preview/upgrade-cards-study-576x324.png","preview/upgrade-cards-study-1728x972.png","preview/upgrade-illustrations-contact-864x704.png"],"notes":["visual study only; not a Godot screenshot","runtime is not verified"]}')
  local log=assert(io.open(SRC.."/generation.log","wb")); log:write("UPGRADE_CARDS_GENERATION_OK\nASEPRITE_VERSION="..tostring(app.version or "unknown").."\nARTS=7x128x80\nFRAMES=3x160x240\nPREVIEW=576x324 plus integer 3x; ART_CONTACT=integer 2x\nPALETTE_SOURCE="..PAL.."\n"); log:close()
  print("UPGRADE_CARDS_GENERATION_OK "..KIT)
  else
    print("PREVIEW_REFRESH_OK "..PRE)
  end
end

local ok,err=xpcall(main,debug.traceback)
if not ok then print("UPGRADE_CARDS_GENERATION_ERROR: "..tostring(err)); error(err) end
