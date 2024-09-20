// init_globals script

global.TILE_SIZE = 64;
global.occupancy_grid = ds_grid_create(2560, 1920);
ds_grid_set_region(global.occupancy_grid, 0, 0, 99, 99, 0);

global.attempt_grid = ds_grid_create(2560, 1920); // Initialize attempt grid
ds_grid_set_region(global.attempt_grid, 0, 0, 99, 99, 0); // Optionally set to 0