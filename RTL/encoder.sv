typedef enum logic [2:0] {
    DATA,
    IDLE,
    START,
    TERMINATE,
    FAULT
} command_type_e;


// IEEE Block Type Values Used
localparam logic [7:0] IDLE_BLOCK      = 8'h1E;
localparam logic [7:0] START_BLOCK     = 8'h33;
localparam logic [7:0] TERMINATE_BLOCK = 8'h87;   // Simplified: one terminate format
localparam logic [7:0] FAULT_BLOCK     = 8'hF0;   // Temporary project-specific value


module encoder(

    // Clock and Reset
    input  logic           clk,         
    input  logic           rst_n,  

    // Input Interface From Testbench
    input  logic           valid_in,     
    input  logic [63:0]    data_in,      
    input  command_type_e  command_type, 

    // Handshake Interface (From Scrambler)
    input  logic           ready,        // Scrambler is ready to accept next block

    // Output Interface (To Scrambler)
    output logic           valid_out,    
    output logic [65:0]    encoded_data
);


    always_ff @(posedge clk or negedge rst_n) begin

        if (!rst_n) begin
            valid_out    <= 1'b0;
            encoded_data <= '0;
        end

        else begin
            if (valid_in && ready) begin
                valid_out    <= 1'b1;

                case (command_type)
                    DATA: begin
                        encoded_data <= {2'b01, data_in};
                    end

                    IDLE: begin
                        encoded_data <= {2'b10, IDLE_BLOCK, 56'd0};
                    end

                    START: begin
                        encoded_data <= {2'b10, START_BLOCK, 56'd0};
                    end

                    TERMINATE: begin
                        encoded_data <= {2'b10, TERMINATE_BLOCK, 56'd0};
                    end

                    FAULT: begin
                        encoded_data <= {2'b10, FAULT_BLOCK, 56'd0};
                    end

                    default: begin
                        valid_out    <= 1'b0;
                        encoded_data <= 66'd0;
                    end
                endcase
            end
            
            else begin
                    valid_out <= 1'b0;
            end
        end      
    end
endmodule