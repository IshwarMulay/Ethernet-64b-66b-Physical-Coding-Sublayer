`timescale 1ns/1ps

`include "uvm_macros.svh"
import uvm_pkg::*;
import ethernet_pkg::*;

interface ethernet_if;
    logic              clk;
    logic              rst_n;
    
    logic              valid_in;
    logic [63:0]       data_in;
    command_type_e     command_type_in;

    logic [63:0]       original_data;
    logic              valid_out;
    command_type_e     command_type_out;

    clocking dr_cb @(posedge clk);
        output valid_in;
        output data_in;
        output command_type_in;
    endclocking

    clocking mon_cb @(posedge clk);
        input original_data;
        input valid_out;
        input command_type_out;
    endclocking

endinterface

//=============================================================================


class ethernet_transaction extends uvm_sequence_item;

    // Input Transaction Fields
    rand bit [63:0]      data_in;
    rand bit             valid_in;
    rand command_type_e  command_type_in;

    bit [63:0]           original_data;
    bit                  valid_out;
    command_type_e       command_type_out;


    // Output Transaction Fields
    function new(string name = "ethernet_transaction");
        super.new(name);
    endfunction

    // Factory Registration
    `uvm_object_utils_begin(ethernet_transaction)
        `uvm_field_int (data_in,        UVM_ALL_ON)
        `uvm_field_int (valid_in,       UVM_ALL_ON)
        `uvm_field_enum(command_type_e, command_type_in,  UVM_ALL_ON)
        `uvm_field_int (original_data,  UVM_ALL_ON)
        `uvm_field_int (valid_out,      UVM_ALL_ON)
        `uvm_field_enum(command_type_e, command_type_out, UVM_ALL_ON)
    `uvm_object_utils_end

    //Constraint
    constraint valid_c {
        valid_in == 1;
    }

endclass

//=============================================================================

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

//=============================================================================

class ethernet_sequencer extends uvm_sequencer #(ethernet_transaction);

    //Factory Registration
    `uvm_component_utils(ethernet_sequencer)

    //Constructor
    function new(string name = "ethernet_sequencer",
                    uvm_component parent = null);
        super.new(name, parent);
    endfunction
endclass

//=============================================================================

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
                @(posedge vif.dr_cb);
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


//=============================================================================


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

//=============================================================================

class ethernet_agent extends uvm_agent;
    `uvm_component_utils(ethernet_agent)

    function new (string name = "ethernet_agent", uvm_component parent);
        super.new(name, parent);
    endfunction

    ethernet_sequencer    sequencer;
    ethernet_driver       driver;
    ethernet_monitor      monitor;

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        sequencer = ethernet_sequencer :: type_id :: create("sequencer", this);
        driver    = ethernet_driver    :: type_id :: create("driver", this);
        monitor   = ethernet_monitor   :: type_id :: create("monitor", this);

    endfunction

    function void connect_phase (uvm_phase phase);
        super.connect_phase(phase);
        driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction
endclass



//=============================================================================

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
            $sformatf("Mismatch Detected!\nExpected : DATA=%0h CMD=%s\nActual : DATA=%0h CMD=%s",
              exp_tr.data_in,
              exp_tr.command_type_in.name(),
              tr.original_data,
              tr.command_type_out.name()))

        end

    endfunction

endclass


//=============================================================================

class ethernet_env extends uvm_env;

    // Factory Registration
    `uvm_component_utils(ethernet_env)

    // Component Handles
    ethernet_agent      agent;
    ethernet_scoreboard scoreboard;

    // Constructor
    function new(string name = "ethernet_env", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    // Build Phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        agent      = ethernet_agent      ::type_id::create("agent", this);
        scoreboard = ethernet_scoreboard ::type_id::create("scoreboard", this);

    endfunction

    // Connect Phase
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        agent.driver.analysis_port.connect(scoreboard.expected_imp);

        agent.monitor.analysis_port.connect(scoreboard.actual_imp);

    endfunction

endclass


//=============================================================================

class ethernet_test extends uvm_test;
    
    `uvm_component_utils(ethernet_test)

    function new(string name = "ethernet_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    ethernet_env      env;
    ethernet_sequence seq;

    function void build_phase (uvm_phase phase);
        super.build_phase(phase);
        
        env = ethernet_env :: type_id :: create("env", this);

    endfunction

    task run_phase (uvm_phase phase);

        phase.raise_objection(this);

        // Create Sequence
        seq = ethernet_sequence::type_id::create("seq");

        // Start Sequence on Agent's Sequencer
        seq.start(env.agent.sequencer);
        
        repeat (700) @(posedge env.agent.driver.vif.clk);
        phase.drop_objection(this);
    endtask
endclass

//=============================================================================

module tb_top;

    // Interface Instance
    ethernet_if vif();

    // DUT Instantiation
    top dut (
        .clk               (vif.clk),
        .rst_n             (vif.rst_n),
        .valid_in          (vif.valid_in),
        .data_in           (vif.data_in),
        .command_type_in   (vif.command_type_in),

        .original_data     (vif.original_data),
        .valid_out         (vif.valid_out),
        .command_type_out  (vif.command_type_out)
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