// obj_enemy_goat - Step Event

if (state == "patrolling") {
	node_timer -= 1;
	patrol_time -= 1;
	patrol_pause_timer -= 1;
	patrol_pause_buffer = irandom_range(0, 30);
	
	//Change node
	if(node_timer <= 0){
		var node_count = instance_number(obj_node);

		if (node_count > 0) {
		    var random_index = irandom_range(0, node_count - 1);
			var target_node = instance_find(obj_node, random_index);

		    // Assign target coordinates from the selected node
		    target_x = target_node.x;
		    target_y = target_node.y;
			
			
			// Check if the enemy is inside the patrol area
            var distance_to_node = point_distance(x, y, target_x, target_y);
            if (distance_to_node > patrol_radius) {
                is_in_patrol_area = false; // Outside of patrol area
            } else {
                is_in_patrol_area = true;  // Within patrol area
            }
			
			//Movement check..................................................
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

			        // Update tile occupancy for the enemy
			        ds_grid_set(global.occupancy_grid, target_x, target_y, id); // 'id' marks this entity as occupying the tile
			        ds_grid_set(global.occupancy_grid, xpos, ypos, 0); // Mark the old tile as unoccupied
			    } else {
			        // Smooth movement calculation
			        x = lerp(x, target_x_pixel, progress);
			        y = lerp(y, target_y_pixel, progress);
				}    
		    } else {
				
				// Handle pausing
                if (patrol_pause_timer <= 0 && patrol_pause_buffer >= 23) {
	                patrol_pause_timer = irandom_range(100, 200);
	                move_x = 0;
	                move_y = 0;
                }
				
				
				if (patrol_pause_timer <= 0) {
					if (!is_in_patrol_area) {
	                    // Move towards the patrol node in grid units
	                    var direction_to_node = point_direction(x, y, target_x * global.TILE_SIZE, target_y * global.TILE_SIZE);
	                    //move_x = round(lengthdir_x(1, direction_to_node)); // Move by one grid unit
	                    move_y = round(lengthdir_y(1, direction_to_node));

	                    // Update position on the grid
	                    x += move_x * global.TILE_SIZE;
	                    y += move_y * global.TILE_SIZE;

	                    // Snap to grid
	                    x = floor(x / global.TILE_SIZE) * global.TILE_SIZE;
	                    y = floor(y / global.TILE_SIZE) * global.TILE_SIZE;

	                    // Check if the enemy is now inside the patrol area
	                    if (point_distance(x, y, target_x * global.TILE_SIZE, target_y * global.TILE_SIZE) <= patrol_radius) {
	                        is_in_patrol_area = true;
	                    }
					
						// Set the movement to active
						is_moving = true;
					} else {
						// Move randomly within patrol area in grid units if not on pause
                        random_dir = irandom_range(0, 3);
                        switch(random_dir){
							case 0:
								move_x = 1;
								move_y = 0;
								break;
							case 1:
								move_x = -1;
								move_y = 0;
								break;
							case 2:
								move_x = 0;
								move_y = 1;
								break;
							case 3:
								move_x = 0;
								move_y = -1;
								break;
						}

                        // Verify that you do not exit the patrol area
                        var next_x = xpos + move_x * global.TILE_SIZE;
                        var next_y = ypos + move_y * global.TILE_SIZE;

                        if (point_distance(next_x, next_y, target_x * global.TILE_SIZE, target_y * global.TILE_SIZE) <= patrol_radius) {
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
                } //Logic for paused state and movement
		    }//Movement check
		}//Verify if nodes exist
	}//Change node
	
    // Transition to resting state if patrol time is finished
    if (patrol_time <= 0) {
        state = "resting";
        rest_time = irandom_range(200, 500); // Set rest duration
    }
} else if (state == "resting") {
    rest_time -= 1;
	
	//transition to patrolling state if resting time is finished
    if (rest_time <= 0) {
        state = "patrolling";
        node_timer = 0;
		patrol_time = irandom_range(120, 1500);
    }
}

show_debug_message("Posicion x: " + string(x));
show_debug_message("Posicion y: " + string(y));
show_debug_message("Move_x: " + string(move_x));
show_debug_message("Move_y: " + string(move_y));
show_debug_message("Within patrol area: " + string(is_in_patrol_area));