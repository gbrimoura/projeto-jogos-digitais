-- Native HUD asset kit generator for Aseprite 1.3.18.6.
-- Parameters must be passed before --script: --script-param root=<repository>
local function main()
  local P=app.params or {}
  local ROOT=assert(P.root,"missing root parameter")
  local KIT=ROOT.."/assets/ui/hud_caldeira_v1"
  local SRC,OUT,PRE=KIT.."/source",KIT.."/export",KIT.."/preview"
  local pc=app.pixelColor
  local HEX={"0E0D0E","0C1B29","142C40","203E50","353B3B","4B555D","59636B","879198","B6BEC3","70432C","925A36","B78342","D2A75C","E8D8B5","F4ECD8","B84B42","7D302E","52BAC7","FFFFFF"}
  local C={}
  for i,h in ipairs(HEX) do C[i]=pc.rgba(tonumber(h:sub(1,2),16),tonumber(h:sub(3,4),16),tonumber(h:sub(5,6),16),255) end
  local K={ink=C[1],navy=C[2],blue=C[3],blue2=C[4],iron=C[5],steelDark=C[6],steel=C[7],steelLight=C[8],silver=C[9],rustDark=C[10],rust=C[11],copper=C[12],amber=C[13],cream=C[14],ivory=C[15],red=C[16],redDark=C[17],cyan=C[18],white=C[19]}
  local function img(w,h) return Image(w,h) end
  local function px(im,x,y,c) if x>=0 and y>=0 and x<im.width and y<im.height then im:drawPixel(x,y,c) end end
  local function rect(im,x,y,w,h,c)
    if w<=0 or h<=0 then return end
    local x0,y0=math.max(0,x),math.max(0,y)
    local x1,y1=math.min(im.width-1,x+w-1),math.min(im.height-1,y+h-1)
    for yy=y0,y1 do for xx=x0,x1 do im:drawPixel(xx,yy,c) end end
  end
  local function line(im,x0,y0,x1,y1,c,width)
    width=width or 1
    local dx,sx=math.abs(x1-x0),x0<x1 and 1 or -1
    local dy,sy=-math.abs(y1-y0),y0<y1 and 1 or -1
    local err=dx+dy
    while true do
      local a=math.floor((width-1)/2); rect(im,x0-a,y0-a,width,width,c)
      if x0==x1 and y0==y1 then break end
      local e=2*err
      if e>=dy then err=err+dy; x0=x0+sx end
      if e<=dx then err=err+dx; y0=y0+sy end
    end
  end
  local function disk(im,cx,cy,r,c)
    for yy=-r,r do local h=math.floor(math.sqrt(math.max(0,r*r-yy*yy))); rect(im,cx-h,cy+yy,h*2+1,1,c) end
  end
  local function paste(dst,src,x,y) dst:drawImage(src,x,y) end
  local function crop(src,x,y,w,h)
    local out=img(w,h)
    for yy=0,h-1 do for xx=0,w-1 do out:drawPixel(xx,yy,src:getPixel(x+xx,y+yy)) end end
    return out
  end
  local function scale(src,n)
    local out=img(src.width*n,src.height*n)
    for y=0,src.height-1 do for x=0,src.width-1 do
      local v=src:getPixel(x,y)
      for dy=0,n-1 do for dx=0,n-1 do out:drawPixel(x*n+dx,y*n+dy,v) end end
    end end
    return out
  end
  local function save(im,path) assert(im:saveAs(path),"save failed: "..path) end
  local function write(path,s) local f=assert(io.open(path,"wb")); f:write(s); f:close() end
  local function esc(s) return '"'..s:gsub("\\","\\\\"):gsub('"','\\"'):gsub("\n","\\n")..'"' end
  local function jwrite(path,s) write(path,s.."\n") end
  local function palette(spr)
    local p=Palette(#HEX)
    for i,h in ipairs(HEX) do p:setColor(i-1,Color(tonumber(h:sub(1,2),16),tonumber(h:sub(3,4),16),tonumber(h:sub(5,6),16),255)) end
    spr:setPalette(p)
  end
  local function panel(w,h)
    local im=img(w,h)
    rect(im,1,0,w-2,h,K.ink); rect(im,0,1,w,h-2,K.ink)
    rect(im,2,1,w-4,h-2,K.navy); rect(im,1,2,w-2,h-4,K.navy)
    rect(im,4,3,w-8,h-6,K.blue); rect(im,6,5,w-12,h-10,K.navy)
    rect(im,6,1,w-12,1,K.copper); rect(im,6,2,w-12,1,K.steel)
    rect(im,6,h-3,w-12,1,K.rust); rect(im,6,h-2,w-12,1,K.ink)
    rect(im,1,6,1,h-12,K.copper); rect(im,2,6,1,h-12,K.steel)
    rect(im,w-3,6,1,h-12,K.rust); rect(im,w-2,6,1,h-12,K.ink)
    local function bolt(x,y)
      rect(im,x-2,y-2,5,5,K.ink); rect(im,x-1,y-1,3,3,K.copper)
      px(im,x-1,y-1,K.cream); px(im,x+1,y+1,K.rustDark)
    end
    bolt(3,3); bolt(w-4,3); bolt(3,h-4); bolt(w-4,h-4)
    return im
  end
  local function barFrame()
    local im=img(96,14)
    rect(im,0,1,96,12,K.ink); rect(im,1,0,94,14,K.ink)
    rect(im,1,1,94,12,K.steelDark); rect(im,2,2,92,10,K.iron)
    rect(im,3,3,90,8,K.navy); rect(im,3,3,90,1,K.blue2); rect(im,3,10,90,1,K.ink)
    px(im,2,2,K.silver); px(im,93,2,K.steel)
    return im
  end
  local function fill(w,base,hi,lo)
    local im=img(w,8); rect(im,0,0,w,1,hi); rect(im,0,1,w,6,base); rect(im,0,7,w,1,lo); return im
  end

  local rows={
    A={"01110","10001","10001","11111","10001","10001","10001"},B={"11110","10001","10001","11110","10001","10001","11110"},
    C={"01111","10000","10000","10000","10000","10000","01111"},D={"11110","10001","10001","10001","10001","10001","11110"},
    E={"11111","10000","10000","11110","10000","10000","11111"},F={"11111","10000","10000","11110","10000","10000","10000"},
    G={"01111","10000","10000","10111","10001","10001","01111"},H={"10001","10001","10001","11111","10001","10001","10001"},
    I={"11111","00100","00100","00100","00100","00100","11111"},J={"00111","00010","00010","00010","00010","10010","01100"},
    K={"10001","10010","10100","11000","10100","10010","10001"},L={"10000","10000","10000","10000","10000","10000","11111"},
    M={"10001","11011","10101","10101","10001","10001","10001"},N={"10001","11001","10101","10011","10001","10001","10001"},
    O={"01110","10001","10001","10001","10001","10001","01110"},P={"11110","10001","10001","11110","10000","10000","10000"},
    Q={"01110","10001","10001","10001","10101","10010","01101"},R={"11110","10001","10001","11110","10100","10010","10001"},
    S={"01111","10000","10000","01110","00001","00001","11110"},T={"11111","00100","00100","00100","00100","00100","00100"},
    U={"10001","10001","10001","10001","10001","10001","01110"},V={"10001","10001","10001","10001","10001","01010","00100"},
    W={"10001","10001","10001","10101","10101","10101","01010"},X={"10001","10001","01010","00100","01010","10001","10001"},
    Y={"10001","10001","01010","00100","00100","00100","00100"},Z={"11111","00001","00010","00100","01000","10000","11111"},
    ["0"]={"01110","10001","10011","10101","11001","10001","01110"},["1"]={"00100","01100","00100","00100","00100","00100","01110"},
    ["2"]={"01110","10001","00001","00010","00100","01000","11111"},["3"]={"11110","00001","00001","01110","00001","00001","11110"},
    ["4"]={"00010","00110","01010","10010","11111","00010","00010"},["5"]={"11111","10000","10000","11110","00001","00001","11110"},
    ["6"]={"01110","10000","10000","11110","10001","10001","01110"},["7"]={"11111","00001","00010","00100","01000","01000","01000"},
    ["8"]={"01110","10001","10001","01110","10001","10001","01110"},["9"]={"01110","10001","10001","01111","00001","00001","01110"},
    s={"00000","01111","10000","01110","00001","10001","01110"},[" "]={"00000","00000","00000","00000","00000","00000","00000"},
    ["/"]={"00001","00010","00010","00100","01000","01000","10000"},[","]={"00000","00000","00000","00000","00110","00110","00100"},[":"]={"00000","00100","00100","00000","00100","00100","00000"},
    ["."]={"00000","00000","00000","00000","00000","00110","00110"},["-"]={"00000","00000","00000","11111","00000","00000","00000"},
    ["%"]={"11001","11010","00100","01000","10110","00110","00000"}
  }
  local accent={
    ["Á"]={base="A",mark={{4,1},{3,2}}},["À"]={base="A",mark={{2,1},{3,2}}},["Â"]={base="A",mark={{2,2},{3,1},{4,2}}},["Ã"]={base="A",mark={{2,1},{3,2},{4,1}}},
    ["É"]={base="E",mark={{4,1},{3,2}}},["Ê"]={base="E",mark={{2,2},{3,1},{4,2}}},["Í"]={base="I",mark={{4,1},{3,2}}},
    ["Ó"]={base="O",mark={{4,1},{3,2}}},["Ô"]={base="O",mark={{2,2},{3,1},{4,2}}},["Õ"]={base="O",mark={{2,1},{3,2},{4,1}}},
    ["Ú"]={base="U",mark={{4,1},{3,2}}},["Ç"]={base="C",cedilla={{4,10},{3,11}}}
  }
  local CHARS={"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z",
    "0","1","2","3","4","5","6","7","8","9","s"," ","/",",",":",".","-","%","Á","À","Â","Ã","É","Ê","Í","Ó","Ô","Õ","Ú","Ç"}
  local function bitmap(ch)
    local d=accent[ch]; local base=d and d.base or ch; assert(rows[base],"missing glyph "..ch)
    local g={}; for y=1,11 do g[y]={false,false,false,false,false} end
    for y=1,7 do for x=1,5 do g[y+2][x]=rows[base][y]:sub(x,x)=="1" end end
    if d and d.mark then for _,p in ipairs(d.mark) do g[p[2]][p[1]]=true end end
    if d and d.cedilla then for _,p in ipairs(d.cedilla) do g[p[2]][p[1]]=true end end
    local out={}; for y=1,11 do local s=""; for x=1,5 do s=s..(g[y][x] and "1" or "0") end; out[y]=s end
    return out
  end
  local glyph={}; for _,ch in ipairs(CHARS) do glyph[ch]=bitmap(ch) end
  local function chars(s)
    local a,i={},1
    while i<=#s do local b=s:byte(i); local n=(b<128 and 1) or (b<224 and 2) or (b<240 and 3) or 4; a[#a+1]=s:sub(i,i+n-1); i=i+n end
    return a
  end
  local function text(im,x,y,s,c)
    local cur=x
    for _,ch in ipairs(chars(s)) do
      local g=assert(glyph[ch],"unsupported text glyph "..ch)
      for yy=1,11 do for xx=1,5 do if g[yy]:sub(xx,xx)=="1" then px(im,cur+xx-1,y+yy-1,c) end end end
      cur=cur+6
    end
    return cur-x
  end
  local function codepoint(ch)
    local u={["Á"]=193,["À"]=192,["Â"]=194,["Ã"]=195,["É"]=201,["Ê"]=202,["Í"]=205,["Ó"]=211,["Ô"]=212,["Õ"]=213,["Ú"]=218,["Ç"]=199}
    return u[ch] or ch:byte(1)
  end
  local function outlineText(im,x,y,s,c)
    local sh=img(#chars(s)*6,12); text(sh,1,1,s,K.ink); paste(im,sh,x,y)
    local fg=img(#chars(s)*6,11); text(fg,0,0,s,c); paste(im,fg,x,y)
  end

  local function dashIcon(ready)
    local im=img(16,16)
    local hi=ready and K.cream or K.steelLight
    local body=ready and K.steel or K.steelDark
    local shade=ready and K.blue2 or K.iron
    local sole=ready and K.iron or K.ink
    -- Three staggered trails remain visibly behind a compact square boot.
    rect(im,0,3,4,1,shade); rect(im,1,6,4,1,body); rect(im,0,9,5,1,shade)
    -- The heel, squared ankle, toe, and sole keep a footwear silhouette at 16 px.
    rect(im,6,4,6,5,sole); rect(im,7,4,4,4,body); rect(im,9,7,5,3,sole)
    rect(im,10,8,4,1,body); rect(im,5,9,10,3,sole); rect(im,5,12,11,2,sole)
    rect(im,7,10,6,1,body); rect(im,6,13,8,1,shade)
    px(im,8,5,hi); px(im,10,5,hi); px(im,12,9,hi)
    return im
  end
  local function clock(i)
    local im=img(24,24); local cx,cy=11,11; local elapsed=1-i/16; local start=elapsed*360
    for y=0,23 do for x=0,23 do
      local dx,dy=x-cx,y-cy; local d=dx*dx+dy*dy
      if d<=100 and d>64 then px(im,x,y,K.ink)
      elseif d<=64 and d>49 then px(im,x,y,K.steelDark)
      elseif d<=49 then
        local a=math.deg(math.atan(dx,-dy)); if a<0 then a=a+360 end
        if elapsed<.999999 and a>=start then px(im,x,y,K.steel) else px(im,x,y,K.navy) end
      end
    end end
    rect(im,11,2,1,2,K.silver); rect(im,20,11,2,1,K.silver); rect(im,11,20,1,2,K.silver); rect(im,2,11,2,1,K.silver)
    local a=elapsed*math.pi*2-math.pi/2; local ex=math.floor(cx+math.cos(a)*6+.5); local ey=math.floor(cy+math.sin(a)*6+.5)
    line(im,11,11,ex,ey,K.silver,1); disk(im,11,11,1,K.cream)
    return im
  end
  local function dial()
    local im=img(37,20); local cx,cy=18,18
    for y=0,19 do for x=0,36 do
      local dx,dy=x-cx,y-cy; local d=math.sqrt(dx*dx+dy*dy)
      if d>=15 and d<=18 and dy<=0 then
        local a=math.deg(math.atan(dy,dx)); if a<0 then a=a+360 end
        if a>=180 and a<=360 then
          local col=(a<225 and K.cream) or (a<270 and K.steelLight) or (a<315 and K.copper) or K.amber
          px(im,x,y,col)
        end
      end
    end end
    rect(im,1,18,35,1,K.steelDark); px(im,0,18,K.ink); px(im,36,18,K.ink)
    for x=3,33,5 do px(im,x,16,K.silver) end
    disk(im,18,18,3,K.ink); disk(im,18,18,2,K.steelDark); px(im,18,18,K.silver)
    return im
  end
  local function needle(step)
    local im=img(37,20); local t=step/8; local a=math.pi-math.pi*t
    local ex=math.floor(18+math.cos(a)*14+.5); local ey=math.floor(18-math.sin(a)*14+.5)
    line(im,18,18,ex,ey,K.ink,3); line(im,18,18,ex,ey,K.copper,1); px(im,ex,ey,K.cream); disk(im,18,18,2,K.ink); px(im,18,18,K.silver)
    return im
  end
  local function concept()
    local im=img(74,15); rect(im,1,1,72,13,K.ink); rect(im,2,2,70,11,K.copper); rect(im,3,3,68,1,K.amber); rect(im,3,12,68,1,K.rustDark)
    text(im,13,2,"CONCEITO",K.ink); return im
  end

  local glyphCols=8; local cellW,cellH=9,15; local glyphRows=math.ceil(#CHARS/glyphCols)
  local fontAtlas=img(glyphCols*cellW,glyphRows*cellH); local glyphMeta={}
  local fontLayer={}
  for i,ch in ipairs(CHARS) do
    local x=((i-1)%glyphCols)*cellW+2; local y=math.floor((i-1)/glyphCols)*cellH+2
    local g=img(5,11)
    for yy=1,11 do for xx=1,5 do if glyph[ch][yy]:sub(xx,xx)=="1" then px(g,xx-1,yy-1,K.white) end end end
    paste(fontAtlas,g,x,y); fontLayer[#fontLayer+1]={name=string.format("glyph_%02d_U%04X",i,codepoint(ch)),image=g,x=x,y=y}
    glyphMeta[#glyphMeta+1]={ch=ch,cp=codepoint(ch),x=x,y=y}
  end
  save(fontAtlas,OUT.."/font-atlas.png")

  local comps={}
  local function add(id,file,im,more)
    local a={id=id,file=file,image=im,pivotX=0,pivotY=0}
    if more then for k,v in pairs(more) do a[k]=v end end
    comps[#comps+1]=a; save(im,OUT.."/"..file); return a
  end
  local panel9=panel(24,24); local pPanel=panel(144,40); local dPanel=panel(144,40); local tPanel=panel(144,40); local rPanel=panel(84,36); local gPanel=panel(84,60)
  local bf=barFrame(); local pfill=fill(90,K.amber,K.cream,K.copper); local tfill=fill(90,K.red,K.cream,K.redDark)
  local iconReady=dashIcon(true); local iconDisabled=dashIcon(false); local clocks={}; local needles={}
  for i=0,16 do clocks[i+1]=clock(i) end
  for i=0,8 do needles[i+1]=needle(i) end
  local gdial=dial(); local clabel=concept()
  local readyPreview=img(144,40); paste(readyPreview,dPanel,0,0); paste(readyPreview,iconReady,6,12); paste(readyPreview,clocks[1],24,8)
  text(readyPreview,50,8,"DASH",K.cream); text(readyPreview,50,20,"PRONTO",K.silver); save(scale(readyPreview,3),PRE.."/dash-ready-state-432x120.png")
  add("panel_9slice","panel-9slice-24.png",panel9,{pivotX=0,pivotY=0,margin=6,inner={x=6,y=6,w=12,h=12}})
  add("panel_player","panel-player-144x40.png",pPanel,{margin=6}); add("panel_dash","panel-dash-144x40.png",dPanel,{margin=6})
  add("panel_target","panel-target-144x40.png",tPanel,{margin=6}); add("panel_rooms","panel-rooms-84x36.png",rPanel,{margin=6}); add("panel_gauge","panel-gauge-84x60.png",gPanel,{margin=6})
  add("bar_frame","bar-frame-96x14.png",bf,{inner={x=3,y=3,w=90,h=8},margin=3})
  add("bar_fill_player","bar-fill-player-90x8.png",pfill); add("bar_fill_target","bar-fill-target-90x8.png",tfill)
  add("dash_icon_ready","dash-icon-ready-16.png",iconReady,{state="ready"}); add("dash_icon_disabled","dash-icon-disabled-16.png",iconDisabled,{state="cooldown"})
  for i=0,16 do add(string.format("clock_%02d",i),string.format("clock-step-%02d.png",i),clocks[i+1],{pivotX=11,pivotY=11,frame=i,state=(i==0 and "ready_empty" or i==16 and "cooldown_full" or "remaining_fraction"),remaining=i/16,elapsed=1-i/16}) end
  add("gauge_dial","gauge-dial-37x20.png",gdial,{pivotX=18,pivotY=18})
  for i=0,8 do add(string.format("gauge_needle_%02d",i),string.format("gauge-needle-%02d.png",i),needles[i+1],{pivotX=18,pivotY=18,frame=i,normalized=i/8,state="normalized_study"}) end
  add("concept_label","label-conceito-74x15.png",clabel,{state="study_only"})

  local playerPath=ROOT.."/assets/player/player-animations.png"
  local targetPath=ROOT.."/assets/enemy/training_target/training_target-atlas.png"
  local workerPath=ROOT.."/assets/enemy/rivet_worker/rivet_worker-atlas.png"
  local pa=Image{fromFile=playerPath}; local ta=Image{fromFile=targetPath}; local wa=Image{fromFile=workerPath}
  assert(pa.width>=64 and pa.height>=64 and ta.width>=64 and ta.height>=64 and wa.width>=64 and wa.height>=64,"unexpected portrait source dimensions")
  save(scale(crop(pa,0,0,64,64),8),PRE.."/source-player-frame0-8x.png")
  save(scale(crop(ta,0,0,64,64),8),PRE.."/source-training-target-frame0-8x.png")
  save(scale(crop(wa,0,0,64,64),8),PRE.."/source-rivet-worker-frame0-8x.png")
  local portraits={
    {id="player",file="portrait-player-24.png",source="assets/player/player-animations.png",crop={x=20,y=8,w=24,h=24},image=crop(pa,20,8,24,24)},
    {id="tranca_lata",file="portrait-tranca-lata-32x28.png",source="assets/enemy/training_target/training_target-atlas.png",crop={x=15,y=8,w=32,h=28},image=crop(ta,15,8,32,28)},
    {id="rivet_worker",file="portrait-rivet-worker-24.png",source="assets/enemy/rivet_worker/rivet_worker-atlas.png",crop={x=20,y=24,w=24,h=24},image=crop(wa,20,24,24,24)}
  }
  local function candidateSheet(src,xs,ys,path)
    local sh=img(#xs*60,#ys*64); rect(sh,0,0,sh.width,sh.height,K.navy)
    for ry,y in ipairs(ys) do for cx,x in ipairs(xs) do
      local c=crop(src,x,y,24,24); paste(sh,scale(c,2),(cx-1)*60,(ry-1)*64)
      text(sh,(cx-1)*60+2,(ry-1)*64+50,string.format("X%02dY%02d",x,y),K.cream)
    end end
    save(sh,path)
  end
  candidateSheet(pa,{8,12,16,20},{0,4,8,12},PRE.."/portrait-candidates-player.png")
  local function candidateSheet32(src,xs,ys,path) local sh=img(#xs*80,#ys*72); rect(sh,0,0,sh.width,sh.height,K.navy); for ry,y in ipairs(ys) do for cx,x in ipairs(xs) do local c=crop(src,x,y,32,28); paste(sh,scale(c,2),(cx-1)*80,(ry-1)*72); text(sh,(cx-1)*80+2,(ry-1)*72+58,string.format("X%02dY%02d",x,y),K.cream) end end; save(sh,path) end; candidateSheet32(ta,{12,15,18},{8,12,16},PRE.."/portrait-candidates-target-32x28.png")
  candidateSheet(wa,{8,12,16,20},{16,20,24,28},PRE.."/portrait-candidates-worker.png")
  for _,p in ipairs(portraits) do save(p.image,OUT.."/"..p.file) end
  local portraitReview=img(384,144); rect(portraitReview,0,0,384,144,K.navy)
  local portraitNames={"PLAYER","TRANCA-LATA","COSPE-REBITE"}
  for i,p in ipairs(portraits) do paste(portraitReview,scale(p.image,4),(i-1)*128,0); text(portraitReview,(i-1)*128,120,portraitNames[i],K.cream) end
  save(portraitReview,PRE.."/portraits-review-4x.png")

  local function pack(items,maxW)
    local x,y,row=2,2,0; local places={}
    for _,it in ipairs(items) do
      local im=it.image
      if x+im.width+2>maxW then y=y+row+4; x=2; row=0 end
      places[#places+1]={item=it,x=x,y=y,w=im.width,h=im.height}
      x=x+im.width+4; row=math.max(row,im.height)
    end
    local atlas=img(maxW,y+row+2)
    for _,p in ipairs(places) do paste(atlas,p.item.image,p.x,p.y) end
    return atlas,places
  end
  local catlas,cplaces=pack(comps,512); save(catlas,OUT.."/components-atlas.png")
  local patlas,pplaces=pack(portraits,96); save(patlas,OUT.."/portraits-atlas.png")

  local function saveLayered(path,w,h,items,pal)
    local spr=Sprite(w,h); while #spr.layers>1 do spr:deleteLayer(spr.layers[#spr.layers]) end
    for i,it in ipairs(items) do
      local layer=i==1 and spr.layers[1] or spr:newLayer(); layer.name=it.name; layer.opacity=255; layer.isVisible=it.visible~=false
      local full=img(w,h); paste(full,it.image,it.x or 0,it.y or 0); spr:newCel(layer,1).image=full
    end
    if pal then palette(spr) end
    assert(spr:saveAs(path),"could not save source: "..path)
  end
  local function saveTimeline(path,w,h,frames,layerName,tagName,pal)
    local spr=Sprite(w,h); while #spr.layers>1 do spr:deleteLayer(spr.layers[#spr.layers]) end
    local layer=spr.layers[1]; layer.name=layerName; layer.opacity=255; layer.isVisible=true
    for i,frameImage in ipairs(frames) do
      if i>1 then spr:newEmptyFrame(i) end
      local cel=spr:newCel(layer,i); cel.image=frameImage
    end
    local tag=spr:newTag(1,#frames); tag.name=tagName; tag.aniDir=AniDir.FORWARD
    tag.data="Study playback only; runtime selects normalized frame index; not cooldown timing."
    if pal then palette(spr) end
    assert(spr:saveAs(path),"could not save timeline source: "..path)
  end
  local function layersFromPlacements(places)
    local out={}; for _,p in ipairs(places) do out[#out+1]={name=p.item.id,image=p.item.image,x=p.x,y=p.y} end; return out
  end
  saveLayered(SRC.."/hud-components.aseprite",catlas.width,catlas.height,layersFromPlacements(cplaces),true)
  saveLayered(SRC.."/hud-portraits.aseprite",patlas.width,patlas.height,layersFromPlacements(pplaces),false)
  saveLayered(SRC.."/font-bitmap.aseprite",fontAtlas.width,fontAtlas.height,fontLayer,true)

  local clockItems,clockSheet={},img(144,72)
  for i=0,16 do local it={name=string.format("clock_%02d_remaining_%02d",i,math.floor(i/16*100+.5)),image=clocks[i+1],x=(i%6)*24,y=math.floor(i/6)*24}; clockItems[#clockItems+1]=it; paste(clockSheet,it.image,it.x,it.y) end
  save(clockSheet,OUT.."/clock-states-sheet.png"); saveTimeline(SRC.."/clock-states.aseprite",24,24,clocks,"clock_state","clock_remaining_normalized_study",true)
  local needleItems,needleSheet={},img(185,40)
  for i=0,8 do local it={name=string.format("needle_%02d_normalized_%02d",i,math.floor(i/8*100+.5)),image=needles[i+1],x=(i%5)*37,y=math.floor(i/5)*20}; needleItems[#needleItems+1]=it; paste(needleSheet,it.image,it.x,it.y) end
  save(needleSheet,OUT.."/gauge-needle-states-sheet.png"); saveTimeline(SRC.."/gauge-needle-states.aseprite",37,20,needles,"gauge_needle_state","gauge_needle_normalized_study",true)

  local A={
    player={x=8,y=8,w=144,h=40},dash={x=8,y=52,w=144,h=40},target={x=216,y=8,w=144,h=40},rooms={x=484,y=8,w=84,h=36},
    gauge={x=484,y=48,w=84,h=60},concept={x=489,y=110,w=74,h=15},playerPortrait={x=14,y=16,w=24,h=24},targetPortrait={x=222,y=14,w=32,h=28},
    playerBar={x=42,y=28,w=96,h=14},targetBar={x=258,y=28,w=96,h=14},dashIcon={x=14,y=64,w=16,h=16},clock={x=32,y=60,w=24,h=24},
    gaugeDial={x=507,y=81,w=37,h=20}
  }
  local function build(gaugeY,labelY,bg)
    local layers,over={},img(576,324)
    local function add(name,im,x,y,vis)
      layers[#layers+1]={name=name,image=im,x=x or 0,y=y or 0,visible=vis}
      if vis~=false and name:sub(1,8)~="Context " then paste(over,im,x or 0,y or 0) end
    end
    if bg then add("Context reference - seed-000 (study)",bg,0,0,true) end
    add("Player panel",pPanel,8,8); add("Player portrait - source crop",portraits[1].image,14,16); add("Player bar frame",bf,42,28); add("Player fill sample 3 of 5",crop(pfill,0,0,54,8),45,31)
    local pt=img(144,40); text(pt,34,7,"VIDA",K.cream); outlineText(pt,112,7,"3/5",K.ivory); add("Player text - editable sample",pt,8,8)
    add("Dash panel",dPanel,8,52); add("Dash icon",iconDisabled,14,64); add("Dash clock normalized sample",clocks[11],32,60)
    local dt=img(144,40); text(dt,50,8,"DASH 0,3s",K.cream); text(dt,50,20,"RECARREGANDO",K.silver); add("Dash text - editable sample",dt,8,52)
    add("Target panel - Tranca-Lata sample",tPanel,A.target.x,A.target.y); add("Target portrait - source crop",portraits[2].image,A.targetPortrait.x,A.targetPortrait.y); add("Target bar frame",bf,A.targetBar.x,A.targetBar.y); add("Target fill sample 4 of 6",crop(tfill,0,0,60,8),A.targetBar.x+3,A.targetBar.y+3)
    local tt=img(144,40); text(tt,42,7,"TRANCA-LATA",K.cream); outlineText(tt,120,7,"4/6",K.ivory); add("Target text - editable sample",tt,216,8)
    add("Rooms panel",rPanel,484,8); local rt=img(84,36); text(rt,9,6,"ANDAR 01",K.cream); text(rt,15,18,"SALA 02",K.cream); add("Rooms text - editable sample",rt,484,8)
    add("Gauge panel - study",gPanel,484,gaugeY); local gt=img(84,60); text(gt,6,6,"ACELERAÇÃO",K.cream); text(gt,21,18,"DA BOLA",K.cream); add("Gauge labels - editable study",gt,484,gaugeY)
    add("Gauge dial - no units",gdial,507,gaugeY+33); add("Gauge needle - normalized study step 04",needles[5],507,gaugeY+33); add("Concept label - study only",clabel,489,labelY)
    return layers,over
  end
  local contextPath=ROOT.."/assets/environment/factory_v1/background_floor1/modular/context-seed-000.png"
  local context2=Image{fromFile=contextPath}; assert(context2.width==1152 and context2.height==648,"context-seed-000 must be 1152x648")
  local context=img(576,324)
  for y=0,323 do for x=0,575 do context:drawPixel(x,y,context2:getPixel(x*2,y*2)) end end
  save(context,PRE.."/context-seed-000-576.png")
  local layers,overlay=build(48,110,context)
  save(overlay,OUT.."/hud-overlay-576.png"); save(scale(overlay,2),OUT.."/hud-overlay-1152.png"); save(scale(overlay,3),PRE.."/hud-overlay-1728.png")
  local comp=img(576,324); paste(comp,context,0,0); paste(comp,overlay,0,0); save(comp,PRE.."/hud-context-576.png")
  local comp2=img(1152,648); paste(comp2,context2,0,0); paste(comp2,scale(overlay,2),0,0); save(comp2,PRE.."/hud-context-1152.png"); save(scale(comp,3),PRE.."/hud-context-1728.png")
  saveLayered(SRC.."/hud-composition.aseprite",576,324,layers,true)
  local altLayers,altOverlay=build(256,238,context); save(altOverlay,PRE.."/hud-layout-alternative-overlay-576.png")
  local alt=img(576,324); paste(alt,context,0,0); paste(alt,altOverlay,0,0); save(scale(alt,3),PRE.."/hud-layout-alternative-context-1728.png")
  saveLayered(SRC.."/hud-composition-alternative.aseprite",576,324,altLayers,true)

  local compact=img(576,144); rect(compact,0,0,576,144,K.navy); rect(compact,0,0,576,18,K.blue); text(compact,8,3,"HUD CALDEIRA V1 - MODULOS",K.ivory)
  paste(compact,pPanel,8,20); paste(compact,portraits[1].image,14,28); paste(compact,bf,42,40); paste(compact,crop(pfill,0,0,54,8),45,43)
  local cpt=img(144,40); text(cpt,34,7,"VIDA",K.cream); outlineText(cpt,112,7,"3/5",K.ivory); paste(compact,cpt,8,20)
  paste(compact,tPanel,216,20); paste(compact,portraits[2].image,222,26); paste(compact,bf,258,40); paste(compact,crop(tfill,0,0,60,8),261,43)
  local ctt=img(144,40); text(ctt,42,7,"TRANCA-LATA",K.cream); outlineText(ctt,120,7,"4/6",K.ivory); paste(compact,ctt,216,20)
  paste(compact,rPanel,484,20); local crt=img(84,36); text(crt,9,6,"ANDAR 01",K.cream); text(crt,15,18,"SALA 02",K.cream); paste(compact,crt,484,20)
  paste(compact,dPanel,8,66); paste(compact,iconDisabled,14,78); paste(compact,clocks[11],32,74)
  local cdt=img(144,40); text(cdt,50,8,"DASH 0,3s",K.cream); text(cdt,50,20,"RECARREGANDO",K.silver); paste(compact,cdt,8,66)
  paste(compact,gPanel,484,66); local cgt=img(84,60); text(cgt,6,6,"ACELERAÇÃO",K.cream); text(cgt,21,18,"DA BOLA",K.cream); paste(compact,cgt,484,66)
  paste(compact,gdial,507,99); paste(compact,needles[5],507,99); paste(compact,clabel,489,128)
  save(compact,PRE.."/hud-modules-compact-native-576x144.png"); save(scale(compact,3),PRE.."/hud-modules-compact-1728x432.png")
  local contact=img(576,800); rect(contact,0,0,576,800,K.navy); rect(contact,0,0,576,20,K.blue); text(contact,8,4,"HUD CALDEIRA V1 - PEÇAS",K.ivory)
  text(contact,8,23,"PLAYER",K.cream); paste(contact,pPanel,8,36); text(contact,160,23,"DASH",K.cream); paste(contact,dPanel,160,36)
  text(contact,312,23,"ALVO",K.cream); paste(contact,tPanel,312,36); text(contact,464,23,"SALAS",K.cream); paste(contact,rPanel,464,36)
  text(contact,8,82,"9-SLICE",K.cream); paste(contact,panel9,8,96); text(contact,60,82,"BARRA",K.cream); paste(contact,bf,60,96); paste(contact,crop(pfill,0,0,54,8),63,99); paste(contact,crop(tfill,0,0,60,8),63,103)
  text(contact,160,82,"CLOCK 00-16",K.cream); paste(contact,clockSheet,160,96); text(contact,312,82,"DIAL / NEEDLES",K.cream); paste(contact,gdial,312,96); paste(contact,needleSheet,352,96)
  text(contact,8,188,"RETRATOS - ESCALA NATIVA",K.cream); paste(contact,portraits[1].image,8,204); paste(contact,portraits[2].image,96,204); paste(contact,portraits[3].image,184,204)
  text(contact,8,238,"PLAYER",K.silver); text(contact,96,238,"TRANCA-LATA",K.silver); text(contact,184,238,"COSPE-REBITE",K.silver)
  text(contact,304,188,"FONTE BITMAP 5X11",K.cream); paste(contact,fontAtlas,304,204)
  text(contact,420,188,"GAUGE",K.cream); paste(contact,gPanel,420,204)
  text(contact,8,330,"AMOSTRAS DE TEXTO / CORES DE PREVIEW",K.cream); text(contact,8,346,"VIDA 3/5",K.cream); text(contact,8,358,"RECARREGANDO 0,3s",K.silver); text(contact,8,370,"ACELERAÇÃO DA BOLA",K.amber)
  text(contact,8,400,"PALETA HUD - MÁSCARA DA FONTE BRANCA",K.cream)
  local sw=img(540,22); for i,c in ipairs(C) do rect(sw,(i-1)*28,0,24,16,c) end; paste(contact,sw,8,416)
  text(contact,8,460,"LAYOUT DE ESTUDO",K.cream); paste(contact,comp,8,476)
  save(contact,PRE.."/hud-elements-native-576x800.png"); save(scale(contact,3),PRE.."/hud-elements-1728x2400.png")

  local function rjson(x,y,w,h) return string.format('{"x":%d,"y":%d,"w":%d,"h":%d}',x or 0,y or 0,w or 0,h or 0) end
  local cr={}
  for _,p in ipairs(cplaces) do
    local a=p.item; local f={'"id":'..esc(a.id),'"file":'..esc("export/"..a.file),'"native_rect":'..rjson(0,0,a.image.width,a.image.height),'"atlas_rect":'..rjson(p.x,p.y,p.w,p.h),'"pivot":{"x":'..(a.pivotX or 0)..',"y":'..(a.pivotY or 0)..'}'}
    if a.margin then f[#f+1]='"margins":{"left":'..a.margin..',"top":'..a.margin..',"right":'..a.margin..',"bottom":'..a.margin..'}' end
    if a.inner then f[#f+1]='"inner_rect":'..rjson(a.inner.x,a.inner.y,a.inner.w,a.inner.h) end
    if a.state then f[#f+1]='"state":'..esc(a.state) end
    if a.frame~=nil then f[#f+1]='"frame":'..a.frame end
    if a.remaining~=nil then f[#f+1]=string.format('"remaining":%.4f,"elapsed":%.4f',a.remaining,a.elapsed) end
    if a.normalized~=nil then f[#f+1]=string.format('"normalized":%.4f',a.normalized) end
    cr[#cr+1]="{"..table.concat(f,",").."}"
  end
  jwrite(OUT.."/components.json",'{"atlas":"components-atlas.png","padding":2,"padding_per_side":2,"inter_region_gap":4,"outer_margin_min":2,"regions":['..table.concat(cr,",")..']}')
  local fr={}; for _,g in ipairs(glyphMeta) do fr[#fr+1]='{"character":'..esc(g.ch)..',"codepoint":'..g.cp..',"rect":'..rjson(g.x,g.y,5,11)..',"advance":6}' end
  jwrite(OUT.."/font.json",'{"atlas":"font-atlas.png","cell":{"w":5,"h":11},"body_rows":{"first":2,"last":8},"accent_rows":{"first":0,"last":1},"cedilla_rows":{"first":9,"last":10},"baseline_from_top_zero_based":8,"advance":6,"line_height":12,"glyphs":['..table.concat(fr,",")..']}')
  local pr={}
  for i,p in ipairs(portraits) do
    local a=pplaces[i]; local w,h=p.image.width,p.image.height
    pr[#pr+1]='{"id":'..esc(p.id)..',"file":'..esc("export/"..p.file)..',"source":'..esc(p.source)..',"frame":0,"crop":'..rjson(p.crop.x,p.crop.y,p.crop.w,p.crop.h)..',"native_rect":{"x":0,"y":0,"w":'..w..',"h":'..h..'},"atlas_rect":'..rjson(a.x,a.y,w,h)..',"pivot":{"x":'..math.floor(w/2)..',"y":'..math.floor(h/2)..'},"resampled":false,"recolored":false}'
  end
  jwrite(OUT.."/portraits.json",'{"atlas":"portraits-atlas.png","padding":2,"padding_per_side":2,"inter_region_gap":4,"outer_margin_min":2,"portraits":['..table.concat(pr,",")..']}')
  local layout='{"native_canvas":{"w":576,"h":324},"logical_application":{"w":1152,"h":648,"scale":2},"default_layout":{'
    .. '"player":{"rect":'..rjson(8,8,144,40)..',"anchor":"top_left"},'
    .. '"dash":{"rect":'..rjson(8,52,144,40)..',"anchor":"top_left"},'
    .. '"target":{"rect":'..rjson(216,8,144,40)..',"anchor":"top_left"},'
    .. '"rooms":{"rect":'..rjson(484,8,84,36)..',"anchor":"top_right"},'
    .. '"gauge":{"rect":'..rjson(484,48,84,60)..',"anchor":"top_right"},'
    .. '"concept_label":{"rect":'..rjson(489,110,74,15)..',"study_only":true},'
    .. '"player_portrait":'..rjson(14,16,24,24)..',"target_portrait":'..rjson(222,14,32,28)..','
    .. '"player_bar_frame":'..rjson(42,28,96,14)..',"target_bar_frame":'..rjson(258,28,96,14)..','
    .. '"player_fill_sample":{"rect":'..rjson(45,31,54,8)..',"fraction":0.6,"rounding":"floor(clamp(current/max,0,1)*90+0.5)"},'
    .. '"target_fill_sample":{"rect":'..rjson(261,31,60,8)..',"fraction":0.6666667,"rounding":"floor(clamp(current/max,0,1)*90+0.5)"},'
    .. '"dash_icon":'..rjson(14,64,16,16)..',"dash_clock":'..rjson(32,60,24,24)..','
    .. '"clock_mapping":{"frames":17,"ready_index":0,"cooldown_full_index":16,"frame_rule":"floor(clamp(remaining,0,1)*16+0.5)"},'
    .. '"gauge_dial":'..rjson(507,81,37,20)..',"gauge_needle_pivot":{"x":525,"y":99},'
    .. '"text_rects":{"player_title":{"rect":'..rjson(42,15,24,11)..'},"player_value":{"rect":'..rjson(42,15,96,11)..',"align":"right","sample":"3/5","max_sample_width":42},'
    .. '"target_name":{"rect":'..rjson(258,15,72,11)..',"sample":"TRANCA-LATA","truncate":{"normal_max_glyphs":12,"with_max_value_glyphs":9,"normal_width_px":72,"with_max_value_width_px":54}},"target_value":{"rect":'..rjson(312,15,42,11)..',"align":"right","sample":"4/6","max_sample_width":42},'
    .. '"dash_time":{"rect":'..rjson(58,60,78,11)..',"sample":"DASH 0,3s"},"dash_status":{"rect":'..rjson(58,72,78,11)..',"sample":"RECARREGANDO"},'
    .. '"rooms_first_line":'..rjson(493,14,48,11)..',"rooms_second_line":'..rjson(499,26,42,11)..'},'
    .. '"alternative_layout":{"gauge":{"rect":'..rjson(484,256,84,60)..',"anchor":"bottom_right"},"concept_label":{"rect":'..rjson(489,238,74,15)..',"study_only":true}},'
    .. '"notes":["Editable sample values do not define HP rules or limits.","Player/worker portraits use native 24x24 crops; the target Tranca-Lata portrait uses native crop (15,8,32,28) to preserve the CRT face and cap. No resampling or recoloring.","Current/max values up to 999/999 require 42 px at advance 6; player value right-aligns in its 96 px field. Target value is right-aligned in a 42 px field; with a 42 px value the name uses a 54 px field (9 glyphs), while shorter values may expose up to 72 px (12 glyphs).","RECARREGANDO uses 12 glyphs (72 px advance; 71 px ink); its 78 px text field leaves 6 px of horizontal slack. Icon/clock gaps are 2 px, giving 122 px total inside the 132 px panel inset.","Clock states are normalized only; no duration is embedded. Gauge has nine normalized study poses, no unit, formula, maximum, or gameplay timing.","The native 576x324 composition maps 2x to 1152x648; final 1920x1080 filtering remains an integration decision."]}'
  jwrite(OUT.."/layout.json",layout)
  local paletteRows={}; for _,h in ipairs(HEX) do paletteRows[#paletteRows+1]=esc("#"..h) end
  jwrite(OUT.."/palette.json",'{"name":"hud_caldeira_v1_local","colors":['..table.concat(paletteRows,",")..'],"alpha":[0,255],"font_mask":"#FFFFFF","note":"Local locked HUD palette; not final GDD palette."}')
  local version=tostring(app.version or "unknown")
  jwrite(OUT.."/manifest.json",'{"kit":"hud_caldeira_v1","aseprite_version":'..esc(version)..',"native_canvas":{"w":576,"h":324},"logical_canvas":{"w":1152,"h":648,"scale":2},"source_context":"assets/environment/factory_v1/background_floor1/modular/context-seed-000.png","component_atlas":"export/components-atlas.png","component_metadata":"export/components.json","font_atlas":"export/font-atlas.png","font_metrics":"export/font.json","portraits_atlas":"export/portraits-atlas.png","portrait_metadata":"export/portraits.json","layout":"export/layout.json","authoring_sources":["source/generate_hud.lua","source/hud-components.aseprite","source/hud-composition.aseprite","source/hud-composition-alternative.aseprite","source/hud-portraits.aseprite","source/font-bitmap.aseprite","source/clock-states.aseprite","source/gauge-needle-states.aseprite"],"timeline_sources":{"clock":{"file":"source/clock-states.aseprite","canvas":{"w":24,"h":24},"frames":17,"tag":"clock_remaining_normalized_study","playback":"study-only; runtime selects normalized frame index; not cooldown timing"},"gauge_needle":{"file":"source/gauge-needle-states.aseprite","canvas":{"w":37,"h":20},"frames":9,"tag":"gauge_needle_normalized_study","playback":"study-only; runtime selects normalized pose index"}},"previews":["preview/hud-elements-1728x2400.png","preview/hud-modules-compact-1728x432.png","preview/dash-ready-state-432x120.png","preview/portraits-review-4x.png","preview/source-player-frame0-8x.png","preview/source-training-target-frame0-8x.png","preview/source-rivet-worker-frame0-8x.png","preview/hud-context-576.png","preview/hud-context-1152.png","preview/hud-context-1728.png","preview/hud-layout-alternative-context-1728.png"],"retained_exploratory_not_delivery":["export/portrait-tranca-lata-24.png","preview/portrait-candidates-target.png","preview/hud-elements-1728x1728.png","preview/hud-elements-native-576x576.png"],"limits":["Study only; not runtime or Godot integration.","HP samples do not define units or maximums.","Clock states are normalized; no seconds or cooldown duration is embedded.","Acceleration dial and CONCEITO are illustrative only.","No automated audit or engine import was run."]}')
  local runlog=assert(io.open(SRC.."/aseprite-production.log","wb"))
  runlog:write("HUD_GENERATION_OK\nASEPRITE_VERSION="..version.."\nCOMPONENT_ATLAS="..catlas.width.."x"..catlas.height.."\n")
  runlog:write("FONT_GLYPHS="..#CHARS.." FONT_ATLAS="..fontAtlas.width.."x"..fontAtlas.height.."\nCLOCK_STATES=17; GAUGE_NEEDLE_STATES=9; PORTRAITS=3\nCLOCK_TIMELINE=24x24 FRAMES=17 TAG=clock_remaining_normalized_study\nGAUGE_TIMELINE=37x20 FRAMES=9 TAG=gauge_needle_normalized_study\nCONCEPT_LABEL=74x15\nOUTPUT_ROOT="..KIT.."\n")
  runlog:close()
  print("HUD_GENERATION_OK"); print("ASEPRITE_VERSION="..version); print("COMPONENT_ATLAS="..catlas.width.."x"..catlas.height)
  print("FONT_GLYPHS="..#CHARS.." FONT_ATLAS="..fontAtlas.width.."x"..fontAtlas.height)
  print("CLOCK_STATES=17; GAUGE_NEEDLE_STATES=9; PORTRAITS=3"); print("CLOCK_TIMELINE=24x24 FRAMES=17 TAG=clock_remaining_normalized_study"); print("GAUGE_TIMELINE=37x20 FRAMES=9 TAG=gauge_needle_normalized_study"); print("CONCEPT_LABEL=74x15"); print("OUTPUT_ROOT="..KIT)
end
local ok,err=xpcall(main,debug.traceback)
if not ok then
  print("HUD_GENERATION_ERROR: "..tostring(err))
  local root=(app.params or {}).root
  if root then local f=io.open(root.."/assets/ui/hud_caldeira_v1/source/aseprite-production-error.log","wb"); if f then f:write(tostring(err)); f:close() end end
  error(err)
end

















