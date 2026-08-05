`include "uvm_macros.svh"

import uvm_pkg::*;
import ethernet_pkg::*;


class encoder_monitor extends uvm_monitor;

    `uvm_component_utils(encoder_monitor)

    virtual ethernet_if vif;

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


    task run_phase(uvm_phase phase);

        forever begin

            @(vif.mon_cb);

            if(vif.mon_cb.encoder_valid) begin

                mon_tr = ethernet_transaction::type_id::create("mon_tr");

                // Encoder input
                mon_tr.txd       = vif.mon_cb.txd;
                mon_tr.txc       = vif.mon_cb.txc;
                mon_tr.valid_in  = vif.mon_cb.valid_in;

                // Encoder output
                mon_tr.encoded_data  = vif.mon_cb.encoded_data;
                mon_tr.encoder_valid = vif.mon_cb.encoder_valid;

                `uvm_info(get_type_name(),
                    $sformatf("Encoder Monitor : TXD=%016h TXC=%02h ENCODED_DATA=%017h",
                              mon_tr.txd,
                              mon_tr.txc,
                              mon_tr.encoded_data),
                    UVM_MEDIUM)

                analysis_port.write(mon_tr);

            end

        end

    endtask

endclass