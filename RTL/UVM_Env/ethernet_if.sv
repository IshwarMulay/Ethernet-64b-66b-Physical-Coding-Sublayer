import ethernet_pkg::*;

interface ethernet_if;
    logic                    clk;
    logic                    rst_n;
    
    logic                    valid_in;
    logic [63:0]             data_in;
    logic command_type_e     command_type_in;

    logic [63:0]             original_data;
    logic                    valid_out;
    logic command_type_e     command_type_out;

endinterface

clocking dr_cb @(posedge clk);
    output valid_in;
    output data_in;
    output command_type_in;
endclocking

clocking mon_cb @(posedge clk);
    input original_data;
    input valid_out;
    input command_type_out;
endclocking