`include "uvm_macros.svh"
import uvm_pkg::*;
import ethernet_pkg::*;


class ethernet_sequencer extends uvm_sequencer #(ethernet_transaction);

    //Factory Registration
    `uvm_component_utils(ethernet_sequencer)

    //Constructor
    function new(string name = "ethernet_sequencer",
                    uvm_component parent = null);
        super.new(name, parent);
    endfunction
endclass