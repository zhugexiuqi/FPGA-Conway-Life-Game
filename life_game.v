module life_game(
	input vga_clk,
	input sys_rst_n,
	input vsync,
	output reg [107:0] game_state_out, //12*9 = 108个格子
	output reg [2:0] color
);

integer i, j, a,b,x,y;

reg game_state_init [8:0][11:0] ; //用于存储初始棋盘状态。在initial里配置。省的用ROM不方便改
reg game_state [8:0][11:0] ;  //用于驱动更新每一帧的棋盘状态

reg [3:0] survive [8:0][11:0]; //用于存储生命游戏每个点的生存状态。即周围生存着的点的个数

wire sec_clk;

initial begin : init_map
    for (i=0; i<9; i=i+1) begin
        for (j=0; j<12; j=j+1) begin
            game_state_init[i][j] = 0;
        end
    end
	 
	 //振荡器
    
    game_state_init[5][6] = 1;
    game_state_init[5][7] = 1;
    game_state_init[5][8] = 1;
	 
	 
	 
	 //滑翔机
	 /*
	 game_state_init[1][2] = 1;
	 game_state_init[1][5] = 1;
	 game_state_init[2][1] = 1;
	 game_state_init[3][1] = 1;
	 game_state_init[3][5] = 1;
	 game_state_init[4][1] = 1;
	 game_state_init[4][2] = 1;
	 game_state_init[4][3] = 1;
	 game_state_init[4][4] = 1;
	 */
end

////////////////////////更新输出
always@(posedge vga_clk)begin  
		for(i=0 ; i<108; i=i+1)begin
			game_state_out [i] <= game_state[i/12][i%12]; 
		end
end

/////////////////////////每秒更新一次游戏状态

////////sec_clk 边沿检测电路
reg delay_sec_clk;

always@(posedge vsync or negedge sys_rst_n)begin 
	if(!sys_rst_n)
		delay_sec_clk <= 0;
	else
		delay_sec_clk <= sec_clk;
end

wire sec_clk_edge;
assign sec_clk_edge = delay_sec_clk ^ sec_clk;

////////流水线节拍控制计数器
reg [5:0] cnt;
always@(posedge vsync or negedge sys_rst_n)begin
	if(!sys_rst_n)
		cnt <= 0;
	else if(sec_clk_edge && sec_clk == 1)
		cnt <= 0;
	else if(cnt < 16)
		cnt <= cnt + 1;
end

reg copy_state [8:0][11:0]; //sec_clk到来后，先拷贝当前棋盘状态避免交叉赋值时序混乱

always@(posedge vga_clk or negedge sys_rst_n)begin
	if(!sys_rst_n)begin 			//初始状态
		for (a=0; a<9; a=a+1)begin
			for (b=0; b<12; b=b+1)begin
				game_state[a][b] <= game_state_init[a][b];
         end
      end
		
		for (a=0; a<9; a=a+1)begin //rst拷贝棋盘也要清零
			for (b=0; b<12; b=b+1)begin
				copy_state[a][b] <= 0;
         end
      end
	end
	else begin  					//游戏状态更新逻辑 //要写新的游戏程序，改这个else begin分支即可
		
		
		////////////////康威生命游戏！
		if(cnt == 2)begin					//先拷贝当前棋盘
			for (a=0; a<9; a=a+1)begin 
				for (b=0; b<12; b=b+1)begin
					copy_state[a][b] <= game_state[a][b];
				end
			end
		end
		
		
		if(cnt == 10)begin
			for(y=0; y<9 ; y=y+1)begin    //更新棋盘，根据统计的生存状态和生存演化规则为下一状态赋值
				for(x=0 ; x<12 ;x=x+1)begin
					if(game_state[y][x] == 0)begin //先处理某个位置本来没有生存点的情况。									
						if(survive[y][x] == 3)					//此时，当且仅当survive==3，周围刚好3个点时，该点生成新的点。
							game_state[y][x] <= 1;
						else
							game_state[y][x] <= 0;
					end
					else begin    //处理某个位置已经有生存点的状况
						if(survive[y][x] > 3)	//周围存在多于3个点，消亡
							game_state[y][x] <= 0;
						else if(survive[y][x] < 2) //周围存在少于2个点，消亡
							game_state[y][x] <= 0;
						else								//周围点数2-3，可以继续存在
							game_state[y][x] <= 1;
					end
				end
			end
		end
		
		
		if(cnt == 6)begin
			for(i=0 ; i<9 ; i=i+1)begin    //更新统计生存状态，即每个点周围点个数
				for(j=0 ; j<12; j=j+1)begin	// (x+4)%5 实现循环减一，避免索引出现负数
					survive[i][j] <=   copy_state[(i+8)%9][(j+11)%12] + copy_state[(i+1)%9][(j+1)%12]//4个角点
										+	copy_state[(i+8)%9][(j+1)%12] + copy_state[(i+1)%9][(j+11)%12]
										+  copy_state[(i+8)%9][j] + copy_state[(i+1)%9][j]
										+  copy_state[i][(j+11)%12] + copy_state[i][(j+1)%12];
				end
			end
		end
		
	end
end

always@(posedge vga_clk or negedge sys_rst_n)begin   //颜色计数器
	if(!sys_rst_n)
		color <= 0;
	else if(color == 6)
		color <= 0;
	else if(sec_clk_edge & sec_clk)
		color <= color + 1;
end

second_clk u_second_clk(   //获得秒信号
	.sys_rst_n(sys_rst_n),
	.vsync(vsync),
	.sec_clk(sec_clk)
);

endmodule
