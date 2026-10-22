module alu(
    input  wire [31:0] A,
    input  wire [31:0] B,
    input  wire [5:0]  ALUFN,
    output wire [31:0] Y
);

    wire [31:0] arith_result;
    wire [31:0] boolean_result;
    wire [31:0] shift_result;
    wire [31:0] cmp_result;

    wire z, n, v;

    arith_unit a1(
        .A(A),
        .B(B),
        .AFN(ALUFN[0]),
        .S(arith_result), .z(z),
        .n(n), .v(v)
    );

    boolean_unit b1(
        .A(A),
        .B(B),
        .BOOLFN(ALUFN[3:0]),
        .OUT(boolean_result)
    );

    shift_unit shift (
        .A(A),
        .B(B[4:0]),
        .SFN(ALUFN[1:0]),
        .Y(shift_result)
    );

    cmp_unit cmp (
        .A(A),
        .B(B),
        .CFN(ALUFN[2:0]),
        .Y(cmp_result)
    );

    assign Y = (ALUFN[5:4] == 2'b00) ? cmp_result :
               (ALUFN[5:4] == 2'b01) ? arith_result :
               (ALUFN[5:4] == 2'b10) ? boolean_result :
               (ALUFN[5:4] == 2'b11) ? shift_result :
               32'b0; // Default case

               endmodule
               