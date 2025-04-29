`include "counter.sv"
`include "fircoefs2.v"

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
    logic [8:0] calc_buf_idx; // 9 bits needed for 0–511
    logic signed [28:0] h;   // filter coeffs
    

    counter #(.MAX_COUNT(512)) in_buf_counter ( // MAX_COUNT's end value is exclusive
        .clk(Clock),
        .rst(Reset),
        .en('1),
        .out(buf_idx)
    );

    logic rst_calc_buf_idx; 
    logic en_calc_buf_idx; 
    logic calc_end_of_buffer; 

    assign rst_calc_buf_idx = (state == LOAD); 
    assign en_calc_buf_idx = (state == CALC); 
    assign calc_end_of_buffer = (calc_buf_idx == 9'd511); 

    assign h = coef(calc_buf_idx);

    counter #(.MAX_COUNT(512)) calc_buf_counter ( // MAX_COUNT's end value is exclusive
        .clk(Clock),
        .rst(rst_calc_buf_idx | Reset),
        .en(en_calc_buf_idx),
        .out(calc_buf_idx)
    );

    logic [511:0] buf_in;
    logic [511:0] buf_calc;

    // double buffer block
    always_ff @(posedge Clock or posedge Reset) begin
        if (Reset) begin
            buf_in <= 0;
            buf_calc <= 0;
        end
        else begin
            if (~FILTER) begin // LOAD
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
            IDLE: begin // this is when we first start and do not have enough data to calculate values
                if (FILTER)
                    next_state = LOAD;
                else
                    next_state = IDLE;
            end
            LOAD: begin
                next_state = CALC;
            end
            CALC: begin
                if (calc_end_of_buffer >> 4) // only need to go to the middle of buffer
                    next_state = OUT;
                else
                    next_state = CALC;
            end
            OUT: begin
                next_state = LOAD;
            end
        endcase
    end
    logic [35:0] acc; 
    // data path
    always_ff @(posedge Clock or posedge Reset) begin 
        if(Reset) begin 
            state <= IDLE; 
            Push <= 0; 
            Dout <= 0; 
            acc <= 0; 
        end
        else begin 
            state <= next_state; 
            case (state)  
                CALC: begin 
                    case({buf_calc[calc_buf_idx], buf_calc[511-calc_buf_idx]})
                        2'b00: acc <= acc; 
                        2'b01, 2'b10: acc <= acc + h; 
                        2'b11: acc <= acc + (h <<< 1);
                    endcase
                end
                OUT: begin 
                    Dout <= (acc + 36'sd128) >>> 8; 
                    Push <= '1;
                    acc <= 0; 
                end
            endcase
        end
    end
endmodule : filt
