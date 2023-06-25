`define  ADDR_SnMR            	16'h0000			
`define  ADDR_SnCR            	16'h0001			
`define	ADDR_SnIMR              16'h002C			
`define	ADDR_SnIR               16'h0002			
`define	ADDR_SnMSSR             16'h0012  //2 
`define	ADDR_PORTR              16'h0004  //2	
`define	ADDR_DHAR               16'h0006  //6	
`define	ADDR_DPORTR             16'h0010  //2	
`define	ADDR_DIPR               16'h000C  //4	
`define	ADDR_SnSR               16'h0003  //4	
`define	ADDR_TXBUF_SIZE         16'h001F  //1	
`define	ADDR_RXBUF_SIZE         16'h001E  //1	

module ini_socket(
		input 						clk			,
		input 						rst_n			,
		input 						ini_en		,
		input 						rdreq			,
		input							den			,
		input 		[07:00]		din			,
		
		input 						wrend			,
		output reg					o_start		,
		output reg		[07:00]	o_cmd			,
		output reg		[15:00]	o_addr		,
		output reg		[15:00]	o_length		,
		output reg		[07:00]	o_dat			,
		output 						o_ini_end	,
		output 						o_ts
);

parameter 	SN_DIP	=32'hC0_A8_00_05,		//wangguan
				SN_DPORT	=16'd6000,			//ziwang
				SN_DSHAR	=48'h010203040506,//MAC
				SN_PORT	=16'd6000;			//IP
				
parameter	IDLE					=6'd00,
				WRMR_CMD				=6'd01,
				WR_MR					=6'd02,
				WRIR_CMD				=6'd03,
				WR_IR					=6'd04,
				WRIMR_CMD			=6'd05,
				WR_IMR				=6'd06,
				WRPORT_CMD			=6'd07,
				WR_PORT				=6'd08,
				WRDHAR_CMD			=6'd09,
				WR_DHAR				=6'd10,
				WRDIPR_CMD			=6'd11,
				WR_DIPR				=6'd12,
				WRDPORT_CMD			=6'd13,
				WR_DPORT				=6'd14,
				WRMSSR_CMD			=6'd15,
				WR_MSSR				=6'd16,
				WRRXBUFSIZE_CMD	=6'd17,
				WR_RXBUFSIZE		=6'd18,
				WRTXBUFSIZE_CMD	=6'd19,
				WR_TXBUFSIZE		=6'd20,
				WRCR_CMD				=6'd21,
				WR_CR					=6'd22,
				RDSR_CMD				=6'd23,
				RD_SR					=6'd24,
				JDSR					=6'd25,
				END					=6'd26;
				
//				MR_CFG	=4'd1,    
//				DLY		=4'd2,    
//				REG_CFG	=4'd3,	 
//				CR_CFG	=4'd4,
//				RD_SR		=4'd5,
//				END		=4'd6,
//				DLY1		=4'd7,
//				DLY2		=4'd8;
				
reg 	[05:00]	state;
wire 				dly_end;
wire 				rdsr_end;
reg 	[04:00]	cnt;
reg	[15:00]	cnt_byte;
wire 				rdsr_start;
reg 	[02:00]	ini_enr;
wire 				ini_enrise;
reg 	[07:0]	sr_dat/*synthesis noprune*/;
reg 				sr_cfg_vld/*synthesis noprune*/;	

assign o_ts=&state;

always@(posedge clk,negedge rst_n)
	if(!rst_n)
		ini_enr<='d0;
	else 
		ini_enr<={ini_enr[1:0],ini_en};
		
assign ini_enrise	=ini_enr[2:1]==2'b01;

