onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_hdmi/clk
add wave -noupdate /tb_hdmi/rst_n
add wave -noupdate /tb_hdmi/u_timing/pix_hs
add wave -noupdate /tb_hdmi/u_timing/pix_vs
add wave -noupdate /tb_hdmi/u_timing/pix_de
add wave -noupdate /tb_hdmi/u_timing/pix_x
add wave -noupdate /tb_hdmi/u_timing/pix_y
add wave -noupdate -expand /tb_hdmi/pattern_rgb
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 2} {1567460000 ps} 0} {{Cursor 3} {0 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 203
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {1367386872 ps} {2278978120 ps}
