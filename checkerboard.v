module checkerboard(

	//input sys_clk,
	input vga_clk , 
	input sys_rst_n , 
	input [9:0] pix_x , 
	input [9:0] pix_y , 
	input vsync,
	output reg [15:0] pix_data 

);
parameter white = 16'b1111111111111111;
parameter black = 16'b0;
parameter red = 16'hF800;
parameter blue = 16'h001F; //蓝色

integer i,j;

wire [107:0] game_state_out;

wire [4:0] x, y;
assign x = (pix_x - 1)/ 50;
assign y = pix_y / 50;

reg [5:0] modx, mody;
always @(posedge vga_clk) begin
    modx <= pix_x % 50;
    mody <= pix_y % 50;
end


always@(posedge vga_clk or negedge sys_rst_n)begin
	if(!sys_rst_n)
		pix_data <= 0;
	else if(pix_x < 604 && pix_y < 453 )begin
		if(modx < 3)				//边框绘制
			pix_data <= white;
		else if(mody < 3)
			pix_data <= white;
		else	begin 				//方格内赋值
			for(i=0; i<108; i=i+1)begin
				for(j=0; j<16 ;j=j+1)begin
					if(game_state_out[(y*12)+x] == 1)
						pix_data <= white;
					else
						pix_data <= black;
				end
			end
		end
	end else				//区域外，涂成黑色
		pix_data <= black;
end


life_game u_life_game(
	.sys_rst_n(sys_rst_n),
	.vga_clk(vga_clk),
	.vsync(vsync),
	.game_state_out(game_state_out)
);

endmodule