library verilog;
use verilog.vl_types.all;
entity socket is
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        task_state      : in     vl_logic_vector(3 downto 0);
        sn_ini_ctl      : in     vl_logic;
        den             : in     vl_logic;
        din             : in     vl_logic_vector(7 downto 0);
        oprend          : in     vl_logic;
        dat_req         : in     vl_logic;
        o_sn_start      : out    vl_logic;
        o_sn_cmd        : out    vl_logic_vector(7 downto 0);
        o_sn_addr       : out    vl_logic_vector(15 downto 0);
        o_sn_length     : out    vl_logic_vector(15 downto 0);
        o_sn_dat        : out    vl_logic_vector(7 downto 0);
        o_sn_ini_end    : out    vl_logic;
        o_sn_tx_end     : out    vl_logic;
        o_sn_rx_end     : out    vl_logic
    );
end socket;
