shader_type canvas_item;

uniform float blur_amount : hint_range(0.0, 5.0) = 0.3;

void fragment() {
    vec2 size = TEXTURE_PIXEL_SIZE * blur_amount;

    vec4 color = vec4(0.0);
    color += texture(TEXTURE, UV + vec2(-size.x, 0.0));
    color += texture(TEXTURE, UV + vec2( size.x, 0.0));
    color += texture(TEXTURE, UV + vec2(0.0, -size.y));
    color += texture(TEXTURE, UV + vec2(0.0,  size.y));
    color += texture(TEXTURE, UV);

    COLOR = color / 5.0;
}
