// obj_controller - Room Start Event

global.tick_time = 0.01; // Set the tick time to match the player's move time
global.tick_timer = 0;   // Initialize the tick timer
global_tick = 0;         // Initialize the global tick count

// Initialize any other necessary global variables here
if (!ds_exists(global.occupancy_grid, ds_type_grid)) {
    global.occupancy_grid = ds_grid_create(grid_width, grid_height);
}