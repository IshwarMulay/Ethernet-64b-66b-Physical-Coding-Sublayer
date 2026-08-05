`timescale 1ns/1ps

`include "uvm_macros.svh"

// Interface
`include "ethernet_if.sv"

// Transaction
`include "encoder_reference_model.sv"
`include "ethernet_transaction.sv"
`include "ethernet_sequence.sv"
`include "ethernet_sequencer.sv"
`include "ethernet_driver.sv"
`include "encoder_monitor.sv"
`include "ethernet_agent.sv"
`include "ethernet_env.sv"
`include "ethernet_test.sv"

import uvm_pkg::*;
import ethernet_pkg::*;

module tb_top;

    // Interface Instance
    ethernet_if vif();

    // DUT Instantiation
    top dut (
        .clk           (vif.clk),
        .rst_n         (vif.rst_n),

        .txd           (vif.txd),
        .txc           (vif.txc),
        .valid_in      (vif.valid_in),

        .rxd           (vif.rxd),
        .rxc           (vif.rxc),
        .valid_out     (vif.valid_out),
        .decode_error  (vif.decode_error)
    );

    // Clock Generation
    initial begin
        vif.clk = 0;
        forever #5 vif.clk = ~vif.clk;
    end

    // Reset Generation
    initial begin
        vif.rst_n = 0;
        repeat(5) @(posedge vif.clk);
        vif.rst_n = 1;
    end

    // UVM Configuration and Test Start
    initial begin

        uvm_config_db#(virtual ethernet_if)::set(
            null, "*", "vif", vif);

        run_test("ethernet_test");

    end

endmodule