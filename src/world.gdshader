shader_type canvas_item;

// Highlight Stuff
uniform vec2 hovered_tile_world_pos;
// The half-extents of your tile size (e.g., if tiles are 16x16, half is 8x8)
uniform vec2 tile_half_size = vec2(24.0, 24.0);
// The color and opacity of the highlight effect
uniform vec4 highlight_color : source_color = vec4(1.0, 1.0, 1.0, 0.4);

varying vec2 world_position;
//end Highlight


// --- User-configurable uniforms (pixels unless noted) ---
// Tile bounding box (width, height) in pixels as set in the Tileset editor
uniform vec2 tile_size = vec2(48.0, 48.0);

// Outer atlas margin (left, top) in pixels
uniform vec2 margin = vec2(10.0, 10.0);

// Separation between tiles in the atlas in pixels (x,y)
uniform vec2 separation = vec2(0.0, 0.0);

// Per-side padding Godot may add when use_texture_padding is enabled.
// Set to vec2(0.0) if you do not use texture padding.
uniform vec2 padding = vec2(0.0, 0.0);

// Outline color and thickness (thickness in pixels)
uniform vec4 outline_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform float outline_thickness = 1.0;

// Anti-alias smoothing width in pixels (small positive value)
uniform float aa = 0.5;

// If true, the shader overlays the outline on top of the sampled tile color.
// If false, the shader outputs only the outline (transparent where no outline).
uniform bool overlay = true;

// Debug modes: 0 = atlas gradient, 1 = tile index blocks, -1 = final border-only rendering
uniform int debug_mode = -1;

float sdHexagon(vec2 p, float r) {
    const vec3 k = vec3(-0.866025404, 0.5, 0.577350269);
    p = abs(p);
    p -= 2.0 * min(dot(k.xy, p), 0.0) * k.xy;
    p -= vec2(clamp(p.x, -k.z * r, k.z * r), r);
    return length(p) * sign(p.y);
}


void vertex() {
	// Capture the absolute world position of the current vertex
	world_position = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
// /* hex highlight block
   // --- Atlas bookkeeping ---
    // Bound texture size in pixels (reflects runtime/padded texture)
    vec2 atlas_size = vec2(textureSize(TEXTURE, 0));
    // Convert UV to atlas pixel coordinates
    vec2 atlas_px = UV * atlas_size;
    // Move into the atlas grid by subtracting the outer margin (in pixels)
    vec2 rel = atlas_px - margin;
    // Effective cell size: tile bounding box + separation + padding on both sides
    vec2 cell = tile_size + separation + padding * 2.0;
    // Integer tile indices (which cell this fragment belongs to)
    vec2 idxf = floor(rel / cell);
    // Local pixel coordinates inside the tile cell (0..tile_size roughly)
    vec2 local = rel - idxf * cell;
    // Detect fragments that lie in the atlas margin or padding area (outside the tile image)
    bool outside = (local.x < 0.0) || (local.y < 0.0) || (local.x >= tile_size.x) || (local.y >= tile_size.y);

    // --- Debug visuals ---
    vec4 atlas_gradient = vec4(atlas_px.x / atlas_size.x, atlas_px.y / atlas_size.y, 0.0, 1.0);
    float ix = mod(idxf.x, 16.0) / 16.0;
    float iy = mod(idxf.y, 16.0) / 16.0;
    vec4 index_blocks = vec4(ix, iy, 0.5, 1.0);

    // Default final color (transparent by default for outline-only mode)
    vec4 final_color = vec4(0.0, 0.0, 0.0, 0.0);

    // Choose debug output if requested
    if (debug_mode == 0) {
        final_color = atlas_gradient;
    } else if (debug_mode == 1) {
        final_color = index_blocks;
    } else {
        // --- Final border-only rendering for flat-topped hex tiles ---
        // Sample the atlas texture at the current UV for the base color
        vec4 base = texture(TEXTURE, UV);

        // If fragment is outside the tile image (in margin/padding)
        if (outside) {
            // If overlay is requested, show base; otherwise keep transparent
            if (overlay) {
                final_color = base;
            } else {
                final_color = vec4(0.0, 0.0, 0.0, 0.0);
            }
        } else {
            // --- Hex SDF (flat-topped) ---
            // Move local coords to hex center (center-based coordinates)
            vec2 center = tile_size * 0.5;
            vec2 p = local - center;

            // Horizontal radius (half width)
            float r = tile_size.x * 0.5;

            // Vertical half-height of the hex (distance from center to flat edge).
            // Use tile_size.y * 0.5 so the shader matches your tile bounding box height exactly.
            float h = tile_size.y * 0.5;

            // Work in absolute coordinates due to hex symmetry
            vec2 ap = abs(p);

            // q approximates the projection onto the 60-degree axis; common cheap hex SDF trick
            // 0.8660254 = cos(30°) = sqrt(3)/2
            float q = max(ap.x * 1.0 + ap.y * 0.5, ap.y);

            // edge_dist is positive inside the hex (distance from interior point to the hex edge in pixels)
            // At the hex edge edge_dist ~ 0. Inside center edge_dist large positive. Outside edge_dist negative.
            float edge_dist = h - q;

            // We want the border to be drawn where the absolute distance to the edge is small.
            // Use absolute distance so border appears on both sides of the exact edge if needed.
            float dist_to_edge = abs(edge_dist);

            // --- Build an anti-aliased mask for the border ---
            // half is the anti-alias smoothing width in pixels
            float half = aa;
            // inner/outer define the smoothstep band around the desired outline_thickness
            float inner = outline_thickness - half;
            float outer = outline_thickness - half;
            // Clamp to valid ranges
            if (inner < 0.0) { inner = 0.0; }
            //if (outer <= inner) { outer = inner + 0.000; }

            // mask == 1 where dist_to_edge is small (near the hex edge), 0 elsewhere.
            // Use decreasing smoothstep so small distances map to 1.
            float raw = 1.0 - smoothstep(outline_thickness, outline_thickness, dist_to_edge);
            float mask = clamp(raw, 0.0, 1.0);

            // Compose final color:
            // - If overlay is true, blend outline over the sampled base color.
            // - If overlay is false, output only the outline (transparent elsewhere).
            if (overlay) {
                final_color = mix(base, outline_color, mask);
				vec2 diff = abs(world_position - hovered_tile_world_pos);
				
				if ( sdHexagon(diff, 24.0) < 0.0 ) {
				// Mix the original color with the highlight color based on its alpha weight
					final_color = vec4(mix(final_color.rgb, highlight_color.rgb, highlight_color.a), base.a + 0.5);
	        }
            } else {
                final_color = vec4(outline_color.rgb, outline_color.a * mask);
            }
			
			
			
			float raw2 = 1.0 - smoothstep(0, 1, dist_to_edge);
            float mask2 = clamp(raw2, 0.0, 1.0);
			

		}
    }

    // Single final assignment to the fragment color (no early returns)
    COLOR = final_color;
}