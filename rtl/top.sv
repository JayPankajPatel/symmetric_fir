
module top(
    input logic clk,
    input logic rst,
    input logic filter,
    input logic bit_out,

    output logic [15:0] dout,
    output logic push
); 

    logic counter_en;

    assign counter_en = push

    counter count_to_255(
        .clk(),
        .rst(),
        .en(), 
        .out()
    ); 


endmodule : top
