`include "uvm_macros.svh"
import uvm_pkg::*;
import ethernet_pkg::*;

class ethernet_transaction extends uvm_sequence_item;

    // Input Transaction Fields
    rand bit [63:0]      txd;
    rand bit [7:0]       txc;
    rand bit             valid_in;

    // Output Transaction Fields
    bit [63:0]           rxd;
    bit [7:0]            rxc;
    bit                  valid_out;
    bit                  decode_error;

    bit [65:0]          encoded_data;
    bit                 encoder_valid;


    function new(string name = "ethernet_transaction");
        super.new(name);
    endfunction

    // Factory Registration
    `uvm_object_utils_begin(ethernet_transaction)
        `uvm_field_int (txd,          UVM_ALL_ON)
        `uvm_field_int (txc,          UVM_ALL_ON)
        `uvm_field_int (valid_in,     UVM_ALL_ON)
        `uvm_field_int (rxd,          UVM_ALL_ON)
        `uvm_field_int (rxc,          UVM_ALL_ON)
        `uvm_field_int (valid_out,    UVM_ALL_ON)
        `uvm_field_int (decode_error, UVM_ALL_ON)

        `uvm_field_int(encoded_data , UVM_ALL_ON)
        `uvm_field_int(encoder_valid, UVM_ALL_ON)
    `uvm_object_utils_end


    constraint valid_c {
        valid_in == 1;
    }

endclass