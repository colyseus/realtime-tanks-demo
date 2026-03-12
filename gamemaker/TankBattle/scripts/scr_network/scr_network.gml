// =============================================================================
// Network - Colyseus SDK Integration
// =============================================================================

/// @func network_send_move(dir_x, dir_y)
function network_send_move(dir_x, dir_y) {
    if (!global.net_connected) return;
    colyseus_send(global.net_room, "move", { x: dir_x, y: dir_y });
}

/// @func network_send_target(angle_degrees)
function network_send_target(angle_degrees) {
    if (!global.net_connected) return;
    colyseus_send(global.net_room, "target", round(angle_degrees));
}

/// @func network_send_shoot(shooting)
function network_send_shoot(shooting) {
    if (!global.net_connected) return;
    colyseus_send(global.net_room, "shoot", shooting);
}

/// @func network_send_name(player_name)
function network_send_name(player_name) {
    if (!global.net_connected) return;
    colyseus_send(global.net_room, "name", player_name);
}

/// @func set_tank_team_sprites(tank, team)
/// @desc Assign body + barrel sprites based on team index
function set_tank_team_sprites(tank, team) {
    switch (team) {
        case 0:
            tank.body_sprite = spr_tank_body_red;
            tank.barrel_sprite = spr_barrel_red;
            break;
        case 1:
            tank.body_sprite = spr_tank_body_blue;
            tank.barrel_sprite = spr_barrel_blue;
            break;
        case 2:
            tank.body_sprite = spr_tank_body_green;
            tank.barrel_sprite = spr_barrel_green;
            break;
        case 3:
            tank.body_sprite = spr_tank_body_yellow;
            tank.barrel_sprite = spr_barrel_yellow;
            break;
    }
}
