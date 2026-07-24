module scrambler (
    input logic clk,
    input logic rst_n,

    input logic valid_in,
    input logic [65:0] encoded_data,

    output logic scrambled_bit,
    output logic valid_out,
    output logic ready
);
    //Internal Registers
    // Stores the 66-bit block received from the encoder
    logic [1:0]  sync_header;
    logic [63:0] shift_reg;

    // Stores the previous scrambled bits (history register)
    logic [57:0] history_reg;

    logic [6:0]  bit_count;
    logic scramble_bit_next;

    
    assign scramble_bit_next = shift_reg[63] ^ history_reg[57] ^ history_reg[38];

    typedef enum logic [1:0] {
        IDLE,
        LOAD,
        SHIFT,
        DONE
    } state_t;

    state_t current_state, next_state;

    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            current_state <= IDLE;
        end
        else begin
            current_state <= next_state;
        end
    end

    always_comb begin
        next_state = current_state;
        case (current_state) 
            IDLE: begin
                if(valid_in)
                    next_state = LOAD;
                else
                    next_state = IDLE;
            end
            LOAD: begin
                next_state = SHIFT;
            end
            SHIFT: begin
                if(bit_count == 65)
                    next_state = DONE;
                else
                    next_state = SHIFT;
            end
            DONE: begin
                next_state = IDLE;
            end
            default: begin
                next_state = IDLE;
            end
        endcase
    end

    always_ff @(posedge clk or negedge rst_n) begin
        
        if(!rst_n) begin
            scrambled_bit <= 1'b0;
            valid_out     <= 1'b0;
            ready         <= 1'b0;
            shift_reg     <= '0;
            sync_header   <= '0;
            history_reg   <= '0;
            bit_count     <= '0;
        end

        else begin
            case (current_state) 
                IDLE: begin
                    ready         <= 1'b1;
                    scrambled_bit <= 1'b0;
                    valid_out     <= 1'b0;
                    bit_count     <= 7'd0;
                end

                LOAD : begin
                    shift_reg     <= encoded_data[63:0];
                    sync_header   <= encoded_data[65:64];
                    ready         <= 1'b0;
                    valid_out     <= 1'b0;
                    bit_count     <= 7'd0;
                end

                SHIFT: begin
                    ready         <= 1'b0;
                    valid_out     <= 1'b1;

                    if(bit_count == 0)
                        scrambled_bit <= sync_header[1];
                    else if (bit_count == 1)
                        scrambled_bit <= sync_header[0];
                    else begin
                    scrambled_bit <= scramble_bit_next;
                    history_reg   <= {history_reg[56:0], scramble_bit_next};
                    shift_reg     <= {shift_reg[62:0], 1'b0};
                    end
                    bit_count     <= bit_count + 1;
                end

                DONE : begin
                    ready         <= 1'b1;
                    valid_out     <= 1'b0;
                    scrambled_bit <= 1'b0;
                    bit_count     <= '0;    
                end

                default : begin
                    ready         <= 1'b0;
                    valid_out     <= 1'b0;
                    scrambled_bit <= 1'b0;
                end
            endcase
        end
    end

endmodule


