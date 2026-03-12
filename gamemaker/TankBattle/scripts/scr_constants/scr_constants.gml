// =============================================================================
// Game Constants - matching server values
// =============================================================================

// Scale: pixels per game unit
#macro UNIT_SIZE 32

// Map
#macro MAP_SIZE 48
#macro MAP_PIXELS (MAP_SIZE * UNIT_SIZE)

// Tank
#macro TANK_SPEED 0.3
#macro TANK_RANGE 16
#macro TANK_RADIUS 0.75

// Bullet
#macro BULLET_SPEED 0.7
#macro BULLET_RADIUS 0.25
#macro BULLET_DAMAGE 3

// Pickable
#macro PICKABLE_RADIUS 0.3

// Timing (ms)
#macro RESPAWN_TIME 5000
#macro INVULN_TIME 2000
#macro RELOAD_TIME 400

// Interpolation rates (per frame)
#macro LERP_POSITION 0.2
#macro LERP_BODY_ROTATION 0.15
#macro LERP_TURRET_ROTATION 0.25
#macro LERP_CAMERA 0.08
#macro LERP_BULLET 0.4

// Camera
#macro CAMERA_VIEW_UNITS 22
#macro CAMERA_VIEW_PIXELS (CAMERA_VIEW_UNITS * UNIT_SIZE)

// Team colors
#macro TEAM_COLOR_RED     $ff4444ff
#macro TEAM_COLOR_BLUE    $ffff8844
#macro TEAM_COLOR_GREEN   $ff44ff44
#macro TEAM_COLOR_YELLOW  $ff44ffff

// Win score
#macro WIN_SCORE 10

// Level blocks: [centerX, centerY, width, height]
// Defined in scr_utils as a function
