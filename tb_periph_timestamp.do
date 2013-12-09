vsim -voptargs=+acc work.tb_periph_timestamp
add wave -radix hexadecimal -r /*

# property wave -radix hexadecimal sim:/tb_periph_timestamp/per_dout \
# sim:/tb_periph_timestamp/addr \
# sim:/tb_periph_timestamp/per_din \
# sim:/tb_periph_timestamp/per_addr \
# sim:/tb_periph_timestamp/uut/per_dout \
# sim:/tb_periph_timestamp/uut/per_addr \
# sim:/tb_periph_timestamp/uut/per_din \
# sim:/tb_periph_timestamp/uut/tscount \
# sim:/tb_periph_timestamp/uut/ts \
# sim:/tb_periph_timestamp/uut/ibus \
# sim:/tb_periph_timestamp/uut/obus \
# sim:/tb_periph_timestamp/uut/inst_timestamp/ibus \
# sim:/tb_periph_timestamp/uut/inst_timestamp/obus \
# sim:/tb_periph_timestamp/uut/inst_timestamp/tscount \
# sim:/tb_periph_timestamp/uut/inst_timestamp/counter \
# sim:/tb_periph_timestamp/uut/inst_timestamp/div \
# sim:/tb_periph_timestamp/uut/inst_timestamp/divlatch

force -deposit /tb_periph_timestamp/uut/inst_timestamp/div 0000000000000000
force -deposit /tb_periph_timestamp/uut/inst_timestamp/counter 0000000000000000
force -deposit /tb_periph_timestamp/uut/inst_timestamp/divlatch 0000000000000000
run -all
