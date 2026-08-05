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

        logic [65:0] expected_block;

        forever begin

            @(vif.mon_cb);

            if(vif.encoder_valid) begin

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
                    encoder_reference_model::generate_expected_block(

                        mon_tr.txd,
                        mon_tr.txc

                    );


                // Compare Expected vs Actual
                if(expected_block == mon_tr.encoded_data) begin

                    `uvm_info(get_type_name(),

                    $sformatf(

                    "\n\n\t\t\t\t        ENCODER VERIFICATION PASS\
                       --------------------------------------------------\
                       TXD = %016h\  TXC = %02h  Sync Header = %b\
                       Expected Block = %017h\
                       Actual Block   = %017h\
                       --------------------------------------------------",

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

                    "\n\n\t\t\t\t        ENCODER VERIFICATION FAIL\
                       --------------------------------------------------\
                       TXD = %016h\  TXC = %02h  Sync Header = %b\
                       Expected Block = %017h\
                       Actual Block   = %017h\
                       --------------------------------------------------",

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