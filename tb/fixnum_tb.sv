`include "../rtl/fixnum.v"
`timescale 1ns/100ps


module fixnum_tb;

reg rstn ,enable;
reg clk;
initial clk = 0;
always #8.9 clk = ~clk;

reg [`FIXWID-1:0] u_fix_mul_a, u_fix_mul_b;
fix_mul u_fix_mul(
	.a(u_fix_mul_a), .b(u_fix_mul_b) 
);
always@(posedge clk) u_fix_mul_a <= $urandom_range(0-2**6,2**6);
always@(posedge clk) u_fix_mul_b <= $urandom_range(0-2**6,2**6);

reg [`FIXWID-1:0] u_fix_div_a, u_fix_div_b;
fix_div u_fix_div(
	.a(u_fix_div_a), .b(u_fix_div_b) 
);
always@(posedge clk) u_fix_div_a <= $urandom_range(0-2**6,2**6);
always@(posedge clk) u_fix_div_b <= $urandom_range(0-2**6,2**6);

reg [`FIXWID-1:0] u_fix_add_a, u_fix_add_b;
fix_add u_fix_add(
	.a(u_fix_add_a), .b(u_fix_add_b) 
);
always@(posedge clk) u_fix_add_a <= $urandom_range(0-2**6,2**6);
always@(posedge clk) u_fix_add_b <= $urandom_range(0-2**6,2**6);

reg [`FIXWID-1:0] u_fix_mac_a, u_fix_mac_b, u_fix_mac_c;
fix_mac u_fix_mac(
	.a(u_fix_mac_a), .b(u_fix_mac_b), .c(u_fix_mac_c) 
);
always@(posedge clk) u_fix_mac_a <= $urandom_range(0-2**6,2**6);
always@(posedge clk) u_fix_mac_b <= $urandom_range(0-2**6,2**6);
always@(posedge clk) u_fix_mac_c <= $urandom_range(0-2**6,2**6);

reg [`FIXWID-1:0] u_fix_sdc_a, u_fix_sdc_b, u_fix_sdc_c;
fix_sdc u_fix_sdc(
	.a(u_fix_sdc_a), .b(u_fix_sdc_b), .c(u_fix_sdc_c) 
);
always@(posedge clk) u_fix_sdc_a <= $urandom_range(0-2**6,2**6);
always@(posedge clk) u_fix_sdc_b <= $urandom_range(0-2**6,2**6);
always@(posedge clk) u_fix_sdc_c <= $urandom_range(0-2**6,2**6);

wire u_fixu_ack;
wire u_fixu_overflow;
wire [`FIXWID-1:0] u_fixu_z;
reg [`FIXWID-1:0] u_fixu_a, u_fixu_b, u_fixu_c;
reg u_fixu_fn;
reg u_fixu_req;
fixu u_fixu(
	.ack(u_fixu_ack), 
	.overflow(u_fixu_overflow), 
	.z(u_fixu_z), 
	.a(u_fixu_a), .b(u_fixu_b), .c(u_fixu_c), 
	.fn(u_fixu_fn), 
	.req(u_fixu_req), 
	.enable(enable), 
	.rstn(rstn), .clk(clk) 
);
reg [1:0] u_fixu_ack_d;
always@(negedge rstn or posedge clk) begin
	if(!rstn) u_fixu_ack_d <= 2'b00;
	else if(enable) begin
		u_fixu_ack_d[1] <= u_fixu_ack_d[0];
		u_fixu_ack_d[0] <= u_fixu_ack;
	end
end
wire u_fixu_ack_x = ^u_fixu_ack_d;
initial u_fixu_fn = $urandom_range(0,1);
always@(posedge u_fixu_ack_x) u_fixu_fn = $urandom_range(0,1);
initial u_fixu_a = $urandom_range(0-2**6,2**6);
always@(posedge u_fixu_ack_x) u_fixu_a = $urandom_range(0-2**6,2**6);
initial u_fixu_b = $urandom_range(0-2**6,2**6);
always@(posedge u_fixu_ack_x) u_fixu_b = $urandom_range(0-2**6,2**6);
initial u_fixu_c = $urandom_range(0-2**6,2**6);
always@(posedge u_fixu_ack_x) u_fixu_c = $urandom_range(0-2**6,2**6);

initial begin
	rstn = 0;
	enable = 0;
	u_fixu_req = $urandom_range(0,1);
	repeat(2) @(negedge clk);
	rstn = 1;
	repeat(2) @(negedge clk);
	enable = 1;
	repeat(2) @(negedge clk);
	u_fixu_req = ~u_fixu_req;
	repeat(50) begin
		@(posedge u_fixu_ack_x);
		u_fixu_req = ~u_fixu_req;
	end
	repeat(2) @(negedge clk);
	rstn = 0;
	repeat(2) @(negedge clk);
	enable = 0;
	repeat(2) @(negedge clk);
	$finish;
end

initial begin
	$dumpfile("../work/fixnum_tb.fst");
	$dumpvars(0, fixnum_tb);
end

endmodule
