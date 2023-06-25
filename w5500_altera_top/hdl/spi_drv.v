module spi_drv(
		input 						clk			,
		input 						rst_n			,
		input 						start			,
		input 		[07:00]		cmd			,
		input 		[15:00]		addr			,
		input 		[15:00]		length		,
		input			[07:00]		dat			,
		output reg					o_dat_vld	,
		output reg	[07:0]		o_dat			,
		output 						o_dat_req	,
		output						o_wr_end		,
			
		input 						spi_miso		,
		output 						o_spi_cs		,
		output 						o_spi_sck	,
		output 						o_spi_mosi			
);

parameter	IDLE		=4'd0,
				PRE		=4'd1,
				WR_ADR	=4'd2,
				WR_CMD	=4'd3,
				WR_DAT	=4'd4,
				END1		=4'd5,
				END2		=4'd6,
				RD_DAT	=4'd7,
				DLY		=4'd8;
wire 					wradr_end	;	
wire 					wrcmd_end	;	
wire 					wrdat_end	;
wire 					rddat_end	;
wire 					dly_end		;
reg 					wrcmd			;//1 wr 0 rd	
reg 	[07:00]		dat_r			;
reg 	[01:00]		cnt_clk		;
reg 	[02:00]		cnt_bit		;
reg 	[15:00]		cnt_byte		;
reg   [05:00]		cnt_dly		;
reg 					dat_req		;
reg 					cs				;
reg 					sck			;
reg 					mosi			;
reg 	[07:00]		l_cmd			;
reg 	[15:00]		l_adr			;
reg 	[07:00]		l_dat			;
reg 	[15:00]		l_len			;
reg 	[03:00]		state			;

always@(posedge clk,negedge rst_n)
	if(!rst_n)begin
		l_cmd<='d0;
		l_adr<='d0;
		l_len<='d0;
	end else if(start) begin
		l_cmd<=cmd   ;
      l_adr<=addr  ;
      l_len<=length;
	end	
	
always@(posedge clk,negedge rst_n)
	if(!rst_n)	
		wrcmd<='d0;
	else if(start)
		wrcmd<=cmd[2];
always@(posedge clk,negedge rst_n)
	if(!rst_n)
		state<=IDLE;
	else begin
		case(state)
			IDLE:
				if(start)
					state<=PRE;
				else
					state<=IDLE;			
			PRE	:	state<=WR_ADR;
			WR_ADR:
					if(wradr_end)
						state<=WR_CMD;
					else 
						state<=WR_ADR;
			WR_CMD:
					if(wrcmd_end)
						if(wrcmd)
							state<=WR_DAT;
						else
							state<=RD_DAT;
					else 
						state<=WR_CMD;				
			WR_DAT:
					if(wrdat_end)
						state<=END1;
					else
						state<=WR_DAT;
			RD_DAT:
					if(rddat_end)
						state<=END1;
					else
						state<=RD_DAT;			
			END1:state<=END2;
			END2:state<=DLY;
			DLY:
				if(dly_end)
					state<=IDLE;
				else
					state<=DLY;
			default:state<=IDLE;
		endcase
	end
	
