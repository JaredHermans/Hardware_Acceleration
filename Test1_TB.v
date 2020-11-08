`timescale 1ns/1ps

module Test1_TB ();
    reg         r_Clk = 0;
    reg  [15:0] r_x = 0;
    reg  [15:0] r_y = 0;
    wire [31:0] r_sum;

    always #5 r_Clk <= ~r_Clk; // Wait 5 time slices then invert clock

    Test1 Test1_Inst (
        .i_Clk       (r_Clk),
        .i_x         (r_x),
        .i_y         (r_y),
        .o_sum       (r_sum)
    );

    initial begin
        #5;     // Delay 1/2 clock
        r_x = 16'b1011_0001_1100_0101; // x1[n] = 45509 = B1C5
        r_y = 16'b1100_1110_0101_1111; // y1[n] = 52831 = CE5F
        #10;    // Delay 1 clock
        r_x = 16'b0101_0100_1000_1001; // x2[n] = 21641 = 5489
        r_y = 16'b1010_0111_0110_1100; // y2[n] = 42860 = A76C
        #10;
        r_x = 16'b0001_1101_1000_0110; // x3[n] = 7558 = 1D86
        r_y = 16'b0001_1101_1110_1010; // y3[n] = 7658 = 1DEA
        #20;
        // r_sum = 45509*52831 + 21641*42860 + 7558*7658 = CA_0A_B1_63
        if (r_sum == 32'hCA_0A_B1_63)
            $display("Test Passed");
        else  
            $display("Test Failed");
        $finish();
    end
endmodule