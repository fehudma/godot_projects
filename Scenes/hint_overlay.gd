extends Node2D

class_name HintOverlay

const FRAME_SIZE: Vector2 = Vector2(108.0, 108.0)
const FRAME_COLOR: Color = Color("f05cff")
const ARROW_COLOR: Color = Color("ffffff")
const FRAME_WIDTH: float = 5.0
const GLOW_WIDTH: float = 12.0
const CORNER_RADIUS: int = 16
const ARROW_INSET: float = 42.0
const ARROW_HEAD_LENGTH: float = 14.0
const ARROW_HEAD_WIDTH: float = 9.0
const PULSE_SPEED: float = 5.0

var first_center: Vector2 = Vector2.ZERO
var second_center: Vector2 = Vector2.ZERO
var is_showing: bool = false
var pulse_time: float = 0.0


func _ready() -> void:
	z_index = 100
	visible = false


func _process(delta: float) -> void:
	if not is_showing:
		return

	pulse_time += delta
	queue_redraw()


func show_hint(first_position: Vector2, second_position: Vector2) -> void:
	first_center = first_position
	second_center = second_position
	pulse_time = 0.0
	is_showing = true
	visible = true
	queue_redraw()


func clear_hint() -> void:
	is_showing = false
	visible = false
	queue_redraw()


func _draw() -> void:
	if not is_showing:
		return

	var pulse: float = (sin(pulse_time * PULSE_SPEED) + 1.0) * 0.5
	var glow_alpha: float = lerpf(0.18, 0.42, pulse)

	_draw_frame(first_center, glow_alpha)
	_draw_frame(second_center, glow_alpha)
	_draw_swap_arrow(first_center, second_center, glow_alpha)


func _draw_frame(center: Vector2, glow_alpha: float) -> void:
	var frame_rect := Rect2(center - FRAME_SIZE * 0.5, FRAME_SIZE)
	var glow_style := _create_frame_style(
		Color(FRAME_COLOR, glow_alpha),
		GLOW_WIDTH
	)
	var frame_style := _create_frame_style(FRAME_COLOR, FRAME_WIDTH)

	draw_style_box(glow_style, frame_rect)
	draw_style_box(frame_style, frame_rect)


func _create_frame_style(color: Color, width: float) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color.TRANSPARENT
	style.border_color = color
	style.set_border_width_all(roundi(width))
	style.set_corner_radius_all(CORNER_RADIUS)
	return style


func _draw_swap_arrow(
	from_center: Vector2,
	to_center: Vector2,
	glow_alpha: float
) -> void:
	var direction := from_center.direction_to(to_center)
	var perpendicular := Vector2(-direction.y, direction.x)
	var arrow_start := from_center + direction * ARROW_INSET
	var arrow_end := to_center - direction * ARROW_INSET
	var glow_color := Color(FRAME_COLOR, glow_alpha)

	draw_line(arrow_start, arrow_end, glow_color, GLOW_WIDTH, true)
	draw_line(arrow_start, arrow_end, ARROW_COLOR, FRAME_WIDTH, true)

	_draw_arrow_head(arrow_start, -direction, perpendicular, glow_color, GLOW_WIDTH)
	_draw_arrow_head(arrow_end, direction, perpendicular, glow_color, GLOW_WIDTH)
	_draw_arrow_head(arrow_start, -direction, perpendicular, ARROW_COLOR, FRAME_WIDTH)
	_draw_arrow_head(arrow_end, direction, perpendicular, ARROW_COLOR, FRAME_WIDTH)


func _draw_arrow_head(
	tip: Vector2,
	direction: Vector2,
	perpendicular: Vector2,
	color: Color,
	width: float
) -> void:
	var base := tip - direction * ARROW_HEAD_LENGTH
	var first_side := base + perpendicular * ARROW_HEAD_WIDTH
	var second_side := base - perpendicular * ARROW_HEAD_WIDTH

	draw_line(tip, first_side, color, width, true)
	draw_line(tip, second_side, color, width, true)
