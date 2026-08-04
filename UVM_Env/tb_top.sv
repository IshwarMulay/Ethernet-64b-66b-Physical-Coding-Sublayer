`timescale 1ns/1ps

`include "uvm_macros.svh"
import uvm_pkg::*;
import ethernet_pkg::*;

module tb_top;

    // Interface Instance
    ethernet_if vif();

    // DUT Instantiation
    top dut (
        .clk               (vif.clk),
        .rst_n             (vif.rst_n),
        .valid_in          (vif.valid_in),
        .data_in           (vif.data_in),
        .command_type      (vif.command_type_in),

        .original_data     (vif.original_data),
        .valid_out         (vif.valid_out),
        .command_type      (vif.command_type_out)
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