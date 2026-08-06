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

    packet_result_t results[$];

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
                
        //for final output table
        packet_result_t result;

        // Queue Empty Check
        if(expected_queue.size() == 0) begin

            `uvm_error(get_type_name(),
                       "Expected Queue is Empty")

            return;

        end

        // Get Expected Transaction
        exp_tr = expected_queue.pop_front();

        total_packets++;

        //for final output table
        result.packet_no    = total_packets;
        result.txd          = exp_tr.txd;
        result.txc          = exp_tr.txc;
        result.rxd          = tr.rxd;
        result.rxc          = tr.rxc;
        result.valid_out    = tr.valid_out;
        result.decode_error = tr.decode_error;

        // Compare Expected vs Actual
        if ( ((exp_tr.txd == tr.rxd && exp_tr.txc == tr.rxc)||
              (tr.rxd == {8{8'hFE}} && tr.rxc == 8'hFF)) && 
              (tr.decode_error == 1'b0)
            )
        begin

            pass_count++;

            result.status = "PASS";
            results.push_back(result);

            `uvm_info(get_type_name(),

                $sformatf(
                    "PASS :\n TXD=%016h TXC=%02h",
                    tr.rxd,
                    tr.rxc),

                UVM_LOW);

        end
        else begin

            fail_count++;
            result.status = "FAIL";
            results.push_back(result);

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

        string report;

        super.report_phase(phase);

        report = "\n";
        report = {report,
    "==============================================================================================================\n"};

        report = {report,
        "No.   TXD                  TXC      RXD                  RXC      VALID      ERROR      STATUS\n"};

        report = {report,
    "==============================================================================================================\n"};

        foreach(results[i]) begin
            report = {report,
                $sformatf("%-5d %-20h %-8h %-20h %-8h %-10b %-10b %-10s\n",
                    results[i].packet_no,
                    results[i].txd,
                    results[i].txc,
                    results[i].rxd,
                    results[i].rxc,
                    results[i].valid_out,
                    results[i].decode_error,
                    results[i].status)
            };
        end

        report = {report,
    "==============================================================================================================\n"};

        report = {report,
            $sformatf("Summary : Total=%0d  Pass=%0d  Fail=%0d\n",
                total_packets,
                pass_count,
                fail_count)
        };

        report = {report,
    "=============================================================================================================="};

        `uvm_info(get_type_name(), report, UVM_NONE)

    endfunction

endclass