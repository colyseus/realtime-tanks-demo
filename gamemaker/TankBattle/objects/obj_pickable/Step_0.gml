// =============================================================================
// obj_pickable - Step Event
// =============================================================================

// Bob up and down
bob_offset += 0.05;
y = base_y + sin(bob_offset) * 4;

// Spin
spin_angle += 2;
if (spin_angle >= 360) spin_angle -= 360;
