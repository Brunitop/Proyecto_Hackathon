// obj_enemy_goat - Create Event

// Wait until global.TILE_SIZE is defined
if (!variable_global_exists("TILE_SIZE")) {
    global.TILE_SIZE = 64; // Default value, or show error
}
//initialize position in grid
xpos = x div global.TILE_SIZE;
ypos = y div global.TILE_SIZE;
target_x = xpos;
target_y = ypos;

// Initialize movement state
is_moving = false;
move_x = 0;
move_y = 0;

MOVE_TIME = 0.20;  // Slightly faster than the player (player's MOVE_TIME is 0.25)

// Timing for movement
move_start_time = 0;

//node and patrol area
node_count = instance_number(obj_node);
node_timer = 0;
patrol_radius = 320;
is_in_patrol_area = false;
node_x = 0;
node_y = 0;

//random variables for patrol behavior
patrol_time = 0;
random_dir = 0;
patrol_pause_timer = 0;
patrol_pause_buffer = 0;
rest_time = 0;

//position
target_x_pixel = 0;
target_y_pixel = 0;

//state, either "patrolling" or "resting"
rest_time = 10; // Set rest duration
state = "resting";

//health
enemy_health = 3;