`timescale 1ns / 1ps

module tb_pingpong_buf;

  logic clk, rst, switch, bit_in;
  logic bit_out;

  pingpong_buf #(.MAX_COUNT(8)) dut (  // use 8 for quick simulation
    .clk(clk),
    .rst(rst),
    .switch(switch),
    .bit_in(bit_in),
    .bit_out(bit_out)
  );

  always #5 clk = ~clk;  // 100 MHz clock

  initial begin
    clk = 0;
    rst = 1;
    switch = 0;
    bit_in = 0;

    #10;
    rst = 0;

    // Write 8 ones into buffer A
    repeat (8) begin
      bit_in = 1;
      @(posedge clk);
    end

    // Trigger switch to B on next cycle
    switch = 1;
    @(posedge clk);
    switch = 0;

    // Write 8 zeros into buffer B, expect to read 8 ones from buffer A
    bit_in = 0;
    repeat (8) begin
      @(posedge clk);
      $display("bit_out = %b", bit_out);
    end

    $display("Test finished.");
    $finish;
  end

endmodule
