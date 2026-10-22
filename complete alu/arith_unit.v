module arith_unit (
    input  wire [31:0] A,
    input  wire [31:0] B,
    input  wire AFN,
    output wire [31:0] S,
    output wire z,
    output wire n,
    output wire v
);

    assign S = AFN ? (A - B) : (A + B);
    assign z = (S == 32'b0);
    assign n = S[31];
    assign v = (~A[31] & (~B[31]^AFN) & S[31]) | (A[31] & (B[31]^AFN) & ~S[31]);

    

endmodule 
 
    