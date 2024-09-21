// obj_enemy_goat - Step Event

if (state == "patrolling") {
	node_timer -= 1;
	patrol_time -= 1;
	patrol_pause_timer -= 1;
	patrol_pause_buffer = irandom_range(0, 60);
	
	// Check for nodes in the room
	if (node_count > 0) {
		
		////Choose random node
		if(node_timer <= 0){	
			node_timer = irandom_range(1000, 1500);
			var random_index = irandom_range(0, node_count - 1);
			var target_node = instance_find(obj_node, random_index);
			
			// Assign target coordinates from the selected node
			node_x = target_node.x;
			node_y = target_node.y;
		}// Always have a random node chosen before moving
		
		// Calculate distance to node
		var distance_to_node_x = node_x - x;
	    var distance_to_node_y = node_y - y;
		// Check if the enemy is inside the patrol area
		if (abs(distance_to_node_x) > patrol_radius || abs(distance_to_node_y) > patrol_radius) {
			is_in_patrol_area = false; // Outside of patrol area
		} else {
			is_in_patrol_area = true;  // Within patrol area
		}
		
		//Movement check..................................................
		if (is_moving) {
		    var timer = (current_time - move_start_time) / 1000;
		    var progress = timer / MOVE_TIME;

			// Check if the target tile is occupied by another entity
		    var occupant = ds_grid_get(global.occupancy_grid, target_x, target_y);
			attempt = ds_grid_get(global.attempt_grid, target_x, target_y);
	
			//show_debug_message("Occupant: " + string(occupant));
			//show_debug_message("Attempt: " + string(attempt));
			//show_debug_message("ID: " + string(id));
	
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
			//in the case of is_moving = false, calculate movement
			
			// Check for tick and whether the enemy is currently moving
		    if (global.global_tick == 1) {
				// Handle pausing
	            if (patrol_pause_timer <= 0 && patrol_pause_buffer >= 60) {
		            patrol_pause_timer = irandom_range(20, 40);
		            move_x = 0;
		            move_y = 0;
	            }
				
				//if not paused, perform movement calculations
				if (patrol_pause_timer <= 0) {
					//logic for patrolling movement in and out of patrol area
					if (!is_in_patrol_area) {
		                // Move towards the patrol node in grid units
					
						if(abs(distance_to_node_x) > abs(distance_to_node_y)){
							move_x = distance_to_node_x/abs(distance_to_node_x);
							move_y = 0;
						} else if (abs(distance_to_node_x) < abs(distance_to_node_y)) {
							move_x = 0;
							move_y = distance_to_node_y/abs(distance_to_node_y);
						} else {
							move_x = distance_to_node_x/abs(distance_to_node_x);
							move_y = 0;
						}

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
					} else {
						// When the enemy is within the patrol area
						// Move randomly in grid units
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

	                    // Calculate the new grid position
						target_x = xpos + move_x;
						target_y = ypos + move_y;

						// Convert to pixel coordinates
						target_x_pixel = target_x * global.TILE_SIZE;
						target_y_pixel = target_y * global.TILE_SIZE;

						// Check to see if it doesn't fall outside the patrol range
						if (point_distance(target_x_pixel, target_y_pixel, node_x, node_y) < patrol_radius) {
                            
						    // Check if target tile is occupied
						    if (ds_grid_get(global.occupancy_grid, target_x, target_y) != 0) {
						        is_moving = false; // Tile is occupied, cancel movement
						        move_x = 0;
						        move_y = 0;
								return;
						    }

							// All conditions for movement are met
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
				} //Logic for paused state and movement calculation		
		    }		
		}//Action/Movement check
	}//Verify if nodes exist
    // Transition to resting state if patrol time is finished
    if (patrol_time <= 0) {
        state = "resting";
        rest_time = irandom_range(240, 600); // Set rest duration
    }
} else if (state == "resting") {
    rest_time -= 1;
	
	// Continue movement from previous patrolling phase if there is any left 
	if (is_moving) {
		var timer = (current_time - move_start_time) / 1000;
		var progress = timer / MOVE_TIME;

		// Check if the target tile is occupied by another entity
		var occupant = ds_grid_get(global.occupancy_grid, target_x, target_y);
		attempt = ds_grid_get(global.attempt_grid, target_x, target_y);
	
		//show_debug_message("Occupant: " + string(occupant));
		//show_debug_message("Attempt: " + string(attempt));
		//show_debug_message("Attempt: " + string(id));
	
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
	}

	//transition to patrolling state if resting time is finished
    if (rest_time <= 0) {
        state = "patrolling";
		node_timer = 0;
		patrol_time = irandom_range(240, 3000);
    }
}

//show_debug_message("Position x: " + string(x) + ", Position y: " + string(y));
//show_debug_message("State: " + string(state) + ", Patrol Pause Timer: " + string(patrol_pause_timer));
//show_debug_message("Within patrol area: " + string(is_in_patrol_area));
//show_debug_message("x: " + string(x) + ", y: " + string(y));