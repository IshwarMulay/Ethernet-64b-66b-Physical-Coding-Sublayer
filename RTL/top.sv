import ethernet_pkg::*;

module top(
    // Clock and Reset
    input  logic           clk,         
    input  logic           rst_n,  

    // Input Interface From Testbench
    input  logic           valid_in,     
    input  logic [63:0]    data_in,      
    input  logic [2:0]     command_type_in, 

    output logic [63:0]    original_data,
    output command_type_e  command_type_out
);

logic           scrambler_ready;
logic           encoder_valid;
logic [65:0]    encoded_data;

logic           scrambled_bit;
logic           scrambler_v_out;

logic           descrambler_v_out;
logic [65:0]    descrambled_data;


encoder dut_encoder(
    .clk              (clk),
    .rst_n            (rst_n),
    .valid_in         (valid_in),
    .data_in          (data_in),
    .command_type     (command_type_in),
    .ready            (scrambler_ready),
    .valid_out        (encoder_valid),
    .encoded_data     (encoded_data)
);

scrambler dut_scrambler(
    .clk              (clk),
    .rst_n            (rst_n),
    .valid_in         (encoder_valid),
    .encoded_data     (encoded_data),
    .scrambled_bit    (scrambled_bit),
    .valid_out        (scrambler_v_out),
    .ready            (scrambler_ready)
);

descrambler dut_descrambler(
    .clk              (clk),
    .rst_n            (rst_n),
    .valid_in         (scrambler_v_out),
    .scrambled_bit    (scrambled_bit), 
    .valid_out        (descrambler_v_out),
    .descrambled_data (descrambled_data)  
);

decoder dut_decoder(
    .clk              (clk),
    .rst_n            (rst_n),
    .valid_in         (descrambler_v_out),
    .descrambled_data (descrambled_data),
    .original_data    (original_data),
    .command_type     (command_type_out)
);

endmodule