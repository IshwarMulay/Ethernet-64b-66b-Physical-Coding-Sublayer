`include "uvm_macros.svh"
import uvm_pkg::*;
import ethernet_pkg::*;


//==============================================================
// DATA BLOCK SEQUENCE
//==============================================================

class data_sequence extends uvm_sequence #(ethernet_transaction);

    `uvm_object_utils(data_sequence)

    ethernet_transaction tr;

    function new(string name="data_sequence");
        super.new(name);
    endfunction

    virtual task body();

        repeat(20) begin

            tr = ethernet_transaction::type_id::create("tr");

            start_item(tr);

            assert(tr.randomize());

            tr.valid_in = 1;
            tr.txc      = 8'h00;

            finish_item(tr);

        end

    endtask

endclass


//==============================================================
// IDLE BLOCK SEQUENCE
//==============================================================

class idle_sequence extends uvm_sequence #(ethernet_transaction);

    `uvm_object_utils(idle_sequence)

    ethernet_transaction tr;

    function new(string name="idle_sequence");
        super.new(name);
    endfunction

    virtual task body();

        repeat(10) begin

            tr = ethernet_transaction::type_id::create("tr");

            start_item(tr);

            tr.valid_in = 1;
            tr.txc      = 8'hFF;
            tr.txd      = {8{8'h07}};

            finish_item(tr);

        end

    endtask

endclass


//==============================================================
// START BLOCK
//==============================================================

class start_sequence extends uvm_sequence #(ethernet_transaction);

    `uvm_object_utils(start_sequence)

    ethernet_transaction tr;

    function new(string name="start_sequence");
        super.new(name);
    endfunction

    virtual task body();

        repeat(10) begin

            tr = ethernet_transaction::type_id::create("tr");

            start_item(tr);

            assert(tr.randomize());

            tr.valid_in = 1;
            tr.txc      = 8'b00000001;
            tr.txd[7:0] = 8'hFB;

            finish_item(tr);

        end

    endtask

endclass


//==============================================================
// TERMINATE BLOCK
//==============================================================

