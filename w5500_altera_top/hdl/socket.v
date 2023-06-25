module socket(
		input 						clk				,
		input 						rst_n				,
		//rx
		output						o_rxdat_vld		,
		output 			[07:00]	o_rxdat			,
		output 						o_rxdat_end		,
		//tx
		output 						o_dat_tx_end	,
		input 	   				dat_tx_req		,
		output 						o_dat_tx_rden	,
		input 			[07:00]	dat				,
		input 			[15:00]	dat_len			,			
		//task
		input				[03:00]	task_state		,
		input 						sn_ini_ctl		,
		//spi_srv		
		input 						den				,
		input 			[07:0]	din				,
		input 						oprend			,
		input 						dat_req			,
		//	
		output reg					o_sn_start		,
		output reg		[07:00]	o_sn_cmd			,
		output reg		[15:00]	o_sn_addr		,
		output reg		[15:00]	o_sn_length		,
		output reg		[07:00]	o_sn_dat			,
		output 						o_sn_ini_end	,
		output						o_sn_tx_end		,
		output 						o_sn_rx_end		
);

wire 					ini_vld ;	
wire 	[07:00]		ini_cmd ;	
wire 	[15:00]		ini_addr;	
wire 	[15:00]		ini_len ;	
wire 	[07:00]		ini_dat ;	

wire 					txd_vld ;	
wire 	[07:00]		txd_cmd ;	
wire 	[15:00]		txd_addr;	
wire 	[15:00]		txd_len ;	
wire 	[07:00]		txd_dat ;	
wire 					txd_end ;

wire 					rxd_vld ;	
wire 	[07:00]		rxd_cmd ;	
wire 	[15:00]		rxd_addr;	
wire 	[15:00]		rxd_len ;	
wire 	[07:00]		rxd_dat ;	
wire 					rxd_end ;	

always@(*)begin
	if(!rst_n)begin
		o_sn_start	<='d0;
	   o_sn_cmd		<='d0;
	   o_sn_addr	<='d0;
	   o_sn_length	<='d0;
	   o_sn_dat		<='d0;	
	end else begin
		case(task_state)
			'd3:begin
				o_sn_start	<=ini_vld ;
			   o_sn_cmd		<=ini_cmd ;
			   o_sn_addr	<=ini_addr;
			   o_sn_length	<=ini_len ;
			   o_sn_dat		<=ini_dat ;			
			end
			'd5:begin
				o_sn_start	<=txd_vld ;
			   o_sn_cmd		<=txd_cmd ;
			   o_sn_addr	<=txd_addr;
			   o_sn_length	<=txd_len ;
			   o_sn_dat		<=txd_dat ;			
			end
			'd6:begin
				o_sn_start	<=rxd_vld ;
			   o_sn_cmd		<=rxd_cmd ;
			   o_sn_addr	<=rxd_addr;
			   o_sn_length	<=rxd_len ;
			   o_sn_dat		<=rxd_dat ;			
			end
			default:begin
				o_sn_start	<='d0;
				o_sn_cmd		<='d0;
				o_sn_addr	<='d0;
				o_sn_length	<='d0;
				o_sn_dat		<='d0;	
			end 
		endcase
	end
end

ini_socket
	unini_socket(
		.clk					( clk				),
		.rst_n				( rst_n			),
		.ini_en				( sn_ini_ctl	),
		.rdreq				( dat_req		),
		.den					( den				),
		.din					( din 			),
				
		.wrend				( oprend			),
		.o_start				( ini_vld		),
		.o_cmd				( ini_cmd		),
		.o_addr				( ini_addr		),
		.o_length			( ini_len		),
		.o_dat				( ini_dat		),
		.o_ini_end			( o_sn_ini_end	),
		.o_ts					()
);
//reg 	[07:00]	txdat;
//wire 				dat_rx_rden;
//reg				txdat_vld;
//reg 				dat_tx_req;
socket_txd
	unsocket_txd(
		.clk					( clk				),
		.rst_n				( rst_n			),
		.rdreq				( dat_req		),
		.den					( den				),
		.din					( din				),
		.task_state			( task_state	),
		
		.txdat_vld			( 		),
		.txdat				( dat				),
		.txdat_len			( dat_len		),
		
		.dat_tx_req			( dat_tx_req	),//
		.o_dat_rx_act		( o_dat_tx_end ),
		.o_dat_rx_rden		( o_dat_tx_rden	),
		//spi_drv
		.wrend				( oprend			),
		.o_start				( txd_vld 		),
		.o_cmd				( txd_cmd 		),
		.o_addr				( txd_addr		),
		.o_length			( txd_len 		),
		.o_dat				( txd_dat 		),
		.o_tx_end			( o_sn_tx_end	),
		.o_ts					()
);

socket_rxd
	ubsocket_rxd(
		.clk					( clk				),
		.rst_n				( rst_n			),
		.rdreq				( dat_req		),
		.den					( den				),
		.din					( din				),
		.task_state			( task_state	),
			
		.o_rxdat_vld		( o_rxdat_vld	),
		.o_rxdat				( o_rxdat		),
		.o_rxdat_end		( o_rxdat_end	),

		.wrend				( oprend			),
		.o_start				( rxd_vld 		),
		.o_cmd				( rxd_cmd 		),
		.o_addr				( rxd_addr		),
		.o_length			( rxd_len 		),
		.o_dat				( rxd_dat 		),
		.o_rx_end			( o_sn_rx_end	),
		.o_ts					()
);


//always@(posedge clk,negedge rst_n)
//	if(!rst_n)
//		txdat_vld<='d0;
//	else
//		txdat_vld<=dat_rx_rden;
//		
//always@(posedge clk,negedge rst_n)
//	if(!rst_n)
//		txdat<='d0;
//	else if(dat_rx_rden)
//		txdat<=txdat+1;
//		
////assign o_sn_rx_end =1;
//
//
//reg 	[31:0]	cnt,cntms;
//always@(posedge clk,negedge rst_n)
//	if(!rst_n)
//		cnt<='d0;
//	else if(cnt==50_000)
//		cnt<='d0;
//	else 
//		cnt<=cnt+'d1;
//		
//always@(posedge clk,negedge rst_n)
//	if(!rst_n)
//		cntms<='d0;
//	else if(cnt==50_000)	
//		if(cntms==2000)
//			cntms<='d0;
//		else
//			cntms<=cntms+'d1;
//	else
//		cntms<=cntms;
//
//always@(posedge clk,negedge rst_n)
//	if(!rst_n)
//		dat_tx_req<='d0;
//	else if(cnt==50_000 && cntms==2000)
//		dat_tx_req<='d1;
//	else if(o_sn_tx_end)
//		dat_tx_req<='d0;
//		
		
			
endmodule 