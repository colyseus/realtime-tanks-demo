// =============================================================================
// obj_tank - Create Event
// =============================================================================

// Server state
session_id = "";
team = 0;
tank_name = "guest";
hp = 10;
shield = 0;
dead = false;
killer = "";
score = 0;

// Server angle (degrees, server convention: 0=south, 90=east)
server_angle = 0;

// Interpolation targets (in pixels)
target_x = x;
target_y = y;

// Body rotation (visual, follows movement direction)
body_angle = 0;       // image_angle for the body sprite
target_body_angle = 0;

// Turret rotation (visual, follows aim direction)
turret_angle = 0;     // image_angle for the barrel sprite
target_turret_angle = 0;

// Previous position for computing movement direction
prev_x = x;
prev_y = y;

// Visual effects
blink_timer = 0;
visible_toggle = true;

// Shield visual
shield_alpha = 0;
shield_pulse = 0;

// Sprite references (set based on team)
body_sprite = spr_tank_body_red;
barrel_sprite = spr_barrel_red;

// Death/explosion
explosion_timer = 0;
explosion_active = false;

// Smoke trail particles
smoke_timer = 0;
