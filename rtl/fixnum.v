`ifndef FIXWID
	`define FIXWID 16
`endif
`ifndef FIXASH
	`define FIXASH 10
`endif


module fix_mul(
	output reg overflow, 
	output reg [`FIXWID-1:0] z, 
	input [`FIXWID-1:0] a, b 
);

reg sign;
reg [`FIXWID-1:0] abs_a, abs_b;
reg [2*`FIXWID-1:0] abs_r_result;
always@(*) begin
	sign = a[`FIXWID-1] ^ b[`FIXWID-1];
	abs_a = a[`FIXWID-1] ? ~a + 1 : a;
	abs_b = b[`FIXWID-1] ? ~b + 1 : b;
	abs_r_result = abs_a[`FIXWID-1:0] * abs_b[`FIXWID-1:0];
	z = sign ? ~abs_r_result[`FIXWID-1+`FIXASH:`FIXASH] + 1 : abs_r_result[`FIXWID-1+`FIXASH:`FIXASH];
	if(abs_r_result[2*`FIXWID-2:`FIXWID-1+`FIXASH] > 0) overflow = 1'b1;
	else overflow = 1'b0;
end

endmodule


module fix_div(
	output reg overflow, 
	output reg [`FIXWID-1:0] z, 
	input [`FIXWID-1:0] a, b 
);

reg sign;
reg [2*`FIXWID-1:0] abs_a;
reg [`FIXWID-1:0] abs_b;
reg [2*`FIXWID-1:0] abs_r_result;
always@(*) begin
	sign = a[`FIXWID-1] ^ b[`FIXWID-1];
	abs_a[`FIXWID-1:0] = 0;
	abs_a[`FIXWID-1+`FIXASH:`FIXASH] = a[`FIXWID-1] ? ~a + 1 : a;
	abs_a[2*`FIXWID-1:`FIXWID+`FIXASH] = 0;
	abs_b = b[`FIXWID-1] ? ~b + 1 : b;
	abs_r_result = abs_a[2*`FIXWID-1:0] / {{`FIXWID{1'b0}},abs_b[`FIXWID-1:0]};
	z = sign ? ~abs_r_result[`FIXWID-1:0] + 1 : abs_r_result[`FIXWID-1:0];
	if(abs_r_result[2*`FIXWID-2:`FIXWID] > 0 || abs_b == 0) overflow = 1'b1;
	else overflow = 1'b0;
end

endmodule


module fix_add(
	output reg overflow, 
	output reg [`FIXWID-1:0] z, 
	input [`FIXWID-1:0] a, b 
);

reg [`FIXWID:0] ext_a, ext_b, r_result;
always@(*) begin
	ext_a = {a[`FIXWID-1],a};
	ext_b = {b[`FIXWID-1],b};
	r_result = ext_a + ext_b;
	z = r_result[`FIXWID-1:0];
	if(r_result[`FIXWID] != r_result[`FIXWID-1]) overflow = 1'b1;
	else overflow = 1'b0;
end

endmodule


module fix_mac(	// z = a * b + c
	output overflow, 
	output [`FIXWID-1:0] z, 
	input [`FIXWID-1:0] a, b, c 
);

wire u_fix_mul_overflow;
wire [`FIXWID-1:0] u_fix_mul_z;
fix_mul u_fix_mul(
	.overflow(u_fix_mul_overflow), 
	.z(u_fix_mul_z), 
	.a(a), .b(b) 
);

wire u_fix_add_overflow;
wire [`FIXWID-1:0] u_fix_add_z;
fix_add u_fix_add(
	.overflow(u_fix_add_overflow), 
	.z(u_fix_add_z), 
	.a(u_fix_mul_z), .b(c) 
);

assign z = u_fix_add_z;
assign overflow = u_fix_mul_overflow | u_fix_add_overflow;

endmodule


module fix_sdc(	// z = (a - b) / c
	output overflow, 
	output [`FIXWID-1:0] z, 
	input [`FIXWID-1:0] a, b, c 
);

wire [`FIXWID-1:0] minus_b = ~b + 1;
wire u_fix_sub_overflow;
wire [`FIXWID-1:0] u_fix_sub_z;
fix_add u_fix_sub(
	.overflow(u_fix_sub_overflow), 
	.z(u_fix_sub_z), 
	.a(a), .b(minus_b) 
);

wire u_fix_div_overflow;
wire [`FIXWID-1:0] u_fix_div_z;
fix_div u_fix_div(
	.overflow(u_fix_div_overflow), 
	.z(u_fix_div_z), 
	.a(u_fix_sub_z), .b(c) 
);

assign z = u_fix_div_z;
assign overflow = u_fix_sub_overflow | u_fix_div_overflow;

endmodule


module fixu(
	output reg ack, 
	output reg overflow, 
	output reg [`FIXWID-1:0] z, 
	input [`FIXWID-1:0] a, b, c, 
	input fn, 
	input req, 
	input enable, 
	input rstn, clk 
);

reg [`FIXWID-1:0] u_fix_mac_a, u_fix_mac_b, u_fix_mac_c;
wire [`FIXWID-1:0] u_fix_mac_z;
wire u_fix_mac_overflow;
fix_mac u_fix_mac(
	.a(u_fix_mac_a), .b(u_fix_mac_b), .c(u_fix_mac_c), 
	.z(u_fix_mac_z), .overflow(u_fix_mac_overflow) 
);

reg [`FIXWID-1:0] u_fix_sdc_a, u_fix_sdc_b, u_fix_sdc_c;
wire [`FIXWID-1:0] u_fix_sdc_z;
wire u_fix_sdc_overflow;
fix_sdc u_fix_sdc(
	.a(u_fix_sdc_a), .b(u_fix_sdc_b), .c(u_fix_sdc_c), 
	.z(u_fix_sdc_z), .overflow(u_fix_sdc_overflow)
);

reg [1:0] req_d;
always@(negedge rstn or posedge clk) begin
	if(!rstn) req_d <= 2'b00;
	else if(enable) begin
		req_d[1] <= req_d[0];
		req_d[0] <= req;
	end
end
wire req_x = ^req_d;

`ifndef FIXDLYMUL
	`define FIXDLYMUL	5'd2
`endif
`ifndef FIXDLYDIV
	`define FIXDLYDIV	5'd10
`endif
reg [4:0] cnt;
always@(negedge rstn or posedge clk) begin
	if(!rstn) begin
		cnt <= 5'd0;
		ack <= 1'b0;
		z <= 0;
		overflow <= 1'b0;
	end
	else if(enable) begin
		if(cnt == 5'd0) begin
			if(req_x) begin
				case(fn)
					1'd0: begin
						cnt <= `FIXDLYMUL;
						u_fix_mac_a <= a;
						u_fix_mac_b <= b;
						u_fix_mac_c <= c;
					end
					1'd1: begin
						cnt <= `FIXDLYDIV;
						u_fix_sdc_a <= a;
						u_fix_sdc_b <= b;
						u_fix_sdc_c <= c;
					end
					default: begin
						u_fix_mac_a <= u_fix_mac_a;
						u_fix_mac_b <= u_fix_mac_b;
						u_fix_mac_c <= u_fix_mac_c;
						u_fix_sdc_a <= u_fix_sdc_a;
						u_fix_sdc_b <= u_fix_sdc_b;
						u_fix_sdc_c <= u_fix_sdc_c;
					end
				endcase
			end
		end
		else begin
			cnt <= cnt - 5'd1;
			if(cnt == 5'd1) begin
				ack <= ~ack;
				case(fn)
					1'd0: begin
						z <= u_fix_mac_z;
						overflow <= u_fix_mac_overflow;
					end
					1'd1: begin
						z <= u_fix_sdc_z;
						overflow <= u_fix_sdc_overflow;
					end
					default: begin
						z <= z;
						overflow <= overflow;
					end
				endcase
			end
		end
	end
end

endmodule
