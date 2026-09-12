// ================================================================
// 文件：address_map.v
// 功能：显示与存储共享常量
// 状态：⚠️ 先写你的版本，B 来了之后双方冻结
// ================================================================

`ifndef ADDRESS_MAP_V
`define ADDRESS_MAP_V

`define PIX_FMT_RGB565      1
`define SCREEN_W            640
`define SCREEN_H            480
`define BYTES_PER_PIXEL     2
`define LINE_STRIDE         1280

`define FB_A_BASE           32'h0000_0000
`define FB_B_BASE           32'h0010_0000

`define BG_BASE             32'h0020_0000
`define TEX_BASE            32'h0040_0000
`define SPRITE_BASE         32'h0060_0000
`define DEBUG_BASE          32'h0080_0000

`endif