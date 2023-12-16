module fix_lpf_table(
	input sel_lpf_0p1875, sel_lpf_0p325, sel_lpf_0p75, 
	output [15:0] lpf_b1, lpf_b2, lpf_b3, lpf_b4, lpf_b5, lpf_b6, 
	output [15:0] lpf_a1, lpf_a2, lpf_a3, lpf_a4, lpf_a5, lpf_a6
);
assign lpf_b1 = sel_lpf_0p1875 ? 16'd30		: sel_lpf_0p325 ? 16'd54	: sel_lpf_0p75 ? 16'd321	: 16'd1024;
assign lpf_b2 = sel_lpf_0p1875 ? -16'd55	: sel_lpf_0p325 ? -16'd3	: sel_lpf_0p75 ? 16'd1362	: 16'd1024;
assign lpf_b3 = sel_lpf_0p1875 ? 16'd33		: sel_lpf_0p325 ? 16'd56	: sel_lpf_0p75 ? 16'd2518	: 16'd1024;
assign lpf_b4 = sel_lpf_0p1875 ? 16'd33		: sel_lpf_0p325 ? 16'd56	: sel_lpf_0p75 ? 16'd2518	: 16'd1024;
assign lpf_b5 = sel_lpf_0p1875 ? -16'd55	: sel_lpf_0p325 ? -16'd3	: sel_lpf_0p75 ? 16'd1362	: 16'd1024;
assign lpf_b6 = sel_lpf_0p1875 ? 16'd30		: sel_lpf_0p325 ? 16'd54	: sel_lpf_0p75 ? 16'd321	: 16'd1024;
assign lpf_a1 = sel_lpf_0p1875 ? 16'd1024	: sel_lpf_0p325 ? 16'd1024	: sel_lpf_0p75 ? 16'd1024	: 16'd1024;
assign lpf_a2 = sel_lpf_0p1875 ? -16'd3507	: sel_lpf_0p325 ? -16'd2266	: sel_lpf_0p75 ? 16'd2270	: 16'd1024;
assign lpf_a3 = sel_lpf_0p1875 ? 16'd5000	: sel_lpf_0p325 ? 16'd2479	: sel_lpf_0p75 ? 16'd2647	: 16'd1024;
assign lpf_a4 = sel_lpf_0p1875 ? -16'd3656	: sel_lpf_0p325 ? -16'd1413	: sel_lpf_0p75 ? 16'd1729	: 16'd1024;
assign lpf_a5 = sel_lpf_0p1875 ? 16'd1366	: sel_lpf_0p325 ? 16'd444	: sel_lpf_0p75 ? 16'd631	: 16'd1024;
assign lpf_a6 = sel_lpf_0p1875 ? -16'd206	: sel_lpf_0p325 ? -16'd53	: sel_lpf_0p75 ? 16'd100	: 16'd1024;
endmodule
