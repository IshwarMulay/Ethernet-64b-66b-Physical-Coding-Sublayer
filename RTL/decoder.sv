`timescale 1ns/1ps

import ethernet_pkg::*;

module decoder(

    input  logic         clk,
    input  logic         rst_n,

    input  logic         valid_in,
    input  logic [65:0]  descrambled_data,

    output logic [63:0]  txd,
    output logic [7:0]   txc,
    output logic         valid_out,
    output logic         decode_error
);

logic [1:0] header;
logic [7:0] block_type;

always_ff @(posedge clk or negedge rst_n) begin

    if(!rst_n) begin

        txd          <= '0;
        txc          <= '0;
        valid_out    <= 0;
        decode_error <= 0;

    end

    else begin

        valid_out    <= 0;
        decode_error <= 0;

        if(valid_in) begin

            header     = descrambled_data[65:64];
            block_type = descrambled_data[63:56];

            // DATA BLOCK
            if(header == 2'b01) begin

                txd       <= descrambled_data[63:0];
                txc       <= 8'h00;
                valid_out <= 1;

            end

            // CONTROL BLOCK
            else if(header == 2'b10) begin

                case(block_type)

                    // IDLE
                    IDLE_BLOCK_TYPE:
                    begin
                        txd <= {8{8'h07}};
                        txc <= 8'hFF;
                        valid_out <= 1;
                    end

                    // START
                    START_BLOCK_TYPE:
                    begin
                        txd <= {
                            descrambled_data[55:0]
                            8'hFB
                        };

                        txc <= 8'b00000001;
                        valid_out <= 1;
                    end

                    // TERM0
                    TERM0_BLOCK_TYPE:
                    begin
                        txd <= {
                            8'h07,8'h07,8'h07,8'h07,
                            8'h07,8'h07,8'h07,8'hFD
                        };

                        txc <= 8'hFF;
                        valid_out <= 1;
                    end

                    // TERM1
                    TERM1_BLOCK_TYPE:
                    begin
                        txd <= {
                            8'h07,8'h07,8'h07,
                            8'h07,8'h07,8'h07,
                            8'hFD,
                            descrambled_data[55:48]
                        };

                        txc <= 8'b11111110;
                        valid_out <= 1;
                    end

                    // TERM2
                    TERM2_BLOCK_TYPE:
                    begin
                        txd <= {
                            8'h07,8'h07,8'h07,
                            8'h07,8'h07,
                            8'hFD,
                            descrambled_data[55:40]
                        };

                        txc <= 8'b11111100;
                        valid_out <= 1;
                    end

                    // TERM3
                    TERM3_BLOCK_TYPE:
                    begin
                        txd <= {
                            8'h07,8'h07,8'h07,
                            8'h07,
                            8'hFD,
                            descrambled_data[55:32]
                        };

                        txc <= 8'b11111000;
                        valid_out <= 1;
                    end

                    // TERM4
                    TERM4_BLOCK_TYPE:
                    begin
                        txd <= {
                            8'h07,8'h07,8'h07,
                            8'hFD,
                            descrambled_data[55:24]
                        };

                        txc <= 8'b11110000;
                        valid_out <= 1;
                    end

                    // TERM5
                    TERM5_BLOCK_TYPE:
                    begin
                        txd <= {
                            8'h07,8'h07,
                            8'hFD,
                            descrambled_data[55:16]
                        };

                        txc <= 8'b11100000;
                        valid_out <= 1;
                    end

                    // TERM6
                    TERM6_BLOCK_TYPE:
                    begin
                        txd <= {
                            8'h07,
                            8'hFD,
                            descrambled_data[55:8]
                        };

                        txc <= 8'b11000000;
                        valid_out <= 1;
                    end

                    // TERM7
                    TERM7_BLOCK_TYPE:
                    begin
                        txd <= {
                            8'hFD,
                            descrambled_data[55:0]
                        };

                        txc <= 8'b10000000;
                        valid_out <= 1;
                    end

                    // FAULT
                    FAULT_BLOCK_TYPE:
                    begin
                        txd <= {8{8'hFE}};
                        txc <= 8'hFF;
                        valid_out <= 1;
                    end

                    // UNKNOWN
                    default
                    begin
                        txd <= 64'd0;
                        txc <= 8'd0;
                        valid_out <= 1;
                        decode_error <= 1;
                    end

                endcase

            end

            else begin

                txd <= 64'd0;
                txc <= 8'd0;
                valid_out <= 1;
                decode_error <= 1;

            end

        end

    end

end

endmodule