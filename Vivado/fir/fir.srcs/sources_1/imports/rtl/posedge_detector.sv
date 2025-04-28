
module posedge_detector(
    input logic clk,
    input logic rst,
    input logic signal,

    output logic is_posedge_signal
); 
    logic in, in_d; 

    assign in = signal;

    always_ff @(posedge clk or posedge rst) begin
        if(rst) begin 
            in_d <= '0;
        end
        else  begin 
            in_d <= in;
        end
    end

    assign is_posedge_signal = ~in_d && in; 
endmodule :  posedge_detector
