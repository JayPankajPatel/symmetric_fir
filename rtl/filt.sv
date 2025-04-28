`include "counter.sv"

module filt (
    input logic Clock,
    input logic Reset,
    input logic FILTER,
    input logic BitIn,

    output logic [15:0] Dout,
    output logic Push
);

    typedef enum logic [2:0] {IDLE, LOAD, CALC, ROUND, OUT} state_t;
    state_t state, next_state;

    logic end_of_buffer;
    
    logic [8:0] buf_idx; // 9 bits needed for 0–511

    counter #(.MAX_COUNT(512)) buf_counter ( // MAX_COUNT's end value is exclusive
        .clk(Clock),
        .rst(Reset),
        .en('1),
        .out(buf_idx)
    );

    logic [511:0] buf_in;
    logic [511:0] buf_calc;

    // buffer block
    always_ff @(posedge Clock or posedge Reset) begin
        if (Reset) begin
            buf_in <= 0;
            buf_calc <= 0;
        end
        else begin
            if (~FILTER) begin
                buf_in[buf_idx] <= BitIn;
            end
            else begin
                buf_calc <= buf_in;
            end
        end
    end

    // control path
    always_comb begin
        next_state = state;
        case (state)
            IDLE: begin
                if (FILTER)
                    next_state = LOAD;
                else
                    next_state = IDLE;
            end
            LOAD: begin
                next_state = CALC;
            end
            CALC: begin
                next_state = ROUND;
            end
            ROUND: begin
                if (end_of_buffer)
                    next_state = OUT;
                else
                    next_state = CALC;
            end
            OUT: begin
                next_state = IDLE;
            end
        endcase
    end
    // data path
    always_ff @(posedge Clock or posedge Reset) begin 
        if(Reset) begin 
            state <= IDLE; 
            Push <= 0; 
            Dout <= 0; 
        end
        else begin 
            state <= next_state; 

        end
    end
endmodule : filt
