`timescale 1ns/1ns
module tb_w5500_top;
reg 		clk,rst_n;

initial begin
	clk=0;
	rst_n=0;
	#100
		rst_n=1;
end

always #10 clk=~clk;

wire sck;
w5500_top
	unw5500_top(
		.clk				(clk),
		.rst_n			(rst_n),
	
		.spi_miso		(~sck),
		.o_spi_cs		(),
		.o_spi_sck		(sck),
		.o_spi_mosi		(),
		.o_w5500_rst	()
);

endmodule 