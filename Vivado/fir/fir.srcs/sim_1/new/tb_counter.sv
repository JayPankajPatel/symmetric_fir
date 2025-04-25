`timescale 1ns / 1ps

module tb_counter;

  // Testbench signals
  logic clk;
  logic rst;
  logic en;
  logic out;

  // Instantiate DUT
  counter #(.MAX_COUNT(8)) dut (  // use 8 for short test
    .clk(clk),
    .rst(rst),
    .en(en),
    .out(out)
  );

  // Clock generation
  always #5 clk = ~clk;  // 100 MHz clock

  initial begin
    $display("Starting counter test...");
    clk = 0;
    rst = 1;
    en = 0;

    // Apply reset
    #10;
    rst = 0;

    // Enable counter
    en = 1;

    // Count and observe output
    repeat (10) begin
      @(posedge clk);
      $display("Time %0t: out = %b", $time, out);
    end

    // Apply reset mid-count
    rst = 1;
    @(posedge clk);
    rst = 0;

    // Resume count
    repeat (10) begin
      @(posedge clk);
      $display("Time %0t: out = %b", $time, out);
    end

    $display("Test finished.");
    $finish;
  end

endmodule
