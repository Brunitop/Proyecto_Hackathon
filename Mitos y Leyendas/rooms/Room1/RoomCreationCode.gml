// init_globals script

global.TILE_SIZE = 64;
global.occupancy_grid = ds_grid_create(12800, 12800);
ds_grid_set_region(global.occupancy_grid, 0, 0, 99, 99, 0);