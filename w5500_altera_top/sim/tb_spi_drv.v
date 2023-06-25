`timescale 1ns/1ns
module tb_spi_drv;

reg 		clk,rst_n;
reg			start;


initial begin
	clk=0;
	rst_n=0;
	start=0;
	#100
		rst_n=1;
	#100000
		@(posedge clk)
			start=1;
		@(posedge clk)
			start=0;
end

always #10 clk=~clk;


wire 				wr_end;
wire 				dat_req;
wire 	[7:0]		cmd;
wire 	[7:0]		dat;
wire 	[15:0]	length,addr;	
wire 				inien;
spi_drv
	unspi_drv(
		.clk			( clk	),
		.rst_n		( rst_n	),
		.start		( inien	),
		.cmd			( cmd),
		.addr			( addr),
		.length		( length),
		.dat			( dat),
		.o_dat_vld	(),
		.o_dat		(),
		.o_dat_req	(dat_req),
		.o_wr_end	(wr_end),
		.spi_miso	(),
		.o_spi_cs	(),
		.o_spi_sck	(),
		.o_spi_mosi	()		
);

ini_w5500
	unini_w5500(
		.clk				(clk),
		.rst_n			(rst_n),
		.ini_en			(start),
		.rdreq			(dat_req),
		.den				(),
		.din				(),
		
		.wrend			(wr_end),
		.o_start			(inien),
		.o_cmd			(cmd),
		.o_addr			(addr),
		.o_length		(length),
		.o_dat			(dat),
		.o_w5500_rst	()
);


endmodule 