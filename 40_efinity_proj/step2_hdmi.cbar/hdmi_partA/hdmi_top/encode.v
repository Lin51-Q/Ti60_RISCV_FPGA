// ================================================================
// 模块名：encode
// 功能：TMDS 8b/10b 编码器
// 状态：✅ 完全独立，不依赖 B
// ================================================================

`timescale 1 ps / 1ps

module encode(
    input  wire        clk,
    input  wire        rst_p,
    input  wire [7:0]  din,
    input  wire [9:0]  aux_data,
    input  wire        c0,
    input  wire        c1,
    input  wire        de,
    output reg  [9:0]  dout
);

wire [3:0] n1_d;
wire [3:0] n0_d;

assign n1_d = din[0] + din[1] + din[2] + din[3] +
              din[4] + din[5] + din[6] + din[7];
assign n0_d = 8 - n1_d;

reg [3:0] disparity;
reg [9:0] dout_r;

always @(posedge clk or posedge rst_p) begin
    if (rst_p) begin
        disparity <= 4'd0;
        dout_r    <= 10'b0;
    end else begin
        if (de) begin
            if (n1_d > 4 || (n1_d == 4 && n0_d > 4)) begin
                dout_r[9]   <= 1'b0;
                dout_r[8]   <= ~din[0];
                dout_r[7:0] <= ~din[7:1];
                disparity   <= disparity - (n1_d - n0_d);
            end else begin
                dout_r[9]   <= 1'b1;
                dout_r[8]   <= din[0];
                dout_r[7:0] <= din[7:1];
                disparity   <= disparity + (n1_d - n0_d);
            end
        end else begin
            case ({c1, c0})
                2'b00: dout_r <= 10'b1101010100;
                2'b01: dout_r <= 10'b0010101011;
                2'b10: dout_r <= 10'b0101010100;
                2'b11: dout_r <= 10'b1010101011;
            endcase
            disparity <= 4'd0;
        end
    end
end

always @(posedge clk) begin
    dout <= dout_r;
end

endmodule 