always@(posedge clk,negedge rst_n)
	if(!rst_n)
		state<=IDLE;
	else begin
		case(state)
			IDLE: 
				if(ini_enrise)
					state<=WRMR_CMD;
				else 
					state<=IDLE;
			WRMR_CMD	:
				state<=WR_MR;
			WR_MR	:
				if(wrend)
					state<=WRIR_CMD;
				else 
					state<=WR_MR;
		   WRIR_CMD:
				state<=WR_IR;
	      WR_IR	:
				if(wrend)
					state<=WRIMR_CMD;
				else 
					state<=WR_IR;
         WRIMR_CMD	:
				state<=WR_IMR;
         WR_IMR:
				if(wrend)
					state<=WRPORT_CMD;
				else 
					state<=WR_IMR;
         WRPORT_CMD:
				state<=WR_PORT;
         WR_PORT:
				if(wrend)
					state<=WRDHAR_CMD;
				else 
					state<=WR_PORT;
         WRDHAR_CMD:
				state<=WR_DHAR;
         WR_DHAR:
				if(wrend)
					state<=WRDIPR_CMD;
				else 
					state<=WR_DHAR;
         WRDIPR_CMD:
				state<=WR_DIPR;
         WR_DIPR	:
				if(wrend)
					state<=WRDPORT_CMD;
				else 
					state<=WR_DIPR;
         WRDPORT_CMD:
				state<=WR_DPORT;
         WR_DPORT	:
				if(wrend)
					state<=WRMSSR_CMD;
				else 
					state<=WR_DPORT;
			WRMSSR_CMD:
				state<=WR_MSSR;
			WR_MSSR:
				if(wrend)
					state<=WRCR_CMD;
				else 
					state<=WR_MSSR;
			WRCR_CMD:
				state<=WR_CR;
			WR_CR:
				if(wrend)
					state<=RDSR_CMD;
				else 
					state<=WR_CR;
			RDSR_CMD:
				state<=RD_SR;
			RD_SR:
				if(wrend)
					state<=JDSR;
				else 
					state<=RD_SR;
			JDSR:
				if(sr_cfg_vld)
					state<=END;
				else 
					state<=IDLE;
					
//         WRRXBUFSIZE_CMD
//         WR_RXBUFSIZE	
//         WRTXBUFSIZE_CMD
//         WR_TXBUFSIZE	
         END:state<=IDLE;				
			default:state<=IDLE;
		endcase
	end
  
//always@(posedge clk,negedge rst_n)
//	if(!rst_n)
//		cnt<='d0;
//	else begin
//		case(state)
//				DLY,DLY1,DLY2,RD_SR:
//					if(dly_end)
//						cnt<='d0;
//					else
//						cnt<=cnt+'d1;
//			default:cnt<='d0;
//		endcase
//	end

always@(posedge clk,negedge rst_n)
	if(!rst_n)
		cnt_byte<='d0;
	else begin
		case(state)
			WR_PORT,WR_DHAR,WR_DIPR,WR_DPORT:
				if(rdreq)
						cnt_byte<=cnt_byte+'d1;
					else
						cnt_byte<=cnt_byte;		
			default:cnt_byte<='d0;
		endcase
	end
	
