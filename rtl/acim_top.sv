// SPDX-License-Identifier: Apache-2.0
// Logical standalone interface. Supply binding and protected I/O pads belong to the mixed-signal wrapper.
module acim_top (
    input wire clk_i, reset_ni, req_i,
    input wire [2:0] cmd_i, row_i, t_i,
    input wire [1:0] frac_i,
    input wire [7:0] d_i,
    output wire ack_o, err_o,
    output wire [3:0] y_o, rdo_o
);
    wire [31:0] stored;
    wire [3:0] cmp, data, fine;
    wire [6:0] coarse;
    wire [7:0] wr, x;
    wire sample_gate, share_gate, evaluate, vsel, vgate;
    acim_ctrl ctrl (.clk_i, .reset_ni, .req_i, .cmd_i, .frac_i, .d_i, .row_i, .t_i,
        .ack_o, .err_o, .y_o, .rdo_o, .stored_i(stored), .cmp_i(cmp), .wr_o(wr), .x_o(x),
        .data_o(data), .fine_o(fine), .coarse_o(coarse), .sample_o(sample_gate),
        .share_o(share_gate), .compare_o(evaluate), .vsel_o(vsel), .vgate_o(vgate));
    acim_array array_i (.x, .wr, .data, .fine, .coarse, .sample_gate, .share_gate,
        .evaluate, .vsel, .vgate, .cmp, .stored);
endmodule
