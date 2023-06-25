module dat_proces(
		input 					clk			,
		input 					rst_n				,
			
		input						rxdat_vld		,
		input 		[07:00]	rxdat				,
		input 					rxdat_end		,
		
		input 					dat_tx_end		,
		output 	reg			o_dat_tx_req	,
		input 					dat_tx_rden		,
		output 		[07:00]	o_dat				,
		output 		[15:00]	o_dat_len		,
		output 					o_ts

);

parameter 	IDLE			=3'd0,
				RDDAT_PRE	=3'd1,
				RD_DAT		=3'd2,
				END			=3'd3;

reg 			[02:00]	state;
reg 			[15:00]	dat_len;
reg 			[15:00]	waddr,raddr;
assign o_ts=&state;

always@(posedge clk,negedge rst_n)
	if(!rst_n)
		state<='d0;
	else begin
		case(state)
			IDLE:
				if(rxdat_end && waddr>'d0)
					state<=RDDAT_PRE;
				else
					state<=IDLE;
			RDDAT_PRE:
				state<=RD_DAT;
			RD_DAT:
				if(dat_tx_end)
					state<=END;
				else 
					state<=RD_DAT;
			END:state<=IDLE;
			default:state<=IDLE;
		endcase
	end

always@(posedge clk,negedge rst_n)
	if(!rst_n)
		dat_len<='d0;
	else if(state==RDDAT_PRE)
		dat_len<=waddr;

always@(posedge clk,negedge rst_n)
	if(!rst_n)
		o_dat_tx_req<='d0;
	else	if(state==RDDAT_PRE)
		o_dat_tx_req<='d1;
	else	if(state==END)
		o_dat_tx_req<='d0;	
	else
		o_dat_tx_req<=o_dat_tx_req;
		

always@(posedge clk,negedge rst_n)
	if(!rst_n)
		waddr<='d0;		
	else if(rxdat_vld)
		waddr<=waddr+'d1;
	else if(state==END)	
		waddr<='d0;	
	
always@(posedge clk,negedge rst_n)
	if(!rst_n)
		raddr<='d0;		
	else if(dat_tx_rden)
		raddr<=raddr+'d1;
	else if(state==END)	
		raddr<='d0;			
		
my_ram	
	my_ram_inst (
			.clock 			( clk 		),
			.wren 			( rxdat_vld	),
			.wraddress 		( waddr 		),
			.data 			( rxdat 		),
			
			.rden 			( dat_tx_rden 	),
			.rdaddress 		( raddr 		),
			.q 				( o_dat 		)
	);
			
assign 	o_dat_len	=dat_len;
endmodule 