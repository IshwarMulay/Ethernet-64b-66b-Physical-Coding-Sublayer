`include "uvm_macros.svh"

import uvm_pkg::*;
import ethernet_pkg::*;

class scr_descr_monitor extends uvm_monitor;

    `uvm_component_utils(scr_descr_monitor)

    virtual ethernet_if vif;

    logic [65:0] expected_queue[$];
    logic [65:0] expected_block;

    //for report generation
    scr_descr_result_t results[$];
    scr_descr_result_t result;

    int total_packets;
    int pass_count;
    int fail_count;

    function new(string name = "scr_descr_monitor",
                 uvm_component parent = null);
        super.new(name, parent);
    endfunction


    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if(!uvm_config_db#(virtual ethernet_if)::get(
            this,"","vif",vif))
        begin
            `uvm_fatal(get_type_name(),
                "Virtual Interface Not Found")
        end
    endfunction


    task run_phase(uvm_phase phase);

        forever begin

            @(vif.mon_cb);

            // Store every encoder output
            if(vif.mon_cb.encoder_valid) begin

                expected_queue.push_back(
                    vif.mon_cb.encoded_data
                );

                `uvm_info(get_type_name(),
                    $sformatf(
                    "\nEncoder Block Stored\nQueue Depth = %0d\nEncoded Block = %017h",
                     expected_queue.size(), vif.mon_cb.encoded_data),

                     UVM_LOW)

            end


            // Compare whenever descrambler completes one block
            if(vif.mon_cb.descrambler_valid) begin

                if(expected_queue.size()==0) begin

                    `uvm_error(get_type_name(),

                        "Expected Queue Empty")

                end
                else begin

                    expected_block = expected_queue.pop_front();

                    //for report generation
                    result.packet_no         = ++total_packets;
                    result.encoder_block     = expected_block;
                    result.descrambled_block = vif.mon_cb.descrambled_data;

                    if(expected_block ==
                       vif.mon_cb.descrambled_data) begin

                        pass_count++;
                        result.status = "PASS";

                        `uvm_info(get_type_name(),
                        $sformatf(
                        "SCR/DESCR PASS : \nExpected=%017h Actual=%017h Queue=%0d",
                        expected_block,
                        vif.mon_cb.descrambled_data,
                        expected_queue.size()),
                        UVM_LOW)

                    end
                    else begin

                        fail_count++;
                        result.status = "FAIL";

                        `uvm_error(get_type_name(),
                        $sformatf(
                        "SCR/DESCR FAIL : \nExpected=%017h Actual=%017h Queue=%0d",
                        expected_block,
                        vif.mon_cb.descrambled_data,
                        expected_queue.size()))
                    end

                end
                results.push_back(result);

            end

        end

    endtask

    function void report_phase(uvm_phase phase);
        string report;
        super.report_phase(phase);

        report = "\n";

        report = {report,
    "==============================================================================================================\n"};

        report = {report,
    "No.  Encoder Block       Descrambled Block    Status\n"};

        report = {report,
    "==============================================================================================================\n"};

        foreach(results[i]) begin

            report = {report,

            $sformatf("%-4d %-18h %-18h %-5s\n",

            results[i].packet_no,
            results[i].encoder_block,
            results[i].descrambled_block,
            results[i].status)};

        end

        report = {report,
    "==============================================================================================================\n"};

        report = {report,

            $sformatf("Total : %0d    Pass : %0d    Fail : %0d\n",

            total_packets,
            pass_count,
            fail_count)};

        report = {report,
    "=============================================================================================================="};

        `uvm_info(get_type_name(), report, UVM_NONE)

    endfunction

endclass