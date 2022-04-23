`timescale 1ns / 1ps

module block_controller(
	input clk, //this clock must be a slow enough clock to view the changing positions of the objects
	input bright,
	input rst,
	input up, input down, input left, input right,
	input [9:0] hCount, vCount,
	input Player1,
	output reg [11:0] rgb,
	output reg [11:0] background,
	output q_Init, q_Wait1press, q_Wait1release, q_Wait2press, q_Wait2release, q_Win, q_Draw
   );

	reg [9:0] xpos, ypos;
	reg [3:0] pointer;
	reg [3:0] moves;
	reg [8:0] fstore;
	reg [8:0] sstore;
	wire WIN1, WIN2, DRAW;
	reg [6:0] state;
	assign {q_Draw, q_Win, q_Wait2release, q_Wait2press, q_Wait1release, q_Wait1press, q_Init} = state;

	localparam
	    QINIT         = 7'b0000001,
	    QWAIT1PRESS   = 7'b0000010,
		QWAIT1RELEASE = 7'b0000100,
	    QWAIT2PRESS   = 7'b0001000,
		QWAIT2RELEASE = 7'b0010000,
	    QWIN          = 7'b0100000,
	    QDRAW         = 7'b1000000,
	    UNK           = 7'bXXXXXXX;

	wire block_fill_1, block_fill_2, block_fill_3, block_fill_4, block_fill_5, block_fill_6, block_fill_7, block_fill_8, block_fill_9;

	parameter RED        = 12'b1111_0000_0000;
	parameter BLACK      = 12'b0000_0000_0000;
	parameter WHITE      = 12'b1111_1111_1111;
	parameter RICE       = 12'b1110_1110_1100;
	parameter BACKGROUND = 12'b1111_1111_1111;
	parameter MID_X      = 463;
	parameter MID_Y      = 275;


	/*when outputting the rgb value in an always block like this, make sure to include the if(~bright) statement, as this ensures the monitor
	will output some data to every pixel and not just the images you are trying to display*/
	always@ (*)
		begin
			if(~bright ) //force black if not inside the display area
				rgb = BLACK;
			else if (block_fill_1||block_fill_5||block_fill_6||block_fill_8||block_fill_9)
				rgb = RICE;
			else if (block_fill_2||block_fill_3||block_fill_4||block_fill_7)
				rgb = BLACK;
			else
				rgb = BACKGROUND;
		end

	always@(posedge clk, negedge rst)
	begin
		if(rst)
			begin
				state<=QINIT;
				//rough values for center of screen
				xpos<=450;
				ypos<=250;
			end
		else
		 	begin
				case(state)
				
					QINIT:
							begin
								fstore<=9'b000000000;
								sstore<=9'b000000000;
								if(Player1==1)
									begin
										state<=QWAIT1RELEASE;
									end
								else
									begin
										state<=QWAIT2RELEASE;
									end
							end
							QWAIT1PRESS:
							begin
								if(right==0 && left==0 && up==0 && down==0)
									begin
										state<=QWAIT1RELEASE;
										moves<=moves+1;
									end
							end
							QWAIT1RELEASE:
								begin
									if(right)
										begin
											state<=QWAIT1PRESS;
											if (pointer==2)
												begin
													pointer<=0;
													xpos <= 300;
												end
											else if (pointer==5)
												begin
													pointer<=3;
													xpos <= 300;
												end
											else if (pointer==8)
												begin
													pointer<=6;
													xpos <= 300;
												end
											else
												begin
													pointer<=pointer+1;
													xpos <= xpos + 150;
												end
										end
									else if(left)
										begin
											state<=QWAIT1PRESS;
											if (pointer==0)
												begin
													pointer<=2;
													xpos<=600;
												end
											else if (pointer==3)
												begin
													pointer<=5;
													xpos<=600;
												end
											else if (pointer==6)
												begin
													pointer<=8;
													xpos<=600;
												end
											else
												begin
													pointer<=pointer-1;
													xpos<=xpos - 150;
												end
										end
									else if(up)
										begin
											state<=QWAIT1PRESS;
											if (pointer==0)
												begin
													pointer<=6;
													ypos<=100;
												end
											else if (pointer==1)
												begin
													pointer<=7;
													ypos<=100;
												end
											else if (pointer==2)
												begin
													pointer<=8;
													ypos<=100;
												end
											else
												begin
													pointer<=pointer-3;
													ypos<=ypos+150;
												end
										end
									else if(down)
										begin
											state<=QWAIT1PRESS;
											if (pointer==6)
												begin
													pointer<=0;
													ypos<=400;
												end
											else if (pointer==7)
												begin
													pointer<=1;
													ypos<=400;
												end
											else if (pointer==8)
												begin
													pointer<=2;
													ypos<=400;
												end
											else
												begin
													pointer<=pointer+3;
													ypos<=ypos-150;
												end
										end
									if(DRAW)
										begin
											state<=QDRAW;
										end
									else if(WIN1||WIN2)
										begin
											state<=QWIN;
										end
									else
										begin
											if(Player1==0)
												state<=QWAIT2RELEASE;
												fstore[pointer]<=1;
										end
								end
							QWAIT2PRESS:
							begin
								if(right==0 && left==0 && up==0 && down==0)
									begin
										state<=QWAIT2RELEASE;
										moves<=moves+1;
									end
								
							end
							QWAIT2RELEASE:
								begin
									if(right)
										begin
											state<=QWAIT2PRESS;
											if (pointer==2)
												begin
													pointer<=0;
												end
											else if (pointer==5)
												begin
													pointer<=3;
												end
											else if (pointer==8)
												begin
													pointer<=6;
												end
											else
												begin
													pointer<=pointer+1;
												end
										end
									else if(left)
										begin
											state<=QWAIT2PRESS;
											if (pointer==0)
												begin
													pointer<=2;
												end
											else if (pointer==3)
												begin
													pointer<=5;
												end
											else if (pointer==6)
												begin
													pointer<=8;
												end
											else
												begin
													pointer<=pointer-1;
												end
										end
									else if(up)
										begin
											state<=QWAIT2PRESS;
											if (pointer==0)
												begin
													pointer<=6;
												end
											else if (pointer==1)
												begin
													pointer<=7;
												end
											else if (pointer==2)
												begin
													pointer<=8;
												end
											else
												begin
													pointer<=pointer-3;
												end
										end

									else if(down)
										begin
											state<=QWAIT2PRESS;
											if (pointer==6)
												begin
													pointer<=0;
												end
											else if (pointer==7)
												begin
													pointer<=1;
												end
											else if (pointer==8)
												begin
													pointer<=2;
												end
											else
												begin
													pointer<=pointer+3;
												end
										end
									if(DRAW)
										begin
											state<=QDRAW;
										end
									else if(WIN1||WIN2)
										begin
											state<=QWIN;
										end
									else
										begin
											if(Player1==1)
												state<=QWAIT1RELEASE;
												sstore[pointer]<=1;
										end
								end
							QWIN:
								begin
									if(rst)
										begin
											state<=QINIT;
										end
								end
							QDRAW:
								begin
									if(rst)
										begin
											state<=QINIT;
										end
								end
							default:
								state <= UNK;
						
						endcase
			end
	   end

	
	assign block_fill_1 = (hCount>=(MID_X-25) &&hCount<=(MID_X+25)&&vCount>=(MID_Y-25)&vCount<=(MID_Y+25));
	assign block_fill_2 = (hCount>=(MID_X-80) &&hCount<=(MID_X-30)&&vCount>=(MID_Y-25)&vCount<=(MID_Y+25));
	assign block_fill_3 = (hCount>=(MID_X+30) &&hCount<=(MID_X+80)&&vCount>=(MID_Y-25)&vCount<=(MID_Y+25));
	assign block_fill_4 = (hCount>=(MID_X-25) &&hCount<=(MID_X+25)&&vCount>=(MID_Y+30)&vCount<=(MID_Y+80));
	assign block_fill_5 = (hCount>=(MID_X-80) &&hCount<=(MID_X-30)&&vCount>=(MID_Y+30)&vCount<=(MID_Y+80));
	assign block_fill_6 = (hCount>=(MID_X+30) &&hCount<=(MID_X+80)&&vCount>=(MID_Y+30)&vCount<=(MID_Y+80));
	assign block_fill_7 = (hCount>=(MID_X-25) &&hCount<=(MID_X+25)&&vCount>=(MID_Y-80)&vCount<=(MID_Y-30));
	assign block_fill_8 = (hCount>=(MID_X-80) &&hCount<=(MID_X-30)&&vCount>=(MID_Y-80)&vCount<=(MID_Y-30));
	assign block_fill_9 = (hCount>=(MID_X+30) &&hCount<=(MID_X+80)&&vCount>=(MID_Y-80)&vCount<=(MID_Y-30));
	
 

		//the +-5 for the positions give the dimension of the block (i.e. it will be 10x10 pixels)
	assign block_fill1=(vCount>=(ypos-50) && vCount<=(ypos+50) && hCount>=(xpos-50) && hCount<=(xpos+50))&&~(vCount>=(ypos-30) && vCount<=(ypos+30) && hCount>=(xpos-30) && hCount<=(xpos+30));
	assign WIN1=fstore[0]*fstore[1]*fstore[2]+fstore[3]*fstore[4]*fstore[5]+fstore[6]*fstore[7]*fstore[8]+
				fstore[0]*fstore[3]*fstore[6]+fstore[1]*fstore[4]*fstore[7]+fstore[2]*fstore[5]*fstore[8]+
				fstore[0]*fstore[4]*fstore[8]+fstore[2]*fstore[4]*fstore[6];

	assign WIN2=sstore[0]*sstore[1]*sstore[2]+sstore[3]*sstore[4]*sstore[5]+sstore[6]*sstore[7]*sstore[8]+
				sstore[0]*sstore[3]*sstore[6]+sstore[1]*sstore[4]*sstore[7]+sstore[2]*sstore[5]*sstore[8]+
				sstore[0]*sstore[4]*sstore[8]+sstore[2]*sstore[4]*sstore[6];

	assign DRAW= ~WIN2 && ~WIN1 && (moves==9);

	
	
endmodule
