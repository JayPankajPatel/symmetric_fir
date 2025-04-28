
module pingpong_buf #(
    parameter MAX_COUNT = 512
)(
    input  logic clk,
    input  logic rst,
    input  logic switch,
    input  logic bit_in,

    output logic bit_out
); 
    // 512-bit buffers
    logic [0:MAX_COUNT-1] buf_a;
    logic [0:MAX_COUNT-1] buf_b;

    // which buffer is used in the convolution 
    logic active_buf;

    logic [$clog2(MAX_COUNT)-1:0] buf_idx;

  

    counter #(.MAX_COUNT(MAX_COUNT)) COUNT_TO_512 (
        .clk(clk),
        .rst(rst),  
        .en('1 & ~rst),
        .out(buf_idx)
    );

  logic switch_rise;
   posedge_detector POS_SWITCH(
       .clk(clk),
       .rst(rst),
       .signal(switch),
       .is_posedge_signal(switch_rise) 
  ); 

    always_ff @(posedge clk or posedge rst) begin 
        if (rst) begin
            buf_a      <= '0;
            buf_b      <= '0;
            bit_out    <= '0;
            active_buf <= '0; 
        end else begin 
            if (switch_rise) begin
                active_buf <= ~active_buf;
            end else begin
                if (!active_buf) begin 
                    buf_a[buf_idx] <= bit_in; 
                    bit_out        <= buf_b[buf_idx];
                end else begin 
                    buf_b[buf_idx] <= bit_in; 
                    bit_out        <= buf_a[buf_idx];
                end
            end 
        end 
    end

endmodule : pingpong_buf
