
module pingpong_buf(
    input logic clk,
    input logic rst,
    input logic switch,
    input logic filter,
    input logic bit_in,

    output logic bit_out, 
); 
    // 512 samples/bits 
    logic [511:0] buf_a;
    logic [511:0] buf_b;

    
endmodule : pingpong_buf
