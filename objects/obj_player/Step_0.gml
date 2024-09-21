// obj_player - Step event (extended)

if (is_moving) {
    var timer = (current_time - move_start_time) / 1000;
    var progress = timer / MOVE_TIME;

	// Check if the target tile is occupied by another entity
    var occupant = ds_grid_get(global.occupancy_grid, target_x, target_y);
	attempt = ds_grid_get(global.attempt_grid, target_x, target_y);
	
	show_debug_message("Occupant: " + string(occupant));
	show_debug_message("Attempt: " + string(attempt));
	show_debug_message("ID: " + string(id));
	
    if (occupant == 0 && attempt == 1) {
		if (progress >= 1) {
			// Movement finished
	        // Snap to the target position when movement is complete
	        x = target_x_pixel;
	        y = target_y_pixel;
			ds_grid_set(global.occupancy_grid, xpos, ypos, 0); // Mark the old tile as unoccupied
			ds_grid_set(global.occupancy_grid, target_x, target_y, id); // 'id' marks this entity as occupying the tile
	        xpos = target_x;
	        ypos = target_y;
	        is_moving = false;
	        move_x = 0;
	        move_y = 0; 
			ds_grid_set(global.attempt_grid, xpos, ypos, 0); // Mark the attempt as finished
	    } else {
			//Movement in progress
	        // Smooth movement calculation
	        x = lerp(x, target_x_pixel, progress);
	        y = lerp(y, target_y_pixel, progress);
	    }
	} else{
		// Finish attempt even if the attempt is unsuccesful
		ds_grid_set(global.attempt_grid, target_x, target_y, 0); // Mark the attempt as finished
		is_moving = false;
	}
	//end of portion for is_moving = true
} else {
	
	// Check for tick and whether the enemy is currently moving
	if (global.global_tick == 1) {
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
			
			// Set number of attempts
			attempt = ds_grid_get(global.attempt_grid, target_x, target_y);
	        // Mark the target tile as occupied (since the player is moving away)
	        ds_grid_set(global.attempt_grid, target_x, target_y, attempt + 1); // Mark tile as occupied by the enemy

	        // Set the movement to active
	        is_moving = true;
	    }
	}
}