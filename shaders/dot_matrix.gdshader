shader_type canvas_item;

// 0 = circle, 1 = square, 2 = diamond — kept in sync with LedSettings.DotShape.
uniform int dot_shape = 0;
uniform vec2 rect_size = vec2(256.0, 256.0);
uniform float dot_radius_px = 3.0;
uniform float dot_spacing_px = 10.0;
uniform float blur_amount : hint_range(0.0, 1.0) = 0.15;
uniform float brightness : hint_range(0.0, 2.0) = 1.0;
uniform vec4 color_on : source_color = vec4(1.0, 0.15, 0.15, 1.0);
uniform vec4 color_off : source_color = vec4(0.07, 0.07, 0.08, 1.0);
uniform sampler2D source_tex : filter_linear;

void fragment() {
	vec2 px = UV * rect_size;
	vec2 cell = floor(px / dot_spacing_px);
	vec2 cell_center_px = (cell + vec2(0.5)) * dot_spacing_px;
	vec2 sample_uv = clamp(cell_center_px / rect_size, vec2(0.0), vec2(1.0));
	float ink = texture(source_tex, sample_uv).a;

	vec2 local = px - cell_center_px;
	float d;
	if (dot_shape == 1) {
		d = max(abs(local.x), abs(local.y));
	} else if (dot_shape == 2) {
		d = abs(local.x) + abs(local.y);
	} else {
		d = length(local);
	}

	float edge_soft = max(dot_radius_px * blur_amount, 0.001);
	float shape_mask = 1.0 - smoothstep(dot_radius_px - edge_soft, dot_radius_px + edge_soft, d);

	vec3 lit_color = color_on.rgb * brightness;
	vec3 final_rgb = mix(color_off.rgb, lit_color, ink * shape_mask);
	COLOR = vec4(final_rgb, 1.0);
}
