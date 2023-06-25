library verilog;
use verilog.vl_types.all;
entity spi_drv is
    generic(
        IDLE            : vl_logic_vector(0 to 3) := (Hi0, Hi0, Hi0, Hi0);
        PRE             : vl_logic_vector(0 to 3) := (Hi0, Hi0, Hi0, Hi1);
        WR_ADR          : vl_logic_vector(0 to 3) := (Hi0, Hi0, Hi1, Hi0);
        WR_CMD          : vl_logic_vector(0 to 3) := (Hi0, Hi0, Hi1, Hi1);
        WR_DAT          : vl_logic_vector(0 to 3) := (Hi0, Hi1, Hi0, Hi0);
        END1            : vl_logic_vector(0 to 3) := (Hi0, Hi1, Hi0, Hi1);
        END2            : vl_logic_vector(0 to 3) := (Hi0, Hi1, Hi1, Hi0);
        RD_DAT          : vl_logic_vector(0 to 3) := (Hi0, Hi1, Hi1, Hi1);
        DLY             : vl_logic_vector(0 to 3) := (Hi1, Hi0, Hi0, Hi0)
    );
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        start           : in     vl_logic;
        cmd             : in     vl_logic_vector(7 downto 0);
        addr            : in     vl_logic_vector(15 downto 0);
        length          : in     vl_logic_vector(15 downto 0);
        dat             : in     vl_logic_vector(7 downto 0);
        o_dat_vld       : out    vl_logic;
        o_dat           : out    vl_logic_vector(7 downto 0);
        o_dat_req       : out    vl_logic;
        o_wr_end        : out    vl_logic;
        spi_miso        : in     vl_logic;
        o_spi_cs        : out    vl_logic;
        o_spi_sck       : out    vl_logic;
        o_spi_mosi      : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of IDLE : constant is 1;
    attribute mti_svvh_generic_type of PRE : constant is 1;
    attribute mti_svvh_generic_type of WR_ADR : constant is 1;
    attribute mti_svvh_generic_type of WR_CMD : constant is 1;
    attribute mti_svvh_generic_type of WR_DAT : constant is 1;
    attribute mti_svvh_generic_type of END1 : constant is 1;
    attribute mti_svvh_generic_type of END2 : constant is 1;
    attribute mti_svvh_generic_type of RD_DAT : constant is 1;
    attribute mti_svvh_generic_type of DLY : constant is 1;
end spi_drv;
