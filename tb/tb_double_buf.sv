module tb_double_buf(); 

    logic clk, rst,
    bit_in, bit_out; 
        
    double_buf dut (
        .clk(clk),
        .rst(rst),
        .bit_in(bit_in),
        .bit_out(bit_out)
    ); 
    
    int clk_count; 
    initial begin 
        clk = 0; 
        rst = 0; 
        forever 
            #5 clk = ~clk; 
    end
    
    initial begin 
        if(clk)
            clk_count += 1; 
    end

    initial begin 
        $dumpvars(0); 
        $dumpfile("double_buf.vcd"); 
    end
    initial begin 
        #5 rst = 1 ; 
        #5 rst = 0 ; 
        repeat(1000) begin 
            #5 bit_in = $urandom_range(0,1); 
        end
        $finish; 
    end
endmodule : tb_double_buf
