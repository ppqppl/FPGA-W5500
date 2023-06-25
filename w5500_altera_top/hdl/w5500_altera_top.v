module w5500_altera_top(
		input 					clk			,
		input 					rst_n			,
		input 					spi_miso		,
		
		output 					o_spi_cs		,
		output 					o_spi_sck	,
		output 					o_spi_mosi	,
		output 					o_w5500_rst
);
 
wire 						rxdat_vld	;
wire  		[07:00]	rxdat			;
wire  					rxdat_end	;


wire 						dat_tx_end	;
wire 						dat_tx_req	;
wire 						dat_tx_rden	;
wire 			[07:00]	dat_tx		;	
wire 			[15:00]	dat_tx_len	;


dat_proces
	undat_proces(
		.clk					( clk				),
		.rst_n				( rst_n			),
		
		.rxdat_vld			( rxdat_vld		),
		.rxdat				( rxdat			),
		.rxdat_end			( rxdat_end		),
		
		.dat_tx_end			( dat_tx_end	),
		.o_dat_tx_req		( dat_tx_req	),
		.dat_tx_rden		( dat_tx_rden	),
		.o_dat				( dat_tx			),
		.o_dat_len			( dat_tx_len	),
		.o_ts					(					)
);


w5500_top
	unw5500_top(
		.clk					( clk				),
		.rst_n				( rst_n			),
	
		.o_rxdat_vld		( rxdat_vld		),
		.o_rxdat				( rxdat			),
		.o_rxdat_end		( rxdat_end		),
		
		.o_dat_tx_end		( dat_tx_end	),
		.dat_tx_req			( dat_tx_req	),
		.o_dat_tx_rden		( dat_tx_rden	),
		.dat					( dat_tx			),
		.dat_len				( dat_tx_len	),
		
		.spi_miso			( spi_miso		),
		.o_spi_cs			( o_spi_cs		),
		.o_spi_sck			( o_spi_sck		),
		.o_spi_mosi			( o_spi_mosi	),
		.o_w5500_rst		( o_w5500_rst)
);



endmodule 