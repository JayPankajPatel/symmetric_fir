
module counter (
    input logic clk,
    input logic rst,
    input logic en, 
    output logic out
); 

    // count to 255 
    logic [$clog(256)-1:0] counter;
    always_ff @(posedge clk or posedge rst) begin 
        if(rst) begin 
            counter <= '0;
        end
        else begin 
            if(en) begin
                counter <= counter + 1; 
            end
        end
    end

    assign out = (counter == '255) ? 1 : 0;



endmodule : counter
