// ================================================================
// 模块名：pixel_mux
// 功能：像素源选择
// 状态：⚠️ 接口已按约定写好，但 B 的输入暂时接 0
// ================================================================

module pixel_mux(
    input  wire        pix_clk,
    input  wire        rst_n,
    input  wire        mode,
    input  wire        pix_de,
    input  wire [15:0] pattern_rgb,
    input  wire [15:0] fb_pixel,        // ← B 没来时接 0
    input  wire        fb_pixel_valid,  // ← B 没来时接 0
    output reg  [15:0] rgb_out,
    output reg         rgb_valid
);

always @(posedge pix_clk or negedge rst_n) begin
    if (!rst_n) begin
        rgb_out   <= 16'h0000;
        rgb_valid <= 1'b0;
    end else begin
        if (!pix_de) begin
            rgb_out   <= 16'h0000;
            rgb_valid <= 1'b0;
        end else if (mode == 1'b0) begin
            rgb_out   <= pattern_rgb;
            rgb_valid <= 1'b1;
        end else begin
            if (fb_pixel_valid) begin
                rgb_out   <= fb_pixel;
                rgb_valid <= 1'b1;
            end else begin
                rgb_out   <= 16'h0000;
                rgb_valid <= 1'b1;
            end
        end
    end
end

endmodule