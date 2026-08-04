`include "uvm_macros.svh"
import uvm_pkg::*;
import ethernet_pkg::*;

class ethernet_driver extends uvm_driver #(ethernet_transaction);
    //Factory registration
    `uvm_component_utils(ethernet_driver)

    uvm_analysis_port #(ethernet_transaction) analysis_port;

    //Default constructor
    function new(string name = "ethernet_driver", uvm_component parent = null);
        super.new(name, parent);
        analysis_port = new("analysis_port", this);
    endfunction

    virtual ethernet_if     vif;
    ethernet_transaction    req_tr;

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if(!uvm_config_db #(virtual ethernet_if) :: get(
                        this, "", "vif", vif))
            `uvm_fatal(get_type_name(), "Virtual Interface not Found")
    endfunction

    task run_phase (uvm_phase phase);
        
        forever begin
            seq_item_port.get_next_item(req_tr);
                @(posedge vif.drv_cb);
                    vif.data_in         <= req_tr.data_in;
                    vif.valid_in        <= req_tr.valid_in;
                    vif.command_type_in <= req_tr.command_type_in;

                    `uvm_info(get_type_name(),
                        $sformatf("Driving Transaction : DATA=%0h CMD=%s",
                                req_tr.data_in, req_tr.command_type_in.name()), UVM_MEDIUM)
                    
                    analysis_port.write(req_tr);
            seq_item_port.item_done();
        end
    endtask

endclass