assign wradr_end = state== WR_ADR && (cnt_clk=='d2&&cnt_bit=='d7&&cnt_byte=='d1);	
assign wrcmd_end = state== WR_CMD && (cnt_clk=='d2&&cnt_bit=='d7&&cnt_byte=='d2);		
assign wrdat_end = state== WR_DAT && (cnt_clk=='d2&&cnt_bit=='d7&&cnt_byte==l_len+2);	
assign rddat_end = state== RD_DAT && (cnt_clk=='d2&&cnt_bit=='d7&&cnt_byte==l_len+2);
assign dly_end	  = &cnt_dly;
		
always@(posedge clk,negedge rst_n)
	if(!rst_n)
		cnt_clk<='d0;
	else case(state)
		WR_ADR,WR_CMD,WR_DAT,RD_DAT:
			cnt_clk<=cnt_clk+'d1;
		default:cnt_clk<='d0;
	endcase
	
always@(posedge clk,negedge rst_n)
	if(!rst_n)
		cnt_bit<='d0;		
	else case(state) 
			WR_ADR,WR_CMD,WR_DAT,RD_DAT:
				if(cnt_clk=='d2)
					cnt_bit<=cnt_bit+'d1;
				else
					cnt_bit<=cnt_bit;
		default:cnt_bit<='d0;
	endcase
		
always@(posedge clk,negedge rst_n)
	if(!rst_n)
		cnt_byte<='d0;		
	else case(state) 
			WR_ADR,WR_CMD,WR_DAT,RD_DAT:
				if(cnt_clk=='d2&&cnt_bit=='d7)
					cnt_byte<=cnt_byte+'d1;
				else
					cnt_byte<=cnt_byte;
		default:cnt_byte<='d0;
	endcase

always@(posedge clk,negedge rst_n)
	if(!rst_n)
		cnt_dly<='d0;	
	else if(state==DLY)
		cnt_dly<=cnt_dly+'d1;
	else
		cnt_dly<='d0;	
	
always@(posedge clk,negedge rst_n)
	if(!rst_n)
		cs<='d1;
	else begin
		case(state)
			WR_ADR,WR_CMD,WR_DAT,END1,RD_DAT:
				if(cnt_clk=='d0)
					cs<='d0;
				else 
					cs<=cs;
			DLY:	
				if(cnt_dly=='d31)
					cs<='d1;	
				else
					cs<=cs;
			default:;
		endcase	
	end
	
always@(posedge clk,negedge rst_n)
	if(!rst_n)
		sck<='d0;
	else if(cnt_clk=='d0)
		sck<='d0;
	else if(cnt_clk=='d2)
		sck<='d1;
		
always@(posedge clk,negedge rst_n)
	if(!rst_n)
		mosi<='d0;	
	else begin
		case(state)
			WR_ADR:
				if(cnt_byte=='d0) begin
					if(cnt_clk=='d0)
						mosi<=l_adr[15-cnt_bit];
					else 
						mosi<=mosi;
				end else if(cnt_byte=='d1)begin
					if(cnt_clk=='d0)
						mosi<=l_adr[7-cnt_bit];
					else 
						mosi<=mosi;
				end
			WR_CMD:	
				if(cnt_clk=='d0)
					mosi<=l_cmd[7-cnt_bit];
				else 
					mosi<=mosi;
			WR_DAT:	
				if(cnt_clk=='d0)
					mosi<=l_dat[7-cnt_bit];
				else 
					mosi<=mosi;
			END1:mosi<=mosi;					
			default:mosi<='d0;
		endcase	
	end
	
always@(posedge clk,negedge rst_n)
	if(!rst_n)
		dat_req<='d0;	
	else if(cnt_clk=='d2&&cnt_bit=='d5)	
		case(state)
			WR_CMD:dat_req<='d1;
			WR_DAT:
				if(cnt_byte<l_len+2)
					dat_req<='d1;
				else
					dat_req<='d0;
			default:dat_req<='d0;		
		endcase
	else
		dat_req<='d0;

always@(posedge clk,negedge rst_n)
	if(!rst_n)
		l_dat<='d0;	
	else if(cnt_clk=='d2&&cnt_bit=='d7)
		l_dat<=dat;
		
assign  o_wr_end= dly_end;//state==END2;	
assign  o_dat_req =dat_req;	


always@(posedge clk,negedge rst_n)
	if(!rst_n)
		dat_r<='d0;
	else if(state==RD_DAT)
		if(cnt_clk=='d2)
			dat_r[7-cnt_bit]<=spi_miso;
		else
			dat_r<=dat_r;
	
reg 	dat_vld;
always@(posedge clk,negedge rst_n)
	if(!rst_n)			
		dat_vld<='d0;
	else if(state==RD_DAT)
		if(cnt_clk=='d2&&cnt_bit=='d7)
			dat_vld<='d1;
		else
			dat_vld<='d0;
	else
		dat_vld<='d0;

always@(posedge clk,negedge rst_n)
	if(!rst_n)			
		o_dat<='d0;		
	else if(dat_vld)
		o_dat<=dat_r;
	else
		o_dat<=o_dat;
		
always@(posedge clk,negedge rst_n)
	if(!rst_n)			
		o_dat_vld<='d0;		
	else
		o_dat_vld<=dat_vld;
		
assign o_spi_cs	= cs;	
assign o_spi_sck	= sck;		
assign o_spi_mosi	= mosi;
		
endmodule 