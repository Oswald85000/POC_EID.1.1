`timescale 1ns/1ps
module eid_tb;
  reg clk=0; always #5 clk=~clk; // 100MHz
  reg rst_n=0;
  initial begin repeat(5) @(posedge clk); rst_n=1; end

  reg  [31:0] din_h,din_f,din_o;
  wire [31:0] dout_dhdt; wire dout_alarm;

  eid_reflex dut(.clk(clk),.rst_n(rst_n),.din_h(din_h),.din_f(din_f),.din_o(din_o),.dout_dhdt(dout_dhdt),.dout_alarm(dout_alarm));

  reg [31:0] vec [0:15][0:4];
  integer N=0;
  initial begin
    $readmemh("test/test_vectors.hex",vec);
    $dumpfile("test/sim.vcd");
    $dumpvars(0,eid_tb);
    while(vec[N][0]!==32'hx) N=N+1;
    integer i; integer fd; fd=$fopen("test/sim_results.csv","w");
    $fwrite(fd,"H,F,O,dHdt,alarm\n");
    for(i=0;i<N;i=i+1) begin
      din_h=vec[i][0]; din_f=vec[i][1]; din_o=vec[i][2];
      @(posedge clk);
      $fwrite(fd,"0x%08x,0x%08x,0x%08x,0x%08x,%0d\n",din_h,din_f,din_o,dout_dhdt,dout_alarm);
      if(dout_alarm!==vec[i][4]) begin $error("alarm mismatch %0d",i); $finish; end
    end
    $display("TEST PASS"); $finish;
  end
endmodule
