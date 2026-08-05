`include "uvm_macros.svh"
import uvm_pkg::*;
import ethernet_pkg::*;

class ethernet_env extends uvm_env;

    // Factory Registration
    `uvm_component_utils(ethernet_env)

    // Component Handles
    ethernet_agent      agent;

    // Constructor
    function new(string name = "ethernet_env", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    // Build Phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        agent      = ethernet_agent      ::type_id::create("agent", this);

    endfunction

endclass