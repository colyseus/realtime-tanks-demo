// =============================================================================
// obj_bullet - Draw Event
// =============================================================================

var spr = special ? spr_bullet_special : bullet_sprite;
var col = special ? c_orange : c_white;

draw_sprite_ext(
    spr, 0,
    x, y,
    bullet_scale, bullet_scale,
    move_angle,
    col, 1
);

// Glow effect for special bullets
if (special) {
    draw_set_alpha(0.3);
    draw_set_color(c_orange);
    draw_circle(x, y, 10, false);
    draw_set_alpha(1);
    draw_set_color(c_white);
}
