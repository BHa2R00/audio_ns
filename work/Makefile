fixnum_tb: ../tb/fixnum_tb.sv
	rm -rfv ../work/fixnum_tb.fst
	iverilog -g2012 ../tb/fixnum_tb.sv 
	vvp ./a.out -fst
	gtkwave ../work/fixnum_tb.fst

audio_ns_tb: ../tb/audio_ns_tb.sv
	rm -rfv ../work/audio_ns_tb.fst
	iverilog -g2012 ../tb/audio_ns_tb.sv 
	vvp ./a.out -fst
	gtkwave ../work/audio_ns_tb.fst
