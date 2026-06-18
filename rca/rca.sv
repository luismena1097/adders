/*
    Módulo: Ripple Carry Adder 
    Descripción: Sumador parametrizable que utiliza como base el full_adder.sv
    Realizado por: Luis Alberto Mena González
    Fecha: Junio/2026
*/
//Usando interface propuesta por el profe
module rca#(
  parameter int WIDTH = 8            // Ancho del adder
)(
  input  logic             clk,            // Reloj para registrar salidas
  input  logic             rst_n,          // Reset activo en bajo
  input  logic [WIDTH-1:0] srca,           // Operando 1
  input  logic [WIDTH-1:0] srcb,           // Operando 2
  input  logic             cin,            // Carry de entrada
  input  logic             is_signed,      // Indica si la operacion es signed(1) o unsigned(0)
  output logic [WIDTH-1:0] result,         // Resultado
  output logic             cout,           // Carry de salida
  output logic             zero_f,         // Bandera de cero
  output logic             ov_f            // Bandera de overflow
); 

logic [WIDTH:0] carry;
logic [WIDTH-1:0] srca_r;
logic [WIDTH-1:0] srcb_r;
logic             cin_r;
logic             is_signed_r;
logic [WIDTH-1:0] result_comb;
logic             cout_comb;
logic             zero_f_comb;
logic             ov_f_comb;

assign carry[0] = cin_r;

genvar i;

generate 
    for (i = 0; i < WIDTH; i = i + 1) begin : full_adder_chain
    full_adder fa (.a(srca_r[i]), .b(srcb_r[i]), .cin(carry[i]), .sum(result_comb[i]), .cout(carry[i+1]));
    end
endgenerate

assign cout_comb = carry[WIDTH];

assign zero_f_comb = (result_comb == '0);

assign ov_f_comb = is_signed_r ? (carry[WIDTH-1] ^ carry[WIDTH]) : cout_comb;

always_ff @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    srca_r      <= '0;
    srcb_r      <= '0;
    cin_r       <= 1'b0;
    is_signed_r <= 1'b0;
  end else begin
    srca_r      <= srca;
    srcb_r      <= srcb;
    cin_r       <= cin;
    is_signed_r <= is_signed;
  end
end

always_ff @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    result <= '0;
    cout   <= 1'b0;
    zero_f <= 1'b1;
    ov_f   <= 1'b0;
  end else begin
    result <= result_comb;
    cout   <= cout_comb;
    zero_f <= zero_f_comb;
    ov_f   <= ov_f_comb;
  end
end

endmodule