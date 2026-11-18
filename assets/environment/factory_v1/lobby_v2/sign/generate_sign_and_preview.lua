-- Rebuild the lobby's 94x30 art-deco elevator plaque and a static lobby preview.
-- Run with the real Aseprite binary in batch mode from any working directory.

local pc = app.pixelColor
local script_file = debug.getinfo(1, "S").source:gsub("^@", ""):gsub("\\", "/")
local script_dir = script_file:match("^(.*)/[^/]+$") or "."
local root = script_dir .. "/../../../../.."
local sign_dir = script_dir

local function rgb(hex)
	local r = tonumber(hex:sub(2, 3), 16)
	local g = tonumber(hex:sub(4, 5), 16)
	local b = tonumber(hex:sub(6, 7), 16)
	return pc.rgba(r, g, b, 255)
end

-- Short palette: lobby ink/amber, background steel, and existing brass door tones.
local INK = rgb("#0C1B29")
local ENAMEL_EDGE = rgb("#2D4D5B")
local OUTER_SHADOW = rgb("#70432C")
local BRONZE = rgb("#925A36")
local BRASS = rgb("#B78342")
local AMBER = rgb("#D2A75C")
local LIGHT_BRASS = rgb("#90816A")
local TRANSPARENT = pc.rgba(0, 0, 0, 0)

local function blank(w, h)
	local image = Image(w, h)
	for y = 0, h - 1 do
		for x = 0, w - 1 do
			image:drawPixel(x, y, TRANSPARENT)
		end
	end
	return image
end

local function fill_rect(image, x, y, w, h, color)
	for py = y, y + h - 1 do
		if py >= 0 and py < image.height then
			for px = x, x + w - 1 do
				if px >= 0 and px < image.width then
					image:drawPixel(px, py, color)
				end
			end
		end
	end
end

local sign_w, sign_h = 94, 30
local outer_left = { 8, 5, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 5, 8 }
local outer_right = { 85, 88, 91, 92, 92, 92, 92, 92, 92, 92, 92, 92, 92, 92, 92, 92, 92, 92, 92, 92, 92, 92, 92, 92, 92, 92, 92, 91, 88, 85 }

local function fill_chamfered(image, inset, color)
	for y = inset, sign_h - inset - 1 do
		local first = outer_left[y + 1] + inset
		local last = outer_right[y + 1] - inset
		fill_rect(image, first, y, last - first + 1, 1, color)
	end
end

local chassis = blank(sign_w, sign_h)
fill_chamfered(chassis, 0, OUTER_SHADOW)
fill_chamfered(chassis, 1, BRONZE)
fill_chamfered(chassis, 2, BRASS)

-- Thin bevels catch the warm light already present on the elevator frame.
fill_rect(chassis, 9, 2, 33, 1, LIGHT_BRASS)
fill_rect(chassis, 52, 2, 33, 1, LIGHT_BRASS)
fill_rect(chassis, 5, 3, 2, 1, AMBER)
fill_rect(chassis, 87, 3, 2, 1, AMBER)
fill_rect(chassis, 9, 27, 76, 1, OUTER_SHADOW)

local enamel = blank(sign_w, sign_h)
fill_chamfered(enamel, 4, INK)
fill_rect(enamel, 15, 5, 64, 1, ENAMEL_EDGE)
fill_rect(enamel, 15, 24, 64, 1, OUTER_SHADOW)
fill_rect(enamel, 10, 8, 1, 14, ENAMEL_EDGE)
fill_rect(enamel, 83, 8, 1, 14, ENAMEL_EDGE)

-- Keep the stepped rails and rivets on top of the enamel with clear contrast.
for y = 8, 21 do
	if y % 3 ~= 0 then
		fill_rect(enamel, 4, y, 2, 1, BRASS)
		fill_rect(enamel, 88, y, 2, 1, BRASS)
	end
end
for _, point in ipairs({ { 8, 7 }, { 84, 7 }, { 8, 22 }, { 84, 22 } }) do
	fill_rect(enamel, point[1], point[2], 2, 2, AMBER)
	fill_rect(enamel, point[1], point[2], 1, 1, LIGHT_BRASS)
end

local glyph = {
	E = { "111", "100", "110", "100", "111" },
	L = { "100", "100", "100", "100", "111" },
	V = { "101", "101", "101", "101", "010" },
	A = { "010", "101", "111", "101", "101" },
	D = { "110", "101", "101", "101", "110" },
	O = { "010", "101", "101", "101", "010" },
	R = { "110", "101", "110", "101", "101" },
	N = { "101", "111", "111", "101", "101" },
	["0"] = { "111", "101", "101", "101", "111" },
	["1"] = { "010", "110", "010", "010", "111" },
}

