// =============================================================================
// obj_background - Draw Event
// Draws the arena ground and grid
// =============================================================================

// --- Ground fill (gradient: white north → soft blue south) ---
for (var row = 0; row < MAP_SIZE; row++) {
    var t = row / MAP_SIZE;
    var col = merge_colour(c_white, #aabbdd, t);
    draw_set_color(col);
    draw_rectangle(
        0, row * UNIT_SIZE,
        MAP_PIXELS, (row + 1) * UNIT_SIZE,
        false
    );
}

// --- Grid overlay ---
draw_set_alpha(0.15);
draw_set_color(#4466aa);
for (var gx = 0; gx <= MAP_SIZE; gx++) {
    draw_line(gx * UNIT_SIZE, 0, gx * UNIT_SIZE, MAP_PIXELS);
}
for (var gy = 0; gy <= MAP_SIZE; gy++) {
    draw_line(0, gy * UNIT_SIZE, MAP_PIXELS, gy * UNIT_SIZE);
}

// --- Boundary walls ---
draw_set_alpha(0.8);
draw_set_color(#1a4488);
var wall = 1.5 * UNIT_SIZE;
// Top
draw_rectangle(0, 0, MAP_PIXELS, wall, false);
// Bottom
draw_rectangle(0, MAP_PIXELS - wall, MAP_PIXELS, MAP_PIXELS, false);
// Left
draw_rectangle(0, 0, wall, MAP_PIXELS, false);
// Right
draw_rectangle(MAP_PIXELS - wall, 0, MAP_PIXELS, MAP_PIXELS, false);

// Wall wireframe
draw_set_alpha(0.4);
draw_set_color(#4488cc);
draw_rectangle(wall, wall, MAP_PIXELS - wall, MAP_PIXELS - wall, true);

draw_set_alpha(1);
draw_set_color(c_white);
