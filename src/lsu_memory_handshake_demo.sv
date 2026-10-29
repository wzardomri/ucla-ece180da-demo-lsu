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
    assign request_valid_o  = (state_q == SEND_REQUEST);
    assign request_address_o = address_q;
    assign response_ready_o = (state_q == WAIT_RESPONSE);
    assign op_done_o        = response_valid_i && response_ready_o;

    // A captured address stays stable while SEND_REQUEST is stalled.
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            state_q   <= IDLE;
            address_q <= '0;
        end else begin
            case (state_q)
                IDLE: begin
                    if (op_valid_i && op_ready_o) begin
                        address_q <= op_address_i;
                        state_q   <= SEND_REQUEST;
                    end
                end
                SEND_REQUEST: begin
                    if (request_ready_i) begin
                        state_q <= WAIT_RESPONSE;
                    end
                end
                WAIT_RESPONSE: begin
                    if (response_valid_i && response_ready_o) begin
                        state_q <= IDLE;
                    end
                end
                default: state_q <= IDLE;
            endcase
        end
    end
endmodule
