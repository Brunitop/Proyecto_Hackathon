// obj_controller - Step Event

// Initialize global variables if they don't exist
if (!variable_global_exists("global_tick")) {
    global.global_tick = 0;
	global.tick_time = 2.05;
}


global.global_tick += 0.05;
show_debug_message("Tick: " + string(global.global_tick))

// If enough time has passed, increment the global tick
if (global.global_tick >= global.tick_time) {
    global.global_tick = 0;
}