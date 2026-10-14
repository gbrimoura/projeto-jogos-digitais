@tool
class_name SolidPlatform
extends StaticBody2D

## Seed compartilhada por todas as plataformas da sala.
## 0 = totalmente aleatório. Defina ANTES de instanciar a sala para reproduzir uma geração.
static var room_seed: int = 0

const FIXED_NAME := &"Floor"
const PLACED_META := &"_placement_done"

@export var size: Vector2 = Vector2(220.0, 24.0):
	set(value):
		size = Vector2(maxf(value.x, 1.0), maxf(value.y, 1.0))
		_sync_geometry()

@export var fill_color: Color = Color("#263545"):
	set(value):
		fill_color = value
		_sync_geometry()

@export var factory_skin_enabled: bool = false:
	set(value):
		factory_skin_enabled = value
		_sync_surface_skin()

@export_enum("Platform", "Block") var factory_surface_style: int = 0:
	set(value):
		factory_surface_style = clampi(value, 0, 1)
		_sync_surface_skin()

@export_group("Random Placement")
## Desmarque para manter esta plataforma exatamente onde está na cena.
## O node chamado "Floor" nunca é randomizado.
@export var randomize_position: bool = true
## Área útil da sala (nas coordenadas do node pai).
@export var room_rect: Rect2 = Rect2(0.0, 0.0, 1280.0, 720.0)
## Alinha comprimento e posições a uma grade (0 = desliga). Use o tamanho do tile da textura.
@export var grid_snap: float = 16.0
## Distância mínima das bordas da sala.
@export var wall_margin: float = 16.0
@export var max_attempts: int = 80

@export_group("Random Size")
## Sorteia só o comprimento. A espessura (size.y) é sempre a definida no editor.
@export var randomize_width: bool = true
## Largura mínima = área de pouso confortável; máxima = limite de uma plataforma larga.
@export var width_range: Vector2 = Vector2(96.0, 288.0)
## Nenhuma plataforma passa dessa fração da largura da sala (evita paredões que bloqueiam o fluxo).
@export_range(0.1, 1.0) var max_width_ratio: float = 0.4

@export_group("Jump Reach")
## Quanto o jogador consegue subir com um pulo (use um valor conservador).
@export var max_jump_height: float = 120.0
## Distância horizontal máxima entre as bordas de duas plataformas.
@export var max_jump_gap: float = 180.0
## Quanto uma plataforma pode ficar abaixo da plataforma de referência.
@export var max_drop_height: float = 200.0
## Espaço livre vertical acima e abaixo (altura do jogador + folga).
@export var vertical_clearance: float = 70.0
## Espaço livre horizontal mínimo entre plataformas.
@export var horizontal_clearance: float = 24.0

func _ready() -> void:
	_sync_geometry()
	if Engine.is_editor_hint():
		return
	add_to_group(&"solid_platform")
	if _is_fixed_platform(self):
		set_meta(PLACED_META, true)
		return
	_place_randomly()
	set_meta(PLACED_META, true)

static func _is_fixed_platform(platform: SolidPlatform) -> bool:
	return platform.name == FIXED_NAME or not platform.randomize_position

func _get_rect() -> Rect2:
	return Rect2(position - size * 0.5, size)

func _place_randomly() -> void:
	var parent := get_parent()
	if parent == null:
		return

	# Plataformas já posicionadas (e as fixas, como o Floor) servem de âncora:
	# cada nova plataforma nasce ao alcance de uma delas, então a sala fica alcançável.
	var anchors: Array[Rect2] = []
	for sibling in parent.get_children():
		var other := sibling as SolidPlatform
		if other == null or other == self:
			continue
		if _is_fixed_platform(other) or other.has_meta(PLACED_META):
			anchors.append(other._get_rect())

	if anchors.is_empty():
		push_warning("%s: nenhuma plataforma de referência (Floor) encontrada." % name)
		return

	var rng := RandomNumberGenerator.new()
	if room_seed == 0:
		rng.randomize()
	else:
		rng.seed = hash([room_seed, get_index()])

	for _attempt in max_attempts:
		var new_size := _roll_size(rng) if randomize_width else size
		var anchor: Rect2 = anchors[rng.randi_range(0, anchors.size() - 1)]

		# Altura do topo em relação ao topo da âncora (negativo = mais alto).
		var rise := rng.randf_range(-max_jump_height, max_drop_height)
		var top := anchor.position.y + rise

		var gap_limit := _allowed_gap(rise)
		var center_x := rng.randf_range(
			anchor.position.x - gap_limit - new_size.x * 0.5,
			anchor.end.x + gap_limit + new_size.x * 0.5
		)

		var candidate := Rect2(Vector2(center_x - new_size.x * 0.5, top), new_size)
		candidate.position = Vector2(
			snappedf(candidate.position.x, grid_snap),
			snappedf(candidate.position.y, grid_snap)
		)

		# O snap pode mexer alguns pixels, então revalida o alcance depois dele.
		if not _is_reachable(candidate, anchor):
			continue
		if not _is_valid(candidate, anchors):
			continue

		size = new_size
		position = candidate.position + new_size * 0.5
		return

	push_warning("%s: não achou posição válida; mantendo a posição original." % name)

