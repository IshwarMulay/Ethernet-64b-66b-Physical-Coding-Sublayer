`include "uvm_macros.svh"

import uvm_pkg::*;
import ethernet_pkg::*;

class encoder_monitor extends uvm_monitor;

    `uvm_component_utils(encoder_monitor)

    virtual ethernet_if vif;

    int expected_packets = 0;

    uvm_analysis_port #(ethernet_transaction) analysis_port;

    ethernet_transaction mon_tr;

    function new(string name = "encoder_monitor",
                 uvm_component parent = null);

        super.new(name, parent);

        analysis_port = new("analysis_port", this);

    endfunction


    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        if(!uvm_config_db#(virtual ethernet_if)::get(
            this, "", "vif", vif))
        begin
            `uvm_fatal(get_type_name(),
                       "Virtual Interface Not Found")
        end

    endfunction

    function automatic logic [65:0] get_expected(

    input logic [63:0] txd,
    input logic [7:0]  txc

);

    // DATA BLOCK
    if (txc == 8'h00)
        return {2'b01, txd};

    // IDLE BLOCK
    if ((txc == 8'hFF) &&
        (txd == 64'h07070707_07070707))
        return {2'b10, IDLE_BLOCK_TYPE, 56'h0};

    // START BLOCK
    if ((txc == 8'h01) &&
        (txd[7:0] == 8'hFB))
        return {2'b10, START_BLOCK_TYPE, txd[63:8]};

    // TERMINATE 0
    if ((txc == 8'hFF) &&
        (txd == 64'h07070707_070707FD))
        return {2'b10, TERM0_BLOCK_TYPE, 56'h0};

    // TERMINATE 1
    if ((txc == 8'hFE) &&
        (txd[63:8] == 56'h07070707_0707FD))
        return {2'b10, TERM1_BLOCK_TYPE,
                txd[7:0], 48'h0};

    // TERMINATE 2
    if ((txc == 8'hFC) &&
        (txd[63:16] == 48'h07070707_07FD))
        return {2'b10, TERM2_BLOCK_TYPE,
                txd[15:0], 40'h0};

    // TERMINATE 3
    if ((txc == 8'hF8) &&
        (txd[63:24] == 40'h07070707_FD))
        return {2'b10, TERM3_BLOCK_TYPE,
                txd[23:0], 32'h0};

    // TERMINATE 4
    if ((txc == 8'hF0) &&
        (txd[63:32] == 32'h070707FD))
        return {2'b10, TERM4_BLOCK_TYPE,
                txd[31:0], 24'h0};

    // TERMINATE 5
    if ((txc == 8'hE0) &&
        (txd[63:40] == 24'h0707FD))
        return {2'b10, TERM5_BLOCK_TYPE,
                txd[39:0], 16'h0};

    // TERMINATE 6
    if ((txc == 8'hC0) &&
        (txd[63:48] == 16'h07FD))
        return {2'b10, TERM6_BLOCK_TYPE,
                txd[47:0], 8'h0};

    // TERMINATE 7
    if ((txc == 8'h80) &&
        (txd[63:56] == 8'hFD))
        return {2'b10, TERM7_BLOCK_TYPE,
                txd[55:0]};

    // Unsupported / Invalid Pattern
    return {2'b10, FAULT_BLOCK_TYPE, 56'h0};

endfunction


    task run_phase(uvm_phase phase);

        logic [65:0] expected_block;

        forever begin

            @(vif.mon_cb);

            if(vif.encoder_valid) begin
                
                expected_packets++;
                // Create Transaction
                mon_tr = ethernet_transaction::type_id::create("mon_tr");


                // Sample Encoder Input
                mon_tr.txd          = vif.mon_cb.txd;
                mon_tr.txc          = vif.mon_cb.txc;
                mon_tr.valid_in     = vif.mon_cb.valid_in;


                // Sample Encoder Output
                mon_tr.encoded_data  = vif.encoded_data;
                mon_tr.encoder_valid = vif.encoder_valid;


                // Generate Expected Encoded Block
                expected_block = 
                            get_expected(
                                mon_tr.txd,
                                mon_tr.txc
                    );


                // Compare Expected vs Actual
                if(expected_block == mon_tr.encoded_data) begin
                `uvm_info(get_type_name(),

                $sformatf(
                "ENCODER PASS : \nTXD=%016h TXC=%02h HDR=%02b\nEXP=%017h ACT=%017h",
                mon_tr.txd,
                mon_tr.txc,
                mon_tr.encoded_data[65:64],
                expected_block,
                mon_tr.encoded_data),

                UVM_LOW)

                end

                else begin
                `uvm_error(get_type_name(),

                $sformatf(
                "ENCODER FAIL : \nTXD=%016h TXC=%02h HDR=%02b\nEXP=%017h ACT=%017h",
                mon_tr.txd,
                mon_tr.txc,
                mon_tr.encoded_data[65:64],
                expected_block,
                mon_tr.encoded_data))

                end

            end

        end

    endtask

endclass