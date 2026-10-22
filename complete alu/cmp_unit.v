module cmp_unit(
    input  wire [31:0] A,
    input  wire [31:0] B,
    input  wire [2:0]  CFN,
    output wire [31:0] Y
);

    wire [31:0] S;
    wire        z, n, v;

    arith_unit a1(
        .A(A),
        .B(B),
        .AFN(CFN[0]),
        .S(S),
        .z(z),
        .n(n),
        .v(v)
    );

    assign Y = (CFN[2:0] == 3'b011) ? {31'b0, z} : // EQ
               (CFN[2:0] == 3'b101) ? {31'b0, n^v} : // LT
               (CFN[2:0] == 3'b111) ? {31'b0, z |  (n^v)} : // OVF
                                32'b0;      // default


endmodule
