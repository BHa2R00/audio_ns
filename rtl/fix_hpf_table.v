module fix_hpf_table(
	input sel_hpf_0p008, sel_hpf_0p002, sel_hpf_0p00025, 
	output [15:0] hpf_b1, hpf_b2, 
	output [15:0] hpf_a1, hpf_a2
);
assign hpf_b1 = sel_hpf_0p008 ? 16'd732		: sel_hpf_0p002 ? 16'd931	: sel_hpf_0p00025 ? 16'd1011	: 16'd1024;
assign hpf_b2 = sel_hpf_0p008 ? -16'd732	: sel_hpf_0p002 ? -16'd931	: sel_hpf_0p00025 ? -16'd1011	: 16'd1024;
assign hpf_a1 = sel_hpf_0p008 ? -16'd1024	: sel_hpf_0p002 ? -16'd1024	: sel_hpf_0p00025 ? -16'd1024	: 16'd1024;
assign hpf_a2 = sel_hpf_0p008 ? 16'd441		: sel_hpf_0p002 ? 16'd838	: sel_hpf_0p00025 ? 16'd998		: 16'd1024;
endmodule
