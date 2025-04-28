
module filt (
    input logic clk,
    input logic rst,
    input logic filter,
    input logic bit_out,

    output logic [15:0] dout,
    output logic push
);


  typedef [2:0] enum {IDLE, LOAD, CALC, OUT} state_t; 
    state_t state, next_state; 

    always_ff @(posedge clk or posedge rst) begin 
        if(rst) begin 
            state <= IDLE; 
        end
        else begin 
            state <= next_state;
        end
    end


    
    // control path
    always_comb begin 
        next_state = state; 
        case(state) begin 
            IDLE: begin 
                if(filter) begin 
                    next_state = LOAD; 
                end
            end
            LOAD: begin 
                if() begin 
                end 
            end
            CALC: begin 
            end
            OUT: begin 
            end
        end
    end


endmodule : top
