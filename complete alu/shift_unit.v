module shift_unit (
    input  wire [31:0] A,
    input  wire [4:0]  B,
    input  wire [1:0]  SFN,
    output reg  [31:0] Y
);

    wire signed [31:0] A_s   = A;
    wire signed [31:0] sra_r = A_s >>> B;   // evaluated in a purely signed context

    always @(*) begin
        case (SFN)
            2'b00:   Y = A << B;
            2'b01:   Y = A >> B;
            2'b11:   Y = sra_r;
            default: Y = 32'b0;
        endcase
    end

endmodule