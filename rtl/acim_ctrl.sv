// SPDX-License-Identifier: Apache-2.0
// Commands (CMD[2:0]): 000 read row, 001 write row, 010 evaluate, 011 burst,
// 100 count, 101 read count, 110/111 reserved (acknowledged, no action).
// D[7:0] carries X for evaluate, burst and count, and the four weight bits in D[3:0] for write.
// FRAC: 00 = 1/2, 01 = 1/4, 10 = 3/4 count above T; 11 = external reference VEXT (test mode).
module acim_ctrl (
    input  logic clk_i, reset_ni, req_i,
    input  logic [2:0] cmd_i,
    input  logic [1:0] frac_i,
    input  logic [7:0] d_i,
    input  logic [2:0] row_i, t_i,
    output logic ack_o, err_o,
    output logic [3:0] y_o, rdo_o,
    input  logic [31:0] stored_i,
    input  logic [3:0] cmp_i,
    output logic [7:0] wr_o, x_o,
    output logic [3:0] data_o, fine_o,
    output logic [6:0] coarse_o,
    output logic sample_o, share_o, compare_o,
    output logic vsel_o, vgate_o
);
    typedef enum logic [6:0] {IDLE=7'b0000001, READ_ROW=7'b0000010, WRITE_ROW=7'b0000100,
        SAMPLE=7'b0001000, SHARE=7'b0010000, COMPARE=7'b0100000, LATCH=7'b1000000} state_t;
    state_t state;
    (* ASYNC_REG = "TRUE" *) logic [1:0] reset_pipe, req_pipe;
    logic tag;
    logic [2:0] row_q, t_q, step_q;
    logic [11:0] remaining;
    logic [3:0] result_q, prev_q;
    logic counting, read_count;
    logic [3:0] count_q [4];
    logic [3:0] count_next [4];

    function automatic logic [6:0] thermometer(input logic [2:0] t);
        for (int j=0; j<7; j++) thermometer[j] = (j < t);
    endfunction

    always_ff @(posedge clk_i or negedge reset_ni) begin
        if (!reset_ni) reset_pipe <= 2'b00;
        else reset_pipe <= {reset_pipe[0],1'b1};
    end
    wire run_n = reset_pipe[1];
    always_ff @(posedge clk_i or negedge run_n) begin
        if (!run_n) req_pipe <= 2'b00;
        else req_pipe <= {req_pipe[0],req_i};
    end

    // The separate falling-edge flops create a half-cycle gap after sampling.
    // VGATE follows SHARE, so the external reference never meets the bus reset.
    assign sample_o = (state == SAMPLE) && !clk_i;
    assign compare_o = (state == COMPARE);
    assign wr_o = ((state == WRITE_ROW) && !clk_i) ? (8'b1 << row_q) : 8'b0;
    always_ff @(negedge clk_i or negedge run_n) begin
        if (!run_n) begin
            share_o <= 1'b0;
            vgate_o <= 1'b0;
        end else begin
            share_o <= (state == SHARE) || (state == COMPARE);
            vgate_o <= vsel_o && ((state == SHARE) || (state == COMPARE));
        end
    end

    always_comb
        for (int c=0; c<4; c++) count_next[c] = count_q[c] + {3'b000, result_q[c]};

    always_ff @(posedge clk_i or negedge run_n) begin
        if (!run_n) begin
            state <= IDLE;
            ack_o <= 0; err_o <= 0; tag <= 0; row_q <= 0; t_q <= 0; step_q <= 0; remaining <= 0;
            x_o <= 0; data_o <= 0; fine_o <= 0; coarse_o <= 0; vsel_o <= 0;
            y_o <= 0; result_q <= 0; prev_q <= 0; rdo_o <= 0;
            counting <= 0; read_count <= 0;
            for (int c=0; c<4; c++) count_q[c] <= 0;
        end else begin
            case (state)
                IDLE: if (req_pipe[1] != ack_o) begin
                    tag <= req_pipe[1];
                    row_q <= row_i;
                    t_q <= t_i;
                    case (cmd_i)
                        3'b000: begin read_count <= 0; state <= READ_ROW; end
                        3'b101: begin read_count <= 1; state <= READ_ROW; end
                        3'b001: begin data_o <= d_i[3:0]; state <= WRITE_ROW; end
                        3'b010, 3'b011: begin
                            x_o <= d_i;
                            coarse_o <= thermometer(t_i);
                            case (frac_i)
                                2'b01: fine_o <= 4'b0001;
                                2'b10: fine_o <= 4'b0111;
                                default: fine_o <= 4'b0011;
                            endcase
                            vsel_o <= (frac_i == 2'b11);
                            counting <= 0;
                            remaining <= (cmd_i == 3'b011) ? 12'hfff : 12'd0;
                            state <= SAMPLE;
                        end
                        3'b100: begin
                            // Eight frames at T = 0..7 with the 1/2 reference.
                            x_o <= d_i;
                            coarse_o <= 7'b0;
                            fine_o <= 4'b0011;
                            vsel_o <= 0;
                            counting <= 1;
                            step_q <= 0;
                            prev_q <= 4'b1111;
                            remaining <= 0;
                            for (int c=0; c<4; c++) count_q[c] <= 0;
                            state <= SAMPLE;
                        end
                        default: ack_o <= req_pipe[1]; // reserved: acknowledge only
                    endcase
                end
                READ_ROW: begin
                    rdo_o <= read_count ? count_q[row_q[1:0]] : stored_i[row_q*4 +: 4];
                    ack_o <= tag; state <= IDLE;
                end
                WRITE_ROW: begin ack_o <= tag; state <= IDLE; end
                SAMPLE: state <= SHARE;
                SHARE: state <= COMPARE;
                COMPARE: begin result_q <= cmp_i; state <= LATCH; end
                LATCH: begin
                    if (counting) begin
                        // A correct column gives a thermometer code: once 0, never 1 again.
                        if (|(result_q & ~prev_q)) err_o <= 1'b1;
                        prev_q <= result_q;
                        for (int c=0; c<4; c++) count_q[c] <= count_next[c];
                        if (step_q == 3'd7) begin
                            for (int c=0; c<4; c++) y_o[c] <= count_next[c] > {1'b0, t_q};
                            counting <= 0;
                            ack_o <= tag;
                            state <= IDLE;
                        end else begin
                            step_q <= step_q + 1'b1;
                            coarse_o <= thermometer(step_q + 1'b1);
                            state <= SAMPLE;
                        end
                    end else if (remaining == 0) begin
                        y_o <= result_q;
                        vsel_o <= 0;
                        ack_o <= tag;
                        state <= IDLE;
                    end else begin
                        x_o <= ~x_o;
                        remaining <= remaining - 1'b1;
                        state <= SAMPLE;
                    end
                end
                default: state <= IDLE;
            endcase
        end
    end
endmodule
