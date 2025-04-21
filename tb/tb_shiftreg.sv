
module tb_shiftreg();
    
    logic clk, rst, en, sin; 
    logic [3:0] sout; 
    
 shiftreg dut (
    .clk(clk),
    .rst(rst),
    .en(en), 
    .sin(sin), 
    .sout(sout)
);
    initial begin 
        clk = 0;
        rst = 0; 
        en = 0; 
        forever #10 clk = ~clk; 
    end

    initial begin 
        $dumpvars(0); 
        $dumpfile("tb_shiftreg.vcd");
    end

   initial begin 
       rst = 1; 
       #10; 
       rst = 0; 
       en = 1; 
       repeat(50) begin 
           sin = $urandom_range(0, 2**3-1); 
           #10; 
       end
       $finish; 
   end

endmodule : tb_shiftreg
