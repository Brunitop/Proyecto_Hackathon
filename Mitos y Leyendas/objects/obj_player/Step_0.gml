// obj_player - Step event (extended)

if (is_moving) {
    var timer = (current_time - move_start_time) / 1000;
    var progress = timer / MOVE_TIME;

    if (progress >= 1) {
        // Snap to the target position when movement is complete
        x = target_x_pixel;
        y = target_y_pixel;
        xpos = target_x;
        ypos = target_y;
        is_moving = false;
        move_x = 0;
        move_y = 0;

        // Check if the target tile is occupied by another entity
        var occupant = ds_grid_get(global.occupancy_grid, target_x, target_y);
        if (occupant != 0) {
            var other_entity = occupant; // occupant is the instance ID
            if (instance_exists(other_entity)) {
                // Move the other entity back to its original position
                other_entity.x = other_entity.original_x;
                other_entity.y = other_entity.original_y;
                ds_grid_set(global.occupancy_grid, other_entity.original_x div global.TILE_SIZE, other_entity.original_y div global.TILE_SIZE, other_entity); // Mark original tile as occupied
                ds_grid_set(global.occupancy_grid, target_x, target_y, 0); // Mark target tile as unoccupied
            }
        }

        // Update tile occupancy for the player
        ds_grid_set(global.occupancy_grid, target_x, target_y, id); // 'id' marks this entity as occupying the tile
        ds_grid_set(global.occupancy_grid, xpos, ypos, 0); // Mark the old tile as unoccupied
    } else {
        // Smooth movement calculation
        x = lerp(x, target_x_pixel, progress);
        y = lerp(y, target_y_pixel, progress);
    }
} else {
    // Check for WASD input and set movement direction
    if (keyboard_check(vk_right)) {
        move_x = 1;
        move_y = 0;
    } else if (keyboard_check(vk_left)) {
        move_x = -1;
        move_y = 0;
    } else if (keyboard_check(vk_up)) {
        move_x = 0;
        move_y = -1;
    } else if (keyboard_check(vk_down)) {
        move_x = 0;
        move_y = 1;
    } else {
        move_x = 0;
        move_y = 0;
    }

    if (move_x != 0 || move_y != 0) {
        // Calculate the new grid position
        target_x = xpos + move_x;
        target_y = ypos + move_y;

        // Check if target tile is occupied
        if (ds_grid_get(global.occupancy_grid, target_x, target_y) != 0) {
            is_moving = false; // Tile is occupied, cancel movement
            move_x = 0;
            move_y = 0;
            return;
        }

        // Convert to pixel coordinates
        target_x_pixel = target_x * global.TILE_SIZE;
        target_y_pixel = target_y * global.TILE_SIZE;

        // Set start time for the movement
        move_start_time = current_time;

        // Mark the current tile as unoccupied (since the player is moving away)
        ds_grid_set(global.occupancy_grid, xpos, ypos, 0);

        // Set the movement to active
        is_moving = true;
    }
}
