// =============================================================================
// obj_pickable - Draw Event
// =============================================================================

var radius = PICKABLE_RADIUS * UNIT_SIZE * 2; // Visual radius (larger than collision)

switch (type) {
    case "repair":
        // Green cross
        draw_set_color(c_lime);
        draw_set_alpha(0.8);
        // Horizontal bar
        draw_rectangle(x - radius, y - radius * 0.3, x + radius, y + radius * 0.3, false);
        // Vertical bar
        draw_rectangle(x - radius * 0.3, y - radius, x + radius * 0.3, y + radius, false);
        break;

    case "shield":
        // Blue diamond/shield shape
        draw_set_color(#4488ff);
        draw_set_alpha(0.8);
        draw_circle(x, y, radius, false);
        draw_set_color(#88bbff);
        draw_set_alpha(0.5);
        draw_circle(x, y, radius * 1.3, true);
        break;

    case "damage":
        // Red octagon/star
        draw_set_color(c_red);
        draw_set_alpha(0.8);
        // Draw as rotated square (diamond)
        draw_sprite_ext(spr_bullet_special, 0, x, y, 1.5, 1.5, spin_angle, c_red, 0.9);
        break;
}

// Glow aura
draw_set_alpha(0.15);
switch (type) {
    case "repair": draw_set_color(c_lime); break;
    case "shield": draw_set_color(#4488ff); break;
    case "damage": draw_set_color(c_red); break;
}
draw_circle(x, y, radius * 2, false);

draw_set_alpha(1);
draw_set_color(c_white);
