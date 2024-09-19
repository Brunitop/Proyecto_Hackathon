// obj_player - Create Event

// Wait until global.TILE_SIZE is defined
if (!variable_global_exists("TILE_SIZE")) {
    global.TILE_SIZE = 64; // Default value, or show error
}

xpos = x div global.TILE_SIZE;
ypos = y div global.TILE_SIZE;

// Movement state
is_moving = false;  // Tracks if the player is currently moving
move_x = 0;         // Movement direction in the X-axis
move_y = 0;         // Movement direction in the Y-axis

// Timing for movement
move_start_time = 0;

// Determines the movement speed of the player
MOVE_TIME = 0.25;   