`define  ADDR_MR      16'h0000		
`define	ADDR_GAR     16'h0001	//4
`define	ADDR_SUBR    16'h0005	//4
`define	ADDR_SHAR    16'h0009	//6
`define	ADDR_SIPR    16'h000F	//4
`define	ADDR_IR      16'h0015	
`define	ADDR_IMR     16'h0016		
`define	ADDR_RTR     16'h0019	//2	
`define	ADDR_RCR     16'h001B		
`define	ADDR_PHY     16'h002E		
module ini_w5500(
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
			output reg					o_w5500_rst	,
			output 						o_ini_end	,
			output 						o_ts			
);
parameter 	GAR	=32'hC0_A8_00_05,		//wangguan
				SUBR	=32'hFFFFFF00,		//ziwang
				SHAR	=48'h010203040506,//MAC
				SIPR	=32'hC0A8000A;		//IP

parameter	IDLE			=6'd00,
				RST			=6'd01,
				WRMR_CMD		=6'd02,
				WR_MR			=6'd03,
				RDMR_CMD		=6'd04,
				RD_MR			=6'd05,
				JDMR			=6'd06,
				WRGAR_CMD	=6'd07,
				WR_GAR		=6'd08,
				WRSUBR_CMD	=6'd09,
				WR_SUBR		=6'd10,
				WRSHAR_CMD	=6'd11,
				WR_SHAR		=6'd12,
				WRIP_CMD		=6'd13,
				WR_IP			=6'd14,
				RDRG_CMD		=6'd15,
				RD_RG			=6'd16,
				JDRG			=6'd17,
				WRIR_CMD		=6'd18,
				WR_IR			=6'd19,
				WRIMR_CMD	=6'd20,
				WR_IMR		=6'd21,
				RDIR_CMD		=6'd22,
				RD_IR			=6'd23,
				JDIR			=6'd24,
				WRRTR_CMD	=6'd25,
				WR_RTR		=6'd26,
				RDRTR_CMD	=6'd27,
				RD_RTR		=6'd28,
				JDRTR			=6'd29,
				WRRCR_CMD	=6'd30,
				WR_RCR		=6'd31,
				RDRCR_CMD	=6'd32,
				RD_RCR		=6'd33,
				JDRCR			=6'd34,
				WRPHY_CMD	=6'd35,
				WR_PHY		=6'd36,
				RDPHY_CMD	=6'd37,
				RD_PHY		=6'd38,
				JDPHY			=6'd39,
				END			=6'd40;
				
//				WR
//				PRE	=4'd2,
//				WRDAT	=4'd3,
//				DLY	=4'd4,
//				PRE1	=4'd5,
//				WRCFG	=4'd6,
//				END	=4'd7;
				
parameter	RSTNUM=16'd4000,
				DLYNUM=16'd10	;

reg 	[04:00]	cnt;
reg	[15:00]	cnt_byte;
reg 	[05:00]	state/*synthesis noprune*/;
wire 				rst_end;
wire 				dly_end;
reg 	[02:00]	ini_enr;
wire 				ini_enrise;

