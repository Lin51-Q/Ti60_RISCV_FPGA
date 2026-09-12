// ================================================================
// 模块名：pattern_gen
// 功能：测试图案生成（RGB565 格式）
// 模式：00=彩条 01=网格 10=矩形 11=字符
// ================================================================

module pattern_gen(
    input  wire        pix_clk,
    input  wire        rst_n,
    input  wire [9:0]  pix_x,        // 有效区坐标 0~639
    input  wire [9:0]  pix_y,        // 有效区坐标 0~479
    input  wire        pix_de,
    input  wire [1:0]  pattern_sel,
    
    output reg  [15:0] pattern_rgb
);

// ================================================================
// RGB565 颜色定义
// ================================================================
localparam RGB_WHITE   = 16'hFFFF;
localparam RGB_YELLOW  = 16'hFFE0;
localparam RGB_CYAN    = 16'h07FF;
localparam RGB_GREEN   = 16'h07E0;
localparam RGB_MAGENTA = 16'hF81F;
localparam RGB_RED     = 16'hF800;
localparam RGB_BLUE    = 16'h001F;
localparam RGB_BLACK   = 16'h0000;

always @(posedge pix_clk or negedge rst_n) begin
    if (!rst_n) begin
        pattern_rgb <= RGB_BLACK;
    end else if (pix_de) begin
        case (pattern_sel)
            2'b00: begin
                if      (pix_x < 80)  pattern_rgb <= RGB_WHITE;
                else if (pix_x < 160) pattern_rgb <= RGB_YELLOW;
                else if (pix_x < 240) pattern_rgb <= RGB_CYAN;
                else if (pix_x < 320) pattern_rgb <= RGB_GREEN;
                else if (pix_x < 400) pattern_rgb <= RGB_MAGENTA;
                else if (pix_x < 480) pattern_rgb <= RGB_RED;
                else if (pix_x < 560) pattern_rgb <= RGB_BLUE;
                else                  pattern_rgb <= RGB_BLACK;
            end
            2'b01: begin
                if ((pix_x[5:0] == 6'd0) || (pix_y[4:0] == 5'd0))
                    pattern_rgb <= RGB_WHITE;
                else
                    pattern_rgb <= RGB_BLACK;
            end
            2'b10: begin
                if ((pix_x >= 200 && pix_x < 440) && 
                    (pix_y >= 140 && pix_y < 340))
                    pattern_rgb <= 16'hFC00;
                else
                    pattern_rgb <= 16'h0010;
            end
            2'b11: begin
                if (pix_x >= 100 && pix_x < 108 && 
                    pix_y >= 100 && pix_y < 108) begin
                    case ({pix_y[2:0], pix_x[2:0]})
                        8'b000_000, 8'b000_001, 8'b000_010, 8'b000_011,
                        8'b000_100, 8'b000_101, 8'b000_110, 8'b000_111:
                            pattern_rgb <= RGB_GREEN;
                        8'b001_000, 8'b001_111: pattern_rgb <= RGB_GREEN;
                        8'b010_000, 8'b010_111: pattern_rgb <= RGB_GREEN;
                        8'b011_000, 8'b011_001, 8'b011_010, 8'b011_011,
                        8'b011_100, 8'b011_101, 8'b011_110, 8'b011_111:
                            pattern_rgb <= RGB_GREEN;
                        8'b100_000, 8'b100_111: pattern_rgb <= RGB_GREEN;
                        8'b101_000, 8'b101_111: pattern_rgb <= RGB_GREEN;
                        8'b110_000, 8'b110_111: pattern_rgb <= RGB_GREEN;
                        8'b111_000, 8'b111_111: pattern_rgb <= RGB_GREEN;
                        default: pattern_rgb <= RGB_BLACK;
                    endcase
                end else begin
                    pattern_rgb <= RGB_BLACK;
                end
            end
            default: pattern_rgb <= RGB_BLACK;
        endcase
    end else begin
        pattern_rgb <= RGB_BLACK;
    end
end

endmodule