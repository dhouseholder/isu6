shader_type canvas_item;

// A seamless noise texture to break up the tiled lines
uniform sampler2D blend_noise : repeat_enable, hint_default_white;
uniform float tiling_scale = 4.0;
uniform float blend_intensity : hint_range(0.0, 1.0) = 0.3;

void fragment() {
    // Sample the base repeating texture
    vec4 base_color = texture(TEXTURE, UV);
    
    // Sample the noise mask using scaled UVs
    float noise = texture(blend_noise, UV * tiling_scale).r;
    
    // Soften or blend the color values based on the noise intensity
    vec3 blended = mix(base_color.rgb, base_color.rgb * noise, blend_intensity);
    
    COLOR = vec4(blended, base_color.a);
}
