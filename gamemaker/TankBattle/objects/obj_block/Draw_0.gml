// =============================================================================
// obj_block - Draw Event
// =============================================================================

var pw = block_w * UNIT_SIZE;
var ph = block_h * UNIT_SIZE;
var px = x - pw / 2;
var py = y - ph / 2;

// Filled block
draw_set_alpha(0.6);
draw_set_color(#2266aa);
draw_rectangle(px, py, px + pw, py + ph, false);

// Wireframe outline
draw_set_alpha(0.8);
draw_set_color(#4488cc);
draw_rectangle(px, py, px + pw, py + ph, true);

// Inner grid lines (for larger blocks)
if (block_w > 1 || block_h > 1) {
    draw_set_alpha(0.2);
    draw_set_color(#88bbff);
    for (var gx = 1; gx < block_w; gx++) {
        var lx = px + gx * UNIT_SIZE;
        draw_line(lx, py, lx, py + ph);
    }
    for (var gy = 1; gy < block_h; gy++) {
        var ly = py + gy * UNIT_SIZE;
        draw_line(px, ly, px + pw, ly);
    }
}

draw_set_alpha(1);
draw_set_color(c_white);
