// obj_controller - Step Event

// Initialize global variables if they don't exist
if (!variable_global_exists("global_tick")) {
    global.global_tick = 0;
    global.tick_time = 0.01;    // Time duration for one tick in seconds
    global.last_tick_time = current_time / 1000;  // Store time in seconds
}

// Calculate time elapsed since the last tick
var current_time_seconds = current_time / 1000;
var time_elapsed = current_time_seconds - global.last_tick_time;

// If enough time has passed, increment the global tick
if (time_elapsed >= global.tick_time) {
    global.global_tick += 1;                // Increment tick
    global.last_tick_time = current_time_seconds;  // Update last tick time

    // Optionally reset the tick count after a certain number of ticks
    if (global.global_tick > 3) {
        global.global_tick = 0;  // Reset after 4 ticks (customize this as needed)
    }
}