# HDMI 显示子系统（A 同学 · 第 2 周交付）

> **项目**：基于 Ti60F225 的 RISC-V + FPGA 2D 游戏渲染加速系统
> **阶段**：第 2 周 —— HDMI 显示模块
> **状态**：✅ 已完成仿真，待与 B 同学集成
> **对齐文档**：《AB并行开发_接口约定与文件清单.md》

---

## 一、模块功能概述

本模块实现 **640×480@60Hz HDMI 显示**，包含：

| 功能 | 说明 |
|------|------|
| **HDMI 时序生成** | 640×480@60Hz VESA 标准时序 |
| **测试图案输出** | 彩条、网格、矩形、字符（4 种） |
| **像素源选择** | 可在测试图案 和 B 同学 DDR3 像素之间切换 |
| **TMDS 编码** | 8b/10b 编码 + LVDS 差分输出 |

---

## 二、顶层模块 `hdmi_top.v` 接口定义

### 2.1 端口列表

| 端口名 | 方向 | 位宽 | 说明 |
|--------|------|------|------|
| `gpio_clk_50m` | input | 1 | 板载 50MHz 晶振 |
| `gpio_rst_n` | input | 1 | **复位，低有效**（按下=0，松开=1） |
| `gpio_mode` | input | 1 | **模式选择**：0=测试图案，1=DDR3 |
| `gpio_pattern_sel_0` | input | 1 | 图案选择 bit0 |
| `gpio_pattern_sel_1` | input | 1 | 图案选择 bit1 |
| `pll_hdmi_LOCKED` | input | 1 | PLL 锁定指示（Efinity 自动生成） |
| `pll_hdmi_CLKOUT0` | input | 1 | 25MHz 像素时钟（Efinity 自动生成） |
| `pll_hdmi_CLKOUT1` | input | 1 | 250MHz 串行时钟（Efinity 自动生成） |
| `pll_hdmi_RSTN` | output | 1 | PLL 复位，**高有效** |
| `lvds_tx_clk_TX_DATA` | output | 10 | TMDS 时钟通道数据 |
| `lvds_tx_clk_TX_OE` | output | 1 | 时钟通道使能，**高有效** |
| `lvds_tx_clk_TX_RST` | output | 1 | 时钟通道复位，**高有效** |
| `lvds_tx_d0_TX_DATA` | output | 10 | 蓝色通道数据 |
| `lvds_tx_d0_TX_OE` | output | 1 | 蓝色通道使能 |
| `lvds_tx_d0_TX_RST` | output | 1 | 蓝色通道复位 |
| `lvds_tx_d1_TX_DATA` | output | 10 | 绿色通道数据 |
| `lvds_tx_d1_TX_OE` | output | 1 | 绿色通道使能 |
| `lvds_tx_d1_TX_RST` | output | 1 | 绿色通道复位 |
| `lvds_tx_d2_TX_DATA` | output | 10 | 红色通道数据 |
| `lvds_tx_d2_TX_OE` | output | 1 | 红色通道使能 |
| `lvds_tx_d2_TX_RST` | output | 1 | 红色通道复位 |

---

## 三、B 同学需要对接的信号（重点！）

### 3.1 像素源选择开关 `gpio_mode`

| 值 | 显示内容 | 使用场景 |
|----|---------|---------|
| **0** | 内部测试图案（彩条/网格/矩形/字符） | **A 独立调试用** |
| **1** | B 提供的 DDR3 像素 | **集成后用** |

> **B 请注意**：把 `gpio_mode` 拨到 **1** 时，HDMI 显示的像素会来自你的 `framebuffer_reader` 输出。

### 3.2 数据流接口（B → A）

在你的 `framebuffer_reader.v` 中，需要向 A 的 `pixel_mux` 提供：

| 信号 | 方向 | 位宽 | 说明 |
|------|------|------|------|
| `fb_pixel` | B→A | 16 | **RGB565 像素**（高5位R，中6位G，低5位B） |
| `fb_pixel_valid` | B→A | 1 | **像素有效**，高电平有效 |

**接口时序约定**：
- ✅ 在 `pix_de=1` 期间，**每个 `pix_clk` 上升沿 `fb_pixel_valid` 必须为 1**，`fb_pixel` 有效。
- ⚠️ `pix_de=0`（消隐期）时，`fb_pixel` 内容任意，A 会忽略。
- ⚠️ DDR3 读延迟问题：**必须在行消隐期预取下一行数据到 FIFO**，保证 `de` 期间不断流。

### 3.3 时钟与控制信号（A → B）

| 信号 | 方向 | 位宽 | 说明 |
|------|------|------|------|
| `pix_clk` | A→B | 1 | **25MHz 像素时钟**（用于 B 的 framebuffer_reader 同步） |
| `pix_x` | A→B | 12 | 当前像素列坐标（**含消隐，0~799**） |
| `pix_y` | A→B | 12 | 当前像素行坐标（**含消隐，0~524**） |
| `pix_de` | A→B | 1 | **数据有效**：`pix_x<640 && pix_y<480` 时为 1 |
| `pix_hs` | A→B | 1 | 行同步 |
| `pix_vs` | A→B | 1 | 场同步（可用于帧同步） |

---

## 四、控制信号极性说明（避免踩坑！）

| 信号 | 有效电平 | 说明 |
|------|---------|------|
| `gpio_rst_n` | **低有效** | 按下按键 = 0 = 复位；松开 = 1 = 正常工作 |
| `gpio_mode` | 高/低均有效 | 0=图案，1=DDR3 |
| `pll_hdmi_RSTN` | **高有效** | 1=复位，0=正常 |
| `lvds_tx_*_TX_OE` | **高有效** | 1=使能输出，0=高阻 |
| `lvds_tx_*_TX_RST` | **高有效** | 1=复位，0=正常 |
| `pix_de` | **高有效** | 1=数据有效 |
| `fb_pixel_valid` | **高有效** | 1=像素有效（B 提供） |

> ⚠️ **特别注意**：复位信号是**低有效**（`rst_n`），不要接反了！

---

## 五、Efinity 工程信息

| 项目 | 值 |
|------|-----|
| **器件** | Ti60F225 |
| **速度等级** | I3 |
| **封装** | 225-ball FBGA |
| **PLL 资源** | PLL_BR0（右下角 PLL） |
| **PLL 输入** | 50MHz 晶振（GPIOR_29） |
| **PLL 输出** | CLKOUT0 = 25MHz（像素时钟），CLKOUT1 = 250MHz（TMDS 时钟） |
| **LVDS 通道** | GPIOR_PN_11（时钟）、GPIOR_PN_12（蓝）、GPIOR_PN_13（绿）、GPIOR_PN_14（红） |
| **HDMI 所在 Bank** | Bank 3A，1.8V |

---

## 六、地址映射（双方共享契约）

**`address_map.v` 里的常量，双方必须一致：**

```verilog
`define PIX_FMT_RGB565      1
`define SCREEN_W            640
`define SCREEN_H            480
`define BYTES_PER_PIXEL     2
`define LINE_STRIDE         1280    // = 640 × 2

`define FB_A_BASE           32'h0000_0000
`define FB_B_BASE           32'h0010_0000
`define BG_BASE             32'h0020_0000
`define TEX_BASE            32'h0040_0000
`define SPRITE_BASE         32'h0060_0000
`define DEBUG_BASE          32'h0080_0000