reg 	      	mr_cfg_vld/*synthesis noprune*/;	
wire 				rg_cfg_vld/*synthesis keep*/;	
wire 				ir_cfg_vld/*synthesis keep*/;	
reg 	      	rtr_cfg_vld/*synthesis noprune*/;	
reg 	      	rcr_cfg_vld/*synthesis noprune*/;
reg 	      	phy_cfg_vld/*synthesis noprune*/;	

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
						state<=RST;
					else 
						state<=IDLE;
				RST:	
					if(rst_end)
						state<=WRMR_CMD;
					else 
						state<=RST;
				WRMR_CMD	:
					state<=WR_MR;
				WR_MR	:
					if(wrend)
						state<=RDMR_CMD;
					else 
						state<=WR_MR;
				RDMR_CMD:
					state<=RD_MR;
				RD_MR:	
					if(wrend)
						state<=JDMR;
					else 
						state<=RD_MR;	
				JDMR:				
		      	if(mr_cfg_vld)	
						state<=WRGAR_CMD;
					else
						state<=WRMR_CMD;
				WRGAR_CMD:
					state<=WR_GAR;
				WR_GAR:
					if(wrend)	
						state<=WRSUBR_CMD;
					else
						state<=WR_GAR;
            WRSUBR_CMD:
					state<=WR_SUBR;
				WR_SUBR:
					if(wrend)	
						state<=WRSHAR_CMD;
					else
						state<=WR_SUBR;
            WRSHAR_CMD:		
            	state<=WR_SHAR;
				WR_SHAR:
            	if(wrend)	
						state<=WRIP_CMD;
					else
						state<=WR_SHAR;	
            WRIP_CMD:
					state<=WR_IP;
				WR_IP:
					if(wrend)	
						state<=RDRG_CMD;
					else
						state<=WR_IP;
				RDRG_CMD:
					state<=RD_RG;
				RD_RG:
					if(wrend)	
						state<=JDRG;
					else
						state<=RD_RG;
            JDRG:		     		
            	if(rg_cfg_vld)	
						state<=WRIR_CMD;
					else
						state<=WRGAR_CMD;		
            WRIR_CMD	:
					state<=WR_IR;
				WR_IR:
					if(wrend)	
						state<=WRIMR_CMD;
					else
						state<=WR_IR;
            WRIMR_CMD:
					state<=WR_IMR;
            WR_IMR:	
            	if(wrend)	
						state<=RDIR_CMD;
					else
						state<=WR_IMR;	
				RDIR_CMD:
					state<=RD_IR;
				RD_IR:
					if(wrend)	
						state<=JDIR;
					else
						state<=RD_IR;	
            JDIR:
					if(ir_cfg_vld)	
						state<=WRRTR_CMD;
					else
						state<=WRIR_CMD;	
            WRRTR_CMD:
					state<=WR_RTR;
            WR_RTR:
					if(wrend)	
						state<=RDRTR_CMD;
					else
						state<=WR_RTR;	
				RDRTR_CMD:
					state<=RD_RTR;
				RD_RTR:
					if(wrend)	
						state<=JDRTR;
					else
						state<=RD_RTR;	
            JDRTR:
					if(rtr_cfg_vld)	
						state<=WRRCR_CMD;
					else
						state<=WRRTR_CMD;
				WRRCR_CMD:
					state<=WR_RCR;
            WR_RCR:
					if(wrend)	
						state<=RDRCR_CMD;
					else
						state<=WRRCR_CMD;
            RDRCR_CMD:
					state<=RD_RCR;
				RD_RCR:
					if(wrend)	
						state<=JDRCR;
					else
						state<=RD_RCR;
            JDRCR	:
					if(rcr_cfg_vld)	
						state<=WRPHY_CMD;
					else
						state<=WRRCR_CMD;				
		      WRPHY_CMD:
					state<=WR_PHY;			
				WR_PHY:
					if(wrend)	
						state<=RDPHY_CMD;
					else
						state<=WR_PHY;
				RDPHY_CMD:
					state<=RD_PHY;
				RD_PHY:
					if(wrend)	
						state<=JDPHY;
					else
						state<=RD_PHY;
				JDPHY:
					if(phy_cfg_vld)	
						state<=END;
					else
						state<=WRPHY_CMD;	
				END:state<=IDLE;									
			default:state<=IDLE;
		endcase
	end

always@(posedge clk,negedge rst_n)
	if(!rst_n)
		cnt<='d0;
	else begin
		case(state)
				RST:cnt<=cnt+'d1;
			default:cnt<='d0;
		endcase
	end

