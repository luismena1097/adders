/*
    Módulo: Carry look ahead 
    Descripción: CLA de 4 bits
    Realizado por: Luis Alberto Mena González
    Fecha: Junio/2026
*/

//Usando interface propuesta por el profe
module cla_4bits(
  input  logic [3:0]  srca,           // Operando 1
  input  logic [3:0]  srcb,           // Operando 2
  input  logic        cin,            // Carry de entrada
  output logic [3:0]  result,         // Resultado
  output logic        gg,             // Group Generate
  output logic        gp              // Group Propagate
); 

  logic [3:0] g, p;
  logic [3:0] c;

  assign g = srca & srcb;         // generate bit a bit
  assign p = srca ^ srcb;         // propagate bit a bit

  // Group Generate: el bloque genera carry sin depender de cin
  assign gg = g[3] | (p[3] & g[2]) | (p[3] & p[2] & g[1]) | (p[3] & p[2] & p[1] & g[0]);

  // Group Propagate: el bloque propaga cin solo si todos los bits propagan
  assign gp = p[3] & p[2] & p[1] & p[0];

  assign c[0] = cin;
  assign c[1] = g[0] | (p[0] & c[0]);
  assign c[2] = g[1] | (p[1] & g[0]) | (p[1] & p[0] & c[0]);
  assign c[3] = g[2] | (p[2] & g[1]) | (p[2] & p[1] & g[0]) | (p[2] & p[1] & p[0] & c[0]);

  assign result = p ^ c[3:0];

endmodule