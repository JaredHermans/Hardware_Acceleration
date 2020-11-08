// Module takes in 2 16-bit numbers and multiplies them and adds the 
// results to the previous results 
module Test1 (
    input               i_Clk,
    input       [15:0]  i_x,            
    input       [15:0]  i_y,
    output      [31:0]  o_sum
);

    reg         [31:0]  r_state = 0;
    reg         [31:0]  r_sum = 0;

    always @(posedge i_Clk) begin
            
        r_state <= i_x * i_y;
        r_sum <= r_sum + r_state;
    end

    assign o_sum = r_sum;

endmodule