module w5500_top(
		input 					clk				,
		input 					rst_n				,
		//rx													
		output					o_rxdat_vld		,
		output 		[07:00]	o_rxdat			,
		output 					o_rxdat_end		,
		//tx
		output 					o_dat_tx_end	,
		input 	   			dat_tx_req		,
		output 					o_dat_tx_rden	,
		input 		[07:00]	dat				,
		input 		[15:00]	dat_len			,		
		//spi_drv
		input 					spi_miso			,
		output 					o_spi_cs			,
		output 					o_spi_sck		,
		output 					o_spi_mosi		,
		output 					o_w5500_rst	
);
wire 				ini_vld	;
wire 	[07:00]	ini_cmd	;
wire 	[15:00]	ini_addr	;
wire 	[07:00]	ini_dat	;
wire 	[15:00]	ini_len	;
wire 				ini_end	;

wire 				s1_vld	;
wire 	[07:00]	s1_cmd	;
wire 	[15:00]	s1_addr	;
wire 	[07:00]	s1_dat	;
wire 	[15:00]	s1_len	;
wire 				s1_ini_end	;
wire 				s1_tx_end;
wire 				s1_rx_end;

wire 				task_vld	;
wire 	[07:00]	task_cmd	;
wire 	[15:00]	task_addr;
wire 	[07:00]	task_dat	;
wire 	[15:00]	task_len	;
wire 				task_end	;

wire 	[03:00]	tast_state;

wire 	[07:00]	din		;
wire 				den		;

wire				opr_end	;
wire 				dat_req	;
wire 				ini_ctl	;
wire 				sn_ini_ctl;
task_sche
	untask_sche(
		.clk					( clk			),
		.rst_n				( rst_n		),		
		//iniw5500
		.ini_vld				( ini_vld	),
		.ini_cmd				( ini_cmd	),
		.ini_addr			( ini_addr	),
		.ini_dat				( ini_dat	),
		.ini_len				( ini_len	),
		.ini_end				( ini_end	),
		//socket		
		.sn_vld				( s1_vld		),
		.sn_cmd				( s1_cmd		),
		.sn_addr				( s1_addr	),
		.sn_dat				( s1_dat		),
		.sn_len				( s1_len		),
		.sn_ini_end			( s1_ini_end),
		.sn_tx_end			( s1_tx_end),
		.sn_rx_end			( s1_rx_end),
		//
		.o_ini_vld			( ini_ctl	),
		.o_sn_vld			( sn_ini_ctl),
		//W5500 IC		
		.o_wic_vld			( task_vld	),
		.o_wic_cmd			( task_cmd	),
		.o_wic_addr			( task_addr	),
		.o_wic_dat			( task_dat	),
		.o_wic_len			( task_len	),
		.o_task_state		( tast_state)
);                       	

spi_drv
	unspi_drv(
		.clk					( clk			),
		.rst_n				( rst_n		),
		.start				( task_vld	),
		.cmd					( task_cmd	),
		.addr					( task_addr	),
		.dat					( task_dat	),
		.length				( task_len	),
		
		.o_dat_vld			( den			),
		.o_dat				( din			),
		.o_dat_req			( dat_req	),
		.o_wr_end			( opr_end	),
		
		.spi_miso			( spi_miso	),
		.o_spi_cs			( o_spi_cs	),
		.o_spi_sck			( o_spi_sck	),
		.o_spi_mosi			( o_spi_mosi)		
);


ini_w5500
	unini_w5500(
		.clk					( clk			),
		.rst_n				( rst_n		),
		.ini_en				( ini_ctl		),
		.rdreq				( dat_req	),
		.den					( den				),
		.din					( din 			),
			
		.wrend				( opr_end	),	
		.o_start				( ini_vld	),	
		.o_cmd				( ini_cmd	),	
		.o_addr				( ini_addr	),	
		.o_length			( ini_len	),	
		.o_dat				( ini_dat	), 	
		.o_ini_end			( ini_end	),
		.o_w5500_rst		( o_w5500_rst),
		.o_ts					()
);

socket
	unsocket(
		.clk					( clk					),
		.rst_n				( rst_n				),
		//rx
		.o_rxdat_vld		( o_rxdat_vld		),
		.o_rxdat				( o_rxdat			),
		.o_rxdat_end		( o_rxdat_end		),
		//tx
		.o_dat_tx_end		( o_dat_tx_end		),
		.dat_tx_req			( dat_tx_req		),
		.o_dat_tx_rden		( o_dat_tx_rden	),
		.dat					( dat					),
		.dat_len				( dat_len			),	
		//task	
		.task_state			( tast_state	),
		.sn_ini_ctl			( sn_ini_ctl	),
		//spi_srv			
		.din					( din				),
		.den					( den				),
		.oprend				( opr_end		),
		.dat_req				( dat_req		),
		//	
		.o_sn_start			(s1_vld		),
		.o_sn_cmd			(s1_cmd		),
		.o_sn_addr			(s1_addr 	),
		.o_sn_dat			(s1_dat		),
		.o_sn_length		(s1_len		),
		.o_sn_ini_end		(s1_ini_end	),
		.o_sn_tx_end		(s1_tx_end	),
		.o_sn_rx_end		(s1_rx_end	)
);


endmodule
