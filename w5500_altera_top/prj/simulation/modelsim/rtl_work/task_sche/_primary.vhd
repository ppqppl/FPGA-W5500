library verilog;
use verilog.vl_types.all;
entity task_sche is
    generic(
        IDLE            : vl_logic_vector(0 to 3) := (Hi0, Hi0, Hi0, Hi0);
        DLY             : vl_logic_vector(0 to 3) := (Hi0, Hi0, Hi0, Hi1);
        INI_WIC         : vl_logic_vector(0 to 3) := (Hi0, Hi0, Hi1, Hi0);
        INI_SN          : vl_logic_vector(0 to 3) := (Hi0, Hi0, Hi1, Hi1);
        STAND_BY        : vl_logic_vector(0 to 3) := (Hi0, Hi1, Hi0, Hi0);
        SN_TX           : vl_logic_vector(0 to 3) := (Hi0, Hi1, Hi0, Hi1);
        SN_RX           : vl_logic_vector(0 to 3) := (Hi0, Hi1, Hi1, Hi0)
    );
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        ini_vld         : in     vl_logic;
        ini_cmd         : in     vl_logic_vector(7 downto 0);
        ini_addr        : in     vl_logic_vector(15 downto 0);
        ini_dat         : in     vl_logic_vector(7 downto 0);
        ini_len         : in     vl_logic_vector(15 downto 0);
        ini_end         : in     vl_logic;
        sn_vld          : in     vl_logic;
        sn_cmd          : in     vl_logic_vector(7 downto 0);
        sn_addr         : in     vl_logic_vector(15 downto 0);
        sn_dat          : in     vl_logic_vector(7 downto 0);
        sn_len          : in     vl_logic_vector(15 downto 0);
        sn_ini_end      : in     vl_logic;
        sn_tx_end       : in     vl_logic;
        sn_rx_end       : in     vl_logic;
        o_ini_vld       : out    vl_logic;
        o_sn_vld        : out    vl_logic;
        o_wic_vld       : out    vl_logic;
        o_wic_cmd       : out    vl_logic_vector(7 downto 0);
        o_wic_addr      : out    vl_logic_vector(15 downto 0);
        o_wic_dat       : out    vl_logic_vector(7 downto 0);
        o_wic_len       : out    vl_logic_vector(15 downto 0);
        o_task_state    : out    vl_logic_vector(3 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of IDLE : constant is 1;
    attribute mti_svvh_generic_type of DLY : constant is 1;
    attribute mti_svvh_generic_type of INI_WIC : constant is 1;
    attribute mti_svvh_generic_type of INI_SN : constant is 1;
    attribute mti_svvh_generic_type of STAND_BY : constant is 1;
    attribute mti_svvh_generic_type of SN_TX : constant is 1;
    attribute mti_svvh_generic_type of SN_RX : constant is 1;
end task_sche;
