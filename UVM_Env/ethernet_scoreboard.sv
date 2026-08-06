`include "uvm_macros.svh"

import uvm_pkg::*;
import ethernet_pkg::*;

`uvm_analysis_imp_decl(_expected)
`uvm_analysis_imp_decl(_actual)

class ethernet_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(ethernet_scoreboard)

    // Analysis Imports
    uvm_analysis_imp_expected #(ethernet_transaction,
                                ethernet_scoreboard) expected_imp;

    uvm_analysis_imp_actual #(ethernet_transaction,
                              ethernet_scoreboard) actual_imp;

    // Expected Transaction Queue
    ethernet_transaction expected_queue[$];

    // Statistics
    int total_packets;
    int pass_count;
    int fail_count;


    function new(string name = "ethernet_scoreboard",
                 uvm_component parent = null);

        super.new(name, parent);

        expected_imp = new("expected_imp", this);
        actual_imp   = new("actual_imp", this);

        total_packets = 0;
        pass_count    = 0;
        fail_count    = 0;

    endfunction

    //==========================================================
    // Receive Expected Transaction from Driver
    //==========================================================
    function void write_expected(ethernet_transaction tr);

        ethernet_transaction exp_tr;

        exp_tr = ethernet_transaction::type_id::create("exp_tr");

        // Copy transaction
        exp_tr.copy(tr);

        // Store in queue
        expected_queue.push_back(exp_tr);

        `uvm_info(get_type_name(),

            $sformatf("EXPECTED : TXD=%016h TXC=%02h Queue=%0d",
                      exp_tr.txd,
                      exp_tr.txc,
                      expected_queue.size()),

            UVM_HIGH)

    endfunction

    //==========================================================
    // Receive Actual Transaction from Decoder Monitor
    //==========================================================
    function void write_actual(ethernet_transaction tr);

        ethernet_transaction exp_tr;

        // Queue Empty Check
        if(expected_queue.size() == 0) begin

            `uvm_error(get_type_name(),
                       "Expected Queue is Empty")

            return;

        end

        // Get Expected Transaction
        exp_tr = expected_queue.pop_front();

        total_packets++;

        // Compare Expected vs Actual
        if((exp_tr.txd == tr.rxd) &&
           (exp_tr.txc == tr.rxc) &&
           (tr.decode_error == 1'b0))
        begin

            pass_count++;

            `uvm_info(get_type_name(),

                $sformatf(
                    "\nPASS : TXD=%016h TXC=%02h",
                    tr.rxd,
                    tr.rxc),

                UVM_LOW);

        end
        else begin

            fail_count++;

            `uvm_error(get_type_name(),

                $sformatf(
                    "FAIL\nExpected : TXD=%016h TXC=%02h\nActual   : RXD=%016h RXC=%02h\nDecode Error = %0b",
                    exp_tr.txd,
                    exp_tr.txc,
                    tr.rxd,
                    tr.rxc,
                    tr.decode_error));

        end

    endfunction

    //==========================================================
    // Final Report
    //==========================================================
    function void report_phase(uvm_phase phase);

        super.report_phase(phase);

        `uvm_info(get_type_name(),

            $sformatf(

            "\n========================================\
             \n      ETHERNET SCOREBOARD SUMMARY\
             \n========================================\
             \nTotal Packets : %0d\
             \nPassed        : %0d\
             \nFailed        : %0d\
             \n========================================",

             total_packets,
             pass_count,
             fail_count),

             UVM_NONE)

    endfunction

endclass