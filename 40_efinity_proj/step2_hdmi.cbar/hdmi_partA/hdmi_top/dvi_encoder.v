// ================================================================
// 模块名：dvi_encoder
// 功能：HDMI/DVI TMDS 编码器（RGB565 输入）
// 状态：✅ 完全独立，不依赖 B
// ================================================================

`timescale 1 ps / 1ps

module dvi_encoder(
    input  wire        pixelclk,
    input  wire        rst_p,
    input  wire [15:0] i_rgb565,
    input  wire        i_hs,
    input  wire        i_vs,
    input  wire        i_de,
    
    output wire [9:0]  tmds_data0,
    output wire [9:0]  tmds_data1,
    output wire [9:0]  tmds_data2,
    output wire [9:0]  tmds_clk
);

wire [7:0] r8, g8, b8;
assign r8 = {i_rgb565[15:11], i_rgb565[15:13]};
assign g8 = {i_rgb565[10:5],  i_rgb565[10:9]};
assign b8 = {i_rgb565[4:0],   i_rgb565[4:2]};

reg [7:0] b_data_r, g_data_r, r_data_r;
reg       hs_r, vs_r, de_r;

always @(posedge pixelclk) begin
    b_data_r <= b8;
    g_data_r <= g8;
    r_data_r <= r8;
    hs_r     <= i_hs;
    vs_r     <= i_vs;
    de_r     <= i_de;
end

localparam PIPELINE_DEPTH = 4;

reg [7:0] b_pipe [PIPELINE_DEPTH-1:0];
reg [7:0] g_pipe [PIPELINE_DEPTH-1:0];
reg [7:0] r_pipe [PIPELINE_DEPTH-1:0];
reg       hs_pipe [PIPELINE_DEPTH-1:0];
reg       vs_pipe [PIPELINE_DEPTH-1:0];
reg       de_pipe [PIPELINE_DEPTH-1:0];

integer i;
always @(posedge pixelclk) begin
    b_pipe[0] <= b_data_r;
    g_pipe[0] <= g_data_r;
    r_pipe[0] <= r_data_r;
    hs_pipe[0] <= hs_r;
    vs_pipe[0] <= vs_r;
    de_pipe[0] <= de_r;
    
    for (i = 1; i < PIPELINE_DEPTH; i = i + 1) begin
        b_pipe[i] <= b_pipe[i-1];
        g_pipe[i] <= g_pipe[i-1];
        r_pipe[i] <= r_pipe[i-1];
        hs_pipe[i] <= hs_pipe[i-1];
        vs_pipe[i] <= vs_pipe[i-1];
        de_pipe[i] <= de_pipe[i-1];
    end
end

wire [7:0] b_out = b_pipe[PIPELINE_DEPTH-1];
wire [7:0] g_out = g_pipe[PIPELINE_DEPTH-1];
wire [7:0] r_out = r_pipe[PIPELINE_DEPTH-1];
wire       hs_out = hs_pipe[PIPELINE_DEPTH-1];
wire       vs_out = vs_pipe[PIPELINE_DEPTH-1];
wire       de_out = de_pipe[PIPELINE_DEPTH-1];

wire [9:0] blue, green, red;

encode encb (
    .clk      (pixelclk),
    .rst_p    (rst_p),
    .din      (b_out),
    .aux_data (10'd0),
    .c0       (hs_out),
    .c1       (vs_out),
    .de       (de_out),
    .dout     (blue)
);

encode encg (
    .clk      (pixelclk),
    .rst_p    (rst_p),
    .din      (g_out),
    .aux_data (10'd0),
    .c0       (1'b0),
    .c1       (1'b0),
    .de       (de_out),
    .dout     (green)
);

encode encr (
    .clk      (pixelclk),
    .rst_p    (rst_p),
    .din      (r_out),
    .aux_data (10'd0),
    .c0       (1'b0),
    .c1       (1'b0),
    .de       (de_out),
    .dout     (red)
);

assign tmds_data0 = blue;
assign tmds_data1 = green;
assign tmds_data2 = red;
assign tmds_clk   = 10'b1111100000;

endmodule