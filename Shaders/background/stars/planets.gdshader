shader_type canvas_item;

uniform float blur_amount : hint_range(0.0, 5.0) = 0.4;
uniform float glow_intensity : hint_range(0.0, 3.0) = 0.8;
uniform float glow_radius : hint_range(0.0, 6.0) = 1.5;

void fragment() {
    /* -------- BLUR -------- */
    vec2 blur_px = TEXTURE_PIXEL_SIZE * blur_amount;

    vec4 blur = vec4(0.0);
    blur += texture(TEXTURE, UV + vec2(-blur_px.x, 0.0));
    blur += texture(TEXTURE, UV + vec2( blur_px.x, 0.0));
    blur += texture(TEXTURE, UV + vec2(0.0, -blur_px.y));
    blur += texture(TEXTURE, UV + vec2(0.0,  blur_px.y));
    blur += texture(TEXTURE, UV);
    blur /= 5.0;

    /* -------- GLOW -------- */
    vec2 glow_px = TEXTURE_PIXEL_SIZE * glow_radius;

    vec4 glow = vec4(0.0);
    glow += texture(TEXTURE, UV + glow_px * vec2(-1.0, 0.0));
    glow += texture(TEXTURE, UV + glow_px * vec2( 1.0, 0.0));
    glow += texture(TEXTURE, UV + glow_px * vec2(0.0, -1.0));
    glow += texture(TEXTURE, UV + glow_px * vec2(0.0,  1.0));
    glow *= glow_intensity * 0.25;

    /* -------- RESULT -------- */
    COLOR = blur + glow;
}
