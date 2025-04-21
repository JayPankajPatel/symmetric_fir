
module posedge_detector(
    input logic clk,
    input logic rst,
    input logic filter,

    output logic posedge_filter, 
); 
    logic in, in_d; 

    assign in = filter;

    always_ff @(posedge clk or posedge rst) begin
        if(rst) begin 
            in_d <= 0';
        end
        else  begin 
            in_d <= in;
        end
    end

    assign posedge_filter = ~in_d && in; 
endmodule :  posedge_detector
