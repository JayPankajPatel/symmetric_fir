module double_buf #(
    parameter MAX_COUNT = 512
)(
    input  logic clk,
    input  logic rst,
    input  logic bit_in,
    output logic [MAX_COUNT-1:0] buf_out 
); 
    // 512-bit buffers
    logic [0:MAX_COUNT-1] buf_in;
    logic [$clog2(MAX_COUNT)-1:0] buf_idx;

    counter #(.MAX_COUNT(MAX_COUNT)) COUNT_TO_511 (
        .clk(clk),
        .rst(rst),  
        .en('1),
        .out(buf_idx)
    );

    assign download = (buf_idx == MAX_COUNT-1);

    // Main buffer read/write logic
    always_ff @(posedge clk or posedge rst) begin 
        if (rst) begin
            buf_a      <= '0;
            buf_b      <= '0;
            bit_out    <= '0;
        end else begin 
            if(download) begin 
                buf_b <= buf_a; 
            end
            else begin 
                buf_a[buf_idx] <= bit_in; 
                bit_out <= buf_b[buf_idx]; 
            end
        end 
    end

endmodule : double_buf