local function text_width(text, scale)
	local units = 0
	for i = 1, #text do
		units = units + (text:sub(i, i) == " " and 2 or 3)
		if i < #text then units = units + 1 end
	end
	return units * scale
end

local function stamp_text(image, text, x, y, scale, color)
	local cursor = x
	for i = 1, #text do
		local ch = text:sub(i, i)
		local pattern = glyph[ch]
		if pattern then
			for gy = 1, 5 do
				for gx = 1, 3 do
					if pattern[gy]:sub(gx, gx) == "1" then
						fill_rect(image, cursor + (gx - 1) * scale, y + (gy - 1) * scale, scale, scale, color)
					end
				end
			end
		end
		cursor = cursor + (ch == " " and 2 or 3) * scale
		if i < #text then cursor = cursor + scale end
	end
end

local lettering = blank(sign_w, sign_h)
local top_line = "ELEVADOR"
local bottom_line = "ANDAR 01"
local top_x = math.floor((sign_w - text_width(top_line, 2)) / 2)
local bottom_x = math.floor((sign_w - text_width(bottom_line, 1)) / 2)

-- The one-pixel lower/right impression and warm face read as stamped lettering.
stamp_text(lettering, top_line, top_x + 1, 7, 2, OUTER_SHADOW)
stamp_text(lettering, bottom_line, bottom_x + 1, 19, 1, OUTER_SHADOW)
stamp_text(lettering, top_line, top_x, 6, 2, AMBER)
stamp_text(lettering, bottom_line, bottom_x, 18, 1, AMBER)

local sprite = Sprite(sign_w, sign_h)
local palette = Palette(7)
palette:setColor(0, Color{ r = 12, g = 27, b = 41 })
palette:setColor(1, Color{ r = 45, g = 77, b = 91 })
palette:setColor(2, Color{ r = 112, g = 67, b = 44 })
palette:setColor(3, Color{ r = 146, g = 90, b = 54 })
palette:setColor(4, Color{ r = 183, g = 131, b = 66 })
palette:setColor(5, Color{ r = 210, g = 167, b = 92 })
palette:setColor(6, Color{ r = 144, g = 129, b = 106 })
sprite:setPalette(palette)

local base_layer = sprite.layers[1]
base_layer.name = "Brass chassis"
sprite:newCel(base_layer, 1).image = chassis
local enamel_layer = sprite:newLayer()
enamel_layer.name = "Dark enamel"
sprite:newCel(enamel_layer, 1).image = enamel
local lettering_layer = sprite:newLayer()
lettering_layer.name = "Stamped lettering"
sprite:newCel(lettering_layer, 1).image = lettering

local aseprite_path = sign_dir .. "/elevator-plaque-94x30.aseprite"
local png_path = sign_dir .. "/elevator-plaque-94x30.png"
sprite:saveAs(aseprite_path)
sprite:saveCopyAs(png_path)

local function clamp(value, low, high)
	return math.max(low, math.min(high, value))
end

local function smoothstep(edge0, edge1, value)
	local t = clamp((value - edge0) / (edge1 - edge0), 0, 1)
	return t * t * (3 - 2 * t)
end

-- This mirrors lobby_player_grade.gdshader in sRGB channel space for the preview.
local function grade_player_pixel(pixel)
	local r = pc.rgbaR(pixel) / 255
	local g = pc.rgbaG(pixel) / 255
	local b = pc.rgbaB(pixel) / 255
	local source_r, source_g, source_b = r, g, b
	local alpha = pc.rgbaA(pixel)
	local luma = 0.2126 * r + 0.7152 * g + 0.0722 * b
	local chroma = math.max(r, g, b) - math.min(r, g, b)

	local ivory_amount = smoothstep(0.62, 0.84, luma) * (1 - smoothstep(0.07, 0.19, chroma)) * 0.72
	local ivory_r = math.min(luma * 1.04, 1)
	local ivory_g = luma * 0.99
	local ivory_b = luma * 0.90
	r = r * (1 - ivory_amount) + ivory_r * ivory_amount
	g = g * (1 - ivory_amount) + ivory_g * ivory_amount
	b = b * (1 - ivory_amount) + ivory_b * ivory_amount

	local blue_amount = smoothstep(0.12, 0.24, source_b - source_g * 1.05) * smoothstep(0.14, 0.30, luma) * (1 - smoothstep(0.65, 0.80, luma)) * 0.82
	local steel_r = luma * 0.84
	local steel_g = luma * 1.08
	local steel_b = math.min(luma * 1.28, 1)
	r = r * (1 - blue_amount) + steel_r * blue_amount
	g = g * (1 - blue_amount) + steel_g * blue_amount
	b = b * (1 - blue_amount) + steel_b * blue_amount

	local yellow_amount = smoothstep(0.08, 0.22, source_r - source_g) * smoothstep(0.18, 0.42, source_g - source_b) * smoothstep(0.28, 0.48, luma) * 0.92
	local brass_r = math.min(luma * 1.07, 1)
	local brass_g = luma * 0.85
	local brass_b = luma * 0.47
	r = r * (1 - yellow_amount) + brass_r * yellow_amount
	g = g * (1 - yellow_amount) + brass_g * yellow_amount
	b = b * (1 - yellow_amount) + brass_b * yellow_amount

	local ink_amount = (1 - smoothstep(0.05, 0.18, luma)) * 0.24
	local ink_r = luma * 1.24 + 0.010
	local ink_g = luma * 1.14 + 0.007
	local ink_b = luma * 0.96 + 0.004
	r = r * (1 - ink_amount) + ink_r * ink_amount
	g = g * (1 - ink_amount) + ink_g * ink_amount
	b = b * (1 - ink_amount) + ink_b * ink_amount

	return pc.rgba(math.floor(clamp(r, 0, 1) * 255 + 0.5), math.floor(clamp(g, 0, 1) * 255 + 0.5), math.floor(clamp(b, 0, 1) * 255 + 0.5), alpha)
