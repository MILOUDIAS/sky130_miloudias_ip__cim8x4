// SPDX-License-Identifier: Apache-2.0
// Functional simulation view. One retained row is transparent while its write gate is high.
// vext_quarters models the external reference in the same quarter-count units as the replica.
// fault_frame injects one inverted column-0 decision on the given evaluation (test hook).
module acim_array (
    input wire [7:0] x, wr, input wire [3:0] data, fine, input wire [6:0] coarse,
    input wire sample_gate, share_gate, evaluate, vsel, vgate,
    output reg [3:0] cmp, output wire [31:0] stored
);
    genvar row;
    generate for (row=0; row<8; row=row+1) begin: cells
        reg [3:0] weights;
        always @(wr[row] or data) if (wr[row]) weights <= data;
        assign stored[4*row +: 4] = weights;
    end endgenerate
    integer sample_count[4];
    integer threshold_quarters;
    integer vext_quarters = 2;
    integer fault_frame = -1;
    integer frames = 0;
    always @(negedge sample_gate) begin
        for (int c=0; c<4; c++) begin
            sample_count[c] = 0;
            for (int r=0; r<8; r++)
                sample_count[c] += x[r] & stored[r*4+c];
        end
        threshold_quarters = 4*$countones(coarse) + $countones(fine);
    end
    always @(posedge vgate) if (sample_gate || !vsel) $fatal(1, "VEXT gate outside the share phase");
    always @(posedge sample_gate) if (vgate) $fatal(1, "VEXT gate overlaps bus reset");
    always @(posedge evaluate) begin
        if (!share_gate || sample_gate) $fatal(1, "invalid compare phase");
        for (int c=0; c<4; c++)
            cmp[c] <= 4*sample_count[c] > (vgate ? vext_quarters : threshold_quarters);
        if (frames == fault_frame) cmp[0] <= !(4*sample_count[0] > (vgate ? vext_quarters : threshold_quarters));
        frames++;
    end
endmodule
