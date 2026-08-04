`include "uvm_macros.svh"

import uvm_pkg::*;
import ethernet_pkg::*;

class ethernet_agent extends uvm_agent;
    `uvm_component_utils(ethernet_agent)

    function new (string name = "ethernet_agent", uvm_component parent)
        super.new(name, parent);
    endfunction

    ethernet_sequencer    sequencer;
    ethernet_driver       driver;
    ethernet_monitor      monitor;

    fucntion void build_phase(uvm_phase phase);
        super.build_phase(phase);

        sequencer = ethernet_sequencer :: type_id :: create("sequencer");
        driver    = ethernet_driver    :: type_id :: create("driver");
        monitor   = ethernet_monitor   :: type_id :: create("monitor");

    endfunction

    function void connect_phase (uvm_phase phase);
        super.new(phase);
        driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction
endclass