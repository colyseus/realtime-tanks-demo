// =============================================================================
// Utility Functions
// =============================================================================

/// @func server_angle_to_image_angle(server_angle)
/// @desc Converts server angle (degrees, 0=south, 90=east) to GameMaker image_angle
///       Kenney sprites face UP by default (image_angle=0 → up)
/// @param {real} server_angle - Angle in degrees from server
/// @returns {real} image_angle for drawing
function server_angle_to_image_angle(server_angle) {
    return server_angle + 180;
}

/// @func client_aim_angle(tank_wx, tank_wy, mouse_wx, mouse_wy)
/// @desc Compute server-format angle from tank to mouse (in world pixels)
/// @returns {real} Angle in degrees (server convention: 0=south, 90=east)
function client_aim_angle(tank_wx, tank_wy, mouse_wx, mouse_wy) {
    var dx = mouse_wx - tank_wx;
    var dy = mouse_wy - tank_wy;
    var a = radtodeg(arctan2(dx, dy));
    // Normalize to [0, 360) to match server/Three.js convention
    return ((a mod 360) + 360) mod 360;
}

/// @func game_to_pixel(val)
/// @desc Convert game units to pixels
function game_to_pixel(val) {
    return val * UNIT_SIZE;
}

/// @func pixel_to_game(val)
/// @desc Convert pixels to game units
function pixel_to_game(val) {
    return val / UNIT_SIZE;
}

/// @func lerp_angle(current, target, amount)
/// @desc Lerp between angles handling wrapping
function lerp_angle(current, target, amount) {
    // Normalize diff to [-180, 180] without GML's signed-mod issue
    var diff = target - current;
    diff = diff - floor(diff / 360 + 0.5) * 360;
    return current + diff * amount;
}

/// @func get_team_color(team_index)
/// @desc Returns the color for a team
function get_team_color(team_index) {
    switch (team_index) {
        case 0: return c_red;
        case 1: return #4488ff;
        case 2: return c_lime;
        case 3: return c_yellow;
        default: return c_white;
    }
}

/// @func get_team_name(team_index)
function get_team_name(team_index) {
    switch (team_index) {
        case 0: return "RED";
        case 1: return "BLUE";
        case 2: return "GREEN";
        case 3: return "YELLOW";
        default: return "???";
    }
}

/// @func get_level_blocks()
/// @desc Returns array of level block definitions [centerX, centerY, width, height]
function get_level_blocks() {
    // Same level data as server (BattleRoom.ts LEVEL)
    return [
        [13.5, 2, 1, 4],
        [13.5, 12, 1, 2],
        [12.5, 13.5, 3, 1],
        [2, 13.5, 4, 1],
        [11.5, 15, 1, 2],
        [11.5, 23.5, 1, 5],
        [10, 26.5, 4, 1],
        [6, 26.5, 4, 1],
        [2, 34.5, 4, 1],
        [12.5, 34.5, 3, 1],
        [13.5, 36, 1, 2],
        [15, 36.5, 2, 1],
        [13.5, 46, 1, 4],
        [23.5, 36.5, 5, 1],
        [26.5, 38, 1, 4],
        [26.5, 42, 1, 4],
        [34.5, 46, 1, 4],
        [34.5, 36, 1, 2],
        [35.5, 34.5, 3, 1],
        [36.5, 33, 1, 2],
        [46, 34.5, 4, 1],
        [36.5, 24.5, 1, 5],
        [38, 21.5, 4, 1],
        [42, 21.5, 4, 1],
        [46, 13.5, 4, 1],
        [35.5, 13.5, 3, 1],
        [34.5, 12, 1, 2],
        [33, 11.5, 2, 1],
        [34.5, 2, 1, 4],
        [24.5, 11.5, 5, 1],
        [21.5, 10, 1, 4],
        [21.5, 6, 1, 4],
        // center
        [18.5, 22, 1, 6],
        [19, 18.5, 2, 1],
        [26, 18.5, 6, 1],
        [29.5, 19, 1, 2],
        [29.5, 26, 1, 6],
        [29, 29.5, 2, 1],
        [22, 29.5, 6, 1],
        [18.5, 29, 1, 2],
    ];
}
