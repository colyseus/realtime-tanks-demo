// =============================================================================
// obj_tank - Draw Event
// =============================================================================

if (!visible_toggle) exit;

var tank_color = get_team_color(team);
var draw_alpha = dead ? 0.5 : 1.0;

// --- Tank Body ---
draw_sprite_ext(
    body_sprite, 0,
    x, y,
    0.7, 0.7,          // Scale down Kenney sprites (75px → ~53px for TANK_RADIUS 0.75)
    body_angle,
    c_white, draw_alpha
);

// --- Barrel/Turret ---
// Barrel pivot: offset from tank center toward the front of the barrel
var barrel_scale = 0.7;
draw_sprite_ext(
    barrel_sprite, 0,
    x, y,
    barrel_scale, barrel_scale,
    turret_angle,
    c_white, draw_alpha
);

// --- Shield Bubble ---
if (shield > 0 && !dead) {
    var shield_radius = TANK_RADIUS * UNIT_SIZE * 1.3;
    draw_set_alpha(shield_alpha);
    draw_set_color(#4488ff);
    draw_circle(x, y, shield_radius, false);
    draw_set_alpha(0.5);
    draw_circle(x, y, shield_radius, true);
    draw_set_alpha(1);
    draw_set_color(c_white);
}

// --- Health Bar (above tank) ---
if (!dead) {
    var hb_w = 40;
    var hb_h = 4;
    var hb_x = x - hb_w / 2;
    var hb_y = y - 35;
    var hp_pct = clamp(hp / 10, 0, 1);

    // Background
    draw_set_alpha(0.4);
    draw_set_color(c_black);
    draw_rectangle(hb_x, hb_y, hb_x + hb_w, hb_y + hb_h, false);

    // Fill
    draw_set_alpha(0.8);
    if (hp_pct > 0.5) draw_set_color(c_green);
    else if (hp_pct > 0.25) draw_set_color(c_orange);
    else draw_set_color(c_red);
    draw_rectangle(hb_x, hb_y, hb_x + hb_w * hp_pct, hb_y + hb_h, false);

    draw_set_alpha(1);
    draw_set_color(c_white);
}

// --- Name Tag ---
if (!dead) {
    draw_set_halign(fa_center);
    draw_set_valign(fa_bottom);
    draw_set_color(tank_color);
    draw_set_alpha(0.8);
    draw_text(x, y - 40, tank_name);
    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}

// --- Explosion Effect ---
if (explosion_active) {
    var t = 1 - (explosion_timer / 600); // 0 to 1 over 600ms
    var exp_radius = t * 3 * UNIT_SIZE;

    // Fireball
    draw_set_alpha((1 - t) * 0.8);
    draw_set_color(c_orange);
    draw_circle(x, y, exp_radius * 0.6, false);
    draw_set_color(c_yellow);
    draw_circle(x, y, exp_radius * 0.3, false);

    // Shockwave ring
    draw_set_alpha((1 - t) * 0.5);
    draw_set_color(c_white);
    draw_circle(x, y, exp_radius, true);

    draw_set_alpha(1);
    draw_set_color(c_white);
}