always@(posedge clk,negedge rst_n)
	if(!rst_n)
		cnt_byte<='d0;
	else begin
		case(state)
				RST:
					if(&cnt)
						cnt_byte<=cnt_byte+'d1;
					else 
						cnt_byte<=cnt_byte;
				WR_GAR,WR_SHAR,WR_SUBR,WR_IP,WR_RTR:
					if(wrend)
						cnt_byte<='d0;
					else if(rdreq)
						cnt_byte<=cnt_byte+'d1;
					else
						cnt_byte<=cnt_byte;
				
				RD_RG,RD_RTR,RD_IR:
					if(wrend)
						cnt_byte<='d0;
					else if(den)
						cnt_byte<=cnt_byte+'d1;
					else
						cnt_byte<=cnt_byte;
			default:cnt_byte<='d0;
		endcase
	end

assign rst_end 	   = state==RST && (&cnt) && (cnt_byte==RSTNUM-1);
//assign dly_end 	   = state==DLY && (&cnt) && (cnt_byte==DLYNUM-1);

always@(posedge clk,negedge rst_n)
	if(!rst_n) begin
		o_start<='d0;
		o_cmd<='d0;
		o_addr<='d0;
		o_length<='d0;			
	end else begin
		case(state)
			WRMR_CMD:begin
				o_start<='d1;
				o_cmd<=8'h04;
				o_addr<=`ADDR_MR;
				o_length<='d1;
			end
			RDMR_CMD:begin
				o_start<='d1;
				o_cmd<=8'h00;
				o_addr<=`ADDR_MR;
				o_length<='d1;
			end
			WRGAR_CMD:begin
				o_start<='d1;
				o_cmd<=8'h04;
				o_addr<=`ADDR_GAR;
				o_length<='d4;
			end
			WRSUBR_CMD:begin
				o_start<='d1;
				o_cmd<=8'h04;
				o_addr<=`ADDR_SUBR;
				o_length<='d4;
			end
			WRSHAR_CMD:begin
				o_start<='d1;
				o_cmd<=8'h04;
				o_addr<=`ADDR_SHAR;
				o_length<='d6;
			end
			WRIP_CMD:begin
				o_start<='d1;
				o_cmd<=8'h04;
				o_addr<=`ADDR_SIPR;
				o_length<='d4;
			end
			RDRG_CMD:begin
				o_start<='d1;
				o_cmd<=8'h00;
				o_addr<=`ADDR_GAR;
				o_length<='d18;
			end
			WRIR_CMD:begin
				o_start<='d1;
				o_cmd<=8'h04;
				o_addr<=`ADDR_IR;
				o_length<='d1;
			end
			WRIMR_CMD:begin
				o_start<='d1;
				o_cmd<=8'h04;
				o_addr<=`ADDR_IMR;
				o_length<='d1;
			end
			RDIR_CMD:begin
				o_start<='d1;
				o_cmd<=8'h00;
				o_addr<=`ADDR_IR;
				o_length<='d2;
			end
			WRRTR_CMD:begin
				o_start<='d1;
				o_cmd<=8'h04;
				o_addr<=`ADDR_RTR;
				o_length<='d2;
			end
			RDRTR_CMD:begin
				o_start<='d1;
				o_cmd<=8'h00;
				o_addr<=`ADDR_RTR;
				o_length<='d2;
			end
			WRRCR_CMD:begin
				o_start<='d1;
				o_cmd<=8'h04;
				o_addr<=`ADDR_RCR;
				o_length<='d1;
			end	
			RDRCR_CMD:begin
				o_start<='d1;
				o_cmd<=8'h00;
				o_addr<=`ADDR_RCR;
				o_length<='d1;
			end
			WRPHY_CMD:begin
				o_start<='d1;
				o_cmd<=8'h04;
				o_addr<=`ADDR_PHY;
				o_length<='d1;
			end
			RDPHY_CMD:begin
				o_start<='d1;
				o_cmd<=8'h00;
				o_addr<=`ADDR_PHY;
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
		o_w5500_rst<='d0;	
	else if(state==RST)
		if(cnt_byte>=RSTNUM>>1)
			o_w5500_rst<='d1;	
		else 
			o_w5500_rst<=o_w5500_rst;

