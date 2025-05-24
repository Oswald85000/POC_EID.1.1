`timescale 1ns/1ps
module eid_tb;
    reg         clk = 0;
    always #5ns clk = ~clk;        // 100 MHz

    reg  [31:0] H,F,O;
    wire [31:0] dHdt;
    wire        alarm;

    eid_reflex dut (.*);           // ★ instanciation

    initial begin
        $dumpfile("sim.vcd");
        $dumpvars(0,eid_tb);

        // vecteur 0 : stable
        H=32'h3f4ccccd; F=32'h3f19999a; O=32'h00000000; @(posedge clk);
        // vecteur 1 : micro-drift
        H=32'h3f59999a; F=32'h3f19999a; O=32'h00000000; @(posedge clk);
        // vecteur 2 : grosse alarme
        H=32'h3e99999a; F=32'h3f666666; O=32'h00000000; @(posedge clk);

        #100ns $finish;
    end
endmodule
