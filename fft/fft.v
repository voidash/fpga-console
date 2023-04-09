/**************** butter unit *************************
Xm(p) ------------------------> Xm+1(p)
           -        ->
             -    -
                -
              -   -
            -        ->
Xm(q) ------------------------> Xm+1(q)
      Wn          -1
*//////////////////////////////////////////////////////

module butterfly (
    input clk,
    input rst_n,
    input en,
    input signed [15:0] xp_re,  // Xm(p)
    input signed [15:0] xp_im,
    input signed [15:0] xq_re,  // Xm(q)
    input signed [15:0] xq_im,
    input signed [15:0] factor_re,  // Wnr
    input signed [15:0] factor_im,
    output vld,
    output signed [15:0] yp_re,  // Xm+1(p)
    output signed [15:0] yp_im,
    output signed [15:0] yq_re,  // Xm+1(q)
    output signed [15:0] yq_im
);
    reg [2:0] en_r;

    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            en_r <= 0;
        end
        else begin
            en_r <= {en_r[1:0],en};
        end
    end

    reg signed [31:0] xq_wnr_re0;
    reg signed [31:0] xq_wnr_re1;
    reg signed [31:0] xq_wnr_im0;
    reg signed [31:0] xq_wnr_im1;
    reg signed [31:0] xp_re_d;
    reg signed [31:0] xp_im_d;

    always @(posedge clk or negedge rst_n) begin
        if (rst_n == 1'b0) begin
            xp_re_d <= 0;
            xp_im_d <= 0;
            xq_wnr_re0 <= 0;
            xq_wnr_re1 <= 0;
            xq_wnr_im0 <= 0;
            xq_wnr_im1 <= 0;            
        end
        else if (en) begin
            xq_wnr_re0 <= xq_re * factor_re;
            xq_wnr_re1 <= xq_im * factor_im;
            xq_wnr_im0 <= xq_re * factor_im;
            xq_wnr_im1 <= xq_im * factor_re;
            xp_re_d <= {{4{xp_re[15]}}, xp_re[14:0], 13'b0};
            xp_im_d <= {{4{xp_im[15]}}, xp_im[14:0], 13'b0};
        end
    end

    reg signed [31:0] xq_wnr_re;
    reg signed [31:0] xq_wnr_im;
    reg signed [31:0] xp_re_d1;
    reg signed [31:0] xp_im_d1;

    always @(posedge clk or negedge rst_n) begin
        if (rst_n == 1'b0) begin
            xq_wnr_re <= 0;
            xq_wnr_im <= 0;
            xp_re_d1 <= 0;
            xp_im_d1 <= 0;
        end
        else if (en_r[0]) begin
            xp_re_d1 <= xp_re_d;
            xp_im_d1 <= xp_im_d;
            xq_wnr_re <= xq_wnr_re0 - xq_wnr_re1;
            xq_wnr_im <= xq_wnr_im0 + xq_wnr_im1;
        end
    end

    reg signed [31:0] yp_re_r;
    reg signed [31:0] yp_im_r;
    reg signed [31:0] yq_re_r;
    reg signed [31:0] yq_im_r;
    
    always @(posedge clk or negedge rst_n) begin
        if (rst_n == 1'b0) begin
            yp_re_r <= 0;
            yp_im_r <= 0;
            yq_re_r <= 0;
            yq_im_r <= 0;
        end
        else if (en_r[1]) begin
            yp_re_r <= xp_re_d1 + xq_wnr_re;
            yp_im_r <= xp_im_d1 + xq_wnr_im;
            yq_re_r <= xp_re_d1 - xq_wnr_re;
            yq_im_r <= xp_im_d1 - xq_wnr_im;
        end
    end

    assign yp_re = {yp_re_r[31],yp_re_r[13+15:13]};
    assign yp_im = {yp_im_r[31],yp_im_r[13+15:13]};
    assign yq_re = {yq_re_r[31],yq_re_r[13+15:13]};
    assign yq_im = {yq_im_r[31],yq_im_r[13+15:13]};
    assign vld = en_r[2];

endmodule
module counter (
    input clk,
    input rst_n,
    input [6:0] thresh,
    input start,
    input valid,
    output reg not_zero,
    output reg full 
);
    
    reg [6:0] cnt;
    reg cur_state, nxt_state;
    reg cnt_en;

    parameter START = 0;
    parameter STOP = 1;

    always @(posedge clk or negedge rst_n) begin
        if (rst_n == 1'b0) begin
            cur_state <= STOP;
            cnt_en <= 0;
        end
        else begin
            cur_state <= nxt_state;
        end
    end

    always @(cur_state or start or full) begin
        case (cur_state)
            STOP : if(start == 1'b1) begin
                nxt_state = START;
                cnt_en = 1'b1; 
            end
            else nxt_state = STOP;
            START : if(full == 1'b1) begin
                nxt_state = STOP;
                cnt_en = 1'b0;
            end
            else nxt_state = START;
            default : nxt_state = STOP;
        endcase
    end

    always @(posedge clk or negedge rst_n) begin
        if (rst_n == 1'b0) begin
            cnt <= 0;
            full <= 1'b0;
            not_zero <= 1'b0;
        end
        else if (cnt == thresh) begin
            cnt <= 0;
            full <= 1'b1;
            not_zero <= 1'b0;
        end
        else if (valid == 1'b1 && cnt_en == 1'b1) begin
            cnt <= cnt + 1;
            full <= 0;
            not_zero <= 1'b1;
        end
        else begin
            cnt <= cnt;
            full <= 1'b0;
            not_zero <= 1'b0;
        end
    end

endmodule
module fft_64 (
    input clk,
    input rst_n,
    input inv,
    input valid_in,
    input sop_in,
    input [15:0] x_re,
    input [15:0] x_im,
    output valid_out,
    output sop_out,
    output [15:0] y_re,
    output [15:0] y_im
);

    // operating data
    wire signed [15:0] xm_re [6:0] [63:0];
    wire signed [15:0] xm_im [6:0] [63:0];
    
    reg signed [15:0] xm_re_buf [63:0];
    reg signed [15:0] xm_im_buf [63:0];

    // enable control
    wire [6:0] en_ctrl;

    // input buffer
    integer k;

    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            for (k = 0; k <= 63; k=k+1 ) begin
                xm_re_buf[k] <= 0;
                xm_im_buf[k] <= 0;
            end
        end
        else begin
            for (k = 0; k <= 62; k=k+1 ) begin
                xm_re_buf[k+1] <= xm_re_buf[k];
                xm_im_buf[k+1] <= xm_im_buf[k];
            end
            xm_re_buf[0] <= x_re;
            xm_im_buf[0] <= x_im;
        end
    end

    // input ctrl
    parameter TIME_THRESH_IN = 62;

    counter counter_u1(
        .clk(clk),
        .rst_n(rst_n),
        .thresh(TIME_THRESH_IN),
        .start(sop_in),
        .valid(valid_in),
        .not_zero(),
        .full(en_ctrl[0]) 
    );

    // output buffer
    reg signed [15:0] ym_re_buf [63:0];
    reg signed [15:0] ym_im_buf [63:0];

    always @(posedge clk or negedge rst_n) begin
        if (rst_n == 1'b0) begin
            for (k = 0; k<=63 ; k=k+1 ) begin
                ym_re_buf[k] <= 0;
                ym_im_buf[k] <= 0;
            end
        end
        else if (en_ctrl[6]) begin
            for (k = 0; k<=63 ; k=k+1 ) begin
                ym_re_buf[k] <= xm_re[6][k];
                ym_im_buf[k] <= xm_im[6][k];
            end
        end
        else begin
            for (k = 0; k<=62; k=k+1 ) begin
                ym_re_buf[k] <= ym_re_buf[k+1];
                ym_im_buf[k] <= ym_im_buf[k+1];
            end
        end
    end
    
    // output ctrl
    parameter TIME_THRESH_OUT = 64;

    counter counter_u2(
        .clk(clk),
        .rst_n(rst_n),
        .thresh(TIME_THRESH_OUT),
        .start(sop_out),
        .valid(1'b1),
        .not_zero(valid_out),
        .full() 
    );   

    assign sop_out = en_ctrl[6];

    reg signed [15:0] y_re_out,y_im_out;

    always@(ym_re_buf[0] or ym_im_buf[0]) begin
        if (inv == 1'b0) begin
            y_re_out = ym_re_buf[0];
            y_im_out = ym_im_buf[0];
        end
        else if(inv == 1'b1) begin
            y_re_out = (ym_im_buf[0] >>> 6);
            y_im_out = (ym_re_buf[0] >>> 6);
        end
    end

    assign y_re = y_re_out;
    assign y_im = y_im_out;

    // Wnr, multiplied by 0x2000
    wire signed [15:0] factor_re[31:0];
    wire signed [15:0] factor_im[31:0];
    
    assign factor_re[0] = 16'h2000;
    assign factor_im[0] = 16'h0000;
    assign factor_re[1] = 16'h1FD8;
    assign factor_im[1] = 16'hFCDD;
    assign factor_re[2] = 16'h1F62;
    assign factor_im[2] = 16'hF9C1;
    assign factor_re[3] = 16'h1E9F;
    assign factor_im[3] = 16'hF6B5;
    assign factor_re[4] = 16'h1D90;
    assign factor_im[4] = 16'hF3C1;
    assign factor_re[5] = 16'h1C38;
    assign factor_im[5] = 16'hF0EA;
    assign factor_re[6] = 16'h1A9B;
    assign factor_im[6] = 16'hEE38;
    assign factor_re[7] = 16'h18BC;
    assign factor_im[7] = 16'hEBB3;
    assign factor_re[8] = 16'h16A0;
    assign factor_im[8] = 16'hE95F;
    assign factor_re[9] = 16'h144C;
    assign factor_im[9] = 16'hE743;
    assign factor_re[10] = 16'h11C7;
    assign factor_im[10] = 16'hE564;
    assign factor_re[11] = 16'h0F15;
    assign factor_im[11] = 16'hE3C7;
    assign factor_re[12] = 16'h0C3E;
    assign factor_im[12] = 16'hE26F;
    assign factor_re[13] = 16'h094A;
    assign factor_im[13] = 16'hE160;
    assign factor_re[14] = 16'h063E;
    assign factor_im[14] = 16'hE09D;
    assign factor_re[15] = 16'h0322;
    assign factor_im[15] = 16'hE027;
    assign factor_re[16] = 16'h0000;
    assign factor_im[16] = 16'hE000;
    assign factor_re[17] = 16'hFCDD;
    assign factor_im[17] = 16'hE027;
    assign factor_re[18] = 16'hF9C1;
    assign factor_im[18] = 16'hE09D;
    assign factor_re[19] = 16'hF6B5;
    assign factor_im[19] = 16'hE160;
    assign factor_re[20] = 16'hF3C1;
    assign factor_im[20] = 16'hE26F;
    assign factor_re[21] = 16'hF0EA;
    assign factor_im[21] = 16'hE3C7;
    assign factor_re[22] = 16'hEE38;
    assign factor_im[22] = 16'hE564;
    assign factor_re[23] = 16'hEBB3;
    assign factor_im[23] = 16'hE743;
    assign factor_re[24] = 16'hE95F;
    assign factor_im[24] = 16'hE95F;
    assign factor_re[25] = 16'hE743;
    assign factor_im[25] = 16'hEBB3;
    assign factor_re[26] = 16'hE564;
    assign factor_im[26] = 16'hEE38;
    assign factor_re[27] = 16'hE3C7;
    assign factor_im[27] = 16'hF0EA;
    assign factor_re[28] = 16'hE26F;
    assign factor_im[28] = 16'hF3C1;
    assign factor_re[29] = 16'hE160;
    assign factor_im[29] = 16'hF6B5;
    assign factor_re[30] = 16'hE09D;
    assign factor_im[30] = 16'hF9C1;
    assign factor_re[31] = 16'hE027;
    assign factor_im[31] = 16'hFCDD;

    // input intial, change order
    assign xm_re[0][0] =  xm_re_buf[0];
    assign xm_re[0][1] =  xm_re_buf[32];
    assign xm_re[0][2] =  xm_re_buf[16];
    assign xm_re[0][3] =  xm_re_buf[48];
    assign xm_re[0][4] =  xm_re_buf[8];
    assign xm_re[0][5] =  xm_re_buf[40];
    assign xm_re[0][6] =  xm_re_buf[24];
    assign xm_re[0][7] =  xm_re_buf[56];
    assign xm_re[0][8] =  xm_re_buf[4];
    assign xm_re[0][9] =  xm_re_buf[36];
    assign xm_re[0][10] = xm_re_buf[20];
    assign xm_re[0][11] = xm_re_buf[52];
    assign xm_re[0][12] = xm_re_buf[12];
    assign xm_re[0][13] = xm_re_buf[44];
    assign xm_re[0][14] = xm_re_buf[28];
    assign xm_re[0][15] = xm_re_buf[60];
    assign xm_re[0][16] = xm_re_buf[2];
    assign xm_re[0][17] = xm_re_buf[34];
    assign xm_re[0][18] = xm_re_buf[18];
    assign xm_re[0][19] = xm_re_buf[50];
    assign xm_re[0][20] = xm_re_buf[10];
    assign xm_re[0][21] = xm_re_buf[42];
    assign xm_re[0][22] = xm_re_buf[26];
    assign xm_re[0][23] = xm_re_buf[58];
    assign xm_re[0][24] = xm_re_buf[6];
    assign xm_re[0][25] = xm_re_buf[38];
    assign xm_re[0][26] = xm_re_buf[22];
    assign xm_re[0][27] = xm_re_buf[54];
    assign xm_re[0][28] = xm_re_buf[14];
    assign xm_re[0][29] = xm_re_buf[46];
    assign xm_re[0][30] = xm_re_buf[30];
    assign xm_re[0][31] = xm_re_buf[62];
    assign xm_re[0][32] = xm_re_buf[1];
    assign xm_re[0][33] = xm_re_buf[33];
    assign xm_re[0][34] = xm_re_buf[17];
    assign xm_re[0][35] = xm_re_buf[49];
    assign xm_re[0][36] = xm_re_buf[9];
    assign xm_re[0][37] = xm_re_buf[41];
    assign xm_re[0][38] = xm_re_buf[25];
    assign xm_re[0][39] = xm_re_buf[57];
    assign xm_re[0][40] = xm_re_buf[5];
    assign xm_re[0][41] = xm_re_buf[37];
    assign xm_re[0][42] = xm_re_buf[21];
    assign xm_re[0][43] = xm_re_buf[53];
    assign xm_re[0][44] = xm_re_buf[13];
    assign xm_re[0][45] = xm_re_buf[45];
    assign xm_re[0][46] = xm_re_buf[29];
    assign xm_re[0][47] = xm_re_buf[61];
    assign xm_re[0][48] = xm_re_buf[3];
    assign xm_re[0][49] = xm_re_buf[35];
    assign xm_re[0][50] = xm_re_buf[19];
    assign xm_re[0][51] = xm_re_buf[51];
    assign xm_re[0][52] = xm_re_buf[11];
    assign xm_re[0][53] = xm_re_buf[43];
    assign xm_re[0][54] = xm_re_buf[27];
    assign xm_re[0][55] = xm_re_buf[59];
    assign xm_re[0][56] = xm_re_buf[7];
    assign xm_re[0][57] = xm_re_buf[39];
    assign xm_re[0][58] = xm_re_buf[23];
    assign xm_re[0][59] = xm_re_buf[55];
    assign xm_re[0][60] = xm_re_buf[15];
    assign xm_re[0][61] = xm_re_buf[47];
    assign xm_re[0][62] = xm_re_buf[31];
    assign xm_re[0][63] = xm_re_buf[63];
    
    assign xm_im[0][0] =  xm_im_buf[0];
    assign xm_im[0][1] =  xm_im_buf[32];
    assign xm_im[0][2] =  xm_im_buf[16];
    assign xm_im[0][3] =  xm_im_buf[48];
    assign xm_im[0][4] =  xm_im_buf[8];
    assign xm_im[0][5] =  xm_im_buf[40];
    assign xm_im[0][6] =  xm_im_buf[24];
    assign xm_im[0][7] =  xm_im_buf[56];
    assign xm_im[0][8] =  xm_im_buf[4];
    assign xm_im[0][9] =  xm_im_buf[36];
    assign xm_im[0][10] = xm_im_buf[20];
    assign xm_im[0][11] = xm_im_buf[52];
    assign xm_im[0][12] = xm_im_buf[12];
    assign xm_im[0][13] = xm_im_buf[44];
    assign xm_im[0][14] = xm_im_buf[28];
    assign xm_im[0][15] = xm_im_buf[60];
    assign xm_im[0][16] = xm_im_buf[2];
    assign xm_im[0][17] = xm_im_buf[34];
    assign xm_im[0][18] = xm_im_buf[18];
    assign xm_im[0][19] = xm_im_buf[50];
    assign xm_im[0][20] = xm_im_buf[10];
    assign xm_im[0][21] = xm_im_buf[42];
    assign xm_im[0][22] = xm_im_buf[26];
    assign xm_im[0][23] = xm_im_buf[58];
    assign xm_im[0][24] = xm_im_buf[6];
    assign xm_im[0][25] = xm_im_buf[38];
    assign xm_im[0][26] = xm_im_buf[22];
    assign xm_im[0][27] = xm_im_buf[54];
    assign xm_im[0][28] = xm_im_buf[14];
    assign xm_im[0][29] = xm_im_buf[46];
    assign xm_im[0][30] = xm_im_buf[30];
    assign xm_im[0][31] = xm_im_buf[62];
    assign xm_im[0][32] = xm_im_buf[1];
    assign xm_im[0][33] = xm_im_buf[33];
    assign xm_im[0][34] = xm_im_buf[17];
    assign xm_im[0][35] = xm_im_buf[49];
    assign xm_im[0][36] = xm_im_buf[9];
    assign xm_im[0][37] = xm_im_buf[41];
    assign xm_im[0][38] = xm_im_buf[25];
    assign xm_im[0][39] = xm_im_buf[57];
    assign xm_im[0][40] = xm_im_buf[5];
    assign xm_im[0][41] = xm_im_buf[37];
    assign xm_im[0][42] = xm_im_buf[21];
    assign xm_im[0][43] = xm_im_buf[53];
    assign xm_im[0][44] = xm_im_buf[13];
    assign xm_im[0][45] = xm_im_buf[45];
    assign xm_im[0][46] = xm_im_buf[29];
    assign xm_im[0][47] = xm_im_buf[61];
    assign xm_im[0][48] = xm_im_buf[3];
    assign xm_im[0][49] = xm_im_buf[35];
    assign xm_im[0][50] = xm_im_buf[19];
    assign xm_im[0][51] = xm_im_buf[51];
    assign xm_im[0][52] = xm_im_buf[11];
    assign xm_im[0][53] = xm_im_buf[43];
    assign xm_im[0][54] = xm_im_buf[27];
    assign xm_im[0][55] = xm_im_buf[59];
    assign xm_im[0][56] = xm_im_buf[7];
    assign xm_im[0][57] = xm_im_buf[39];
    assign xm_im[0][58] = xm_im_buf[23];
    assign xm_im[0][59] = xm_im_buf[55];
    assign xm_im[0][60] = xm_im_buf[15];
    assign xm_im[0][61] = xm_im_buf[47];
    assign xm_im[0][62] = xm_im_buf[31];
    assign xm_im[0][63] = xm_im_buf[63];

    // butter instantiation
    genvar m,i,j;

    generate
        
        for (m = 0; m <= 5; m=m+1) begin:stage
            for (i = 0; i <= (1<<(5-m))-1 ; i=i+1) begin:group
                for (j = 0; j <= (1<<m)-1 ; j=j+1) begin:unit
                     butterfly butterfly_u(
                        .clk(clk),
                        .rst_n(rst_n),
                        .en(en_ctrl[m]),
                        .xp_re(xm_re[m][(i<<(m+1))+j]),
                        .xp_im(xm_im[m][(i<<(m+1))+j]),
                        .xq_re(xm_re[m][(i<<(m+1))+j+(1<<m)]),
                        .xq_im(xm_im[m][(i<<(m+1))+j+(1<<m)]),
                        .factor_re(factor_re[(1<<(5-m))*j]),
                        .factor_im(factor_im[(1<<(5-m))*j]),
                        .vld(en_ctrl[m+1]),
                        .yp_re(xm_re[m+1][(i<<(m+1))+j]),
                        .yp_im(xm_im[m+1][(i<<(m+1))+j]),
                        .yq_re(xm_re[m+1][(i<<(m+1))+j+(1<<m)]),
                        .yq_im(xm_im[m+1][(i<<(m+1))+j+(1<<m)])
                    );
                end
            end 
        end

    endgenerate

endmodule


module testbench ();
    reg clk;
    reg rst_n;
    reg inv;
    reg valid_in;
    reg sop_in;
    reg [15:0] x_re;
    reg [15:0] x_im;
    wire valid_out;
    wire sop_out;
    wire signed [15:0] y_re;
    wire signed [15:0] y_im;

    initial begin
        clk <= 1'b0;
        rst_n <= 1'b0;
        sop_in <= 1'b0;
        valid_in <= 1'b0;
        inv <= 1;
        x_re <= 0;
        x_im <= 0;
        #30
        rst_n <= 1'b1;
        sop_in <= 1'b1;
        valid_in <= 1'b1;
        x_re <= 64;
        x_im <= 64;
        #20
        sop_in <= 1'b0;
        x_re <= 63;
        x_im <= 63;
        #20
        x_re <= 62;
        x_im <= 62;
        #20
        x_re <= 61;
        x_im <= 61;
        #20
        x_re <= 60;
        x_im <= 60;
        #20
        x_re <= 59;
        x_im <= 59;
        #20
        x_re <= 58;
        x_im <= 58;
        #20
        x_re <= 57;
        x_im <= 57;
        #20
        x_re <= 56;
        x_im <= 56;
        #20
        x_re <= 55;
        x_im <= 55;
        #20
        x_re <= 54;
        x_im <= 54;
        #20
        x_re <= 53;
        x_im <= 53;
        #20
        x_re <= 52;
        x_im <= 52;
        #20
        x_re <= 51;
        x_im <= 51;
        #20
        x_re <= 50;
        x_im <= 50;
        #20
        x_re <= 49;
        x_im <= 49;
        #20
        x_re <= 48;
        x_im <= 48;
        #20
        x_re <= 47;
        x_im <= 47;
        #20
        x_re <= 46;
        x_im <= 46;
        #20
        x_re <= 45;
        x_im <= 45;
        #20
        x_re <= 44;
        x_im <= 44;
        #20
        x_re <= 43;
        x_im <= 43;
        #20
        x_re <= 42;
        x_im <= 42;
        #20
        x_re <= 41;
        x_im <= 41;
        #20
        x_re <= 40;
        x_im <= 40;
        #20
        x_re <= 39;
        x_im <= 39;
        #20
        x_re <= 38;
        x_im <= 38;
        #20
        x_re <= 37;
        x_im <= 37;
        #20
        x_re <= 36;
        x_im <= 36;
        #20
        x_re <= 35;
        x_im <= 35;
        #20
        x_re <= 34;
        x_im <= 34;
        #20
        x_re <= 33;
        x_im <= 33;
        #20
        x_re <= 32;
        x_im <= 32;
        #20
        x_re <= 31;
        x_im <= 31;
        #20
        x_re <= 30;
        x_im <= 30;
        #20
        x_re <= 29;
        x_im <= 29;
        #20
        x_re <= 28;
        x_im <= 28;
        #20
        x_re <= 27;
        x_im <= 27;
        #20
        x_re <= 26;
        x_im <= 26;
        #20
        x_re <= 25;
        x_im <= 25;
        #20
        x_re <= 24;
        x_im <= 24;
        #20
        x_re <= 23;
        x_im <= 23;
        #20
        x_re <= 22;
        x_im <= 22;
        #20
        x_re <= 21;
        x_im <= 21;
        #20
        x_re <= 20;
        x_im <= 20;
        #20
        x_re <= 19;
        x_im <= 19;
        #20
        x_re <= 18;
        x_im <= 18;
        #20
        x_re <= 17;
        x_im <= 17;
        #20
        x_re <= 16;
        x_im <= 16;
        #20
        x_re <= 15;
        x_im <= 15;
        #20
        x_re <= 14;
        x_im <= 14;
        #20
        x_re <= 13;
        x_im <= 13;
        #20
        x_re <= 12;
        x_im <= 12;
        #20
        x_re <= 11;
        x_im <= 11;
        #20
        x_re <= 10;
        x_im <= 10;
        #20
        x_re <= 9;
        x_im <= 9;
        #20
        x_re <= 8;
        x_im <= 8;
        #20
        x_re <= 7;
        x_im <= 7;
        #20
        x_re <= 6;
        x_im <= 6;
        #20
        x_re <= 5;
        x_im <= 5;
        #20
        x_re <= 4;
        x_im <= 4;
        #20
        x_re <= 3;
        x_im <= 3;
        #20
        x_re <= 2;
        x_im <= 2;
        #20
        x_re <= 1;
        x_im <= 1;
        #20
        valid_in <= 1'b0;
    end

    always #10 clk <= ~clk;

    integer w_file;

    initial w_file = $fopen("fft_output.txt");

    always@(posedge clk) begin
        if(valid_out == 1'b1) begin
            $fwrite(w_file,"%d,%d\n",y_re,y_im);
        end
    end

    fft_64 fft_64_u1(
        .clk(clk),
        .rst_n(rst_n),
        .inv(inv),
        .valid_in(valid_in),
        .sop_in(sop_in),
        .x_re(x_re),
        .x_im(x_im),
        .valid_out(valid_out),
        .sop_out(sop_out),
        .y_re(y_re),
        .y_im(y_im)
    );
endmodule