always@(posedge clk,negedge rst_n)
	if(!rst_n)
		o_dat<='d0;
	else begin
		case(state)
			WR_MR://WRMR_CMD,
				o_dat<=8'h00;
			WRGAR_CMD,WR_GAR:
				if(rdreq)
					case(cnt_byte)
							'd00:o_dat<=GAR[31:24];
							'd01:o_dat<=GAR[23:16];
							'd02:o_dat<=GAR[15:08];
							'd03:o_dat<=GAR[07:00];
						default:;
					endcase
				else
					o_dat<=o_dat;
			WR_SUBR://WRSUBR_CMD,
				if(rdreq)
					case(cnt_byte)
							'd00:o_dat<=SUBR[31:24];
							'd01:o_dat<=SUBR[23:16];
							'd02:o_dat<=SUBR[15:08];
							'd03:o_dat<=SUBR[07:00];
						default:;
					endcase
				else
					o_dat<=o_dat;
			WR_SHAR://WRSHAR_CMD,
				if(rdreq)
					case(cnt_byte)
							'd00:o_dat<=SHAR[47:40];
							'd01:o_dat<=SHAR[39:32];
							'd02:o_dat<=SHAR[31:24];
							'd03:o_dat<=SHAR[23:16];
							'd04:o_dat<=SHAR[15:08];
							'd05:o_dat<=SHAR[07:00];							
						default:;
					endcase
				else
					o_dat<=o_dat;	
			WR_IP://WRIP_CMD,
				if(rdreq)
					case(cnt_byte)
							'd00:o_dat<=SIPR[31:24];
							'd01:o_dat<=SIPR[23:16];
							'd02:o_dat<=SIPR[15:08];
							'd03:o_dat<=SIPR[07:00];
						default:;
					endcase
				else
					o_dat<=o_dat;
			WRIR_CMD,WR_IR,WRIMR_CMD,WR_IMR:
				o_dat<=8'hFF;
			WR_RTR://WRRTR_CMD,
				if(rdreq)
					case(cnt_byte)
							'd00:o_dat<=8'h07;
							'd01:o_dat<=8'hD0;
						default:;
					endcase
				else
					o_dat<=o_dat;
			WRRCR_CMD,WR_RCR:
				o_dat<=8'h08;
			WRPHY_CMD,WR_PHY:
				o_dat<=8'b11111111;
			default:o_dat<=8'h00;
		endcase
	end
/*		
	else if(state==WRDAT)
		if(rdreq)begin
			case(cnt_byte)
				'd00:o_dat<=8'h00;	
				'd01:o_dat<=GAR[31:24];	
				'd02:o_dat<=GAR[23:16];	
				'd03:o_dat<=GAR[15:08];	
				'd04:o_dat<=GAR[07:00];
				'd05:o_dat<=SUBR[31:24];
				'd06:o_dat<=SUBR[23:16];
				'd07:o_dat<=SUBR[15:08];
				'd08:o_dat<=SUBR[07:00];
				'd09:o_dat<=SHAR[47:40];
				'd10:o_dat<=SHAR[39:32];
				'd11:o_dat<=SHAR[31:24];
				'd12:o_dat<=SHAR[23:16];
				'd13:o_dat<=SHAR[15:08];
				'd14:o_dat<=SHAR[07:00];
				'd15:o_dat<=SIPR[31:24];
				'd16:o_dat<=SIPR[23:16];
				'd17:o_dat<=SIPR[15:08];
				'd18:o_dat<=SIPR[07:00];
				'd19:o_dat<=8'h00;
				'd20:o_dat<=8'h00;
				'd21:o_dat<=8'hFF;
				'd22:o_dat<=8'hFF;
				'd23:o_dat<=8'hFF;
				'd24:o_dat<=8'hFF;
				'd25:o_dat<=8'h07;
				'd26:o_dat<=8'hD0;
				'd27:o_dat<=8'h08;
				default:o_dat<=o_dat;
			endcase
		end else
			o_dat<=o_dat;
	else if(state==PRE1)
		o_dat<=8'hBF;
*/	
reg 	[07:0]	mr_dat/*synthesis noprune*/;
reg 	[07:0]	ir_dat/*synthesis noprune*/;
reg 	[07:0]	imr_dat/*synthesis noprune*/;
reg 	[15:0]	rtr_dat/*synthesis noprune*/;
reg 	[07:0]	rcr_dat/*synthesis noprune*/;
reg 	[07:0]	phy_dat/*synthesis noprune*/;
reg 	[31:0]	gateway/*synthesis noprune*/;
reg 	[31:0]	ipaddr/*synthesis noprune*/;
reg 	[31:0]	subcode/*synthesis noprune*/;
reg 	[47:0]	macaddr/*synthesis noprune*/;

