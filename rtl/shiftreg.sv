module shiftreg (
    input logic clk,
    input logic rst,
    input logic en, 
    input logic sin, 
    output logic [3:0] sout
);

    always_ff @(posedge clk or posedge rst) begin
        if(rst) begin
            sout <= '0;
        end
        else begin 
            if(en) begin
                sout[0] <= sin;
                sout[1] <= sout[0];
                sout[2] <= sout[1];
                sout[3] <= sout[2];
            end
        end
    end

endmodule : shiftreg
