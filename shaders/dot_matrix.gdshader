shader_type canvas_item;

// 0 = circle, 1 = square, 2 = diamond — kept in sync with LedSettings.DotShape.
uniform bool mask_enabled = true;
uniform int dot_shape = 0;
uniform vec2 rect_size = vec2(256.0, 256.0);
uniform float dot_radius_px = 3.0;
uniform float dot_spacing_px = 10.0;
uniform float blur_amount : hint_range(0.0, 1.0) = 0.15;
uniform float brightness : hint_range(0.0, 2.0) = 1.0;
uniform vec4 gap_color : source_color = vec4(0.07, 0.07, 0.08, 1.0);
uniform sampler2D source_tex : filter_linear;

void fragment() {
	vec4 src = texture(source_tex, UV);

	if (mask_enabled) {
		vec2 px = UV * rect_size;
		vec2 cell = floor(px / dot_spacing_px);
		vec2 cell_center_px = (cell + vec2(0.5)) * dot_spacing_px;
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

		vec3 revealed = src.rgb * brightness;
		COLOR = vec4(mix(gap_color.rgb, revealed, shape_mask), mix(gap_color.a, src.a, shape_mask));
	} else {
		COLOR = src;
	}
}