always@(posedge clk,negedge rst_n)
	if(!rst_n) begin
		o_start<='d0;
		o_cmd<='d0;
		o_addr<='d0;
		o_length<='d0;			
	end else begin
		case(state)
			WRMR_CMD:begin //MR
				o_start<='d1;
				o_cmd<=8'h0C;
				o_addr<=`ADDR_SnMR;
				o_length<='d1;
			end
			WRIR_CMD:begin //IR
				o_start<='d1;
				o_cmd<=8'h0C;
				o_addr<=`ADDR_SnIR;
				o_length<='d1;
			end
			WRIMR_CMD:begin //IMR
				o_start<='d1;
				o_cmd<=8'h0C;
				o_addr<=`ADDR_SnIMR;
				o_length<='d1;
			end
			WRPORT_CMD:begin //PORT
				o_start<='d1;
				o_cmd<=8'h0C;
				o_addr<=`ADDR_PORTR;
				o_length<='d2;
			end
			WRDHAR_CMD:begin //DHAR
				o_start<='d1;
				o_cmd<=8'h0C;
				o_addr<=`ADDR_DHAR;
				o_length<='d6;
			end
			WRDIPR_CMD:begin //DIP
				o_start<='d1;
				o_cmd<=8'h0C;
				o_addr<=`ADDR_DIPR;
				o_length<='d4;
			end
			WRDPORT_CMD:begin //DPORT
				o_start<='d1;
				o_cmd<=8'h0C;
				o_addr<=`ADDR_DPORTR;
				o_length<='d2;
			end
			WRMSSR_CMD:begin //DPORT
				o_start<='d1;
				o_cmd<=8'h0C;
				o_addr<=`ADDR_SnMSSR;
				o_length<='d2;
			end
			WRCR_CMD:begin //CR
				o_start<='d1;
				o_cmd<=8'h0C;
				o_addr<=`ADDR_SnCR;
				o_length<='d1;
			end
			RDSR_CMD:begin //SR
				o_start<='d1;
				o_cmd<=8'h08;
				o_addr<=`ADDR_SnSR;
				o_length<='d1;
			end				
			default:begin
				o_start<='d0;
				o_cmd<='d0;
				o_addr<='d0;
				o_length<='d0;			
			end 
		endcase
	end	

always@(posedge clk,negedge rst_n)
	if(!rst_n)
		o_dat<='d0;	
	else begin
		case(state)
			WR_MR:
				o_dat<=8'h02;
			WR_IR,WR_IMR:
				o_dat<=8'hFF;
			WR_PORT:
				if(rdreq)
					case(cnt_byte)
						'd00:o_dat<=SN_PORT[15:08];		
						'd01:o_dat<=SN_PORT[07:00];
						default:;
					endcase
				else
					o_dat<=o_dat;
			WR_DHAR:
				if(rdreq)
					case(cnt_byte)
						'd00:o_dat<=SN_DSHAR[47:40];		
						'd01:o_dat<=SN_DSHAR[39:32];
						'd02:o_dat<=SN_DSHAR[31:24];		
						'd03:o_dat<=SN_DSHAR[23:16];
						'd04:o_dat<=SN_DSHAR[15:08];		
						'd05:o_dat<=SN_DSHAR[07:00];							
						default:;
					endcase
				else
					o_dat<=o_dat;
			WR_DIPR:
				if(rdreq)
					case(cnt_byte)
						'd00:o_dat<=SN_DIP[31:24];		
						'd01:o_dat<=SN_DIP[23:16];
						'd02:o_dat<=SN_DIP[15:08];		
						'd03:o_dat<=SN_DIP[07:00];						
						default:;
					endcase
				else
					o_dat<=o_dat;
			WR_DPORT:
				if(rdreq)
					case(cnt_byte)
						'd00:o_dat<=SN_DPORT[15:08];		
						'd01:o_dat<=SN_DPORT[07:00];
						default:;
					endcase
				else
					o_dat<=o_dat;
			WR_MSSR:
				if(rdreq)
					case(cnt_byte)
						'd00:o_dat<=8'h05;		
						'd01:o_dat<=8'hB4;
						default:;
					endcase
				else
					o_dat<=o_dat;		
			WR_CR:
				o_dat<=8'h01;		
			default:;
		endcase	
	end
	
	
	

always@(posedge clk,negedge rst_n)
	if(!rst_n)
		sr_dat<='d0;	
	else if(state==RD_SR)
		if(den)
			sr_dat<=din;
		else
			sr_dat<=sr_dat;

always@(posedge clk,negedge rst_n)
	if(!rst_n)
		sr_cfg_vld<='d0;	
	else if(state==RD_SR)	
		if(sr_dat==8'h22)
			sr_cfg_vld<='d1;
		else
			sr_cfg_vld<=sr_cfg_vld;
	else
		sr_cfg_vld<=sr_cfg_vld;				
	
assign o_ini_end= state==END;	
//assign rdsr_end = state==RD_SR && den && din==8'h22;	
	
	
endmodule 