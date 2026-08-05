`include "uvm_macros.svh"
import uvm_pkg::*;
import ethernet_pkg::*;

class ethernet_env extends uvm_env;

    // Factory Registration
    `uvm_component_utils(ethernet_env)

    // Component Handles
    ethernet_agent      agent;
    encoder_scoreboard encoder_sb;

    // Constructor
    function new(string name = "ethernet_env", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    // Build Phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        agent      = ethernet_agent      ::type_id::create("agent", this);
        encoder_sb = encoder_scoreboard  ::type_id::create("encoder_sb", this);

    endfunction

    // Connect Phase
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        agent.driver.analysis_port.connect(encoder_sb.expected_imp);

        agent.enc_mon.analysis_port.connect(encoder_sb.actual_imp);

    endfunction

endclass