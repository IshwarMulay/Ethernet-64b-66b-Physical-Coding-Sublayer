`include "uvm_macros.svh"
import uvm_pkg::*;
import ethernet_pkg::*;

// Create two different analysis implementations
`uvm_analysis_imp_decl(_expected)
`uvm_analysis_imp_decl(_actual)

class ethernet_scoreboard extends uvm_scoreboard;

    // Factory Registration
    `uvm_component_utils(ethernet_scoreboard)

    // Analysis Implementations
    uvm_analysis_imp_expected #(ethernet_transaction, ethernet_scoreboard) expected_imp;
    uvm_analysis_imp_actual   #(ethernet_transaction, ethernet_scoreboard) actual_imp;

    // Queue to store expected transactions
    ethernet_transaction expected_queue[$];

    // Temporary transaction handle
    ethernet_transaction exp_tr;

    // Constructor
    function new(string name = "ethernet_scoreboard",
                 uvm_component parent = null);
        super.new(name, parent);

        expected_imp = new("expected_imp", this);
        actual_imp   = new("actual_imp", this);
    endfunction


    //=========================================================
    // Called by Driver (Expected Transactions)
    //=========================================================
    function void write_expected(ethernet_transaction tr);

        ethernet_transaction exp_copy;

        // Create a copy so the queue has its own object
        exp_copy = ethernet_transaction::type_id::create("exp_copy");
        exp_copy.copy(tr);

        expected_queue.push_back(exp_copy);

        `uvm_info(get_type_name(),
                  $sformatf("EXPECTED : DATA = %0h  CMD = %s",
                            exp_copy.data_in,
                            exp_copy.command_type_in.name()),
                  UVM_MEDIUM)

    endfunction


    //=========================================================
    // Called by Monitor (Actual Transactions)
    //=========================================================
    function void write_actual(ethernet_transaction tr);

        // Check queue is not empty
        if(expected_queue.size() == 0) begin
            `uvm_error(get_type_name(),
                       "Expected Queue is Empty!")
            return;
        end

        // Get oldest expected transaction
        exp_tr = expected_queue.pop_front();

        // Compare Data and Command Type
        if((exp_tr.data_in == tr.original_data) &&
           (exp_tr.command_type_in == tr.command_type_out))
        begin

            `uvm_info(get_type_name(),
                      $sformatf("PASS : DATA=%0h CMD=%s",
                                tr.original_data,
                                tr.command_type_out.name()),
                      UVM_LOW)

        end
        else begin

            `uvm_error(get_type_name(),
                $sformatf(
                "\nMismatch Detected!"
                "\nExpected : DATA=%0h CMD=%s"
                "\nActual   : DATA=%0h CMD=%s",
                exp_tr.data_in,
                exp_tr.command_type_in.name(),
                tr.original_data,
                tr.command_type_out.name()))

        end

    endfunction

endclass