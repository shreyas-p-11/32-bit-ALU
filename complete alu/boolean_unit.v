module boolean_unit (
    input  wire [31:0] A,
    input  wire [31:0] B,
    input  wire [3:0]  BOOLFN,
    output wire [31:0] OUT
);
 
    assign OUT = ( ~A & ~B & {32{BOOLFN[0]}} ) |
             (  A & ~B & {32{BOOLFN[1]}} ) |
             ( ~A &  B & {32{BOOLFN[2]}} ) |
             (  A &  B & {32{BOOLFN[3]}} );
 
endmodule