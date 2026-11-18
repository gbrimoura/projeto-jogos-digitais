-- Build the tower's editable brass/enamel plaque in Aseprite and compose a
-- temporary static preview over the previously harmonized lobby image.

local pc = app.pixelColor
local script_file = debug.getinfo(1, "S").source:gsub("^@", ""):gsub("\\", "/")
local script_dir = script_file:match("^(.*)/[^/]+$") or "."

local function rgb(hex)
	return pc.rgba(tonumber(hex:sub(2, 3), 16), tonumber(hex:sub(4, 5), 16), tonumber(hex:sub(6, 7), 16), 255)
end

-- Reuse the established lobby plaque palette for a single visual language.
local INK = rgb("#0C1B29")
local ENAMEL_EDGE = rgb("#2D4D5B")
local OUTER_SHADOW = rgb("#70432C")
local BRONZE = rgb("#925A36")
local BRASS = rgb("#B78342")
local AMBER = rgb("#D2A75C")
local LIGHT_BRASS = rgb("#90816A")
local PALE_GOLD = rgb("#EED49A")
local TRANSPARENT = pc.rgba(0, 0, 0, 0)

local function blank(width, height)
	local image = Image(width, height)
	for y = 0, height - 1 do
		for x = 0, width - 1 do
			image:drawPixel(x, y, TRANSPARENT)
		end
	end
	return image
end

local function fill_rect(image, x, y, width, height, color)
	for py = y, y + height - 1 do
		for px = x, x + width - 1 do
			if px >= 0 and px < image.width and py >= 0 and py < image.height then
				image:drawPixel(px, py, color)
			end
		end
	end
end

local width, height = 128, 22

local function edge_margin(y)
	if y == 0 or y == height - 1 then return 10 end
	if y == 1 or y == height - 2 then return 6 end
	if y == 2 or y == height - 3 then return 3 end
	return 1
end

local function fill_plate(image, inset, color)
	for y = inset, height - inset - 1 do
		local margin = edge_margin(y) + inset
		fill_rect(image, margin, y, width - margin * 2, 1, color)
	end
end

local chassis = blank(width, height)
fill_plate(chassis, 0, OUTER_SHADOW)
fill_plate(chassis, 1, BRONZE)
fill_plate(chassis, 2, BRASS)

-- Paired stepped friezes and bevels keep the trim crisp and symmetrical.
fill_rect(chassis, 9, 20, 110, 1, OUTER_SHADOW)

local enamel = blank(width, height)
fill_plate(enamel, 3, INK)
fill_rect(enamel, 15, 3, 34, 1, LIGHT_BRASS)
fill_rect(enamel, 79, 3, 34, 1, LIGHT_BRASS)
fill_rect(enamel, 15, 18, 34, 1, OUTER_SHADOW)
fill_rect(enamel, 79, 18, 34, 1, OUTER_SHADOW)
fill_rect(enamel, 7, 4, 3, 1, AMBER)
fill_rect(enamel, 118, 4, 3, 1, AMBER)
fill_rect(enamel, 12, 5, 104, 1, ENAMEL_EDGE)
fill_rect(enamel, 12, 16, 104, 1, OUTER_SHADOW)
fill_rect(enamel, 5, 6, 1, 10, ENAMEL_EDGE)
fill_rect(enamel, 122, 6, 1, 10, ENAMEL_EDGE)
-- Tiny stepped side ornaments sit clear of the lettering.
fill_rect(enamel, 6, 9, 2, 1, BRASS)
fill_rect(enamel, 6, 12, 2, 1, BRASS)
fill_rect(enamel, 120, 9, 2, 1, BRASS)
fill_rect(enamel, 120, 12, 2, 1, BRASS)

-- Small flush rivets tie the plaque to the masonry without obscuring its name.
for _, y in ipairs({ 6, 14 }) do
	fill_rect(enamel, 3, y, 2, 2, BRASS)
	fill_rect(enamel, 123, y, 2, 2, BRASS)
	fill_rect(enamel, 3, y, 1, 1, AMBER)
	fill_rect(enamel, 123, y, 1, 1, AMBER)
