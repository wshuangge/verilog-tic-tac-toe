module ee354_GCD(Clk, Reset, Start, Ack, Player1, left,right,up,down, q_Init, q_Wait1press, q_Wait1release, q_Wait2press, q_Wait2release, q_Win, q_Draw);


	input Clk, Reset, Start, Ack;
	input Player1;
	input left,right,up,down;

	reg [3:0] pointer;
	reg [3:0] moves;
	reg [8:0] 1store;
	reg [8:0] 2store;
	wire WIN1, WIN2, DRAW;

	output q_Init, q_Wait1press, q_Wait1release, q_Wait2press, q_Wait2release, q_Win, q_Draw;
	reg [6:0] state;	
	assign {q_Init, q_Wait1press, q_Wait1release, q_Wait2press, q_Wait2release, q_Win, q_Draw} = state;

	localparam
	    QINIT   =        7'b0000001,
	    QWAIT1PRESS  =   7'b0000010,
		QWAIT1RELEASE  = 7'b0000100,
	    QWAIT2PRESS  =   7'b0001000,
		QWAIT2RELEASE  = 7'b0010000,
	    QWIN1   =        7'b0100000,
	    QDRAW   =        7'b1000000,
	
	always @ (posedge Clk, posedge Reset)
	begin 
		if(Reset) 
		  begin
			state <= QINIT;

		  end
				case(state)	
					QINIT:
					begin
						1store<=9'b000000000;
						2store<=9'b000000000;
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
						else		
					end
					QWAIT1RELEASE:
						begin
							if(right)
								begin
									state<=QWAIT1PRESS;
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
									state<=QWAIT1PRESS;
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
									state<=QWAIT1PRESS;
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
									state<=QWAIT1PRESS;
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
									state<=DRAW;
								end
							else if(WIN1||WIN2)
								begin
									state<=WIN;
								end
							else
								begin
									if(Player1==0)
										state<=QWAIT2RELEASE;
										1store[pointer]<=1;
								end
					
					QWAIT2PRESS:
					begin
						if(right==0 && left==0 && up==0 && down==0)
							begin
								state<=QWAIT2RELEASE;
								moves<=moves+1;
							end
						else		
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
									state<=DRAW;
								end
							else if(WIN1||WIN2)
								begin
									state<=WIN;
								end
							else
								begin
									if(Player1==1)
										state<=QWAIT1RELEASE;
										2store[pointer]<=1;
								end			
					QWIN:
						begin
							if(Ack)
								begin
									state<=QINIT;
								end
						end
					QDRAW:
						begin
							if(Ack)
								begin
									state<=QINIT;
								end
						end		
					default:		
						state <= UNK;
				endcase
	end
	

	assign WIN1=1store[0]*1store[1]*1store[2]+1store[3]*1store[4]*1store[5]+1store[6]*1store[7]*1store[8]+
				1store[0]*1store[3]*1store[6]+1store[1]*1store[4]*1store[7]+1store[2]*1store[5]*1store[8]+
				1store[0]*1store[4]*1store[8]+1store[2]*1store[4]*1store[6];

	assign WIN2=2store[0]*2store[1]*2store[2]+2store[3]*2store[4]*2store[5]+2store[6]*2store[7]*2store[8]+
				2store[0]*2store[3]*2store[6]+2store[1]*2store[4]*2store[7]+2store[2]*2store[5]*2store[8]+
				2store[0]*2store[4]*2store[8]+2store[2]*2store[4]*2store[6];

	assign DRAW= ~WIN2 && ~WIN1 && (moves==9)
endmodule