## Sorteia só a largura; a espessura continua a do editor.
func _roll_size(rng: RandomNumberGenerator) -> Vector2:
	var max_width := minf(width_range.y, room_rect.size.x * max_width_ratio)
	var min_width := minf(width_range.x, max_width)

	# Média de dois sorteios: favorece larguras médias em vez dos extremos.
	var t := (rng.randf() + rng.randf()) * 0.5
	var width := lerpf(min_width, max_width, t)

	return Vector2(maxf(snappedf(width, grid_snap), min_width), size.y)

## Vão horizontal permitido: quanto mais alto o pulo, menor o vão.
func _allowed_gap(rise: float) -> float:
	var rise_ratio := clampf(-rise / maxf(max_jump_height, 1.0), 0.0, 1.0)
	return max_jump_gap * (1.0 - 0.6 * rise_ratio)

func _is_reachable(candidate: Rect2, anchor: Rect2) -> bool:
	var rise := candidate.position.y - anchor.position.y
	if rise < -max_jump_height or rise > max_drop_height:
		return false
	var gap := maxf(0.0, maxf(candidate.position.x - anchor.end.x, anchor.position.x - candidate.end.x))
	return gap <= _allowed_gap(rise)

func _is_valid(candidate: Rect2, anchors: Array[Rect2]) -> bool:
	var bounds := room_rect.grow(-wall_margin)

	# Precisa sobrar espaço acima da plataforma para o jogador pular sem bater no teto.
	var with_headroom := Rect2(
		candidate.position - Vector2(0.0, vertical_clearance),
		candidate.size + Vector2(0.0, vertical_clearance)
	)
	if not bounds.encloses(with_headroom):
		return false

	var padded := candidate.grow_individual(
		horizontal_clearance, vertical_clearance,
		horizontal_clearance, vertical_clearance
	)
	for obstacle in anchors:
		if padded.intersects(obstacle):
			return false
	return true

func _sync_geometry() -> void:
	var collision_shape := get_node_or_null("CollisionShape2D") as CollisionShape2D
	if collision_shape != null:
		var rectangle := collision_shape.shape as RectangleShape2D
		if rectangle != null:
			if not rectangle.resource_local_to_scene:
				rectangle = rectangle.duplicate() as RectangleShape2D
				rectangle.resource_local_to_scene = true
				collision_shape.shape = rectangle
			rectangle.size = size

	var half_size := size * 0.5
	var visual_fill := get_node_or_null("Visuals/Fill") as Polygon2D
	if visual_fill != null:
		visual_fill.color = fill_color
		visual_fill.polygon = PackedVector2Array([
			Vector2(-half_size.x, -half_size.y),
			Vector2(half_size.x, -half_size.y),
			Vector2(half_size.x, half_size.y),
			Vector2(-half_size.x, half_size.y),
		])

	var top_edge := get_node_or_null("Visuals/TopEdge") as Line2D
	if top_edge != null:
		top_edge.points = PackedVector2Array([
			Vector2(-half_size.x, -half_size.y),
			Vector2(half_size.x, -half_size.y),
		])

	var floor_detail := get_node_or_null("FloorDetail") as Line2D
	if floor_detail != null:
		floor_detail.position = Vector2(0.0, -half_size.y + 32.0)
		floor_detail.points = PackedVector2Array([
			Vector2(-half_size.x, 0.0),
			Vector2(half_size.x, 0.0),
		])

	_sync_surface_skin()

func _sync_surface_skin() -> void:
	var surface_visual := get_node_or_null("Visuals/FactorySurfaceVisual") as Node2D
	var visual_fill := get_node_or_null("Visuals/Fill") as Polygon2D
	var top_edge := get_node_or_null("Visuals/TopEdge") as Line2D
	var floor_detail := get_node_or_null("FloorDetail") as Line2D
	var use_factory_skin: bool = factory_skin_enabled and surface_visual != null
	if surface_visual != null:
		surface_visual.set("surface_size", size)
		surface_visual.set("surface_style", factory_surface_style)
		surface_visual.visible = use_factory_skin
	if visual_fill != null:
		visual_fill.visible = not use_factory_skin
	if top_edge != null:
		top_edge.visible = not use_factory_skin
	if floor_detail != null:
		floor_detail.visible = not use_factory_skin
