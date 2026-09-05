# 2026 FPGA 竞赛 · 赛题二

## 基于 RISC-V 与 FPGA 异构架构的 2D 图形渲染加速引擎

> 平台：Ti60F225 | 工具：Efinity 2026.1.132 | 队伍：3 人 | 周期：2026.09 – 2026.11.01

---

## 一、系统概述

RISC-V 运行游戏逻辑并生成绘图指令，FPGA 端 2D 硬件加速器（BitBlt Engine）完成
图像块搬运（Block Copy）、纯色填充（Solid Fill）与图层合成（Color Key / Alpha
Blending），DDR3 存储纹理/Sprite/双 Framebuffer，HDMI 输出 640×480@60Hz。

## 二、目录说明

```
00_reference/    官方资料：开发板原理图/引脚约束/官方例程/Sapphire RISC-V SDK（大文件，不入 Git）
10_vendor/       需集成/改动的官方代码（DDR3、HDMI、Sapphire SoC 包装）
20_src_rtl/      自研 RTL：top / cmd / render / display / mem / common
30_riscv_sw/     RISC-V C 软件：driver(驱动) / app(游戏) / bsp / tools
40_efinity_proj/ Efinity 工程，按里程碑分 step1_led, step2_hdmi, ...
50_sim/          仿真：tb / test_data / scripts
60_scripts/      脚本：编译、下载、图片转换、性能统计
70_docs/         文档：架构图 / 寄存器说明 / 接口确认表 / 周报 / 测试报告
80_deliverable/  11 月交付与答辩材料：PPT / 视频 / 手册 / 备用 bitstream
```

## 三、三人分工

| 成员 | 主责 | 备份 |
|---|---|---|
| A | 显示与存储：HDMI/DDR3/Framebuffer/双缓冲 | 加速器 DDR 接口、性能测试 |
| B | 2D 加速器：寄存器/命令解析/Solid Fill/Block Copy | Alpha Blending、RTL 仿真 |
| C | RISC-V 软件与 Demo：C 驱动/游戏/FPS | Color Keying、报告整理 |

## 四、开发流程要点

1. 顶层与所有目录用**纯英文路径**（Efinity 不支持中文路径）；
2. 官方例程原样放 `00_reference/efinity_ref/`，要改动时复制到对应工程目录改；
3. Efinity 工程按里程碑分目录（`40_efinity_proj/stepN_xxx`），不共用一个工程反复改；
4. 编译产物 `outflow/` 已被 .gitignore 忽略，不入版本库。

## 五、进度

- [ ] 第 1 周：环境搭建与资料确认（目标：三人能独立下载 bitstream）
- [ ] 第 2 周：HDMI 显示
- [ ] 第 3 周：DDR3 与 Framebuffer
- [ ] 第 4 周：Solid Fill
- [ ] 第 5 周：Block Copy
- [ ] 第 6 周：RISC-V 驱动与双缓冲
- [ ] 第 7 周：软件/硬件性能对比
- [ ] 第 8 周：游戏 Demo
- [ ] 第 9 周：Color Keying
- [ ] 第 10 周：Alpha Blending
- [ ] 第 11 周：系统优化与稳定性
- [ ] 11/1 前：提交与答辩材料
