`include "uvm_macros.svh"

import uvm_pkg::*;
import ethernet_pkg::*;

`uvm_analysis_imp_decl(_expected)
`uvm_analysis_imp_decl(_actual)

class encoder_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(encoder_scoreboard)

    // Analysis ports
    uvm_analysis_imp_expected #(ethernet_transaction,
                                encoder_scoreboard) expected_imp;

    uvm_analysis_imp_actual #(ethernet_transaction,
                              encoder_scoreboard) actual_imp;

    // Queue
    ethernet_transaction expected_queue[$];

    // Constructor
    function new(string name = "encoder_scoreboard",
                 uvm_component parent = null);

        super.new(name, parent);

        expected_imp = new("expected_imp", this);
        actual_imp   = new("actual_imp", this);

    endfunction


    //==========================================================
    // Driver writes expected transactions
    //==========================================================
    function void write_expected(ethernet_transaction tr);

        ethernet_transaction exp_tr;

        exp_tr = ethernet_transaction::type_id::create("exp_tr");

        exp_tr.copy(tr);

        expected_queue.push_back(exp_tr);

    endfunction


    //==========================================================
    // Character Decoder (Reference Model)
    //==========================================================
    function automatic character_t decode_character(

        input logic [7:0] byte_data,
        input logic       control

    );

        if(!control)
            return CH_DATA;

        unique case(byte_data)

            8'h07 : return CH_IDLE;
            8'hFB : return CH_START;
            8'hFD : return CH_TERM;
            8'hFE : return CH_ERROR;
            8'h9C : return CH_SEQ_OS;

            default : return CH_UNKNOWN;

        endcase

    endfunction


    //==========================================================
    // Detect Terminate Position
    //==========================================================
    function automatic logic [2:0] detect_term_pos(

        input character_t char_type[8]

    );

        for(int i=0;i<8;i++) begin

            if(char_type[i]==CH_TERM)
                return i[2:0];

        end

        return 3'd0;

    endfunction


    //==========================================================
    // Validate Terminate Pattern
    //==========================================================
    function automatic logic valid_terminate(

        input character_t char_type[8]

    );

        logic found_term;

        found_term = 0;

        for(int i=0;i<8;i++) begin

            if(!found_term) begin

                if(char_type[i]==CH_TERM)
                    found_term = 1;

                else if(char_type[i]!=CH_DATA)
                    return 0;

            end
            else begin

                if(char_type[i]!=CH_IDLE)
                    return 0;

            end

        end

        return found_term;

    endfunction


    //==========================================================
    // Block Detector
    //==========================================================
    function automatic block_type_t detect_block_type(

        input character_t char_type[8]

    );

        logic all_data;
        logic all_idle;
        logic found_term;

        all_data   = 1;
        all_idle   = 1;
        found_term = 0;

        for(int i=0;i<8;i++) begin

            if(char_type[i]!=CH_DATA)
                all_data = 0;

            if(char_type[i]!=CH_IDLE)
                all_idle = 0;

            if(char_type[i]==CH_TERM)
                found_term = 1;

        end


        // DATA BLOCK
        if(all_data)
            return BLK_DATA;


        // IDLE BLOCK
        if(all_idle)
            return BLK_IDLE;


        // START BLOCK
        if(char_type[0]==CH_START &&
           char_type[1]==CH_DATA  &&
           char_type[2]==CH_DATA  &&
           char_type[3]==CH_DATA  &&
           char_type[4]==CH_DATA  &&
           char_type[5]==CH_DATA  &&
           char_type[6]==CH_DATA  &&
           char_type[7]==CH_DATA)

            return BLK_START;


        // TERMINATE BLOCK
        if(found_term) begin

            if(valid_terminate(char_type))
                return BLK_TERMINATE;

        end


        // ERROR BLOCK
        return BLK_ERROR;

    endfunction


    //==========================================================
    // Payload Formatter
    //==========================================================

    function automatic logic [63:0] format_data(
        input logic [63:0] txd
    );
        return txd;
    endfunction


    function automatic logic [63:0] format_idle();

        return {IDLE_BLOCK_TYPE,56'h0};

    endfunction


    function automatic logic [63:0] format_start(
        input logic [63:0] txd
    );

        return {START_BLOCK_TYPE,txd[63:8]};

    endfunction


    function automatic logic [63:0] format_terminate(

        input logic [63:0] txd,
        input logic [2:0]  term_pos

    );

        logic [63:0] payload;

        unique case(term_pos)

            3'd0 : payload = {TERM0_BLOCK_TYPE,56'h0};

            3'd1 : payload = {TERM1_BLOCK_TYPE,
                              txd[7:0],
                              48'h0};

            3'd2 : payload = {TERM2_BLOCK_TYPE,
                              txd[15:0],
                              40'h0};

            3'd3 : payload = {TERM3_BLOCK_TYPE,
                              txd[23:0],
                              32'h0};

            3'd4 : payload = {TERM4_BLOCK_TYPE,
                              txd[31:0],
                              24'h0};

            3'd5 : payload = {TERM5_BLOCK_TYPE,
                              txd[39:0],
                              16'h0};

            3'd6 : payload = {TERM6_BLOCK_TYPE,
                              txd[47:0],
                              8'h0};

            3'd7 : payload = {TERM7_BLOCK_TYPE,
                              txd[55:0]};

            default : payload = 64'd0;

        endcase

        return payload;

    endfunction


    //==========================================================
    // Generate Expected Encoded Block
    //==========================================================

    function automatic logic [65:0] generate_expected_block(

        input logic [63:0] txd,
        input logic [7:0]  txc

    );

        character_t  char_type[8];

        block_type_t block_type;

        logic [2:0]  term_pos;

        logic [63:0] payload;

        logic [1:0]  header;

        logic        control;


        // Character Decode

        for(int i=0;i<8;i++) begin

            control = txc[i];

            char_type[i] =
                decode_character(
                    txd[(8*i)+:8],
                    control
                );

        end


        // Detect Block

        block_type = detect_block_type(char_type);

        term_pos   = detect_term_pos(char_type);


        // Generate Payload

        unique case(block_type)

            BLK_DATA :
                payload = format_data(txd);

            BLK_IDLE :
                payload = format_idle();

            BLK_START :
                payload = format_start(txd);

            BLK_TERMINATE :
                payload = format_terminate(
                                txd,
                                term_pos
                          );

            BLK_ERROR :
                payload = {FAULT_BLOCK_TYPE,56'h0};

            default :
                payload = 64'd0;

        endcase


        // Header

        if(block_type==BLK_DATA)
            header = 2'b01;
        else
            header = 2'b10;


        return {header,payload};

    endfunction


    //==========================================================
    // Compare DUT Output
    //==========================================================

    function void write_actual(

        ethernet_transaction tr

    );

        ethernet_transaction exp_tr;

        logic [65:0] expected_block;


        if(expected_queue.size()==0) begin

            `uvm_error(get_type_name(),
                "Expected Queue Empty")

            return;

        end


        exp_tr = expected_queue.pop_front();


        expected_block =
            generate_expected_block(
                exp_tr.txd,
                exp_tr.txc
            );


        if(expected_block==tr.encoded_data) begin

            `uvm_info(get_type_name(),

                $sformatf(
                "PASS\nTXD=%016h\nTXC=%02h\nENCODED=%017h",

                exp_tr.txd,
                exp_tr.txc,
                tr.encoded_data),

                UVM_LOW)

        end

        else begin

            `uvm_error(get_type_name(),

            $sformatf(

            "\nEncoder Mismatch"

            "\nTXD      = %016h"

            "\nTXC      = %02h"

            "\nExpected = %017h"

            "\nActual   = %017h",

            exp_tr.txd,

            exp_tr.txc,

            expected_block,

            tr.encoded_data

            ))

        end

    endfunction

endclass