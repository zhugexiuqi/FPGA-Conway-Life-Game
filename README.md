# FPGA-Conway-Life-Game
this project builds a conway life game on fpga, diaplay through 480*640 VGA screen. your VGA driver module has to supply pclk, vsync, x, y to this module.

the checkboard's scale is 9* 12.

set the initial checkerboard state by change the code in the 'init_map'initial block in the life_game module.

for example, if you want to create a simplest osc, substitute with following code:

    game_state_init[5][6] = 1;
    game_state_init[5][7] = 1;
    game_state_init[5][8] = 1;

the board has periodic boundary condition, which means if a block is moving right, when its x_position is 8, it will goes to 0.(remember the checkerboard has 9 col, 0-8)
