// Teaching sketch for one outstanding LSU-to-memory request.
// See the course contract: common/data_memory_if.sv.
module lsu_memory_handshake_demo (
    input  logic        clk_i,
    input  logic        rst_ni,
    input  logic        op_valid_i,
    output logic        op_ready_o,
    input  logic [31:0] op_address_i,
    output logic        request_valid_o,
    input  logic        request_ready_i,
    output logic [31:0] request_address_o,
    input  logic        response_valid_i,
    output logic        response_ready_o,
    output logic        op_done_o
);
    typedef enum logic [1:0] {IDLE, SEND_REQUEST, WAIT_RESPONSE} state_t;
    state_t state_q;
    logic [31:0] address_q;

    assign op_ready_o       = (state_q == IDLE);
    assign request_valid_o  = 1'b0;
    assign request_address_o = address_q;
    assign response_ready_o = 1'b0;
    assign op_done_o        = 1'b0;

    // TODO: capture a request, hold it through request_ready, then await response.
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            state_q   <= IDLE;
            address_q <= '0;
        end else if (state_q == IDLE && op_valid_i) begin
            address_q <= op_address_i;
            state_q   <= SEND_REQUEST;
        end
    end
endmodule