class terminate_sequence extends uvm_sequence #(ethernet_transaction);

    `uvm_object_utils(terminate_sequence)

    ethernet_transaction tr;

    function new(string name="terminate_sequence");
        super.new(name);
    endfunction

    virtual task body();

        //---------------- TERM0 ----------------
        tr = ethernet_transaction::type_id::create("term0");
        start_item(tr);
        assert(tr.randomize());
        tr.valid_in = 1;
        tr.txc = 8'hFF;
        tr.txd = {8'h07,8'h07,8'h07,8'h07,8'h07,8'h07,8'h07,8'hFD};
        finish_item(tr);

        //---------------- TERM1 ----------------
        tr = ethernet_transaction::type_id::create("term1");
        start_item(tr);
        assert(tr.randomize());
        tr.valid_in = 1;
        tr.txc = 8'hFE;
        tr.txd[7:0]   = $urandom;
        tr.txd[15:8]  = 8'hFD;
        tr.txd[63:16] = {6{8'h07}};
        finish_item(tr);

        //---------------- TERM2 ----------------
        tr = ethernet_transaction::type_id::create("term2");
        start_item(tr);
        assert(tr.randomize());
        tr.valid_in = 1;
        tr.txc = 8'hFC;
        tr.txd[7:0]   = $urandom;
        tr.txd[15:8]  = $urandom;
        tr.txd[23:16] = 8'hFD;
        tr.txd[63:24] = {5{8'h07}};
        finish_item(tr);

        //---------------- TERM3 ----------------
        tr = ethernet_transaction::type_id::create("term3");
        start_item(tr);
        assert(tr.randomize());
        tr.valid_in = 1;
        tr.txc = 8'hF8;
        tr.txd[7:0]    = $urandom;
        tr.txd[15:8]   = $urandom;
        tr.txd[23:16]  = $urandom;
        tr.txd[31:24]  = 8'hFD;
        tr.txd[63:32]  = {4{8'h07}};
        finish_item(tr);

        //---------------- TERM4 ----------------
        tr = ethernet_transaction::type_id::create("term4");
        start_item(tr);
        assert(tr.randomize());
        tr.valid_in = 1;
        tr.txc = 8'hF0;
        tr.txd[7:0]    = $urandom;
        tr.txd[15:8]   = $urandom;
        tr.txd[23:16]  = $urandom;
        tr.txd[31:24]  = $urandom;
        tr.txd[39:32]  = 8'hFD;
        tr.txd[63:40]  = {3{8'h07}};
        finish_item(tr);

        //---------------- TERM5 ----------------
        tr = ethernet_transaction::type_id::create("term5");
        start_item(tr);
        assert(tr.randomize());
        tr.valid_in = 1;
        tr.txc = 8'hE0;
        tr.txd[7:0]    = $urandom;
        tr.txd[15:8]   = $urandom;
        tr.txd[23:16]  = $urandom;
        tr.txd[31:24]  = $urandom;
        tr.txd[39:32]  = $urandom;
        tr.txd[47:40]  = 8'hFD;
        tr.txd[63:48]  = {2{8'h07}};
        finish_item(tr);

        //---------------- TERM6 ----------------
        tr = ethernet_transaction::type_id::create("term6");
        start_item(tr);
        assert(tr.randomize());
        tr.valid_in = 1;
        tr.txc = 8'hC0;
        tr.txd[7:0]    = $urandom;
        tr.txd[15:8]   = $urandom;
        tr.txd[23:16]  = $urandom;
        tr.txd[31:24]  = $urandom;
        tr.txd[39:32]  = $urandom;
        tr.txd[47:40]  = $urandom;
        tr.txd[55:48]  = 8'hFD;
        tr.txd[63:56]  = 8'h07;
        finish_item(tr);

        //---------------- TERM7 ----------------
        tr = ethernet_transaction::type_id::create("term7");
        start_item(tr);
        assert(tr.randomize());
        tr.valid_in = 1;
        tr.txc = 8'h80;
        tr.txd[7:0]    = $urandom;
        tr.txd[15:8]   = $urandom;
        tr.txd[23:16]  = $urandom;
        tr.txd[31:24]  = $urandom;
        tr.txd[39:32]  = $urandom;
        tr.txd[47:40]  = $urandom;
        tr.txd[55:48]  = $urandom;
        tr.txd[63:56]  = 8'hFD;
        finish_item(tr);

    endtask

endclass


//==============================================================
// FAULT BLOCK
//==============================================================

class fault_sequence extends uvm_sequence #(ethernet_transaction);

    `uvm_object_utils(fault_sequence)

    ethernet_transaction tr;

    function new(string name="fault_sequence");
        super.new(name);
    endfunction

    virtual task body();

        repeat(5) begin

            tr = ethernet_transaction::type_id::create("tr");

            start_item(tr);

            tr.valid_in = 1;
            tr.txc      = 8'hFF;
            tr.txd      = {8{8'hFE}};

            finish_item(tr);

        end

    endtask

endclass


//==============================================================
// INVALID BLOCKS
//==============================================================

class invalid_sequence extends uvm_sequence #(ethernet_transaction);

    `uvm_object_utils(invalid_sequence)

    ethernet_transaction tr;

    function new(string name="invalid_sequence");
        super.new(name);
    endfunction

    virtual task body();

        repeat(20) begin

            tr = ethernet_transaction::type_id::create("tr");

            start_item(tr);

            assert(tr.randomize());

            tr.valid_in = 1;

            case($urandom_range(0,4))

                0: begin
                    tr.txc = 8'h00;
                    tr.txd[7:0] = 8'hFB;
                end

                1: begin
                    tr.txc = 8'h00;
                    tr.txd[15:8] = 8'hFD;
                end

                2: begin
                    tr.txc = 8'h55;
                end

                3: begin
                    tr.txc = 8'hAA;
                end

                4: begin
                    tr.txc = 8'h01;
                    tr.txd[7:0] = 8'h11;
                end

            endcase

            finish_item(tr);

        end

    endtask

endclass