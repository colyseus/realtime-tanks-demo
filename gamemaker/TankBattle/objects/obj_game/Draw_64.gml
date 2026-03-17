// =============================================================================
// obj_game - Draw GUI Event (HUD)
// =============================================================================

var gui_w = display_get_gui_width();
var gui_h = display_get_gui_height();
var cx = gui_w / 2;

// --- Connection Status ---
if (!global.net_connected) {
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(c_gray);
    draw_set_font(-1);
    var _msg = (connect_error != "") ? connect_error : "Connecting...";
    draw_text(cx, gui_h / 2, _msg);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
    exit;
}

// --- Health Bar ---
if (instance_exists(my_tank) && !my_tank.dead) {
    var bar_w = 200;
    var bar_h = 12;
    var bar_x = cx - bar_w / 2;
    var bar_y = gui_h - 50;
    var hp_pct = clamp(my_tank.hp / 10, 0, 1);

    // Background
    draw_set_alpha(0.5);
    draw_set_color(c_dkgray);
    draw_rectangle(bar_x, bar_y, bar_x + bar_w, bar_y + bar_h, false);

    // Health fill
    draw_set_alpha(0.9);
    if (hp_pct > 0.5) draw_set_color(c_green);
    else if (hp_pct > 0.25) draw_set_color(c_orange);
    else draw_set_color(c_red);
    draw_rectangle(bar_x, bar_y, bar_x + bar_w * hp_pct, bar_y + bar_h, false);

    // Border
    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_rectangle(bar_x, bar_y, bar_x + bar_w, bar_y + bar_h, true);

    // Shield bar (above health)
    if (my_tank.shield > 0) {
        var shield_y = bar_y - 10;
        var shield_h = 6;
        var shield_pct = clamp(my_tank.shield / 10, 0, 1);

        draw_set_alpha(0.5);
        draw_set_color(c_dkgray);
        draw_rectangle(bar_x, shield_y, bar_x + bar_w, shield_y + shield_h, false);

        draw_set_alpha(0.9);
        draw_set_color(#4488ff);
        draw_rectangle(bar_x, shield_y, bar_x + bar_w * shield_pct, shield_y + shield_h, false);

        draw_set_alpha(1);
        draw_set_color(c_white);
        draw_rectangle(bar_x, shield_y, bar_x + bar_w, shield_y + shield_h, true);
    }
}

// --- Leaderboard ---
draw_set_alpha(0.7);
draw_set_color(c_black);
draw_rectangle(gui_w - 170, 10, gui_w - 10, 110, false);
draw_set_alpha(1);
draw_set_color(c_white);
draw_rectangle(gui_w - 170, 10, gui_w - 10, 110, true);

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_font(-1);
var team_names = ["RED", "BLUE", "GREEN", "YELLOW"];
var team_colors = [c_red, #4488ff, c_lime, c_yellow];
for (var i = 0; i < 4; i++) {
    var ty = 18 + i * 22;
    draw_set_color(team_colors[i]);
    draw_text(gui_w - 160, ty, team_names[i]);
    draw_set_color(c_white);
    draw_text(gui_w - 80, ty, string(team_scores[i]));
}

// --- Death Screen ---
if (instance_exists(my_tank) && my_tank.dead) {
    draw_set_alpha(0.5);
    draw_set_color(c_black);
    draw_rectangle(0, gui_h / 2 - 40, gui_w, gui_h / 2 + 40, false);
    draw_set_alpha(1);
    draw_set_color(c_red);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text(cx, gui_h / 2, "DESTROYED");
}

// --- Winner Screen ---
if (winner_team >= 0 && winner_team < 4) {
    draw_set_alpha(0.7);
    draw_set_color(c_black);
    draw_rectangle(0, 0, gui_w, gui_h, false);

    draw_set_alpha(1);
    draw_set_color(team_colors[winner_team]);
    draw_rectangle(0, gui_h / 2 - 60, gui_w, gui_h / 2 + 60, false);

    draw_set_color(c_white);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text(cx, gui_h / 2 - 20, "TEAM " + team_names[winner_team] + " WINS!");
    var is_victory = (instance_exists(my_tank) && winner_team == my_tank.team);
    draw_text(cx, gui_h / 2 + 20, is_victory ? "VICTORY!" : "DEFEAT");
}

// Reset draw state
draw_set_alpha(1);
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