end

local glyph = {
	S = { "111", "100", "111", "001", "111" },
	E = { "111", "100", "110", "100", "111" },
	L = { "100", "100", "100", "100", "111" },
	N = { "101", "111", "111", "101", "101" },
	I = { "111", "010", "010", "010", "111" },
	T = { "111", "010", "010", "010", "010" },
	O = { "010", "101", "101", "101", "010" },
	W = { "101", "101", "101", "111", "101" },
	R = { "110", "101", "110", "101", "101" },
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
		local character = text:sub(i, i)
		local pattern = glyph[character]
		if pattern then
			for gy = 1, 5 do
				for gx = 1, 3 do
					if pattern[gy]:sub(gx, gx) == "1" then
						fill_rect(image, cursor + (gx - 1) * scale, y + (gy - 1) * scale, scale, scale, color)
					end
				end
			end
		end
		cursor = cursor + (character == " " and 2 or 3) * scale
		if i < #text then cursor = cursor + scale end
	end
end

local lettering = blank(width, height)
local name = "SELENITE TOWER"
local scale = 2
local text_x = math.floor((width - text_width(name, scale)) / 2)
stamp_text(lettering, name, text_x + 1, 7, scale, OUTER_SHADOW)
stamp_text(lettering, name, text_x, 6, scale, PALE_GOLD)

local sprite = Sprite(width, height)
local palette = Palette(8)
palette:setColor(0, Color{ r = 12, g = 27, b = 41 })
palette:setColor(1, Color{ r = 45, g = 77, b = 91 })
palette:setColor(2, Color{ r = 112, g = 67, b = 44 })
palette:setColor(3, Color{ r = 146, g = 90, b = 54 })
palette:setColor(4, Color{ r = 183, g = 131, b = 66 })
palette:setColor(5, Color{ r = 210, g = 167, b = 92 })
palette:setColor(6, Color{ r = 144, g = 129, b = 106 })
palette:setColor(7, Color{ r = 238, g = 212, b = 154 })
sprite:setPalette(palette)

local chassis_layer = sprite.layers[1]
chassis_layer.name = "Brass chassis"
sprite:newCel(chassis_layer, 1).image = chassis
local enamel_layer = sprite:newLayer()
enamel_layer.name = "Dark enamel"
sprite:newCel(enamel_layer, 1).image = enamel
local lettering_layer = sprite:newLayer()
lettering_layer.name = "Stamped SELENITE TOWER"
sprite:newCel(lettering_layer, 1).image = lettering

local png_path = script_dir .. "/tower-plaque-128x22.png"
sprite:saveAs(script_dir .. "/tower-plaque-128x22.aseprite")
sprite:saveCopyAs(png_path)
print("TOWER_SIGN_OK 128x22, editable 3-layer Aseprite, exact text SELENITE TOWER, Aseprite " .. tostring(app.version))

local temp_dir = os.getenv("TEMP")
if not temp_dir or temp_dir == "" then
	temp_dir = os.getenv("TMP")
end
if not temp_dir or temp_dir == "" then
	print("TOWER_SIGN_PREVIEW_SKIPPED: TEMP/TMP are unset; production assets were saved")
	return
end

local base_path = temp_dir .. "/lobby-v2-harmonizado-1152x648.png"
local base_file = io.open(base_path, "rb")
if not base_file then
	print("TOWER_SIGN_PREVIEW_SKIPPED: previous harmonized preview not found: " .. base_path)
	return
end
base_file:close()

local preview = Image{ fromFile = base_path }
assert(preview.width == 1152 and preview.height == 648, "Unexpected base preview dimensions")
preview:drawImage(Image{ fromFile = png_path }, 893, 111)
local preview_path = temp_dir .. "/lobby-v2-tower-sign-preview-1152x648.png"
preview:saveAs(preview_path)

print("TOWER_SIGN_PREVIEW_OK 1152x648, base=" .. base_path .. ", plaque x=893 y=111 width=128 height=22")
