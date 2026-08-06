`include "uvm_macros.svh"

import uvm_pkg::*;
import ethernet_pkg::*;

class ethernet_agent extends uvm_agent;

    `uvm_component_utils(ethernet_agent)

    ethernet_sequencer sequencer;
    ethernet_driver    driver;
    encoder_monitor    enc_mon;
    scr_descr_monitor  scr_descr_mon;
    decoder_monitor    dec_mon;

    function new(string name = "ethernet_agent",
                 uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        sequencer     = ethernet_sequencer::type_id::create("sequencer", this);
        driver        = ethernet_driver   ::type_id::create("driver", this);
        enc_mon       = encoder_monitor   ::type_id::create("enc_mon", this);
        scr_descr_mon = scr_descr_monitor ::type_id::create("scr_descr_mon", this);
        dec_mon       = decoder_monitor   ::type_id::create("decoder_monitor", this);

    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        driver.seq_item_port.connect(sequencer.seq_item_export);

    endfunction

endclass