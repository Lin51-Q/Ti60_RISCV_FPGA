// ================================================================
// 模块名：hdmi_timing
// 功能：640×480@60Hz VESA 时序生成
// 输出：pix_x[11:0]、pix_y[11:0]、pix_de、pix_hs、pix_vs
// 特点：使用状态机实现
// ================================================================

module hdmi_timing(
    input  wire        pix_clk,       // 25.175MHz 像素时钟
    input  wire        rst_n,         // 复位（低有效）
    
    output reg  [11:0] pix_x,         // 列坐标（有效区 0~639）
    output reg  [11:0] pix_y,         // 行坐标（有效区 0~479）
    output reg         pix_de,        // 数据有效
    output reg         pix_hs,        // 行同步
    output reg         pix_vs         // 场同步
);

// ================================================================
// 640×480@60Hz 时序参数
// ================================================================
localparam H_SYNC        = 96;
localparam H_BACK_PORCH  = 48;
localparam H_VALID       = 640;
localparam H_FRONT_PORCH = 16;

localparam V_SYNC        = 2;
localparam V_BACK_PORCH  = 33;
localparam V_VALID       = 480;
localparam V_FRONT_PORCH = 10;

// ================================================================
// 状态机定义
// ================================================================
localparam S_H_SYNC        = 2'd0;
localparam S_H_BACK_PORCH  = 2'd1;
localparam S_H_VALID       = 2'd2;
localparam S_H_FRONT_PORCH = 2'd3;

localparam S_V_SYNC        = 2'd0;
localparam S_V_BACK_PORCH  = 2'd1;
localparam S_V_VALID       = 2'd2;
localparam S_V_FRONT_PORCH = 2'd3;

reg [1:0]  h_state;
reg [1:0]  v_state;
reg [11:0] h_cnt;
reg [11:0] v_cnt;

// ================================================================
// 行状态机
// ================================================================
always @(posedge pix_clk or negedge rst_n) begin
    if (!rst_n) begin
        h_state <= S_H_SYNC;
        h_cnt   <= 12'd0;
    end else begin
        case (h_state)
            S_H_SYNC: begin
                if (h_cnt == H_SYNC - 1) begin
                    h_cnt   <= 12'd0;
                    h_state <= S_H_BACK_PORCH;
                end else
                    h_cnt <= h_cnt + 1'b1;
            end
            S_H_BACK_PORCH: begin
                if (h_cnt == H_BACK_PORCH - 1) begin
                    h_cnt   <= 12'd0;
                    h_state <= S_H_VALID;
                end else
                    h_cnt <= h_cnt + 1'b1;
            end
            S_H_VALID: begin
                if (h_cnt == H_VALID - 1) begin
                    h_cnt   <= 12'd0;
                    h_state <= S_H_FRONT_PORCH;
                end else
                    h_cnt <= h_cnt + 1'b1;
            end
            S_H_FRONT_PORCH: begin
                if (h_cnt == H_FRONT_PORCH - 1) begin
                    h_cnt   <= 12'd0;
                    h_state <= S_H_SYNC;
                end else
                    h_cnt <= h_cnt + 1'b1;
            end
        endcase
    end
end

// ================================================================
// 场状态机
// ================================================================
wire h_end = (h_cnt == H_FRONT_PORCH - 1) && (h_state == S_H_FRONT_PORCH);

always @(posedge pix_clk or negedge rst_n) begin
    if (!rst_n) begin
        v_state <= S_V_SYNC;
        v_cnt   <= 12'd0;
    end else if (h_end) begin
        case (v_state)
            S_V_SYNC: begin
                if (v_cnt == V_SYNC - 1) begin
                    v_cnt   <= 12'd0;
                    v_state <= S_V_BACK_PORCH;
                end else
                    v_cnt <= v_cnt + 1'b1;
            end
            S_V_BACK_PORCH: begin
                if (v_cnt == V_BACK_PORCH - 1) begin
                    v_cnt   <= 12'd0;
                    v_state <= S_V_VALID;
                end else
                    v_cnt <= v_cnt + 1'b1;
            end
            S_V_VALID: begin
                if (v_cnt == V_VALID - 1) begin
                    v_cnt   <= 12'd0;
                    v_state <= S_V_FRONT_PORCH;
                end else
                    v_cnt <= v_cnt + 1'b1;
            end
            S_V_FRONT_PORCH: begin
                if (v_cnt == V_FRONT_PORCH - 1) begin
                    v_cnt   <= 12'd0;
                    v_state <= S_V_SYNC;
                end else
                    v_cnt <= v_cnt + 1'b1;
            end
        endcase
    end
end

// ================================================================
// 输出：pix_x / pix_y / pix_de / pix_hs / pix_vs
// ================================================================
always @(posedge pix_clk or negedge rst_n) begin
    if (!rst_n) begin
        pix_x  <= 12'd0;
        pix_y  <= 12'd0;
        pix_de <= 1'b0;
        pix_hs <= 1'b1;
        pix_vs <= 1'b1;
    end else begin
        pix_x  <= (h_state == S_H_VALID) ? h_cnt : 12'd0;
        pix_y  <= (v_state == S_V_VALID) ? v_cnt : 12'd0;
        pix_de <= (h_state == S_H_VALID) && (v_state == S_V_VALID);
        pix_hs <= (h_state == S_H_SYNC) ? 1'b0 : 1'b1;
        pix_vs <= (v_state == S_V_SYNC) ? 1'b0 : 1'b1;
    end
end

endmodule