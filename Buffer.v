module FIFO_Buffer(
    input               i_Clk,
    // EN decides whether the program runs when i_Clk gets to positive edge. 
    // The program only runs if EN is 1
    input               i_EN,           
    input               i_Reset,
    input [127:0]       i_Data_Input,
    // i_Data_Coming is a variable that decides whether the buffer can receive new inputs. 
    // The buffer can only receive new inputs if it is 1
    input               i_Data_Coming,
    // i_Data_Leaving is a variable that decides wheather the buffer can release inputs and 
    // make them outputs. Only happens at 1
    input               i_Data_Leaving,

    output              o_Buffer_Full,
    output              o_Buffer_Empty,
    output reg [127:0]  r_Data_Output
);

    reg [2:0]           r_Count         = 3'b000;   // Amount of numbers currently in the buffer
    reg [127:0]         r_Buffer_Array [0:7];       // Buffer
    reg [2:0]           r_Amount_InBuffer = 3'b000; // Amount of numbers that entered the buffer
    reg [2:0]           r_Amount_OutBuffer = 3'b000;// Amount of numbers that was processed out and ready for use


    assign o_Buffer_Empty = (r_Count == 0) ? 1'b1 : 1'b0;     // Checking to see if the buffer is empty
    assign o_Buffer_Full  = (r_Count == 8) ? 1'b1 : 1'b0;     // Checking to see if buffer is full


    always @(posedge i_Clk) begin
        if (~i_EN);       // If the EN input is off, then do nothing
        else begin
            if (i_Reset) begin // If reset input is on
                r_Amount_InBuffer <= 0;     // set this variable to 0
                r_Amount_OutBuffer <= 0;
            end 

            // Buffer is ready to receive inputs and the buffer has less than 8 numbers
            else if (i_Data_Coming == 1'b1 && r_Count < 8) begin
                r_Buffer_Array[r_Amount_InBuffer] <= i_Data_Input;  // Take the input and put it in the buffer
                r_Amount_InBuffer <= r_Amount_InBuffer + 1; // Increment the amount of numbers that have entered the buffer
            end

            // if buffer is ready to release numbers and it has at least one number
            else if (i_Data_Leaving == 1'b1 && r_Count != 0) begin
                r_Data_Output <= r_Buffer_Array[r_Amount_InBuffer]; // Turn that number into an output
                r_Amount_OutBuffer <= r_Amount_OutBuffer + 1; // increment #'s released from the buffer
            end
            else;

            if (r_Amount_InBuffer == 8) // Once the buffer has recieved 8 numbers
                r_Amount_InBuffer <= 0; // Reset
            
            else if (r_Amount_OutBuffer == 8) // Once the buffer has released 8 numbers
                r_Amount_OutBuffer <= 0; // Reset
            else;

            if (r_Amount_OutBuffer > r_Amount_InBuffer)
                r_Count <= r_Amount_OutBuffer - r_Amount_InBuffer; // Make sure count is right

            else if (r_Amount_InBuffer > r_Amount_OutBuffer) 
                r_Count <= r_Amount_InBuffer - r_Amount_OutBuffer; // Make sure count is right
            else;
        end
    end 

endmodule