`include "uvm_macros.svh"
import uvm_pkg::*;
import ethernet_pkg::*;

class ethernet_transaction extends uvm_sequence_item;

    // Input Transaction Fields
    rand bit [63:0]      data_in;
    rand bit             valid_in;
    rand command_type_e  command_type_in;

    bit [63:0]           original_data;
    bit                  valid_out;
    command_type_e       command_type_out;


    // Output Transaction Fields
    function new(string name = "ethernet_transaction");
        super.new(name);
    endfunction

    // Factory Registration
    `uvm_object_utils_begin(ethernet_transaction)
        `uvm_field_int (data_in,        UVM_ALL_ON)
        `uvm_field_int (valid_in,       UVM_ALL_ON)
        `uvm_field_enum(command_type_e, command_type_in,  UVM_ALL_ON)
        `uvm_field_int (original_data,  UVM_ALL_ON)
        `uvm_field_int (valid_out,      UVM_ALL_ON)
        `uvm_field_enum(command_type_e, command_type_out, UVM_ALL_ON)
    `uvm_object_utils_end

    //Constraint
    constraint valid_c {
        valid_in == 1;
    }

endclass