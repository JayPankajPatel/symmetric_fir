
`include "fircoefs2.v"

module filt (
    input logic Clock,
    input logic Reset,
    input logic FILTER,
    input logic BitIn,

    output logic [15:0] Dout,
    output logic Push
);

    typedef enum logic [2:0] {IDLE, LOAD, CALC, OUT} state_t;
    state_t state, next_state;

    logic [511:0] buf_in_d, buf_in;
    logic [511:0] buf_calc_d, buf_calc;
    logic signed [35:0] acc, acc_d; 
    logic signed [35:0] pair0, pair0_d; 
    logic signed [35:0] pair1, pair1_d; 
    logic signed [35:0] sumpairs, sumpairs_d; 
    logic push_d, push_comb; 
    logic [15:0] dout_d, dout_comb; 
    logic [$clog2(127)-1 : 0] counter, counter_d; 
    logic [$clog2(127) : 0] base_idx, base_idx_d; 

    assign buf_calc = FILTER ? buf_in_d : buf_calc_d; 

    assign h = coef(counter_d);
    //buffer logic start

    always_ff @(posedge Clock or posedge Reset) begin
        if(Reset) begin 
            buf_in_d <= '0;
            buf_calc_d <= '0;
        end
        else begin
            buf_in_d <= buf_in;
            buf_calc_d <= buf_calc;
        end
    end


    always_comb begin
        buf_in = buf_in_d; 
        buf_in = {BitIn, buf_in_d [511:1]};
    end
    //buffer logic end

    // control path start
    always_ff @(posedge Clock or posedge Reset) begin
        if(Reset) begin 
            state <= IDLE; 
        end 
        else begin 
            state <= next_state; 
        end 
    end

    always_comb begin
        next_state = state;
        case (state)
            IDLE: begin // this is when we first start and do not have enough data to calculate values
                if (FILTER) begin 
                    next_state = CALC;
                end
                else
                    next_state = IDLE;
            end
            LOAD: begin 
                if(FILTER)
                next_state = CALC;
            end
            CALC: begin
                if (counter_d == 127) 
                    next_state = OUT;
                else
                    next_state = CALC;
            end
            OUT: begin
                next_state = LOAD;
            end
        endcase
    end
    // control path end


    // data path start
    always_ff @(posedge Clock or posedge Reset) begin 
        if(Reset) begin 
            push_d <= 0; 
            dout_d <= 0; 
            acc_d <= 0; 
            counter_d <= 0;
            base_idx_d <= 0;
            pair0_d <= 0;
            pair1_d <= 0;
            sumpairs_d <= 0;
        end
        else begin
            push_d <= push_comb; 
            dout_d <= dout_comb; 
            acc_d <= acc; 
            counter_d <= counter;
            base_idx_d <= base_idx; 
            pair0_d <= pair0;
            pair1_d <= pair1;
            sumpairs_d <= sumpairs;
        end
    end


    always_comb begin
            push_comb = push_d; 
            dout_comb = dout_d; 
            acc = acc_d; 
            counter = counter_d; 
            base_idx = base_idx_d; 
            base_idx = counter_d << 1; 
            pair0 = pair0_d;
            pair1 = pair1_d;
            sumpairs = sumpairs_d;
            
        case(state)
            LOAD: begin
                acc = '0;
                counter = '0; 
                push_comb = '0;
                //dout_comb = '0;
            end
            CALC: begin 
                case({buf_calc_d[base_idx], buf_calc_d[511-base_idx]})
                    2'b00: pair0 = 0;  
                    2'b01, 2'b10: pair0 = coef(base_idx); 
                    2'b11: pair0 = (coef(base_idx) <<< 1); 
                endcase
                case({buf_calc_d[base_idx+1], buf_calc_d[511-(base_idx+1)]})
                    2'b00: pair1 = 0;  
                    2'b01, 2'b10: pair1 = coef(base_idx+1); 
                    2'b11: pair1 = (coef(base_idx+1) <<< 1); 
                endcase
                sumpairs = pair0 + pair1; 
                acc = acc_d + sumpairs;
                counter = counter_d + 1;
            end
            OUT: begin 
                dout_comb = (acc_d + 36'sd128) >>> 8;
                push_comb = 1;
            end
        endcase 
    end
    // data path end
    
    assign Push = push_d;
    assign Dout = dout_d;


endmodule : filt
