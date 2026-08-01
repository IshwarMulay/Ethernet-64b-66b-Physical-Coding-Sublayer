`timescale 1ns/1ps

import ethernet_pkg::*;

module decoder (

    // Clock and Reset
    input  logic           clk,
    input  logic           rst_n,

    // Input Interface (From Descrambler)
    input  logic           valid_in,
    input  logic [65:0]    descrambled_data,

    // Output Interface
    output logic [63:0]    original_data,
    output logic           valid_out,
    output command_type_e  command_type,

    // Terminate information
    output logic [2:0]     terminate_position,

    // Error indication
    output logic           decode_error
);

    // Decoder Logic

    always_ff @(posedge clk or negedge rst_n) begin

        if(!rst_n) begin
            original_data       <= '0;
            valid_out           <= 1'b0;
            command_type        <= DATA;
            terminate_position  <= 3'd0;
            decode_error        <= 1'b0;
        end

        else begin

            valid_out    <= 1'b0;
            decode_error <= 1'b0;

            if(valid_in) begin

                // DATA BLOCK
                if(descrambled_data[65:64] == 2'b01) begin

                    command_type       <= DATA;
                    original_data      <= descrambled_data[63:0];
                    terminate_position <= 3'd0;
                    valid_out          <= 1'b1;

                end


                // CONTROL BLOCK
                else if(descrambled_data[65:64] == 2'b10) begin

                    case(descrambled_data[63:56])

                        // IDLE BLOCK
                        IDLE_BLOCK_TYPE:
                        begin
                            command_type       <= IDLE;
                            original_data      <= 64'd0;
                            terminate_position <= 3'd0;
                            valid_out          <= 1'b1;
                        end

                        // START BLOCK
                        START_BLOCK_TYPE:
                        begin
                            command_type       <= START;
                            original_data      <= descrambled_data[55:0];
                            terminate_position <= 3'd0;
                            valid_out          <= 1'b1;
                        end

                        // TERMINATE BLOCKS
                        TERM0_BLOCK_TYPE:
                        begin
                            command_type       <= TERMINATE;
                            original_data      <= descrambled_data[55:0];
                            terminate_position <= 3'd0;
                            valid_out          <= 1'b1;
                        end

                        TERM1_BLOCK_TYPE:
                        begin
                            command_type       <= TERMINATE;
                            original_data      <= descrambled_data[55:0];
                            terminate_position <= 3'd1;
                            valid_out          <= 1'b1;
                        end

                        TERM2_BLOCK_TYPE:
                        begin
                            command_type       <= TERMINATE;
                            original_data      <= descrambled_data[55:0];
                            terminate_position <= 3'd2;
                            valid_out          <= 1'b1;
                        end

                        TERM3_BLOCK_TYPE:
                        begin
                            command_type       <= TERMINATE;
                            original_data      <= descrambled_data[55:0];
                            terminate_position <= 3'd3;
                            valid_out          <= 1'b1;
                        end

                        TERM4_BLOCK_TYPE:
                        begin
                            command_type       <= TERMINATE;
                            original_data      <= descrambled_data[55:0];
                            terminate_position <= 3'd4;
                            valid_out          <= 1'b1;
                        end

                        TERM5_BLOCK_TYPE:
                        begin
                            command_type       <= TERMINATE;
                            original_data      <= descrambled_data[55:0];
                            terminate_position <= 3'd5;
                            valid_out          <= 1'b1;
                        end

                        TERM6_BLOCK_TYPE:
                        begin
                            command_type       <= TERMINATE;
                            original_data      <= descrambled_data[55:0];
                            terminate_position <= 3'd6;
                            valid_out          <= 1'b1;
                        end

                        TERM7_BLOCK_TYPE:
                        begin
                            command_type       <= TERMINATE;
                            original_data      <= descrambled_data[55:0];
                            terminate_position <= 3'd7;
                            valid_out          <= 1'b1;
                        end

                        // FAULT BLOCK
                        FAULT_BLOCK:
                        begin
                            command_type       <= FAULT;
                            original_data      <= 64'd0;
                            terminate_position <= 3'd0;
                            valid_out          <= 1'b1;
                        end

                        // UNKNOWN CONTROL BLOCK
                        default:
                        begin
                            command_type       <= FAULT;
                            original_data      <= 64'd0;
                            terminate_position <= 3'd0;
                            valid_out          <= 1'b1;
                            decode_error       <= 1'b1;
                        end
                    endcase

                end

                // INVALID SYNC HEADER
                else begin
                    command_type       <= FAULT;
                    original_data      <= 64'd0;
                    terminate_position <= 3'd0;
                    valid_out          <= 1'b1;
                    decode_error       <= 1'b1;

                end
            end
        end
    end

endmodule