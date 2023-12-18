`include "../rtl/audio_ns.v"
`timescale 1ns/100ps

module audio_ns_tb;

reg lrclk;
initial lrclk = 0;
always #31250.002 lrclk = ~lrclk;

wire dut_ack;
wire dut_overflow;
wire [`FIXWID-1:0] dut_tx_data;
reg [`FIXWID-1:0] dut_rx_data;
reg [`FIXWID+`FIXWID+4-1:0] dut_conf;
reg dut_req;
reg dut_enable;
reg dut_rstn, dut_clk;

fix_audio_ns dut(
	.ack(dut_ack), 
	.overflow(dut_overflow), 
	.tx_data(dut_tx_data), 
	.rx_data(dut_rx_data), 
	.conf(dut_conf), 
	.req(dut_req), 
	.enable(dut_enable), 
	.rstn(dut_rstn), .clk(dut_clk) 
);

initial dut_clk = 0;
always #8.9 dut_clk = ~dut_clk;

task reset();
	dut_rstn = 0;
	dut_req = 0;
	dut_rx_data = 0;
	repeat(5) @(negedge dut_clk);
	dut_rstn = 1;
endtask

task enable();
	dut_enable = 0;
	repeat(5) @(negedge dut_clk);
	dut_enable = 1;
endtask

task push_dut_rx_data();
	@(posedge dut_ack or negedge dut_ack);
	$display("dut_tx_data = %d", $signed(dut_tx_data));
	dut_rx_data = ($urandom_range(0-0, 0+0) 
		+ 1024*$sin(    4*$time*2*3.1415926)
		+  768*$sin(    8*$time*2*3.1415926)
		+  512*$sin(   16*$time*2*3.1415926)
		+  384*$sin(   32*$time*2*3.1415926)
		+  256*$sin(   64*$time*2*3.1415926)
		+  192*$sin(  128*$time*2*3.1415926)
		+  128*$sin(  256*$time*2*3.1415926)
		+   96*$sin(  512*$time*2*3.1415926)
		+   64*$sin( 1024*$time*2*3.1415926)
		+   32*$sin( 2048*$time*2*3.1415926)
		+   16*$sin( 4096*$time*2*3.1415926)
		+   12*$sin( 8192*$time*2*3.1415926)
		+    8*$sin(16384*$time*2*3.1415926)
		)*2;
	@(posedge lrclk);
	dut_req = ~dut_req;
endtask

reg [1:0] sel_hpf;
reg [1:0] sel_lpf;
reg [`FIXWID-1:0] kal_pnc;
reg [`FIXWID-1:0] vol;

task test(int k);
	dut_conf = {vol,kal_pnc,sel_lpf,sel_hpf};
	reset();
	enable();
	$display("test: sel_hpf = %b, sel_lpf = %b, kal_pnc = %d", sel_hpf, sel_lpf, kal_pnc);
	@(posedge lrclk);
	dut_req = ~dut_req;
	repeat(k) push_dut_rx_data();
endtask

initial begin
	vol = 1024; sel_hpf = 2'b00; sel_lpf = 2'b00; kal_pnc =   0; test(500);
	vol = 1024; sel_hpf = 2'b01; sel_lpf = 2'b00; kal_pnc =   0; test(1000);
	vol = 1024; sel_hpf = 2'b10; sel_lpf = 2'b00; kal_pnc =   0; test(1000);
	vol = 1024; sel_hpf = 2'b11; sel_lpf = 2'b00; kal_pnc =   0; test(1000);
	vol = 1024; sel_hpf = 2'b00; sel_lpf = 2'b00; kal_pnc =   0; test(500);
	vol = 1024; sel_hpf = 2'b00; sel_lpf = 2'b01; kal_pnc =   0; test(1000);
	vol = 1024; sel_hpf = 2'b00; sel_lpf = 2'b10; kal_pnc =   0; test(1000);
	vol = 1024; sel_hpf = 2'b00; sel_lpf = 2'b11; kal_pnc =   0; test(1000);
	vol = 1024; sel_hpf = 2'b00; sel_lpf = 2'b00; kal_pnc =   0; test(500);
	vol = 1024; sel_hpf = 2'b00; sel_lpf = 2'b00; kal_pnc = 102; test(1000);
	vol = 1024; sel_hpf = 2'b00; sel_lpf = 2'b00; kal_pnc =  10; test(1000);
	vol = 1024; sel_hpf = 2'b00; sel_lpf = 2'b00; kal_pnc =   1; test(1000);
	vol = 1024; sel_hpf = 2'b00; sel_lpf = 2'b00; kal_pnc =   0; test(500);
	vol = 1024; sel_hpf = 2'b01; sel_lpf = 2'b01; kal_pnc =   0; test(1000);
	vol = 1024; sel_hpf = 2'b10; sel_lpf = 2'b10; kal_pnc =   0; test(1000);
	vol = 1024; sel_hpf = 2'b11; sel_lpf = 2'b11; kal_pnc =   0; test(1000);
	vol = 1024; sel_hpf = 2'b00; sel_lpf = 2'b00; kal_pnc =   0; test(500);
	vol = 1024; sel_hpf = 2'b10; sel_lpf = 2'b10; kal_pnc =  10; test(1000);
	vol = 3072; sel_hpf = 2'b10; sel_lpf = 2'b10; kal_pnc =  10; test(1000);
	vol = 9216; sel_hpf = 2'b10; sel_lpf = 2'b10; kal_pnc =  10; test(1000);
	$finish;
end

initial begin
	$dumpfile("../work/audio_ns_tb.fst");
	$dumpvars(0,audio_ns_tb);
end

endmodule
