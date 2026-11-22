// SPDX-License-Identifier: Apache-2.0
`timescale 1ns/1ns
module controller_tb;
    reg clk_i=0, reset_ni=1, req_i=0;
    reg [2:0] cmd_i=0;
    reg [1:0] frac_i=0;
    reg [7:0] d_i=0;
    reg [2:0] row_i=0, t_i=0;
    wire ack_o, err_o; wire [3:0] y_o,rdo_o;
    acim_top dut(.*);
    always #500 clk_i=~clk_i;
    reg [3:0] weights[8];
    integer ncomp=0, nwrites=0, transactions=0, ncounts=0;
    time last_sample_end=0, last_share_end=0;
    integer frame_index=0;
    always @(req_i) frame_index=0;
    always @(posedge dut.evaluate) begin
        ncomp++;
        if (cmd_i==4) begin
            if (dut.coarse !== ((7'b1 << frame_index) - 1'b1)) $fatal(1,"count-mode threshold step %0d",frame_index);
            if (dut.fine !== 4'b0011) $fatal(1,"count-mode reference fraction");
            if (dut.vsel || dut.vgate) $fatal(1,"count mode must use the internal reference");
            if (dut.x !== d_i) $fatal(1,"count-mode activation");
        end else begin
            if (dut.coarse !== ((7'b1 << t_i) - 1'b1)) $fatal(1,"integer threshold decoder");
            case (frac_i)
                2'b01: if (dut.fine !== 4'b0001) $fatal(1,"quarter threshold decoder");
                2'b10: if (dut.fine !== 4'b0111) $fatal(1,"three-quarter threshold decoder");
                default: if (dut.fine !== 4'b0011) $fatal(1,"midpoint threshold decoder");
            endcase
            if (dut.vsel !== (frac_i==2'b11) || dut.vgate !== (frac_i==2'b11)) $fatal(1,"VEXT select or gate");
            if (dut.x !== ((cmd_i==3 && (frame_index%2)==1) ? ~d_i : d_i))
                $fatal(1,"wrong activation in frame %0d",frame_index);
        end
        frame_index++;
    end
    always @(posedge dut.sample_gate) if (reset_ni && (dut.share_gate || ($time-last_share_end)<490)) $fatal(1,"sample/share overlap");
    always @(negedge dut.sample_gate) last_sample_end=$time;
    always @(posedge dut.share_gate) if (dut.sample_gate || ($time-last_sample_end)<490) $fatal(1,"inadequate break before share");
    always @(negedge dut.share_gate) last_share_end=$time;
    always @(dut.wr) if (|dut.wr) begin
        if (!$onehot(dut.wr) || dut.sample_gate || dut.share_gate) $fatal(1,"invalid write phase");
        nwrites++;
    end

    function automatic integer overlap(input [7:0] x, input integer c);
        overlap=0;
        for (int r=0; r<8; r++) if (x[r] && weights[r][c]) overlap++;
    endfunction
    function automatic [3:0] expected(input [7:0] x, input [2:0] threshold);
        for (int c=0; c<4; c++) expected[c]=overlap(x,c)>threshold;
    endfunction

    task automatic transact(input [2:0] cmd);
        integer elapsed,limit,first_count;
        reg [3:0] old_y;
        begin
            first_count=ncomp; old_y=y_o;
            @(negedge clk_i); #113; cmd_i=cmd; req_i=~req_i;
            elapsed=0; limit=(cmd==3) ? 16410 : (cmd==4) ? 60 : 12;
            while (ack_o !== req_i && elapsed < limit) begin
                @(posedge clk_i); #2; elapsed++;
                if (ack_o !== req_i && y_o !== old_y) $fatal(1,"partial result visible");
            end
            if (elapsed==limit) $fatal(1,"ACK timeout");
            if ((cmd==2 || cmd==3 || cmd==4) && ncomp-first_count != ((cmd==3)?4096:(cmd==4)?8:1)) $fatal(1,"evaluation count");
            if (cmd==3 && elapsed!=16387) $fatal(1,"burst size or timing: %0d clocks",elapsed);
            if (cmd==2 && elapsed!=7) $fatal(1,"single frame timing: %0d clocks",elapsed);
            if (cmd==4 && elapsed!=35) $fatal(1,"count timing: %0d clocks",elapsed);
            if (dut.vsel !== 0) $fatal(1,"VEXT select left on after completion");
            transactions++;
        end
    endtask

    // Count mode plus four read-count transactions; checks every column count and Y at T.
    task automatic count_and_check(input [7:0] x);
        begin
            d_i=x; transact(4);
            if (y_o!==expected(x,t_i)) $fatal(1,"count-mode Y x=%0d t=%0d",x,t_i);
            for (int c=0;c<4;c++) begin
                row_i=c; transact(5);
                if (rdo_o!==overlap(x,c)) $fatal(1,"count x=%0d column %0d: %0d",x,c,rdo_o);
            end
            ncounts++;
        end
    endtask

    string trace_file;
    integer trace_fd=0;
    initial if ($value$plusargs("TRACE=%s",trace_file)) begin
        trace_fd=$fopen(trace_file,"w");
        if (!trace_fd) $fatal(1,"cannot open trace");
        $fdisplay(trace_fd,"ns,x,wr,d,coarse,fine,sam,shr,ev,vsel,vg");
    end
    always @(dut.x or dut.wr or dut.data or dut.coarse or dut.fine or dut.sample_gate or dut.share_gate or dut.evaluate or dut.vsel or dut.vgate)
        if (trace_fd && $time>0) $fstrobe(trace_fd,"%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d",
            $time,dut.x,dut.wr,dut.data,dut.coarse,dut.fine,dut.sample_gate,dut.share_gate,dut.evaluate,dut.vsel,dut.vgate);

    initial begin
        #1 reset_ni=0; #2120 reset_ni=1;
        repeat (4) @(posedge clk_i);
        if ($test$plusargs("DEMO")) begin
            // Column masks in column order 0..3 are 0F, 33, 55, F0.
            for (int r=0;r<8;r++) begin
                weights[r] = {(r >= 4), (r % 2 == 0), (r % 4 < 2), (r < 4)};
                row_i=r; d_i=weights[r]; transact(1);
            end
            for (int r=0;r<8;r++) begin
                row_i=r; transact(0);
                if (rdo_o!==weights[r]) $fatal(1,"digital readback row %0d",r);
                d_i=8'b1 << r; t_i=0; frac_i=0; transact(2);
                if (y_o!==weights[r]) $fatal(1,"compute readback row %0d",r);
            end
            d_i=8'h0f; t_i=2; frac_i=0; transact(2);
            if (y_o!==4'b0001) $fatal(1,"application example");
            for (int x=0;x<256;x++) begin
                for (int t=0;t<8;t++) begin
                    d_i=x; t_i=t; transact(2);
                    if (y_o!==expected(x,t)) $fatal(1,"demo x=%0d t=%0d",x,t);
                end
            end
            for (int x=0;x<256;x++) begin t_i=x%8; count_and_check(x); end
            if (err_o!==0) $fatal(1,"ERR set without a fault");
            $display("PASS application: 8 digital reads, 8 one-hot rows, Y=0001, 2048 threshold words, %0d count sets",ncounts);
            $finish;
        end
        for (int r=0;r<8;r++) begin
            weights[r]=(4'h9 ^ (r*3)); row_i=r; d_i=weights[r]; transact(1);
        end
        if (trace_fd) begin
            d_i=8'hff; t_i=3; frac_i=0; transact(2);
            if (y_o!==expected(d_i,t_i)) $fatal(1,"trace frame 1");
            d_i=8'h01; t_i=0; frac_i=2; transact(2);
            if (y_o!==expected(d_i,t_i)) $fatal(1,"trace frame 2");
            d_i=8'hfe; t_i=4; frac_i=1; transact(2);
            if (y_o!==expected(d_i,t_i)) $fatal(1,"trace frame 3");
            frac_i=0; t_i=1; count_and_check(8'h5a);
            $fclose(trace_fd); $display("PASS RTL trace: eight writes, three evaluations and one count set"); $finish;
        end
        for (int r=0;r<8;r++) begin
            row_i=r; transact(0); if (rdo_o!==weights[r]) $fatal(1,"readback");
        end
        // FRAC = 11 selects VEXT; the model's external level is set to the midpoint above T.
        for (int x=0;x<256;x++)
            for (int t=0;t<8;t++) begin
                d_i=x; t_i=t; frac_i=(x+t)%4;
                dut.array_i.vext_quarters = 4*t+2;
                transact(2);
                if (y_o!==expected(d_i,t_i)) $fatal(1,"eval x=%0d t=%0d frac=%0d",x,t,frac_i);
            end
        frac_i=0;
        d_i=8'h53; t_i=2; transact(3);
        if (y_o!==expected(~d_i,t_i)) $fatal(1,"burst last vector");
        for (int r=0;r<8;r++) begin
            row_i=r; transact(0); if (rdo_o!==weights[r]) $fatal(1,"burst corrupted weight");
        end
        // External reference set between counts: Y must follow VEXT, not T.
        for (int level=0; level<36; level+=5) begin
            d_i=8'hff; t_i=7; frac_i=3; dut.array_i.vext_quarters=level; transact(2);
            for (int c=0;c<4;c++) if (y_o[c] !== (4*overlap(d_i,c) > level)) $fatal(1,"VEXT level %0d column %0d",level,c);
        end
        frac_i=0;
        // Count mode on every input, then reserved commands leave state untouched.
        for (int x=0;x<256;x++) begin t_i=(x*5)%8; count_and_check(x); end
        if (err_o!==0) $fatal(1,"ERR set without a fault");
        begin : reserved_check
            reg [3:0] y_before, rdo_before;
            y_before=y_o; rdo_before=rdo_o;
            transact(6); transact(7);
            if (y_o!==y_before || rdo_o!==rdo_before) $fatal(1,"reserved command changed state");
        end
        // Inject one wrong decision at T = 3 of a count whose column 0 is all zeros: ERR must latch.
        dut.array_i.fault_frame = dut.array_i.frames + 3;
        d_i=8'h00; transact(4);
        if (err_o!==1) $fatal(1,"ERR did not flag a non-monotonic count");
        d_i=8'h0f; t_i=1; frac_i=0; transact(2);
        if (err_o!==1) $fatal(1,"ERR must stay set until reset");
        // Abort a burst during compare, restart the host toggle from zero, re-check weights.
        @(negedge clk_i); #97; req_i=~req_i; cmd_i=3; @(posedge dut.evaluate); #113;
        reset_ni=0; req_i=0; #1700; reset_ni=1; repeat(5) @(posedge clk_i);
        if (ack_o!==0 || y_o!==0 || err_o!==0 || dut.share_gate!==0 || dut.evaluate!==0 || dut.vsel!==0 || dut.vgate!==0)
            $fatal(1,"reset recovery");
        row_i=4; transact(0); if (rdo_o!==weights[4]) $fatal(1,"retention across controller reset");
        if (nwrites != 8) $fatal(1,"unexpected write count");
        $display("PASS %0d completed commands, 2048 one-shot evaluations incl. 512 in VEXT mode, %0d count sets, ERR fault detection, 4096-frame burst and reset recovery",transactions,ncounts);
        $finish;
    end
endmodule
