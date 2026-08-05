`include "uvm_macros.svh"

import uvm_pkg::*;
import ethernet_pkg::*;

class ethernet_driver extends uvm_driver #(ethernet_transaction);

    // Factory Registration
    `uvm_component_utils(ethernet_driver)

    // Analysis Port (Expected Transaction to Scoreboard)
    uvm_analysis_port #(ethernet_transaction) analysis_port;

    // Virtual Interface
    virtual ethernet_if vif;

    // Transaction Handles
    ethernet_transaction req_tr;
    ethernet_transaction drv_tr;

    // Constructor
    function new(string name = "ethernet_driver",
                 uvm_component parent = null);
        super.new(name, parent);

        analysis_port = new("analysis_port", this);
    endfunction

    //=========================================================
    // Build Phase
    //=========================================================
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if(!uvm_config_db#(virtual ethernet_if)::get(this,
                                                     "",
                                                     "vif",
                                                     vif))
        begin
            `uvm_fatal(get_type_name(),
                       "Virtual Interface Not Found")
        end
    endfunction

    //=========================================================
    // Run Phase
    //=========================================================
    task run_phase(uvm_phase phase);

        // Drive default values
        vif.drv_cb.valid_in <= 1'b0;
        vif.drv_cb.txd      <= '0;
        vif.drv_cb.txc      <= '0;

        @(posedge vif.rst_n);

        forever begin

            // Get transaction from sequencer
            seq_item_port.get_next_item(req_tr);

            //-------------------------------------------------
            // Drive DUT Inputs
            //-------------------------------------------------
            @(vif.drv_cb);

            vif.drv_cb.txd      <= req_tr.txd;
            vif.drv_cb.txc      <= req_tr.txc;
            vif.drv_cb.valid_in <= req_tr.valid_in;

            //-------------------------------------------------
            // Send Expected Transaction to Scoreboard
            //-------------------------------------------------
            drv_tr = ethernet_transaction::type_id::create("drv_tr");
            drv_tr.copy(req_tr);

            analysis_port.write(drv_tr);

            //-------------------------------------------------
            // Print Transaction
            //-------------------------------------------------
            `uvm_info(get_type_name(),
                $sformatf("DRIVE : TXD = %016h  TXC = %02h  VALID = %0b",
                          req_tr.txd,
                          req_tr.txc,
                          req_tr.valid_in),
                UVM_LOW)

            //-------------------------------------------------
            // De-assert valid after one clock
            //-------------------------------------------------
            @(vif.drv_cb);

            vif.drv_cb.valid_in <= 1'b0;

            // Transaction Complete
            seq_item_port.item_done();

        end

    endtask

endclass