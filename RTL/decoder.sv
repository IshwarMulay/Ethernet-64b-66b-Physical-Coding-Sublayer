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
    output command_type_e  command_type

);

    always_ff @(posedge clk or negedge rst_n) begin

        if (!rst_n) begin
            original_data <= '0;
            command_type  <= DATA;
        end

        else begin

            if (valid_in) begin

                // DATA BLOCK
                if (descrambled_data[65:64] == 2'b01) begin
                    command_type  <= DATA;
                    original_data <= descrambled_data[63:0];
                end

                // CONTROL BLOCK
                else if (descrambled_data[65:64] == 2'b10) begin

                    case (descrambled_data[63:56])

                        IDLE_BLOCK: begin
                            command_type  <= IDLE;
                            original_data <= 64'd0;
                        end

                        START_BLOCK: begin
                            command_type  <= START;
                            original_data <= 64'd0;
                        end

                        TERMINATE_BLOCK: begin
                            command_type  <= TERMINATE;
                            original_data <= 64'd0;
                        end

                        FAULT_BLOCK: begin
                            command_type  <= FAULT;
                            original_data <= 64'd0;
                        end

                        default: begin
                            command_type  <= DATA;
                            original_data <= 64'd0;
                        end

                    endcase

                end

                else begin
                    command_type  <= DATA;
                    original_data <= 64'd0;
                end
            end
        end
    end

endmodule