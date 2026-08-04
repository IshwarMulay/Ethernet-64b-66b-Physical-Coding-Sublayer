`include "uvm_macros.svh"
import uvm_pkg::*;
import ethernet_pkg::*;


class ethernet_sequence extends uvm_sequence #(ethernet_transaction);

    `uvm_object_utils(ethernet_sequence)

    function new(string name = "ethernet_sequence");
        super.new(name);
    endfunction

    ethernet_transaction req_tr;

    virtual task body();
        repeat(10) begin
            req_tr = ethernet_transaction :: type_id :: create("req_tr");

            start_item(req_tr);

            if(!req_tr.randomize()) begin
                `uvm_info(get_type_name(), "Randomization Failed", UVM_MEDIUM)
            end
            else begin
                req_tr.command_type_in = DATA;
                `uvm_info(get_type_name(),
                    $sformatf("DATA = %0h CMD = %s",
                    req_tr.data_in, req_tr.command_type_in.name()), UVM_MEDIUM)
            end

            finish_item(req_tr);
        end

    endtask
endclass