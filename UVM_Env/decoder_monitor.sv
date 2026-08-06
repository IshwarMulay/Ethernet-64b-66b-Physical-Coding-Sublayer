`include "uvm_macros.svh"

import uvm_pkg::*;
import ethernet_pkg::*;

class decoder_monitor extends uvm_monitor;

    `uvm_component_utils(decoder_monitor)

    virtual ethernet_if vif;

    uvm_analysis_port #(ethernet_transaction) analysis_port;

    ethernet_transaction mon_tr;

    int received_packets = 0;


    function new(string name = "decoder_monitor",
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

            // Decoder has produced one complete output block
            if(vif.mon_cb.valid_out || vif.mon_cb.decode_error) begin

                received_packets++;

                mon_tr = ethernet_transaction::type_id::create("mon_tr");

                // Decoder Outputs
                mon_tr.rxd          = vif.mon_cb.rxd;
                mon_tr.rxc          = vif.mon_cb.rxc;
                mon_tr.valid_out    = vif.mon_cb.valid_out;
                mon_tr.decode_error = vif.mon_cb.decode_error;

                `uvm_info(get_type_name(),

                $sformatf("DECODER : \nRXD=%016h RXC=%02h VALID=%0b ERROR=%0b",
                        mon_tr.rxd,
                        mon_tr.rxc,
                        mon_tr.valid_out,
                        mon_tr.decode_error),

                UVM_LOW)

                analysis_port.write(mon_tr);

            end

        end

    endtask

endclass