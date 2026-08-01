`timescale 1ns/1ps

import ethernet_pkg::*;

module xgmii_formatter (

    input  logic           clk,
    input  logic           rst_n,

    // Input from Decoder
    input  logic           valid_in,
    input  logic [63:0]    original_data,
    input  command_type_e  command_type,
    input  logic [2:0]     terminate_position,


    // XGMII RX Interface
    output logic [63:0]    rxd,
    output logic [7:0]     rxc,
    output logic           valid_out

);

always_ff @(posedge clk or negedge rst_n)
begin

    if(!rst_n)
    begin
        rxd       <= 64'd0;
        rxc       <= 8'd0;
        valid_out <= 1'b0;
    end

    else
    begin
        valid_out <= 1'b0;

        if(valid_in)
        begin
            valid_out <= 1'b1;

            case(command_type)

                // DATA BLOCK
                DATA:
                begin
                    rxd <= original_data;
                    // All 8 bytes are data
                    rxc <= 8'b00000000;

                end

                // IDLE BLOCK
                IDLE:
                begin
                    /*
                       XGMII:
                       Byte7 Byte6 ... Byte0
                       07 07 07 07 07 07 07 07
                       All are control characters
                    */
                    rxd <= {
                            8'h07,
                            8'h07,
                            8'h07,
                            8'h07,
                            8'h07,
                            8'h07,
                            8'h07,
                            8'h07
                           };
                    rxc <= 8'b11111111;
                end

                // START BLOCK
                START:
                begin
                    /*
                      Encoder format:
                      Byte0 = START (/S/)
                      Byte1-7 = DATA
                    */
                    rxd <= {
                            original_data[55:0],
                            8'hFB
                           };
                    rxc <= 8'b00000001;

                end

                // TERMINATE BLOCK
                TERMINATE:
                begin
                    case(terminate_position)
                        // T at byte0
                        3'd0:
                        begin
                            rxd <= {
                                    56'h07070707070707,
                                    8'hFD
                                   };
                            rxc <= 8'b11111111;
                        end

                        // T at byte1
                        3'd1:
                        begin
                            rxd <= {
                                    48'h070707070707,
                                    8'hFD,
                                    original_data[7:0]
                                   };
                            rxc <= 8'b11111110;
                        end

                        // T at byte2
                        3'd2:
                        begin
                            rxd <= {
                                    40'h0707070707,
                                    8'hFD,
                                    original_data[15:8],
                                    original_data[7:0]
                                   };
                            rxc <= 8'b11111100;
                        end

                        // T at byte3
                        3'd3:
                        begin
                            rxd <= {
                                    32'h07070707,
                                    8'hFD,
                                    original_data[23:16],
                                    original_data[15:8],
                                    original_data[7:0]
                                   };
                            rxc <= 8'b11111000;
                        end

                        // T at byte4
                        3'd4:
                        begin
                            rxd <= {
                                    24'h070707,
                                    8'hFD,
                                    original_data[31:24],
                                    original_data[23:16],
                                    original_data[15:8],
                                    original_data[7:0]
                                   };
                            rxc <= 8'b11110000;
                        end

                        // T at byte5
                        3'd5:
                        begin
                            rxd <= {
                                    16'h0707,
                                    8'hFD,
                                    original_data[39:32],
                                    original_data[31:24],
                                    original_data[23:16],
                                    original_data[15:8],
                                    original_data[7:0]
                                   };
                            rxc <= 8'b11100000;
                        end

                        // T at byte6
                        3'd6:
                        begin
                            rxd <= {
                                    8'h07,
                                    8'hFD,
                                    original_data[47:40],
                                    original_data[39:32],
                                    original_data[31:24],
                                    original_data[23:16],
                                    original_data[15:8],
                                    original_data[7:0]
                                   };
                            rxc <= 8'b11000000;
                        end

                        // T at byte7
                        3'd7:
                        begin
                            rxd <= {
                                    8'hFD,
                                    original_data[55:48],
                                    original_data[47:40],
                                    original_data[39:32],
                                    original_data[31:24],
                                    original_data[23:16],
                                    original_data[15:8],
                                    original_data[7:0]
                                   };
                            rxc <= 8'b10000000;
                        end

                        default:
                        begin
                            rxd <= 64'd0;
                            rxc <= 8'd0;
                        end
                    endcase
                end

                // FAULT BLOCK
                FAULT:
                begin
                    rxd <= {
                            8'hFE,
                            8'hFE,
                            8'hFE,
                            8'hFE,
                            8'hFE,
                            8'hFE,
                            8'hFE,
                            8'hFE
                           };
                    rxc <= 8'b11111111;
                end
                // DEFAULT
                default:
                begin
                    rxd <= 64'd0;
                    rxc <= 8'd0;

                end
            endcase
        end
    end
end

endmodule