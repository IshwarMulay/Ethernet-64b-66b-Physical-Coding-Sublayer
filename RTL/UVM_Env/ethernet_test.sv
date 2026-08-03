`include "uvm_macros.svh"
import uvm_pkg::*;
import ethernet_pkg::*;

class ethernet_test extends uvm_test;
    
    `uvm_component_utils(ethernet_test)

    function new(string name = "ethernet_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    ethernet_env      env;
    ethernet_sequence seq;

    fucntion void build_phase (uvm_phase phase);
        super.build_phase(phase);
        
        env = ethernet_env :: type_id :: create("env");

    endfunction

    task run_phase (uvm_phase phase);

        phase.raise_objection(this);

        // Create Sequence
        seq = ethernet_sequence::type_id::create("seq");

        // Start Sequence on Agent's Sequencer
        seq.start(env.agent.sequencer);

        phase.drop_objection(this);
    endtask
endclass