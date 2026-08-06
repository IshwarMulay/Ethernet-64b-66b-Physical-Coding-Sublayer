`include "uvm_macros.svh"

import uvm_pkg::*;
import ethernet_pkg::*;

class ethernet_test extends uvm_test;

    `uvm_component_utils(ethernet_test)

    ethernet_env env;

    data_sequence      data_seq;
    idle_sequence      idle_seq;
    start_sequence     start_seq;
    terminate_sequence term_seq;
    fault_sequence     fault_seq;
    invalid_sequence   invalid_seq;

    function new(string name = "ethernet_test",
                 uvm_component parent = null);
        super.new(name, parent);
    endfunction


    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        env = ethernet_env::type_id::create("env", this);

    endfunction


    task run_phase(uvm_phase phase);

        phase.raise_objection(this);

        //---------------------------------------
        // DATA
        //---------------------------------------
        data_seq = data_sequence::type_id::create("data_seq");
        data_seq.start(env.agent.sequencer);

        //---------------------------------------
        // IDLE
        //---------------------------------------
        idle_seq = idle_sequence::type_id::create("idle_seq");
        idle_seq.start(env.agent.sequencer);

        //---------------------------------------
        // START
        //---------------------------------------
        start_seq = start_sequence::type_id::create("start_seq");
        start_seq.start(env.agent.sequencer);

        //---------------------------------------
        // TERMINATE
        //---------------------------------------
        term_seq = terminate_sequence::type_id::create("term_seq");
        term_seq.start(env.agent.sequencer);

        //---------------------------------------
        // FAULT
        //---------------------------------------
        fault_seq = fault_sequence::type_id::create("fault_seq");
        fault_seq.start(env.agent.sequencer);

        //---------------------------------------
        // INVALID
        //---------------------------------------
        invalid_seq = invalid_sequence::type_id::create("invalid_seq");
        invalid_seq.start(env.agent.sequencer);

        wait(env.agent.dec_mon.received_packets ==
            env.agent.enc_mon.expected_packets);

        repeat(10)
            @(posedge env.agent.driver.vif.clk);

        phase.drop_objection(this);

    endtask

endclass