wire 	      	gateway_vld/*synthesis keep*/;
wire 				ipaddr_vld/*synthesis keep*/;
wire 				subcode_vld/*synthesis keep*/;
wire 				macaddr_vld/*synthesis keep*/;

wire 				ir_vld/*synthesis keep*/;
wire 				imr_vld/*synthesis keep*/;
wire 				rcr_vld/*synthesis keep*/;
wire 				rtr_vld/*synthesis keep*/;
reg				denr;
reg 	[47:00]	dinr;
always@(posedge clk,negedge rst_n)
	if(!rst_n) 
		denr<='d0;
	else
		denr<=den;
	
always@(posedge clk,negedge rst_n)
	if(!rst_n) 
		dinr<='d0;
	else if(den)
		dinr<={dinr[39:00],din};

assign gateway_vld= state==RD_RG && den && cnt_byte=='d4;		
assign ipaddr_vld	= state==RD_RG && denr&& cnt_byte=='d18;	
assign subcode_vld= state==RD_RG && den && cnt_byte=='d8;
assign macaddr_vld= state==RD_RG && den && cnt_byte=='d14;
assign ir_vld		= state==RD_IR && denr&& cnt_byte=='d1;
assign imr_vld		= state==RD_IR && denr&& cnt_byte=='d2;
assign rtr_vld		= state==RD_RTR&& denr&& cnt_byte=='d2;

always@(posedge clk,negedge rst_n)
	if(!rst_n)
		gateway<='d0;
	else if(gateway_vld)
		gateway<=dinr[31:00];
	else
		gateway<=gateway;
		
always@(posedge clk,negedge rst_n)
	if(!rst_n)
		subcode<='d0;
	else if(subcode_vld)
		subcode<=dinr[31:00];
	else
		subcode<=subcode;

always@(posedge clk,negedge rst_n)
	if(!rst_n)
		macaddr<='d0;
	else if(macaddr_vld)
		macaddr<=dinr;
	else
		macaddr<=macaddr;		

always@(posedge clk,negedge rst_n)
	if(!rst_n)
		ipaddr<='d0;
	else if(ipaddr_vld)
		ipaddr<=dinr[31:00];
	else
		ipaddr<=ipaddr;		

always@(posedge clk,negedge rst_n)
	if(!rst_n)
		mr_dat<='d0;	
	else if(state==RD_MR)
		if(den)
			mr_dat<=din;
		else
			mr_dat<=mr_dat;
			
always@(posedge clk,negedge rst_n)
	if(!rst_n)
		ir_dat<='d0;
	else if(ir_vld)
		ir_dat<=din;
	else
		ir_dat<=ir_dat;
always@(posedge clk,negedge rst_n)
	if(!rst_n)
		imr_dat<='d0;
	else if(imr_vld)
		imr_dat<=din;
	else
		imr_dat<=imr_dat;
		
