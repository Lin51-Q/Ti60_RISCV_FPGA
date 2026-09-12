// ================================================================
// 模块名：hdmi_top
// 功能：HDMI 显示子系统顶层（适配 Efinity Interface Designer）
// 说明：PLL 和 LVDS 由 Efinity 自动处理，这里只使用端口信号
// ================================================================

module hdmi_top
(
    // ===== GPIO 输入 =====
    input  wire        gpio_mode,              // 模式选择（0=图案 1=DDR3）
    input  wire        gpio_pattern_sel_0,     // 图案选择 bit0
    input  wire        gpio_pattern_sel_1,     // 图案选择 bit1
    input  wire        gpio_rst_n,             // 复位（低有效）
    input  wire        gpio_clk_50m,           // 50MHz 晶振
    
    // ===== PLL 接口 =====
    input  wire        pll_hdmi_LOCKED,        // PLL 锁定指示（输入）
    input  wire        pll_hdmi_CLKOUT1,       // 250MHz 时钟（输入）
    input  wire        pll_hdmi_CLKOUT0,       // 25MHz 时钟（输入）
    output wire        pll_hdmi_RSTN,          // PLL 复位（输出）
    
    // ===== LVDS 时钟通道 =====
    output wire        lvds_tx_clk_TX_OE,      // 时钟通道使能
    output wire [9:0]  lvds_tx_clk_TX_DATA,    // 时钟通道数据
    output wire        lvds_tx_clk_TX_RST,     // 时钟通道复位
    
    // ===== LVDS 蓝色通道（d0）=====
    output wire        lvds_tx_d0_TX_OE,
    output wire [9:0]  lvds_tx_d0_TX_DATA,
    output wire        lvds_tx_d0_TX_RST,
    
    // ===== LVDS 绿色通道（d1）=====
    output wire        lvds_tx_d1_TX_OE,
    output wire [9:0]  lvds_tx_d1_TX_DATA,
    output wire        lvds_tx_d1_TX_RST,
    
    // ===== LVDS 红色通道（d2）=====
    output wire        lvds_tx_d2_TX_OE,
    output wire [9:0]  lvds_tx_d2_TX_DATA,
    output wire        lvds_tx_d2_TX_RST
);

// ================================================================
// 1. 时钟和复位
// ================================================================
wire clk_pixel = pll_hdmi_CLKOUT0;   // 25MHz 像素时钟
wire clk_tmds  = pll_hdmi_CLKOUT1;   // 250MHz 串行时钟

// PLL 复位：平时拉高（不复位），上电后延时释放
reg [7:0] pll_rst_cnt = 8'd0;
always @(posedge clk_pixel or negedge gpio_rst_n) begin
    if (!gpio_rst_n)
        pll_rst_cnt <= 8'd0;
    else if (pll_hdmi_LOCKED && pll_rst_cnt != 8'hFF)
        pll_rst_cnt <= pll_rst_cnt + 1'b1;
end
assign pll_hdmi_RSTN = (pll_rst_cnt == 8'hFF);  // 延时后释放

// 内部复位（PLL 锁定后延时释放）
wire rst_n_sync = pll_hdmi_LOCKED && (pll_rst_cnt == 8'hFF);

// ================================================================
// 2. GPIO 输入转换
// ================================================================
wire [1:0] pattern_sel;
assign pattern_sel = {gpio_pattern_sel_1, gpio_pattern_sel_0};

// ================================================================
// 3. VGA 时序生成
// ================================================================
wire [11:0] pix_x_int, pix_y_int;
wire        pix_de_int, pix_hs_int, pix_vs_int;

hdmi_timing u_timing (
    .pix_clk (clk_pixel),
    .rst_n   (rst_n_sync),
    .pix_x   (pix_x_int),
    .pix_y   (pix_y_int),
    .pix_de  (pix_de_int),
    .pix_hs  (pix_hs_int),
    .pix_vs  (pix_vs_int)
);

// ================================================================
// 4. 测试图案生成
// ================================================================
wire [15:0] pattern_rgb;

pattern_gen u_pattern (
    .pix_clk     (clk_pixel),
    .rst_n       (rst_n_sync),
    .pix_x       (pix_x_int[9:0]),
    .pix_y       (pix_y_int[9:0]),
    .pix_de      (pix_de_int),
    .pattern_sel (pattern_sel),
    .pattern_rgb (pattern_rgb)
);

// ================================================================
// 5. 像素源选择（mode: 0=图案 1=DDR3）
// ================================================================
wire [15:0] rgb565_mux;
wire        fb_pixel_valid_unused = 1'b0;   // B 同学还没交付，暂时接地
wire [15:0] fb_pixel_unused       = 16'h0000;

pixel_mux u_mux (
    .pix_clk        (clk_pixel),
    .rst_n          (rst_n_sync),
    .mode           (gpio_mode),
    .pix_de         (pix_de_int),
    .pattern_rgb    (pattern_rgb),
    .fb_pixel       (fb_pixel_unused),
    .fb_pixel_valid (fb_pixel_valid_unused),
    .rgb_out        (rgb565_mux),
    .rgb_valid      ()
);

// ================================================================
// 6. TMDS 编码
// ================================================================
wire [9:0] tmds_blue, tmds_green, tmds_red, tmds_clk_out;

dvi_encoder u_dvi_encoder (
    .pixelclk  (clk_pixel),
    .rst_p     (~rst_n_sync),        // 高有效复位
    .i_rgb565  (rgb565_mux),
    .i_hs      (pix_hs_int),
    .i_vs      (pix_vs_int),
    .i_de      (pix_de_int),
    .tmds_data0(tmds_blue),          // 蓝色
    .tmds_data1(tmds_green),         // 绿色
    .tmds_data2(tmds_red),           // 红色
    .tmds_clk  (tmds_clk_out)        // 时钟
);

// ================================================================
// 7. 连接到 LVDS 端口
// ================================================================
// 时钟通道
assign lvds_tx_clk_TX_DATA = tmds_clk_out;
assign lvds_tx_clk_TX_OE   = 1'b1;           // 一直使能
assign lvds_tx_clk_TX_RST  = ~rst_n_sync;    // 高有效复位

// 蓝色通道
assign lvds_tx_d0_TX_DATA  = tmds_blue;
assign lvds_tx_d0_TX_OE    = 1'b1;
assign lvds_tx_d0_TX_RST   = ~rst_n_sync;

// 绿色通道
assign lvds_tx_d1_TX_DATA  = tmds_green;
assign lvds_tx_d1_TX_OE    = 1'b1;
assign lvds_tx_d1_TX_RST   = ~rst_n_sync;

// 红色通道
assign lvds_tx_d2_TX_DATA  = tmds_red;
assign lvds_tx_d2_TX_OE    = 1'b1;
assign lvds_tx_d2_TX_RST   = ~rst_n_sync;

endmodule