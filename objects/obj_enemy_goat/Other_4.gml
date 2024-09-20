// obj_enemy_goat - room_start Event

// Ensure global.TILE_SIZE has been initialized
xpos = x div global.TILE_SIZE;
ypos = y div global.TILE_SIZE;

// Update tile occupancy for the enemy
ds_grid_set(global.occupancy_grid, xpos, ypos, id); // 'id' marks this entity as occupying the current tile