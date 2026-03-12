// =============================================================================
// obj_game - Clean Up Event
// =============================================================================

if (global.net_room != 0) {
    colyseus_room_leave(global.net_room);
    colyseus_room_free(global.net_room);
}

camera_destroy(camera);
