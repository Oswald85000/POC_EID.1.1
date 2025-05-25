// =============================================================================
// EID_CTRL — Entropy-Informed Derivative core (Q16.16, 3 pipeline stages)
// =============================================================================
`timescale 1ns/1ps
`include "qtypes.svh"
import qtypes::*;

module eid_reflex #(
    parameter integer WIDTH = 32,
    parameter integer FRAC  = 16          // Q16.16
)(
    input  wire                 clk,  /// clock
    input  wire                 rst_n,  /// async reset

    // ---------- AXI-Lite WRITE-ONLY (α β γ δ) ------------------------------
    input  wire  [3:0]          s_axi_awaddr,  /// AW address
    input  wire                 s_axi_awvalid,  /// AW valid
    output wire                 s_axi_awready,  /// AW ready
    input  wire  [31:0]         s_axi_wdata,  /// W data
    input  wire                 s_axi_wvalid,  /// W valid
    output wire                 s_axi_wready,  /// W ready

    // ---------- AXI-Lite READ (jamais utilisé) -----------------------------
    input  wire  [3:0]          s_axi_araddr,  /// AR address
    input  wire                 s_axi_arvalid,  /// AR valid
    output wire                 s_axi_arready,  /// AR ready
    output wire [31:0]          s_axi_rdata,  /// R data
    output wire                 s_axi_rvalid,  /// R valid
    input  wire                 s_axi_rready,  /// R ready

    // ---------- flux H, F, O -----------------------------------------------
    input  wire [WIDTH-1:0]     din_h,  /// H input
    input  wire [WIDTH-1:0]     din_f,  /// F input
    input  wire [WIDTH-1:0]     din_o,  /// O input
    input  wire                 din_valid,  /// valid in
    output wire                 din_ready,  /// ready out

    // ---------- sorties -----------------------------------------------------
    output wire [WIDTH-1:0]     dout_dhdt,  /// dH/dt output
    output wire                 dout_alarm,  /// alarm
    output wire [31:0]         cfg_rd_data,  /// debug coeffs
    output wire                 dout_valid,  /// valid out
    input  wire                 dout_ready  /// ready in
);

typedef logic signed [WIDTH-1:0] sfixed_t;
initial assert(LAT==3) else $fatal("LAT mismatch");
    // ---------------------------------------------------------------------[1]
    // registres coefficients
    // -------------------------------------------------------------------------
    sfixed_t alpha, beta, gamma, delta;

    /* verilator coverage_off */   // “fil-de-fer” inertes → ignorés
    assign s_axi_awready = 1'b1;
    assign s_axi_wready  = 1'b1;
    assign s_axi_arready = 1'b1;
    assign s_axi_rvalid  = 1'b0;
    assign s_axi_rdata   = 32'h0;
    /* verilator coverage_on */

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            alpha <= 32'sh0001_3334;   //  1.2
            beta  <= 32'sh0001_0000;   //  1.0
            gamma <= 32'sh0000_0CCD;   //  0.05
            delta <= 32'sh0000_0000;   //  0.0
        end
        else if (s_axi_awvalid && s_axi_wvalid) begin
            case (s_axi_awaddr[3:2])
                2'd0: alpha <= s_axi_wdata;
                2'd1: beta  <= s_axi_wdata;
                2'd2: gamma <= s_axi_wdata;
                2'd3: delta <= s_axi_wdata;
            endcase
        end
    end

    // ---------------------------------------------------------------------[2]
    // datapath Q16.16 saturé – 3 étapes
    // -------------------------------------------------------------------------
    sfixed_t m_alpha, m_beta, m_gamma;
    sfixed_t add1, add2, dhdt_q32;

    qmul_sat mul_alpha (.a(-alpha), .b(din_h), .y(m_alpha));          // −α·H
    qmul_sat mul_beta  (.a( beta),  .b(din_f), .y(m_beta));           // +β·F
    qadd_sat add_s1    (.a(m_alpha), .b(m_beta),  .y(add1));

    qmul_sat mul_gamma (.a( gamma), .b(din_o), .y(m_gamma));          // −γ·O
    qadd_sat add_s2a   (.a(add1),    .b(-m_gamma), .y(add2));
    qadd_sat add_s2b   (.a(add2),    .b( delta),   .y(dhdt_q32));     // +δ

    // ---------------------------------------------------------------------[3] pipeline valid/ready
    reg v0, v1, v2;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin v0<=0; v1<=0; v2<=0; end else begin
            v0 <= din_valid;
            v1 <= v0;
            v2 <= v1;
        end
    end

    assign din_ready  = 1'b1;
    assign dout_valid = v2 & dout_ready;
    assign dout_dhdt  = dhdt_q32;
    assign cfg_rd_data = alpha;

    // ---------------------------------------------------------------------[4] alarme μ < 1  (α < β)
    reg alarm_r;
    always @(posedge clk or negedge rst_n) if(!rst_n) alarm_r<=0; else alarm_r <= (alpha < beta);
    assign dout_alarm = alarm_r;

endmodule
// TODO: vérifier timing & latence (2 cycles?)
