package ethernet_pkg;

typedef enum logic [2:0] {
    DATA,
    IDLE,
    START,
    TERMINATE,
    FAULT
} command_type_e;

localparam logic [7:0] IDLE_BLOCK      = 8'h1E;
localparam logic [7:0] START_BLOCK     = 8'h33;
localparam logic [7:0] TERMINATE_BLOCK = 8'h87;
localparam logic [7:0] FAULT_BLOCK     = 8'hF0;

endpackage