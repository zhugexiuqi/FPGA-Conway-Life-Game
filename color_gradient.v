module color_gradient(

	input sys_clk,
	input vga_clk , 
	input sys_rst_n , 
	input [9:0] pix_x , 
	input [9:0] pix_y , 
	input vsync,
	output reg [15:0] moving_color 

);

parameter H_VALID = 10'd640 , //行有效数据
V_VALID = 10'd480 ; //列有效数据




always@(posedge vga_clk or negedge sys_rst_n)begin
	if(!sys_rst_n)
		moving_color <= 0;
	else begin
		//moving_color[15:11] <= (10*5'd31 - (pix_y*4'd10)/16)/10; 
		//moving_color[4:0] <= (pix_y * 4'd10)/160;
		//moving_color[10:5] <= pix_x/10;
		
		moving_color[15:11] <= q1;
		moving_color[10:5] <= q2;
		moving_color[4:0] <= q3;
		
	end
end

wire [4:0] q1,q2,q3;

wire [8:0] address1;
wire [8:0] address2;
wire [8:0] address3;

reg [8:0] t;

assign address1 = pix_y[8:0] - t*2;
assign address2 = pix_x[8:0] - t;
assign address3 =  pix_y[8:0] - t  + 200;


always@(posedge vsync or negedge sys_rst_n)begin
	if(!sys_rst_n)
		t <= 0;
	else
		t <= t + 4;
end

rom_ip	rom_ip_inst1(
	.address (address1),
	.clock (sys_clk),
	.q (q1)
);

rom_ip	rom_ip_inst2(
	.address (address2),
	.clock (sys_clk),
	.q (q2)
);

rom_ip	rom_ip_inst3(
	.address ( address3 ),
	.clock (sys_clk),
	.q (q3)
);

endmodule