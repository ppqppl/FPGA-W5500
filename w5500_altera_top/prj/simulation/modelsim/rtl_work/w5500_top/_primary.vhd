library verilog;
use verilog.vl_types.all;
entity w5500_top is
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        spi_miso        : in     vl_logic;
        o_spi_cs        : out    vl_logic;
        o_spi_sck       : out    vl_logic;
        o_spi_mosi      : out    vl_logic;
        o_w5500_rst     : out    vl_logic
    );
end w5500_top;
