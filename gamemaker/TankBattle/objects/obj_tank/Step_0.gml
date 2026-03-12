// =============================================================================
// obj_tank - Step Event
// =============================================================================

// --- Position Interpolation ---
x = lerp(x, target_x, LERP_POSITION);
y = lerp(y, target_y, LERP_POSITION);

// --- Body Rotation (follows movement direction) ---
var dx = x - prev_x;
var dy = y - prev_y;
if (abs(dx) > 0.5 || abs(dy) > 0.5) {
    // Compute movement direction as image_angle
    // point_direction returns GML angle (0=right, 90=up, 270=down)
    // Subtract 90 because Kenney sprites face UP at angle 0
    target_body_angle = point_direction(0, 0, dx, dy) - 90;
}
body_angle = lerp_angle(body_angle, target_body_angle, LERP_BODY_ROTATION);
prev_x = x;
prev_y = y;

// --- Turret Rotation ---
// Convert server angle to image_angle for drawing
target_turret_angle = server_angle_to_image_angle(server_angle);
turret_angle = lerp_angle(turret_angle, target_turret_angle, LERP_TURRET_ROTATION);

// --- Death Blinking ---
if (dead) {
    blink_timer += delta_time / 1000; // microseconds to ms
    visible_toggle = (floor(blink_timer / 500) mod 2 == 0);
} else {
    visible_toggle = true;
    blink_timer = 0;
}

// --- Shield Pulse ---
if (shield > 0) {
    shield_pulse += 0.05;
    shield_alpha = 0.2 + sin(shield_pulse) * 0.1;
} else {
    shield_alpha = 0;
}

// --- Explosion Animation ---
if (explosion_active) {
    explosion_timer -= delta_time / 1000;
    if (explosion_timer <= 0) {
        explosion_active = false;
    }
}

// --- Smoke Trail ---
if (!dead && (abs(dx) > 0.5 || abs(dy) > 0.5)) {
    smoke_timer += delta_time / 1000;
    if (smoke_timer > 100) { // Every 100ms
        smoke_timer = 0;
        // Create a smoke particle behind the tank
        var smoke = instance_create_layer(x, y, "Effects", obj_smoke);
        if (instance_exists(smoke)) {
            smoke.image_alpha = 0.4;
        }
    }
}
