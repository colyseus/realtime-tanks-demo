// =============================================================================
// obj_smoke - Draw Event
// =============================================================================

if (sprite_exists(spr_smoke)) {
    draw_sprite_ext(spr_smoke, 0, x, y, image_xscale, image_yscale, 0, c_white, image_alpha);
} else {
    // Fallback: draw a simple circle
    draw_set_alpha(image_alpha);
    draw_set_color(c_gray);
    draw_circle(x, y, 8 * image_xscale, false);
    draw_set_alpha(1);
    draw_set_color(c_white);
}
