// alu_tb.v
// Stimulus-only testbench for alu.v -- exercises every real ALUFN opcode
// the Beta ISA defines (MUL/DIV excluded -- optional, not implemented).
//
// Usage:
//   iverilog -o alu_tb arith_unit.v boolean_unit.v shift_unit.v cmp_unit.v alu.v alu_tb.v
//   vvp alu_tb
//   gtkwave alu_tb.vcd

`timescale 1ns/1ps

module alu_tb;

    reg  [31:0] A, B;
    reg  [5:0]  ALUFN;
    wire [31:0] Y;

    alu DUT (
        .A(A),
        .B(B),
        .ALUFN(ALUFN),
        .Y(Y)
    );

    initial begin
        $dumpfile("alu_tb.vcd");
        $dumpvars(0, alu_tb);

        // ================= ARITHMETIC =================

        // ADD: 5 + 3 = 8
        A = 32'd5; B = 32'd3; ALUFN = 6'b010000; #1;
        $display("ADD    A=%0d B=%0d ALUFN=%b -> Y=%0d (0x%h)", A, B, ALUFN, $signed(Y), Y);

        // SUB, asymmetric: 3 - 10 = -7 (catches A/B swap)
        A = 32'd3; B = 32'd10; ALUFN = 6'b010001; #1;
        $display("SUB    A=%0d B=%0d ALUFN=%b -> Y=%0d (0x%h)", A, B, ALUFN, $signed(Y), Y);

        // ADD overflow: 0x7FFFFFFF + 1
        A = 32'h7FFFFFFF; B = 32'h00000001; ALUFN = 6'b010000; #1;
        $display("ADD(ovf) A=0x%h B=0x%h ALUFN=%b -> Y=0x%h", A, B, ALUFN, Y);

        // ================= BOOLEAN =================

        // AND
        A = 32'hA5A5A5A5; B = 32'h5A5A5A5A; ALUFN = 6'b101000; #1;
        $display("AND    A=0x%h B=0x%h ALUFN=%b -> Y=0x%h", A, B, ALUFN, Y);

        // OR
        A = 32'hA5A5A5A5; B = 32'h5A5A5A5A; ALUFN = 6'b101110; #1;
        $display("OR     A=0x%h B=0x%h ALUFN=%b -> Y=0x%h", A, B, ALUFN, Y);

        // XOR
        A = 32'h12345678; B = 32'hCAFEBABE; ALUFN = 6'b100110; #1;
        $display("XOR    A=0x%h B=0x%h ALUFN=%b -> Y=0x%h", A, B, ALUFN, Y);

        // XNOR
        A = 32'h12345678; B = 32'hCAFEBABE; ALUFN = 6'b101001; #1;
        $display("XNOR   A=0x%h B=0x%h ALUFN=%b -> Y=0x%h", A, B, ALUFN, Y);

        // "A" passthrough, asymmetric A != B (catches A/B index-order bugs;
        // used internally by the datapath's ASEL mux for LDR)
        A = 32'h12345678; B = 32'hCAFEBABE; ALUFN = 6'b101010; #1;
        $display("A(pass) A=0x%h B=0x%h ALUFN=%b -> Y=0x%h  (expect Y==A)", A, B, ALUFN, Y);

        // ================= SHIFT =================

        // SHL: 1 << 8 = 256
        A = 32'd1; B = 32'd8; ALUFN = 6'b110000; #1;
        $display("SHL    A=%0d B=%0d ALUFN=%b -> Y=%0d (0x%h)", A, B, ALUFN, Y, Y);

        // SHR (logical): 0x80000000 >> 4 -- zero-fills, must NOT sign extend
        A = 32'h80000000; B = 32'd4; ALUFN = 6'b110001; #1;
        $display("SHR    A=0x%h B=%0d ALUFN=%b -> Y=0x%h  (expect 0x08000000)", A, B, ALUFN, Y);

        // SRA (arithmetic): 0x80000000 >>> 4 -- must sign extend
        A = 32'h80000000; B = 32'd4; ALUFN = 6'b110011; #1;
        $display("SRA    A=0x%h B=%0d ALUFN=%b -> Y=0x%h  (expect 0xF8000000)", A, B, ALUFN, Y);

        // ================= COMPARE =================

        // CMPEQ: equ̥al -> 1
        A = 32'd5; B = 32'd5; ALUFN = 6'b000011; #1;
        $display("CMPEQ  A=%0d B=%0d ALUFN=%b -> Y=%0d", A, B, ALUFN, Y);

        // CMPEQ: not equal -> 0
        A = 32'd5; B = 32'd3; ALUFN = 6'b000011; #1;
        $display("CMPEQ  A=%0d B=%0d ALUFN=%b -> Y=%0d", A, B, ALUFN, Y);

        // CMPLT: asymmetric, negative < positive -> 1
        A = -32'sd5; B = 32'd3; ALUFN = 6'b000101; #1;
        $display("CMPLT  A=%0d B=%0d ALUFN=%b -> Y=%0d", $signed(A), $signed(B), ALUFN, Y);

        // CMPLT: reversed operands -> 0 (catches A/B swap)
        A = 32'd3; B = -32'sd5; ALUFN = 6'b000101; #1;
        $display("CMPLT  A=%0d B=%0d ALUFN=%b -> Y=%0d", $signed(A), $signed(B), ALUFN, Y);

        // CMPLT: overflow-corrected case, A=MIN_NEG, B=1 -> should be 1
        A = 32'h80000000; B = 32'd1; ALUFN = 6'b000101; #1;
        $display("CMPLT(ovf) A=0x%h B=%0d ALUFN=%b -> Y=%0d", A, B, ALUFN, Y);

        // CMPLE: equal -> 1
        A = 32'd10; B = 32'd10; ALUFN = 6'b000111; #1;
        $display("CMPLE  A=%0d B=%0d ALUFN=%b -> Y=%0d", A, B, ALUFN, Y);

        // CMPLE: greater -> 0
        A = 32'd10; B = 32'd3; ALUFN = 6'b000111; #1;
        $display("CMPLE  A=%0d B=%0d ALUFN=%b -> Y=%0d", A, B, ALUFN, Y);

        $finish;
    end

endmodule
