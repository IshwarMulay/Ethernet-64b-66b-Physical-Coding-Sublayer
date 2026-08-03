`include "uvm_macros.svh"

import uvm_pkg::*;
import ethernet_pkg::*;

class ethernet_monitor extends uvm_monitor;

    virtual ethernet_if vif;

    ethernet_transaction mon_tr;

    uvm_analysis_port #(ethernet_transaction) analysis_port;

    // Factory Registration
    `uvm_component_utils(ethernet_monitor)

    // Constructor
    function new(string name = "ethernet_monitor",
                 uvm_component parent = null);
        super.new(name, parent);

        analysis_port = new("analysis_port", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(virtual ethernet_if)::get(
                this, "", "vif", vif))
        begin
            `uvm_fatal(get_type_name(),
                       "Virtual Interface Not Found")
        end
    endfunction

    task run_phase(uvm_phase phase);

        forever begin

            @(vif.mon_cb);

            if (vif.mon_cb.valid_out) begin

                mon_tr = ethernet_transaction::type_id::create("mon_tr");

                mon_tr.original_data    = vif.mon_cb.original_data;
                mon_tr.valid_out        = vif.mon_cb.valid_out;
                mon_tr.command_type_out = vif.mon_cb.command_type_out;

                `uvm_info(get_type_name(),
                    $sformatf("Observed Transaction : DATA=%0h CMD=%s",
                              mon_tr.original_data,
                              mon_tr.command_type_out.name()),
                    UVM_MEDIUM)

                analysis_port.write(mon_tr);

            end

        end

    endtask

endclass