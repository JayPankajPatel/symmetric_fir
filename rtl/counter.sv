
// MAX_COUNT uses an exclusive on the upper bound meaning it will count up to MAX_COUNT-1
// or simply [0-MAX_COUNT-1]
module counter #(parameter MAX_COUNT = 256)(
    input logic clk,
    input logic rst,
    input logic en, 
    output logic [$clog2(MAX_COUNT)-1:0] out
); 

    // count to MAX_COUNT
    logic [$clog2(MAX_COUNT)-1:0] counter;
    always_ff @(posedge clk or posedge rst) begin 
        if(rst) begin 
            counter <= '0;
        end
        else begin 
            if(en && ~rst) begin
                counter <= counter + 1; 
            end
        end
    end

    assign out = counter; 



endmodule : counter
