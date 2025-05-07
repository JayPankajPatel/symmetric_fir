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

    typedef enum logic [2:0] {IDLE, LOAD, CALC, OUT} state_t;
    state_t state, next_state;

    
    logic [8:0] buf_idx; // 9 bits needed for 0–511
    logic [8:0] calc_buf_idx; // 9 bits needed for 0–511
    logic signed [28:0] h;   // filter coeffs
    

    //logic en_calc_buf_idx; 
    //logic calc_end_of_buffer; 

    //assign rst_calc_buf_idx = (state == LOAD); 
    //assign en_calc_buf_idx = (state == CALC); 
    //assign calc_end_of_buffer = (calc_buf_idx == 9'd511); 

    logic [511:0] buf_in_d, buf_in;
    logic [511:0] buf_calc_d, buf_calc;
    logic signed [35:0] acc, acc_d; 
    logic push_d; 
    logic [15:0] dout_d; 
    logic [$clog2(512)-1 : 0] counter, counter_d; 

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
        buf_in = {BitIn, buf_in_d [511:1]};
    end
    //buffer logic end

    always_ff @(posedge Clock or posedge Reset) begin
        if(Reset) begin 
            state <= IDLE; 
        end 
        else begin 
            state <= next_state; 
        end 
    end
    // control path
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
                
            end
            CALC: begin
                if (counter_d == 255) // only need to go to the middle of buffer
                    next_state = OUT;
                else
                    next_state = CALC;
            end
            OUT: begin
                next_state = LOAD;
            end
        endcase
    end

    // data path for calculation and output
    always_ff @(posedge Clock or posedge Reset) begin 
        if(Reset) begin 
            push_d <= 0; 
            dout_d <= 0; 
            acc_d <= 0; 
            counter_d <= 0;
        end
        else begin
            push_d <= Push; 
            dout_d <= Dout; 
            acc_d <= acc; 
            counter_d <= counter;
        end
    end


    always_comb begin
            Push = push_d; 
            Dout = dout_d; 
            acc = acc_d; 
            counter = counter_d; 

        case(state)
            CALC: begin 
                case({buf_calc_d[counter_d], buf_calc_d[511-counter_d]})
                    2'b00: acc = acc_d;  
                    2'b01, 2'b10: acc = acc_d + h; 
                    2'b11: acc = acc_d + (h <<< 1); 
                endcase
                counter = counter_d + 1;
            end
            OUT: begin 
                Dout = (acc_d + 36'sd128) >>> 8;
                Push = 1;
            end
        endcase 
        
    end

///    always_ff @(posedge Clock or posedge Reset) begin 
///        if(Reset) begin 
///            state <= IDLE; 
///            Push <= 0; 
///            Dout <= 0; 
///            acc <= 0; 
///        end
///        else begin 
///            state <= next_state; 
///            case (state)  
///                CALC: begin 
///                    case({buf_calc[calc_buf_idx], buf_calc[511-calc_buf_idx]})
///                        2'b00: acc <= acc; 
///                        2'b01, 2'b10: acc <= acc + h; 
///                        2'b11: acc <= acc + (h <<< 1); // mulitplying by 2
///                    endcase
///                end
///                OUT: begin 
///                    Dout <= (acc + 36'sd128) >>> 8;  // rounding step
///                    Push <= '1;
///                    acc <= 0; 
///                end
///            endcase
///        end
///    end
endmodule : filt
