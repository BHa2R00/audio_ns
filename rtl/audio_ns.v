`include "../rtl/fixnum.v"
`include "../rtl/fix_hpf_table.v"
`include "../rtl/fix_lpf_table.v"


module fix_audio_ns(
	output reg ack, 
	output reg overflow, 
	output reg [`FIXWID-1:0] tx_data, 
	input [`FIXWID-1:0] rx_data, 
	input [`FIXWID+`FIXWID+4-1:0] conf, 
	input req, 
	input enable, 
	input rstn, clk 
);

`ifndef gray
	`define gray(x) (x^(x>>1))
`endif
reg [5:0] cst;
localparam
	st_error = `gray(47),
	st_done = `gray(46),
	st_vol = `gray(45), st_load_vol = `gray(44),
	st_kal_update_eec = `gray(43), st_kal_update_load_eec = `gray(42),
	st_kal_update_es = `gray(41), st_kal_update_load_es = `gray(40),
	st_kal_update_k = `gray(39),
	st_kal_update_k_load = `gray(38), st_kal_update_k_1 = `gray(37),
	st_kal_idle = `gray(36),
	st_lpf_y0 = `gray(35), st_lpf_a1 = `gray(34), 
	st_lpf_a6 = `gray(33), st_lpf_load_a6 = `gray(32), 
	st_lpf_a5 = `gray(31), st_lpf_load_a5 = `gray(30), 
	st_lpf_a4 = `gray(29), st_lpf_load_a4 = `gray(28), 
	st_lpf_a3 = `gray(27), st_lpf_load_a3 = `gray(26), 
	st_lpf_a2 = `gray(25), st_lpf_load_a2 = `gray(24), 
	st_lpf_b6 = `gray(23), st_lpf_load_b6 = `gray(22), 
	st_lpf_b5 = `gray(21), st_lpf_load_b5 = `gray(20), 
	st_lpf_b4 = `gray(19), st_lpf_load_b4 = `gray(18), 
	st_lpf_b3 = `gray(17), st_lpf_load_b3 = `gray(16), 
	st_lpf_b2 = `gray(15), st_lpf_load_b2 = `gray(14), 
	st_lpf_b1 = `gray(13), st_lpf_load_b1 = `gray(12), 
	st_lpf_shift = `gray(11),
	st_hpf_y0 = `gray(10),
	st_hpf_a1 = `gray(09), st_hpf_load_a1 = `gray(08), 
	st_hpf_a2 = `gray(07), st_hpf_load_a2 = `gray(06), 
	st_hpf_b2 = `gray(05), st_hpf_load_b2 = `gray(04), 
	st_hpf_b1 = `gray(03), st_hpf_load_b1 = `gray(02), 
	st_hpf_shift = `gray(01),
	st_idle = `gray(00);

wire [1:0] sel_hpf = conf[1:0];
wire sel_hpf_0p008 = sel_hpf == 2'b11;
wire sel_hpf_0p002 = sel_hpf == 2'b10;
wire sel_hpf_0p00025 = sel_hpf == 2'b01;
wire disable_hpf = sel_hpf == 2'b00;
wire [15:0] hpf_b1, hpf_b2, hpf_a1, hpf_a2;
fix_hpf_table u_fix_hpf_table(
	sel_hpf_0p008, sel_hpf_0p002, sel_hpf_0p00025, 
	hpf_b1, hpf_b2, 
	hpf_a1, hpf_a2
);
wire [1:0] sel_lpf = conf[3:2];
wire sel_lpf_0p75 = sel_lpf == 2'b01;
wire sel_lpf_0p325 = sel_lpf == 2'b10;
wire sel_lpf_0p1875 = sel_lpf == 2'b11;
wire disable_lpf = sel_lpf == 2'b00;
wire [15:0] lpf_b1, lpf_b2, lpf_b3, lpf_b4, lpf_b5, lpf_b6;
wire [15:0] lpf_a1, lpf_a2, lpf_a3, lpf_a4, lpf_a5, lpf_a6;
fix_lpf_table u_fix_lpf_table(
	sel_lpf_0p1875, sel_lpf_0p325, sel_lpf_0p75, 
	lpf_b1, lpf_b2, lpf_b3, lpf_b4, lpf_b5, lpf_b6, 
	lpf_a1, lpf_a2, lpf_a3, lpf_a4, lpf_a5, lpf_a6
);
wire [`FIXWID-1:0] kal_pnc = conf[`FIXWID+4-1:4];
wire disable_kal = kal_pnc == {`FIXWID{1'b0}};
wire [`FIXWID-1:0] kal_mnc = 16'd1024;
wire [`FIXWID-1:0] vol = conf[`FIXWID+`FIXWID+4-1:`FIXWID+4];

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

reg [1:0] req_d, u_fixu_ack_d;
always@(negedge rstn or posedge clk) begin
	if(!rstn) begin
		req_d <= 2'b00;
		u_fixu_ack_d <= 2'b00;
	end
	else if(enable) begin
		req_d[1] <= req_d[0];
		req_d[0] <= req;
		u_fixu_ack_d[1] <= u_fixu_ack_d[0];
		u_fixu_ack_d[0] <= u_fixu_ack;
	end
end
wire req_x = ^req_d;
wire u_fixu_ack_x = ^u_fixu_ack_d;

reg [`FIXWID-1:0] data;

reg [`FIXWID-1:0] hpf_x0, hpf_x1;
reg [`FIXWID-1:0] hpf_y0, hpf_y1;
reg [`FIXWID-1:0] lpf_x0, lpf_x1, lpf_x2, lpf_x3, lpf_x4, lpf_x5;
reg [`FIXWID-1:0] lpf_y0, lpf_y1, lpf_y2, lpf_y3, lpf_y4, lpf_y5;
reg [15:0] kal_k, kal_es, kal_eec;
//kalman predict
wire [15:0] kal_es_nst = kal_es;
wire [15:0] kal_eec_nst = kal_eec + kal_pnc;

always@(negedge rstn or posedge clk) begin
	if(!rstn) begin
		cst <= st_idle;
		data <= 0;
		u_fixu_fn <= 1'b0;
		u_fixu_req <= 1'b0;
		u_fixu_a <= 0;
		u_fixu_b <= 0;
		u_fixu_c <= 0;
		hpf_x0 <= 0; hpf_x1 <= 0;
		hpf_y0 <= 0; hpf_y1 <= 0;
		lpf_x0 <= 0; lpf_x1 <= 0; lpf_x2 <= 0; lpf_x3 <= 0; lpf_x4 <= 0; lpf_x5 <= 0;
		lpf_y0 <= 0; lpf_y1 <= 0; lpf_y2 <= 0; lpf_y3 <= 0; lpf_y4 <= 0; lpf_y5 <= 0;
		kal_k <= 0; kal_es <= 0; kal_eec <= 0;
		overflow <= 1'b0;
		ack <= 1'b0;
	end
	else if(enable) begin
		case(cst)
			st_idle: 
				if(req_x) begin
					cst <= st_hpf_shift;
					data <= rx_data;
					overflow <= 1'b0;
				end
			// hpf
			st_hpf_shift: begin
				if(disable_hpf) cst <= st_lpf_shift;
				else cst <= st_hpf_load_b1;
				hpf_x0 <= data; hpf_x1 <= hpf_x0;
				hpf_y1 <= hpf_y0;
			end
			st_hpf_load_b1: begin
				cst <= st_hpf_b1;
				u_fixu_fn <= 1'b0;
				u_fixu_req <= ~u_fixu_req;
				u_fixu_a <= hpf_b1;
				u_fixu_b <= hpf_x0;
				u_fixu_c <= 0;
			end
			st_hpf_b1: 
				if(u_fixu_ack_x) begin
					if(u_fixu_overflow) cst <= st_error;
					else cst <= st_hpf_load_b2;
				end
			st_hpf_load_b2: begin
				cst <= st_hpf_b2;
				u_fixu_fn <= 1'b0;
				u_fixu_req <= ~u_fixu_req;
				u_fixu_a <= hpf_b2;
				u_fixu_b <= hpf_x1;
				u_fixu_c <= u_fixu_z;
			end
			st_hpf_b2: 
				if(u_fixu_ack_x) begin
					if(u_fixu_overflow) cst <= st_error;
					else begin
						cst <= st_hpf_load_a2;
						data <= u_fixu_z;
					end
				end
			st_hpf_load_a2: begin
				cst <= st_hpf_a2;
				u_fixu_fn <= 1'b0;
				u_fixu_req <= ~u_fixu_req;
				u_fixu_a <= hpf_a2;
				u_fixu_b <= hpf_y1;
				u_fixu_c <= 0;
			end
			st_hpf_a2: 
				if(u_fixu_ack_x) begin
					if(u_fixu_overflow) cst <= st_error;
					else cst <= st_hpf_load_a1;
				end
			st_hpf_load_a1: begin
				cst <= st_hpf_y0;
				u_fixu_fn <= 1'b1;
				u_fixu_req <= ~u_fixu_req;
				u_fixu_a <= data;
				u_fixu_b <= u_fixu_z;
				u_fixu_c <= hpf_a1;
			end
			st_hpf_y0: 
				if(u_fixu_ack_x) begin
					if(u_fixu_overflow) cst <= st_error;
					else begin
						cst <= st_lpf_shift;
						hpf_y0 <= u_fixu_z;
						data <= u_fixu_z;
					end
				end
			// lpf
			st_lpf_shift: begin
				if(disable_lpf) cst <= st_kal_idle;
				else cst <= st_lpf_load_b1;
				lpf_x0 <= data;
				lpf_x1 <= lpf_x0; lpf_x2 <= lpf_x1; lpf_x3 <= lpf_x2; lpf_x4 <= lpf_x3; lpf_x5 <= lpf_x4;
				lpf_y1 <= lpf_y0; lpf_y2 <= lpf_y1; lpf_y3 <= lpf_y2; lpf_y4 <= lpf_y3; lpf_y5 <= lpf_y4;
			end
			st_lpf_load_b1: begin
				cst <= st_lpf_b1;
				u_fixu_fn <= 1'b0;
				u_fixu_req <= ~u_fixu_req;
				u_fixu_a <= lpf_b1;
				u_fixu_b <= lpf_x0;
				u_fixu_c <= 0;
			end
			st_lpf_b1: 
				if(u_fixu_ack_x) begin
					if(u_fixu_overflow) cst <= st_error;
					else cst <= st_lpf_load_b2;
				end
			st_lpf_load_b2: begin
				cst <= st_lpf_b2;
				u_fixu_fn <= 1'b0;
				u_fixu_req <= ~u_fixu_req;
				u_fixu_a <= lpf_b2;
				u_fixu_b <= lpf_x1;
				u_fixu_c <= u_fixu_z;
			end
			st_lpf_b2: 
				if(u_fixu_ack_x) begin
					if(u_fixu_overflow) cst <= st_error;
					else cst <= st_lpf_load_b3;
				end
			st_lpf_load_b3: begin
				cst <= st_lpf_b3;
				u_fixu_fn <= 1'b0;
				u_fixu_req <= ~u_fixu_req;
				u_fixu_a <= lpf_b3;
				u_fixu_b <= lpf_x2;
				u_fixu_c <= u_fixu_z;
			end
			st_lpf_b3: 
				if(u_fixu_ack_x) begin
					if(u_fixu_overflow) cst <= st_error;
					else cst <= st_lpf_load_b4;
				end
			st_lpf_load_b4: begin
				cst <= st_lpf_b4;
				u_fixu_fn <= 1'b0;
				u_fixu_req <= ~u_fixu_req;
				u_fixu_a <= lpf_b4;
				u_fixu_b <= lpf_x3;
				u_fixu_c <= u_fixu_z;
			end
			st_lpf_b4: 
				if(u_fixu_ack_x) begin
					if(u_fixu_overflow) cst <= st_error;
					else cst <= st_lpf_load_b5;
				end
			st_lpf_load_b5: begin
				cst <= st_lpf_b5;
				u_fixu_fn <= 1'b0;
				u_fixu_req <= ~u_fixu_req;
				u_fixu_a <= lpf_b5;
				u_fixu_b <= lpf_x4;
				u_fixu_c <= u_fixu_z;
			end
			st_lpf_b5: 
				if(u_fixu_ack_x) begin
					if(u_fixu_overflow) cst <= st_error;
					else cst <= st_lpf_load_b6;
				end
			st_lpf_load_b6: begin
				cst <= st_lpf_b6;
				u_fixu_fn <= 1'b0;
				u_fixu_req <= ~u_fixu_req;
				u_fixu_a <= lpf_b6;
				u_fixu_b <= lpf_x5;
				u_fixu_c <= u_fixu_z;
			end
			st_lpf_b6: 
				if(u_fixu_ack_x) begin
					if(u_fixu_overflow) cst <= st_error;
					else begin
						cst <= st_lpf_load_a2;
						data <= u_fixu_z;
					end
				end
			st_lpf_load_a2: begin
				cst <= st_lpf_a2;
				u_fixu_fn <= 1'b0;
				u_fixu_req <= ~u_fixu_req;
				u_fixu_a <= lpf_a2;
				u_fixu_b <= lpf_y1;
				u_fixu_c <= 0;
			end
			st_lpf_a2: 
				if(u_fixu_ack_x) begin
					if(u_fixu_overflow) cst <= st_error;
					else cst <= st_lpf_load_a3;
				end
			st_lpf_load_a3: begin
				cst <= st_lpf_a3;
				u_fixu_fn <= 1'b0;
				u_fixu_req <= ~u_fixu_req;
				u_fixu_a <= lpf_a3;
				u_fixu_b <= lpf_y2;
				u_fixu_c <= u_fixu_z;
			end
			st_lpf_a3: 
				if(u_fixu_ack_x) begin
					if(u_fixu_overflow) cst <= st_error;
					else cst <= st_lpf_load_a4;
				end
			st_lpf_load_a4: begin
				cst <= st_lpf_a4;
				u_fixu_fn <= 1'b0;
				u_fixu_req <= ~u_fixu_req;
				u_fixu_a <= lpf_a4;
				u_fixu_b <= lpf_y3;
				u_fixu_c <= u_fixu_z;
			end
			st_lpf_a4: 
				if(u_fixu_ack_x) begin
					if(u_fixu_overflow) cst <= st_error;
					else cst <= st_lpf_load_a5;
				end
			st_lpf_load_a5: begin
				cst <= st_lpf_a5;
				u_fixu_fn <= 1'b0;
				u_fixu_req <= ~u_fixu_req;
				u_fixu_a <= lpf_a5;
				u_fixu_b <= lpf_y4;
				u_fixu_c <= u_fixu_z;
			end
			st_lpf_a5: 
				if(u_fixu_ack_x) begin
					if(u_fixu_overflow) cst <= st_error;
					else cst <= st_lpf_load_a6;
				end
			st_lpf_load_a6: begin
				cst <= st_lpf_a6;
				u_fixu_fn <= 1'b0;
				u_fixu_req <= ~u_fixu_req;
				u_fixu_a <= lpf_a6;
				u_fixu_b <= lpf_y5;
				u_fixu_c <= u_fixu_z;
			end
			st_lpf_a6: 
				if(u_fixu_ack_x) begin
					if(u_fixu_overflow) cst <= st_error;
					else cst <= st_lpf_a1;
				end
			st_lpf_a1: begin
				cst <= st_lpf_y0;
				u_fixu_fn <= 1'b1;
				u_fixu_req <= ~u_fixu_req;
				u_fixu_a <= data;
				u_fixu_b <= u_fixu_z;
				u_fixu_c <= lpf_a1;
			end
			st_lpf_y0: 
				if(u_fixu_ack_x) begin
					if(u_fixu_overflow) cst <= st_error;
					else begin
						cst <= st_kal_idle;
						lpf_y0 <= u_fixu_z;
						data <= u_fixu_z;
					end
				end
			// kal
			st_kal_idle: begin
				if(disable_kal) cst <= st_done;
				else cst <= st_kal_update_k_1;
			end
			st_kal_update_k_1: begin
				cst <= st_kal_update_k_load;
				kal_k <= kal_eec_nst + kal_mnc;
			end
			st_kal_update_k_load: begin
				cst <= st_kal_update_k;
				u_fixu_fn <= 1'b1;
				u_fixu_req <= ~u_fixu_req;
				u_fixu_a <= kal_eec_nst;
				u_fixu_b <= 0;
				u_fixu_c <= kal_k;
			end
			st_kal_update_k: 
				if(u_fixu_ack_x) begin
					if(u_fixu_overflow) cst <= st_error;
					else begin
						cst <= st_kal_update_load_es;
						kal_k <= u_fixu_z;
					end
				end
			st_kal_update_load_es: begin
				cst <= st_kal_update_es;
				u_fixu_fn <= 1'b0;
				u_fixu_req <= ~u_fixu_req;
				u_fixu_a <= kal_k;
				u_fixu_b <= data + (~kal_es_nst + 1);
				u_fixu_c <= kal_es_nst;
			end
			st_kal_update_es: 
				if(u_fixu_ack_x) begin
					if(u_fixu_overflow) cst <= st_error;
					else begin
						cst <= st_kal_update_load_eec;
						kal_es <= u_fixu_z;
					end
				end
			st_kal_update_load_eec: begin
				cst <= st_kal_update_eec;
				u_fixu_fn <= 1'b0;
				u_fixu_req <= ~u_fixu_req;
				u_fixu_a <= ~kal_k + 1;
				u_fixu_b <= kal_eec_nst;
				u_fixu_c <= kal_eec_nst;
			end
			st_kal_update_eec: 
				if(u_fixu_ack_x) begin
					if(u_fixu_overflow) cst <= st_error;
					else begin
						cst <= st_load_vol;
						kal_eec <= u_fixu_z;
						data <= kal_es;
					end
				end
			st_load_vol: begin
				cst <= st_vol;
				u_fixu_fn <= 1'b0;
				u_fixu_req <= ~u_fixu_req;
				u_fixu_a <= data;
				u_fixu_b <= vol;
				u_fixu_c <= 0;
			end
			st_vol: begin
				if(u_fixu_ack_x) begin
					if(u_fixu_overflow) cst <= st_error;
					else begin
						cst <= st_done;
						data <= u_fixu_z;
					end
				end
			end
			// error
			st_error: begin
				cst <= st_done;
				overflow <= 1'b1;
			end
			// done
			st_done: begin
				cst <= st_idle;
				tx_data <= data;
				ack <= ~ack;
			end
			default: cst <= st_idle;
		endcase
	end
end

endmodule
