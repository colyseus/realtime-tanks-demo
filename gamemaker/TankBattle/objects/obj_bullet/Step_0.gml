// =============================================================================
// obj_bullet - Step Event
// =============================================================================

// Interpolate toward target
var old_x = x;
var old_y = y;
x = lerp(x, target_x, LERP_BULLET);
y = lerp(y, target_y, LERP_BULLET);

// Update rotation based on movement
var dx = x - old_x;
var dy = y - old_y;
if (abs(dx) > 0.1 || abs(dy) > 0.1) {
    move_angle = point_direction(0, 0, dx, dy) - 90;
}
