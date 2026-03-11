# FPGA-Conway-Life-Game
this project builds a conway life game on fpga, diaplay through 480*640 VGA screen. your VGA driver module has to supply pclk, vsync, x, y to this module.

the checkboard's scale is 9* 12.

set the initial checkerboard state by change the code in the 'init_map'initial block in the life_game module.

for example, if you want to create a simplest osc, substitute with following code:

    game_state_init[5][6] = 1;
    game_state_init[5][7] = 1;
    game_state_init[5][8] = 1;

the board has periodic boundary condition, which means if a block is moving right, when its x_position is 8, it will goes to 0.(remember the checkerboard has 9 col, 0-8)

# block color changes per s
checkerboard_1.v

the color of the block changes periodically, the order is

    case(color)
		0 : pix_data <= red;
		1 : pix_data <= orange;
		2 : pix_data <= yellow;
		3 : pix_data <= green;
		4 : pix_data <= cyan;
		5 : pix_data <= blue;
		6 : pix_data <= purple;
		default : pix_data <= black;
	endcase

# block with dynamic gradient color
checkboar_2.v
the colorgradient module generates dynaic gradient color.

the triangle waveform scan through the screen in time, the amplitude of the waveform decideds the intensity of R, G, B.

<img width="426" height="320" alt="1" src="https://github.com/user-attachments/assets/47a59de8-b304-4bcf-85f9-81fd8395f8e9" />
<img width="426" height="320" alt="2" src="https://github.com/user-attachments/assets/b0095afb-c989-4309-8823-66f214868ef7" />
<img width="426" height="320" alt="3" src="https://github.com/user-attachments/assets/a918329f-9b03-490d-b1f1-764ffb05769b" />
<img width="426" height="320" alt="4" src="https://github.com/user-attachments/assets/6861a707-738e-43e9-b07d-5331288b5e79" />




