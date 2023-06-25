module task_sche(
		input 				clk		,
		input 				rst_n		,
		
		//iniw5500
		input 				ini_vld	,
		input		[07:00]	ini_cmd	,
		input 	[15:00]	ini_addr	,
		input 	[07:00]	ini_dat	,
		input 	[15:00]	ini_len	,
		input					ini_end	,
		//socket
		input 				sn_vld	,
		input		[07:00]	sn_cmd	,
		input 	[15:00]	sn_addr	,
		input 	[07:00]	sn_dat	,
		input 	[15:00]	sn_len	,
		input 				sn_ini_end	,
		input 				sn_tx_end	,
		input 				sn_rx_end	,
		//
		output 				o_ini_vld	,
		output				o_sn_vld		,
		//W5500 IC
		output reg				o_wic_vld	,
		output reg  [07:00]	o_wic_cmd	,
		output reg	[15:00]	o_wic_addr	,
		output reg	[07:00]	o_wic_dat	,
		output reg	[15:00]	o_wic_len	,
		
		output 		[03:00]	o_task_state
);

parameter	IDLE		=4'd0,
				DLY		=4'd1,
				INI_WIC	=4'd2,
				INI_SN	=4'd3,
				STAND_BY	=4'd4,
				SN_TX		=4'd5,
				SN_RX		=4'd6;

wire 				dly_end;
reg 	[03:00]	state;
reg 	[07:00]	cnt	;	
always@(posedge clk,negedge rst_n)
	if(!rst_n)
		state<=IDLE;
	else begin
		case(state)
			IDLE:state<=DLY;
			DLY:	
				if(dly_end)
					state<=INI_WIC;
				else
					state<=DLY;
			INI_WIC:
				if(ini_end)
					state<=INI_SN;
					//state<=STAND_BY;
				else
					state<=INI_WIC;
			INI_SN:
				if(sn_ini_end)
					state<=STAND_BY;
				else
					state<=INI_SN;
			STAND_BY:state<=SN_TX;				
			SN_TX:
				if(sn_tx_end)
					state<=SN_RX;
				else
					state<=SN_TX;
			SN_RX:
				if(sn_rx_end)
					state<=STAND_BY;
				else
					state<=SN_RX;			
			default:state<=IDLE;
		endcase
	end
	
	
always@(*)begin
	if(!rst_n)begin
		o_wic_vld	<='d0;
		o_wic_cmd	<='d0;
		o_wic_addr	<='d0;
		o_wic_dat	<='d0;
		o_wic_len	<='d0;
	end else begin
		case(state)
			INI_WIC: begin
				o_wic_vld	<=ini_vld	;
	         o_wic_cmd	<=ini_cmd	;
            o_wic_addr	<=ini_addr	;
            o_wic_dat	<=ini_dat	;
	         o_wic_len	<=ini_len	;
			end
			SN_TX,SN_RX,INI_SN:begin
				o_wic_vld	<=sn_vld		;
	         o_wic_cmd	<=sn_cmd		;
            o_wic_addr	<=sn_addr	;
            o_wic_dat	<=sn_dat		;
	         o_wic_len	<=sn_len		;
			end	
			default:begin
				o_wic_vld	<='d0;
				o_wic_cmd	<='d0;
				o_wic_addr	<='d0;
				o_wic_dat	<='d0;
				o_wic_len	<='d0;
			end
		endcase
	end

end	

assign o_ini_vld= (state==INI_WIC)?1'b1:1'b0;
assign o_sn_vld =	state==INI_SN;	
	
always@(posedge clk,negedge rst_n)
	if(!rst_n)
		cnt<='d0;
	else if(state==DLY)
		cnt<=cnt+'d1;
	else
		cnt<='d0;

assign dly_end = state==DLY && (&cnt);	

assign o_task_state=state;	
		
endmodule 