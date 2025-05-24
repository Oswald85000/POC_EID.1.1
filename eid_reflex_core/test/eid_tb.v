`timescale 1ns/1ps
module eid_tb;
    reg clk=0; always #5 clk=~clk;
    reg rst_n=0;
    reg [31:0] din_h,din_f,din_o;
    reg din_valid;
    wire din_ready;
    wire [31:0] dout_dhdt; wire dout_alarm; wire dout_valid;

    eid_reflex dut(
        .clk(clk), .rst_n(rst_n),
        .s_axi_awaddr(0), .s_axi_awvalid(0), .s_axi_awready(),
        .s_axi_wdata(0), .s_axi_wvalid(0), .s_axi_wready(),
        .s_axi_araddr(0), .s_axi_arvalid(0), .s_axi_arready(),
        .s_axi_rdata(), .s_axi_rvalid(), .s_axi_rready(1'b1),
        .din_h(din_h), .din_f(din_f), .din_o(din_o),
        .din_valid(din_valid), .din_ready(din_ready),
        .dout_dhdt(dout_dhdt), .dout_alarm(dout_alarm),
        .dout_valid(dout_valid), .dout_ready(1'b1)
    );

    integer csv;
    initial begin
        csv=$fopen("sim_results.csv","w");
        rst_n=0; din_valid=0; repeat(5) @(posedge clk); rst_n=1;

        $readmemh("test_vectors.hex",mem);
        for (i=0;i<N;i++) begin
            {din_h,din_f,din_o,exp_dhdt,exp_alarm} = mem[i];
            din_valid=1; @(posedge clk); din_valid=0;
            @(posedge clk); // wait one cycle for pipeline
            $fwrite(csv,"%08x,%08x,%08x,%08x,%1d\n",din_h,din_f,din_o,dout_dhdt,dout_alarm);
            if(dout_alarm!==exp_alarm) $fatal(1,"ALARM mismatch %0d",i);
            if($signed(dout_dhdt)-$signed(exp_dhdt)>2 || $signed(exp_dhdt)-$signed(dout_dhdt)>2)
                $fatal(1,"dHdt mismatch %0d",i);
        end
        $display("PASS"); $finish;
    end

    parameter N=3;
    reg [159:0] mem [0:N-1];
    reg [31:0] exp_dhdt; reg exp_alarm;
    integer i;
endmodule