end

local function load_image(path)
	return Image{ fromFile = path }
end

local function resize_bilinear(source, width, height)
	local result = Image(width, height)
	for y = 0, height - 1 do
		local fy = (y + 0.5) * source.height / height - 0.5
		local y0 = math.floor(fy)
		local ty = fy - y0
		local y1 = y0 + 1
		y0 = clamp(y0, 0, source.height - 1)
		y1 = clamp(y1, 0, source.height - 1)
		for x = 0, width - 1 do
			local fx = (x + 0.5) * source.width / width - 0.5
			local x0 = math.floor(fx)
			local tx = fx - x0
			local x1 = x0 + 1
			x0 = clamp(x0, 0, source.width - 1)
			x1 = clamp(x1, 0, source.width - 1)
			local c00 = source:getPixel(x0, y0)
			local c10 = source:getPixel(x1, y0)
			local c01 = source:getPixel(x0, y1)
			local c11 = source:getPixel(x1, y1)
			local function channel(getter)
				local top = getter(c00) * (1 - tx) + getter(c10) * tx
				local bottom = getter(c01) * (1 - tx) + getter(c11) * tx
				return math.floor(top * (1 - ty) + bottom * ty + 0.5)
			end
			result:drawPixel(x, y, pc.rgba(channel(pc.rgbaR), channel(pc.rgbaG), channel(pc.rgbaB), 255))
		end
	end
	return result
end

local function resize_nearest(source, width, height)
	local result = Image(width, height)
	for y = 0, height - 1 do
		local sy = math.floor(y * source.height / height)
		for x = 0, width - 1 do
			result:drawPixel(x, y, source:getPixel(math.floor(x * source.width / width), sy))
		end
	end
	return result
end

local function add_lobby_lights(image)
	local lamp_centers = { 921, 959, 997 }
	for _, center_x in ipairs(lamp_centers) do
		fill_rect(image, center_x - 5, 411, 10, 10, INK)
		fill_rect(image, center_x - 3, 413, 6, 6, rgb("#4B555D"))
	end
end

local bg_path = root .. "/assets/environment/factory_v1/lobby_v2/factory-lobby-generated-1672x941.png"
local atlas_path = root .. "/assets/player/player-animations.png"
local source_bg = load_image(bg_path)
local bg_h = math.floor(source_bg.height * 560 / 808 + 0.5)
local lobby_bg = resize_bilinear(source_bg, 1152, bg_h)
local preview = Image(1152, 648)
preview:drawImage(lobby_bg, 0, 0)
add_lobby_lights(preview)
preview:drawImage(load_image(png_path), 912, 424)

-- Actual idle_0 atlas frame (64x64), matching the scene's AnimatedSprite2D scale 2.
local atlas = load_image(atlas_path)
local player_frame = blank(64, 64)
for y = 0, 63 do
	for x = 0, 63 do
		player_frame:drawPixel(x, y, grade_player_pixel(atlas:getPixel(x, y)))
	end
end
local player_2x = resize_nearest(player_frame, 128, 128)
preview:drawImage(player_2x, 176, 446)

local preview_dir = os.getenv("TEMP")
if not preview_dir or preview_dir == "" then
	preview_dir = os.getenv("TMP")
end
if preview_dir and preview_dir ~= "" then
	preview:saveAs(preview_dir .. "/lobby-v2-harmonizado-1152x648.png")
	print("LOBBY_PREVIEW_OK 1152x648, idle_0 atlas frame, 2x nearest, spawn x=240 y=560")
else
	print("LOBBY_PREVIEW_SKIPPED: TEMP and TMP are unset; no preview written inside res://")
end

print("LOBBY_PLAQUE_OK 94x30, 3 editable layers, Aseprite " .. tostring(app.version))
