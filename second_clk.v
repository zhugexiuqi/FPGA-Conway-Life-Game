module second_clk(
	input sys_rst_n,
	input vsync,
	output reg sec_clk
);

reg [10:0] cnt;

always@(posedge vsync or negedge sys_rst_n)begin
	if(!sys_rst_n)begin
		cnt <= 0;
		sec_clk <= 0;
	end
	else if(cnt == 29)begin
		cnt <=0;
		sec_clk <= ~sec_clk;
	end
	else
		cnt <= cnt + 1;
end

endmodule