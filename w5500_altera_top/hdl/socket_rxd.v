`define     ADDR_SnCR        16'h0001     //socket 命令寄存器
`define     ADDR_SnRSR       16'h0026     //socket 接收长度寄存器  -Socket n 空闲接收缓存寄存器  -Socket n 接收缓存中已接收和保存的数据大小
`define     ADDR_SnRXRD      16'h0028     //socket 接收读指针寄存器

module socket_rxd(
		input 						clk			,
		input 						rst_n			,
		input 						rdreq			,
		input							den			,
		input 		[07:00]		din			,
		input 		[03:00]		task_state	,
		
		output 						o_rxdat_vld	,
		output 		[07:00]		o_rxdat			,
		output						o_rxdat_end	,
				
		input 						wrend			,
		output reg					o_start		,
		output reg		[07:00]	o_cmd			,
		output reg		[15:00]	o_addr		,
		output reg		[15:00]	o_length		,
		output reg		[07:00]	o_dat			,
		output 						o_rx_end		,
		output						o_ts
);

parameter 	IDLE					=6'd00,
				RDRXRSR_CMD			=6'd01,
				RD_RXRSR				=6'd02,
				JDRXRSR				=6'd03,
				RDRXRD_CMD			=6'd04,
				RD_RXRD				=6'd05,
				RDRXBUF_CMD			=6'd06,
				RD_RXBUF				=6'd07,
				WRRXRD_CMD			=6'd08,
				WR_RXRD				=6'd09,
				WRCR_CMD				=6'd10,
				WR_CR					=6'd11,
				END               =6'd12,
				RDRXWD_CMD			=6'd13,
				RD_RXWD				=6'd14;
                               
                               
reg		[05:00]		state;  
reg 		[15:00]		rsrsize;  
reg 		[15:00]		rx_ptr;
reg 		[15:00]		cnt_byte;
wire 						rx_vld;
reg 		[02:00]		rx_vldr;
reg 		[15:00]		wr_ptr/*synthesis noprune*/;		


assign o_ts=&state;
assign rx_vld= task_state=='d6;

always@(posedge clk,negedge rst_n)
	if(!rst_n)
		rx_vldr<='d0;
	else 
		rx_vldr<={rx_vldr[1:0],rx_vld};


always@(posedge clk,negedge rst_n)
	if(!rst_n)
		state<='d0;
	else begin
		case(state)
			IDLE:
				if(rx_vldr[2:1]==2'b01)
					state<=RDRXRSR_CMD;
				else
					state<=IDLE;
			RDRXRSR_CMD:
				state<=RD_RXRSR;
			RD_RXRSR		:
				if(wrend)
					state<=JDRXRSR;
				else
					state<=RD_RXRSR;
		   JDRXRSR	:
				if(rsrsize>0)
					state<=RDRXRD_CMD;
				else 
					state<=END;
	      RDRXRD_CMD	:
				state<=RD_RXRD;
         RD_RXRD		:
				if(wrend)
					state<=RDRXBUF_CMD;
				else
					state<=RD_RXRD;
         RDRXBUF_CMD	:
				state<=RD_RXBUF;
         RD_RXBUF		:
				if(wrend)
					state<=WRRXRD_CMD;
				else
					state<=RD_RXBUF;
         WRRXRD_CMD	:
				state<=WR_RXRD;
         WR_RXRD		:
				if(wrend)
					state<=WRCR_CMD;
				else
					state<=WR_RXRD;
         WRCR_CMD		:
				state<=WR_CR;
         WR_CR			:
				if(wrend)
					state<=RDRXWD_CMD;
				else
					state<=WR_CR;
			RDRXWD_CMD:
				state<=RD_RXWD;
			RD_RXWD:
				if(wrend)
					state<=END;
				else
					state<=RD_RXWD;
         END :state<=IDLE;        
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
			RDRXRSR_CMD:begin //RSR
				o_start<='d1;
				o_cmd<=8'h08;
				o_addr<=`ADDR_SnRSR;
				o_length<='d2;			
			end
			RDRXRD_CMD:begin //IR
				o_start<='d1;
				o_cmd<=8'h08;
				o_addr<=`ADDR_SnRXRD;
				o_length<='d2;
			end
			RDRXBUF_CMD:begin //IR
				o_start<='d1;
				o_cmd<=8'h18;
				o_addr<=rx_ptr;
				o_length<=rsrsize;
			end
			WRRXRD_CMD:begin //IR
				o_start<='d1;
				o_cmd<=8'h0C;
				o_addr<=`ADDR_SnRXRD;
				o_length<='d2;
			end
			WRCR_CMD:begin //IR
				o_start<='d1;
				o_cmd<=8'h0C;
				o_addr<=`ADDR_SnCR;
				o_length<='d2;
			end
			RDRXWD_CMD:begin //
				o_start<='d1;
				o_cmd<=8'h08;
				o_addr<=16'h002a;
				o_length<='d2;
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
			WR_RXRD:	
				if(rdreq)
					case(cnt_byte)
						'd00:o_dat<=rx_ptr[15:08];		
						'd01:o_dat<=rx_ptr[07:00];
						default:;
					endcase
				else
					o_dat<=o_dat;
			WR_CR:
				o_dat<=8'h40;		
			default:o_dat<=o_dat;
		endcase
	end
	
always@(posedge clk,negedge rst_n)
	if(!rst_n)
		cnt_byte<='d0;
	else begin
		case(state)
				WR_RXRD:
					if(rdreq)
						cnt_byte<=cnt_byte+'d1;
					else
						cnt_byte<=cnt_byte;		
				RD_RXRSR,RD_RXBUF,RD_RXWD:
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
		
wire 				rdrsr_vld/*synthesis keep*/;		
wire 				rdrxrd_vld/*synthesis keep*/;
wire 				rdrxwd_vld/*synthesis keep*/;	
assign	rdrsr_vld  = state==RD_RXRSR   && denr && cnt_byte=='d2;		
assign	rdrxrd_vld = state==RD_RXRD    && denr && cnt_byte=='d2;	
assign	rdrxwd_vld = state==RD_RXWD    && denr && cnt_byte=='d2;

always@(posedge clk,negedge rst_n)
	if(!rst_n)
		rsrsize<='d0;
	else if(state==RD_RXRSR)
		if(rdrsr_vld)
			rsrsize<=dinr;
		else
			rsrsize<=rsrsize;
	else if(state==END)
		rsrsize<='d0;
	else
		rsrsize<=rsrsize;
		
always@(posedge clk,negedge rst_n)
	if(!rst_n)
		rx_ptr<='d0;
	else begin
		case(state)
				RD_RXRD:
					if(rdrxrd_vld)
						rx_ptr<=dinr;
					else
						rx_ptr<=rx_ptr;
				RD_RXBUF:
					if(den)
						rx_ptr<=rx_ptr+'d1;
					else
						rx_ptr<=rx_ptr;
//				END:
//					rx_ptr<='d0;
			default:rx_ptr<=rx_ptr;
		endcase	
	end
	
always@(posedge clk,negedge rst_n)
	if(!rst_n)
		wr_ptr<='d0;	
	else if(state==RD_RXWD)
		if(rdrxwd_vld)
			wr_ptr<=dinr;
		else
			wr_ptr<=wr_ptr;
	else if(state==END)
		wr_ptr<='d0;	
	else
		wr_ptr<=wr_ptr;
		
assign o_rxdat_vld	= state==RD_RXBUF && den &&cnt_byte>='d8;	
assign o_rxdat			= din;
assign o_rxdat_end	= state==RD_RXBUF && wrend;		
assign o_rx_end = state==END;		
endmodule 