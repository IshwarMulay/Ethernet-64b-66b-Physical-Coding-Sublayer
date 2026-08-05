import ethernet_pkg::*;

interface ethernet_if;

    logic           clk;
    logic           rst_n;
    
    logic [63:0]    txd;
    logic [7:0]     txc;
    logic           valid_in;

    logic [63:0]    rxd;
    logic [7:0]     rxc;
    logic           valid_out;
    logic           decode_error;

    logic [65:0]    encoded_data;
    logic           encoder_valid;
    
    logic [65:0]    descrambled_data;
    logic           descrambler_valid;




    clocking drv_cb @(posedge clk);
        output txd;
        output txc;
        output valid_in;
    endclocking

    clocking mon_cb @(posedge clk);

        input txd;
        input txc;
        input valid_in;

        input encoded_data;
        input encoder_valid;

        input descrambled_data;
        input descrambler_valid;

        input rxd;
        input rxc;
        input valid_out;
        input decode_error;

    endclocking


endinterface