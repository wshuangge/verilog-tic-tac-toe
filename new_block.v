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
	wire block_fill;
	wire H_U_M, H_U_R, H_D_L, H_D_M, H_D_R, V_L_U, V_L_M, V_L_D, V_R_U, V_R_M, V_R_D;
	
	//these two values dictate the center of the block, incrementing and decrementing them leads the block to move in certain directions
	reg [9:0] xpos, ypos;
	reg [3:0] pointer;
	reg [3:0] moves;
	reg [8:0] fstore;
	reg [8:0] sstore;
	wire WIN1, WIN2, DRAW;
	reg [6:0] state;
	assign {q_Draw, q_Win, q_Wait2release, q_Wait2press, q_Wait1release, q_Wait1press, q_Init} = state;

	localparam
	    QINIT   =        7'b0000001,
	    QWAIT1PRESS  =   7'b0000010,
		QWAIT1RELEASE  = 7'b0000100,
	    QWAIT2PRESS  =   7'b0001000,
		QWAIT2RELEASE  = 7'b0010000,
	    QWIN   =        7'b0100000,
	    QDRAW   =        7'b1000000,
	    UNK = 7'bXXXXXXX;
	parameter RED   = 12'b1111_0000_0000;
	parameter BLUE  = 12'b0000_0000_1111;
	parameter GREEN = 12'b0000_1111_0000;
	parameter X = 450;
	parameter Y = 250;

	/*when outputting the rgb value in an always block like this, make sure to include the if(~bright) statement, as this ensures the monitor
	will output some data to every pixel and not just the images you are trying to display*/
	always@ (*) begin
     if(~bright ) //force black if not inside the display area
        rgb = 12'b0000_0000_0000;
     else if(grid)
        rgb=GREEN;
     else if(block_fill1)
         rgb=RED;
     else
         rgb=12'b0000_0000_0000;
  /*else if (board_1) 
    rgb = RED; 
  else if(board_2)
      rgb = RED;
  else if(board_3)
      rgb =RED;
  else if(board_4)
    rgb=RED;*/
  
 end
  //the +-5 for the positions give the dimension of the block (i.e. it will be 10x10 pixels)
 //assign block_fill= vCount>=ypos&& hCount>=xpos&& vCount<=(ypos+5) && hCount<=(xpos+5)&&vCount>=ypos&&vCount+200==hCount; 
 //assign first_line = hCount>=100&&hCount<=700&&vCount>=200&&vCount <= 202;
 //assign second_line = hCount>=100&&hCount<=700&&vCount>=600&&vCount <= 602;
 //assign third_line = hCount>=300 &&hCount<=302 && vCount>=100 &&vCount <=800;
 //assign block_fill = hCount>=200&&hCount<=700&&vCount>=480&&vCount <= 485;
 //assign H_U_L=(hCount>=200&&hCount<=680&&vCount>=460&&vCount <= 465);
 //assign V_L_U=(hCount>=360&&hCount<=365&&vCount>=470&&vCount <= 490);
 assign grid = (vCount>=(Y-75) && vCount<=(Y+75) && hCount>=(X-75) && hCount<=(X+75));
 /*
 assign H_U_M=
 assign H_U_R=
 assign H_D_L=
 assign H_D_M=
 assign H_D_R=
 
 assign V_L_M=
 assign V_L_D=
 assign V_R_U=
 assign V_R_M=
 assign V_R_D=
 */
 
 

		//the +-5 for the positions give the dimension of the block (i.e. it will be 10x10 pixels)
	assign block_fill1=(vCount>=(ypos-50) && vCount<=(ypos+50) && hCount>=(xpos-50) && hCount<=(xpos+50))&&~(vCount>=(ypos-30) && vCount<=(ypos+30) && hCount>=(xpos-30) && hCount<=(xpos+30));
	assign WIN1=fstore[0]*fstore[1]*fstore[2]+fstore[3]*fstore[4]*fstore[5]+fstore[6]*fstore[7]*fstore[8]+
				fstore[0]*fstore[3]*fstore[6]+fstore[1]*fstore[4]*fstore[7]+fstore[2]*fstore[5]*fstore[8]+
				fstore[0]*fstore[4]*fstore[8]+fstore[2]*fstore[4]*fstore[6];

	assign WIN2=sstore[0]*sstore[1]*sstore[2]+sstore[3]*sstore[4]*sstore[5]+sstore[6]*sstore[7]*sstore[8]+
				sstore[0]*sstore[3]*sstore[6]+sstore[1]*sstore[4]*sstore[7]+sstore[2]*sstore[5]*sstore[8]+
				sstore[0]*sstore[4]*sstore[8]+sstore[2]*sstore[4]*sstore[6];

	assign DRAW= ~WIN2 && ~WIN1 && (moves==9);

	always@(*)
	begin
		if(rst)
		begin
		    state<=QINIT;
			//rough values for center of screen
			xpos<=450;
			ypos<=250;
		end

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
	
		//else if (clk) begin
		
		/* Note that the top left of the screen does NOT correlate to vCount=0 and hCount=0. The display_controller.v file has the 
			synchronizing pulses for both the horizontal sync and the vertical sync begin at vcount=0 and hcount=0. Recall that after 
			the length of the pulse, there is also a short period called the back porch before the display area begins. So effectively, 
			the top left corner corresponds to (hcount,vcount)~(144,35). Which means with a 640x480 resolution, the bottom right corner 
			corresponds to ~(783,515).  
		*/
		/*
			if(right) begin
				xpos<=xpos+2; //change the amount you increment to make the speed faster 
				if(xpos==800) //these are rough values to attempt looping around, you can fine-tune them to make it more accurate- refer to the block comment above
					xpos<=150;
			end
			else if(left) begin
				xpos<=xpos-2;
				if(xpos==150)
					xpos<=800;
			end
			else if(up) begin
				ypos<=ypos-2;
				if(ypos==34)
					ypos<=514;
			end
			else if(down) begin
				ypos<=ypos+2;
				if(ypos==514)
					ypos<=34;
			end
		end
	end
	*/
	
	//the background color reflects the most recent button press
	/*always@(posedge clk, posedge rst) begin
		if(rst)
			background <= 12'b1111_1111_1111;
		else 
			if(right)
				background <= 12'b1111_1111_0000;
			else if(left)
				background <= 12'b0000_1111_1111;
			else if(down)
				background <= 12'b0000_1111_0000;
			else if(up)
				background <= 12'b0000_0000_1111;
	end*/

	
	
endmodule