always@(posedge clk,negedge rst_n)
	if(!rst_n)
		rtr_dat<='d0;
	else if(rtr_vld)
		rtr_dat<=dinr[15:00];
	else
		rtr_dat<=rtr_dat;		
always@(posedge clk,negedge rst_n)
	if(!rst_n)
		rcr_dat<='d0;	
	else if(state==RD_RCR)
		if(den)
			rcr_dat<=din;
		else
			rcr_dat<=rcr_dat;
			
always@(posedge clk,negedge rst_n)
	if(!rst_n)
		phy_dat<='d0;	
	else if(state==RD_PHY)
		if(den)
			phy_dat<=din;
		else
			phy_dat<=phy_dat;		
			
	
always@(posedge clk,negedge rst_n)
	if(!rst_n)
		mr_cfg_vld<='d0;	
	else if(state==RD_MR)	
		if(mr_dat==8'h00)
			mr_cfg_vld<='d1;
		else
			mr_cfg_vld<=mr_cfg_vld;
	else
		mr_cfg_vld<=mr_cfg_vld;	
		
reg 	      	gar_ok/*synthesis noprune*/;
reg 	      	sub_ok/*synthesis noprune*/;
reg 	      	mac_ok/*synthesis noprune*/;
reg 	      	sip_ok/*synthesis noprune*/;	
	
assign rg_cfg_vld= gar_ok && sub_ok &&mac_ok &&sip_ok;
always@(posedge clk,negedge rst_n)
	if(!rst_n) begin
		gar_ok<='d0;
		sub_ok<='d0;
		mac_ok<='d0;
		sip_ok<='d0;
	end else if(state==RD_RG)begin
		if(gateway==GAR)
			gar_ok<='d1;	
		else
			gar_ok<=gar_ok;
		if(subcode==SUBR)	
			sub_ok<='d1;
		else
			sub_ok<=sub_ok;
		if(macaddr==SHAR)
			mac_ok<='d1;
		else 
			mac_ok<=mac_ok;
		if(ipaddr==SIPR)
			sip_ok<='d1;
		else
			sip_ok<=sip_ok;
	end

reg 	      	ir_ok/*synthesis noprune*/;
reg 	      	imr_ok/*synthesis noprune*/;
		
assign ir_cfg_vld=ir_ok&&imr_ok;
always@(posedge clk,negedge rst_n)
	if(!rst_n) begin
		ir_ok<='d0;
		imr_ok<='d0;
	end else if(state==RD_IR)begin
		if(ir_dat==8'h00)
			ir_ok<='d1;	
		else
			ir_ok<=ir_ok;
		if(imr_dat==8'hFF)	
			imr_ok<='d1;
		else
			imr_ok<=imr_ok;
	end


always@(posedge clk,negedge rst_n)
	if(!rst_n)
		rtr_cfg_vld<='d0;	
	else if(state==RD_RTR)	
		if(rtr_dat==16'h07D0)
			rtr_cfg_vld<='d1;
		else
			rtr_cfg_vld<=rtr_cfg_vld;
	else
		rtr_cfg_vld<=rtr_cfg_vld;	
		
			
always@(posedge clk,negedge rst_n)
	if(!rst_n)
		rcr_cfg_vld<='d0;	
	else if(state==RD_RCR)	
		if(rcr_dat==8'h08)
			rcr_cfg_vld<='d1;
		else
			rcr_cfg_vld<=rcr_cfg_vld;
	else
		rcr_cfg_vld<=rcr_cfg_vld;	
		
always@(posedge clk,negedge rst_n)
	if(!rst_n)
		phy_cfg_vld<='d0;	
	else if(state==RD_PHY)	
		if(phy_dat[7:6]==2'b11)
			phy_cfg_vld<='d1;
		else
			phy_cfg_vld<=phy_cfg_vld;
	else
		phy_cfg_vld<=phy_cfg_vld;			
		
		
assign o_ini_end= state==END;
endmodule 