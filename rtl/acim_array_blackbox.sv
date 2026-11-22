// SPDX-License-Identifier: Apache-2.0
// Logical view of analog/acim_array.spice for digital synthesis.
// vsel enables the thick-oxide VEXT input switch; vgate connects VEXT to each reference bus.
(* blackbox *) module acim_array (
    input wire [7:0] x, wr, input wire [3:0] data, fine, input wire [6:0] coarse,
    input wire sample_gate, share_gate, evaluate, vsel, vgate,
    output wire [3:0] cmp, output wire [31:0] stored
);
endmodule
