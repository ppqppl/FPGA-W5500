`define  ADDR_SnTX_CR           16'h0001 		//Socket n 配置寄存器				  -设置 Socket n 的配置命令
`define  ADDR_SnIR              16'h0002  		//Socket n 中断寄存器				  -提供给 Socket n 中断类型信息
`define  ADDR_SnFSR             16'h0020 //2	//Socket n 空闲发送缓存寄存器20-21   -Socket n 发送缓存的空闲空间大小。该寄存器初始化配置为Sn_TXBUF_SIZE大小
`define  ADDR_SnTXWR            16'h0024		//Socket n 发送写指针寄存器（24-25） -通过 OPEN 配置命令进行初始化
//`define     ADDR_SnWRSR            10'h222 
`define	 ADDR_DPORTR            16'h0010 		//Socket n 目标端口寄存器（10-11）	  -指示了Socket n的目标主机端口号
`define	 ADDR_DIPR              16'h000C		//Socket n 目标IP地址寄存器（0C-0F）  -指示的为Socket  的目标主机IP地址
`define	 ADDR_DHAR              16'h0006  //6  	//Socket n 目的MAC地址寄存器(06-0B)  -UDP模式下，使用Send_MAC配置命令，配置Socket n的目标主机MAC地址；	  


module socket_txd(
		input 						clk			,
		input 						rst_n			,
		input 						rdreq			,
		input							den			,
		input 		[07:00]		din			,
		input 		[03:00]		task_state	,
		
		input 						txdat_vld	,
		input 		[07:00]		txdat			,
		input			[15:00]		txdat_len	,
				
		input 						dat_tx_req	,
		output 						o_dat_rx_act,
		output 						o_dat_rx_rden,
		input 						wrend			,
		output reg					o_start		,
		output reg		[07:00]	o_cmd			,
		output reg		[15:00]	o_addr		,
		output reg		[15:00]	o_length		,
		output reg		[07:00]	o_dat			,
		output 						o_tx_end		,
		output						o_ts
);

parameter	IDLE			=5'd00,
				RDFSR_CMD	=5'd01,
				RD_FSR		=5'd02,
				JDFSR			=5'd03,
				WRIR_CMD		=5'd04,
				WR_IR			=5'd05,
				RDTXWD_CMD	=5'd06,
				RD_TX_WD		=5'd07,
				WRDIP_CMD	=5'd08,
				WR_DIP		=5'd09,
				WRDPORT_CMD	=5'd10,
				WR_DPORT		=5'd11,
				WRTXBUF_CMD	=5'd12,
				WR_TXBUF		=5'd13,
				WRTXWD_CMD	=5'd14,
				WR_TXWD		=5'd15,
				WRCR_CMD		=5'd16,
				WR_CR			=5'd17,
				RDIR_CMD		=5'd18,
				RD_IR			=5'd19,
				JDIR			=5'd20,
				END			=5'd21;
				
parameter 	SN_DIP		=32'hC0_A8_00_05,		//wangguan
				SN_DPORT		=16'd6000,			//ziwang
				SN_DSHAR		=48'h010203040506,//MAC
				SN_PORT		=16'd6000;			//IP				

reg	[04:00]		state	;
reg 	[04:00]		cnt;
reg	[15:00]		cnt_byte;
reg 	[15:00]		freesize;
reg 					bufsize_vld;
wire 					sendok;
wire					timeout;
reg 	[15:00]		wrcnt;
reg 	[15:00]		tx_ptr;

reg 	[31:00]		dip/*keep=noprune*/;
reg 	[15:00]		dport/*keep=noprune*/;
reg 	[15:00]		sport/*keep=noprune*/;

assign o_dat_rx_act=state==WRTXBUF_CMD;

assign o_ts=&state || &dip || &dport || &sport;
always@(posedge clk,negedge rst_n)
	if(!rst_n)
		state<=IDLE;
	else begin
		case(state)
			IDLE:
				if(dat_tx_req&&task_state=='d5)
					state<=RDFSR_CMD;
				else
					state<=END;
			RDFSR_CMD:
				state<=RD_FSR;		
			RD_FSR:
				if(wrend)
					state<=JDFSR;
				else
					state<=RD_FSR;
			JDFSR:
				if(bufsize_vld)
					state<=WRIR_CMD;
				else
					state<=END;
	      WRIR_CMD	:
				state<=WR_IR;
         WR_IR	:
				if(wrend)
					state<=RDTXWD_CMD;
				else
					state<=WR_IR;
         RDTXWD_CMD	:
				state<=RD_TX_WD;
         RD_TX_WD		:
				if(wrend)
					state<=WRDIP_CMD;
				else
					state<=RD_TX_WD;
         WRDIP_CMD	:	
				state<=WR_DIP;
         WR_DIP		:
				if(wrend)
					state<=WRDPORT_CMD;
				else
					state<=WR_DIP;
         WRDPORT_CMD	:
				state<=WR_DPORT;
         WR_DPORT		:
				if(wrend)
					state<=WRTXBUF_CMD;
				else
					state<=WR_DPORT;
         WRTXBUF_CMD	:
				state<=WR_TXBUF;
         WR_TXBUF		:
				if(wrend)
					state<=WRTXWD_CMD;
				else
					state<=WR_TXBUF;
         WRTXWD_CMD	:
				state<=WR_TXWD;
         WR_TXWD		:
				if(wrend)
					state<=WRCR_CMD;
				else
					state<=WR_TXWD;
         WRCR_CMD		:
				state<=WR_CR;
         WR_CR			:
				if(wrend)
					state<=RDIR_CMD;
				else
					state<=WR_CR;
         RDIR_CMD		:
				state<=RD_IR;
         RD_IR			:
				if(wrend)
					state<=JDIR;
				else
					state<=RD_IR;
         JDIR:	
				if(sendok||timeout)
					state<=END;
				else
					state<=RDIR_CMD;
         END:state<=IDLE;					
			default:state<=IDLE;
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
			RDFSR_CMD:begin //FSR
				o_start<='d1;
				o_cmd<=8'h08;
				o_addr<=`ADDR_SnFSR;
				o_length<='d2;			
			end
			WRIR_CMD:begin //IR
				o_start<='d1;
				o_cmd<=8'h0C;
				o_addr<=`ADDR_SnIR;
				o_length<='d1;
			end
			RDTXWD_CMD:begin //IR
				o_start<='d1;
				o_cmd<=8'h08;
				o_addr<=`ADDR_SnTXWR;
				o_length<='d2;
			end
			WRDIP_CMD:begin //IR
				o_start<='d1;
				o_cmd<=8'h0C;
				o_addr<=`ADDR_DIPR;
				o_length<='d4;
			end
			WRDPORT_CMD:begin //IR
				o_start<='d1;
				o_cmd<=8'h0C;
				o_addr<=`ADDR_DPORTR;
				o_length<='d2;
			end
			WRTXBUF_CMD:begin //IR
				o_start<='d1;
				o_cmd<=8'h14;
				o_addr<=tx_ptr;
				o_length<=txdat_len;
			end
			WRTXWD_CMD:begin //IR
				o_start<='d1;
				o_cmd<=8'h0C;
				o_addr<=`ADDR_SnTXWR;
				o_length<='d2;
			end
			WRCR_CMD:begin //IR
				o_start<='d1;
				o_cmd<=8'h0C;
				o_addr<=`ADDR_SnTX_CR;
				o_length<='d1;
			end
			RDIR_CMD:begin //IR
				o_start<='d1;
				o_cmd<=8'h08;
				o_addr<=`ADDR_SnIR;
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
			WR_IR:
				o_dat<=8'hFF;
			WR_DIP:
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
			WR_TXBUF:
				o_dat<=txdat;
			WR_TXWD:	
				if(rdreq)
					case(cnt_byte)
						'd00:o_dat<=tx_ptr[15:08];		
						'd01:o_dat<=tx_ptr[07:00];
						default:;
					endcase
				else
					o_dat<=o_dat;
			WR_CR:
				o_dat<=8'h20;		
			default:o_dat<=o_dat;
		endcase
	end
	
always@(posedge clk,negedge rst_n)
	if(!rst_n)
		cnt_byte<='d0;
	else begin
		case(state)
				WR_DIP,WR_DPORT,WR_TXBUF,WR_TXWD:
					if(rdreq)
						cnt_byte<=cnt_byte+'d1;
					else
						cnt_byte<=cnt_byte;		
				RD_FSR,RD_TX_WD,RD_IR:
					if(den)
						cnt_byte<=cnt_byte+'d1;
					else
						cnt_byte<=cnt_byte;	
			default:cnt_byte<='d0;
		endcase
	end


reg 	[15:00]	dinr;
reg				denr;
always@(posedge clk,negedge rst_n)
	if(!rst_n) 
		denr<='d0;
	else
		denr<=den;
	
always@(posedge clk,negedge rst_n)
	if(!rst_n) 
		dinr<='d0;
	else if(den)
		dinr<={dinr[07:00],din};
		
wire 				rdfsr_vld/*synthesis keep*/;	
wire 				rdtxwr_vld/*synthesis keep*/;	
wire 				rdir_vld/*synthesis keep*/;	
reg 	[07:00]	ir_dat/*synthesis noprune*/;	
assign	rdfsr_vld  = state==RD_FSR   && denr && cnt_byte=='d2;		
assign	rdtxwr_vld = state==RD_TX_WD && denr && cnt_byte=='d2;
assign   ir_vld	  = state==RD_IR    && denr && cnt_byte=='d1;

always@(posedge clk,negedge rst_n)
	if(!rst_n)
		freesize<='d0;
	else if(state==RD_FSR)
		if(rdfsr_vld)
			freesize<=dinr;
		else
			freesize<=freesize;
	else 
		freesize<=freesize;
		
always@(posedge clk,negedge rst_n)
	if(!rst_n)
		tx_ptr<='d0;
	else begin
		case(state)
				RD_TX_WD:
					if(rdtxwr_vld)
						tx_ptr<=dinr;
					else
						tx_ptr<=tx_ptr;
				WR_TXBUF:
					if(rdreq)
						tx_ptr<=tx_ptr+'d1;
					else
						tx_ptr<=tx_ptr;
				END:
					tx_ptr<='d0;
			default:tx_ptr<=tx_ptr;
		endcase	
	end

always@(posedge clk,negedge rst_n)
	if(!rst_n)
		ir_dat<='d0;
	else if(ir_vld)
		ir_dat<=din;
	else
		ir_dat<=ir_dat;
	
always@(posedge clk,negedge rst_n)
	if(!rst_n)
		bufsize_vld<='d0;	
	else if(freesize>=txdat_len)	
		bufsize_vld<='d1;	
	else
		bufsize_vld<='d0;	
		
assign sendok  = ir_dat[4];// state==RD_IR && den && din[4];
assign timeout = ir_dat[3];//state==RD_IR && den && din[3];
assign o_dat_rx_rden = state==WR_TXBUF && rdreq;
assign o_tx_end = state==END;

		
endmodule 