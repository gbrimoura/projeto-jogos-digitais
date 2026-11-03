local function main()
  local P=app.params or {}
  local ROOT=assert(P.root,"missing root parameter")
  local KIT=ROOT.."/assets/ui/upgrade_cards_v1"
  local SRC=KIT.."/source"
  local OUT=KIT.."/export"
  local BASE=ROOT.."/assets/ui/hud_caldeira_v1/export"
  local pc=app.pixelColor
  local function read(path)
    local f=assert(io.open(path,"rb"),"cannot read "..path)
    local s=f:read("*a"); f:close(); return s
  end
  local function write(path,s)
    local f=assert(io.open(path,"wb"),"cannot write "..path)
    f:write(s); f:close()
  end
  local function img(w,h) return Image(w,h) end
  local function px(im,x,y,c)
    assert(x>=0 and y>=0 and x<im.width and y<im.height,"pixel out of range")
    im:drawPixel(x,y,c)
  end
  local function rect(im,x,y,w,h,c)
    for yy=y,y+h-1 do for xx=x,x+w-1 do px(im,xx,yy,c) end end
  end

  local baseJson=read(BASE.."/font.json")
  assert(baseJson:find('"cell":{"w":5,"h":11}',1,true),"source font cell changed")
  assert(baseJson:find('"advance":6',1,true),"source font advance changed")
  assert(baseJson:find('"line_height":12',1,true),"source line height changed")
  assert(baseJson:find('"baseline_from_top_zero_based":8',1,true),"source baseline changed")
  local source=Image{fromFile=BASE.."/font-atlas.png"}
  assert(source.width==72 and source.height==105,"source atlas dimensions changed")

  local paletteJson=read(BASE.."/palette.json")
  assert(paletteJson:find('"alpha":[0,255]',1,true),"palette alpha constraint changed")
  local colorsRaw=assert(paletteJson:match('"colors":%[([^%]]+)%]'),"palette colors missing")
  local paletteColors={}
  for h in colorsRaw:gmatch("#([0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f])") do
    paletteColors[#paletteColors+1]=Color(tonumber(h:sub(1,2),16),tonumber(h:sub(3,4),16),tonumber(h:sub(5,6),16),255)
  end
  local white=assert(paletteColors[19],"palette white missing")
  local mask=pc.rgba(255,255,255,255)
  local W,H=84,105

  local plusRows={"00000","00000","00100","00100","11111","00100","00100","00000","00000","00000","00000"}
  local greaterRows={"00000","00000","10000","01000","00100","01000","10000","00000","00000","00000","00000"}
  local baseLayer=img(W,H)
  baseLayer:drawImage(source,0,0)
  local plusLayer=img(W,H)
  local greaterLayer=img(W,H)
  local function drawGlyph(dst,x,y,rows)
    assert(#rows==11,"glyph height must be 11")
    for yy,row in ipairs(rows) do
      assert(#row==5,"glyph width must be 5")
      for xx=1,5 do if row:sub(xx,xx)=="1" then px(dst,x+xx-1,y+yy-1,mask) end end
    end
  end
  drawGlyph(plusLayer,72,2,plusRows)
  drawGlyph(greaterLayer,78,2,greaterRows)
  local composite=img(W,H)
  composite:drawImage(baseLayer,0,0)
  composite:drawImage(plusLayer,0,0)
  composite:drawImage(greaterLayer,0,0)
  assert(composite:saveAs(OUT.."/card-font-atlas.png"),"font atlas export failed")

  local spr=Sprite(W,H)
  while #spr.layers>1 do spr:deleteLayer(spr.layers[#spr.layers]) end
  local layers={
    {name="Base HUD bitmap atlas - unchanged",image=baseLayer},
    {name="Added glyph plus",image=plusLayer},
    {name="Added glyph greater-than",image=greaterLayer}
  }
  for i,e in ipairs(layers) do
    local layer=i==1 and spr.layers[1] or spr:newLayer()
    layer.name=e.name; layer.opacity=255; layer.isVisible=true
    local full=img(W,H); full:drawImage(e.image,0,0); spr:newCel(layer,1).image=full
  end
  local palette=Palette(#paletteColors)
  for i,c in ipairs(paletteColors) do palette:setColor(i-1,c) end
  spr:setPalette(palette)
  assert(spr:saveAs(SRC.."/card-font.aseprite"),"font source save failed")

  local additions=[[
{
  "source_font_paths": {
    "bundle": "assets/ui/hud_caldeira_v1/export/font.json",
    "atlas": "assets/ui/hud_caldeira_v1/export/font-atlas.png",
    "palette": "assets/ui/hud_caldeira_v1/export/palette.json"
  },
  "base_canvas": {"w": 72, "h": 105},
  "replacement_atlas": "assets/ui/upgrade_cards_v1/export/card-font-atlas.png",
  "canvas": {"w": 84, "h": 105},
  "font_metrics": {
    "cell": {"w": 5, "h": 11},
    "advance": 6,
    "line_height": 12,
    "baseline_from_top_zero_based": 8,
    "mask": "#FFFFFF",
    "alpha": [0, 255]
  },
  "glyphs": [
    {"character": "+", "codepoint": 43, "rect": {"x": 72, "y": 2, "w": 5, "h": 11}, "advance": 6},
    {"character": ">", "codepoint": 62, "rect": {"x": 78, "y": 2, "w": 5, "h": 11}, "advance": 6}
  ],
  "integration": "Load the existing font.json bundle; replace its atlas path with card-font-atlas.png; append these glyph records while retaining all base glyphs/metrics; then call configure_font(bundle) on HudBitmapText."
}
]]
  write(OUT.."/card-font-additions.json",additions)

  local geomPath=KIT.."/integration_geometry.json"
  local geom=read(geomPath)
  local fontField=[["font":{"base_bundle":"assets/ui/hud_caldeira_v1/export/font.json","base_atlas":"assets/ui/hud_caldeira_v1/export/font-atlas.png","replacement_atlas":"assets/ui/upgrade_cards_v1/export/card-font-atlas.png","additions":"assets/ui/upgrade_cards_v1/export/card-font-additions.json","metrics":{"cell":{"w":5,"h":11},"advance":6,"line_height":12,"baseline_from_top_zero_based":8,"canvas":{"w":84,"h":105}},"integration":"Load the base font bundle, replace its atlas path, append additions.glyphs and call configure_font(bundle) on HudBitmapText."},
  "preview":]]
  assert(geom:find('"preview":',1,true),"preview geometry field missing")
  geom=geom:gsub('"preview":',fontField,1)
  write(geomPath,geom)

  local readmePath=KIT.."/README.md"
  local readme=read(readmePath)
  local old="HUD bitmap font 5x11 atlas and metrics without changing the HUD kit."
  local new="card font bundle reuses the HUD 5x11 bitmap atlas and adds only the + and > glyphs."
  if readme:find(old,1,true) then readme=readme:gsub(old,new,1) end
  if not readme:find("## Card bitmap font bundle",1,true) then
    readme=readme..[[
## Card bitmap font bundle

Keep the HUD's original font.json and font-atlas.png unchanged. Load the original
font bundle, replace its atlas path with assets/ui/upgrade_cards_v1/export/card-font-atlas.png,
append glyph records from assets/ui/upgrade_cards_v1/export/card-font-additions.json,
and call configure_font(bundle) on the existing HudBitmapText component. Base
glyph coordinates and font metrics remain unchanged; only + and > are appended.
]]
  end
  write(readmePath,readme)

  local manifestPath=OUT.."/manifest.json"
  local manifest=read(manifestPath)
  if not manifest:find('"card_font"',1,true) then
    local field=',"card_font":{"base_bundle":"assets/ui/hud_caldeira_v1/export/font.json","replacement_atlas":"card-font-atlas.png","additions":"card-font-additions.json","canvas":{"w":84,"h":105},"glyphs":["+@",">"]}'
    -- Keep the public glyph names and codepoints explicit in the companion metadata.
    field=',"card_font":{"base_bundle":"assets/ui/hud_caldeira_v1/export/font.json","replacement_atlas":"card-font-atlas.png","additions":"card-font-additions.json","canvas":{"w":84,"h":105},"glyphs":[{"character":"+","codepoint":43},{"character":">","codepoint":62}]}'
    assert(manifest:find(',"notes":',1,true),"manifest insertion point missing")
    manifest=manifest:gsub(',"notes":',field..',"notes":',1)
    write(manifestPath,manifest)
  end

  local log=assert(io.open(SRC.."/card-font-production.log","wb"))
  log:write("CARD_FONT_GENERATION_OK\nASEPRITE_VERSION="..tostring(app.version or "unknown").."\nBASE_ATLAS=72x105\nREPLACEMENT_ATLAS=84x105\nGLYPHS=+ (43) @72,2; > (62) @78,2\nCELL=5x11 ADVANCE=6 LINE_HEIGHT=12\n")
  log:close()
  print("CARD_FONT_GENERATION_OK")
  print("ASEPRITE_VERSION="..tostring(app.version or "unknown"))
  print("CARD_FONT_ATLAS=84x105")
end

local ok,err=xpcall(main,debug.traceback)
if not ok then print("CARD_FONT_GENERATION_ERROR: "..tostring(err)); error(err) end
