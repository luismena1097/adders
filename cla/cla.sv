/*
    Módulo: Carry Look Ahead using base of CLA 4 bits
    Descripción: Sumador que utiliza CLA de 4 bits como base 
    Realizado por: Luis Alberto Mena González
    Fecha: Junio/2026
*/

//Usando interface propuesta por el profe
module cla#(
  parameter int WIDTH = 8  // Ancho del adder
)(
  input  logic             clk,            // Reloj
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
  // Numero de bloques de CLA de 4 bits que son necesarios para sumar los operandos del ancho WIDTH
  localparam int NUM_BLOCKS = WIDTH/4;
  // Señales de entrada registradas para poder obtener timing en Quartus
  logic [WIDTH-1:0] srca_q;
  logic [WIDTH-1:0] srcb_q;
  logic             cin_q;
  logic             is_signed_q;
  // Señales de salida registradas para poder obtener timing en Quartus
  logic [WIDTH-1:0] result_c;
  logic             cout_c;
  logic             zero_f_c;
  logic             ov_f_c;
 
  logic [NUM_BLOCKS:0]   carry; // Carry que se propaga através de los bloques 
  logic [NUM_BLOCKS-1:0] gg_grp, gp_grp; // Generate y Propagate que van a los bloques de 4 bits
  genvar i;

  logic acc, chain;  // Señales para generar el carry al siguiente bloque 
  // Nivel 1: instanciar bloques de 4 bits
  generate
    for (i = 0; i < NUM_BLOCKS; i++) begin : CLA4Bits_Nivel1
      cla_4bits u_cla4 (
        .srca  (srca_q[i*4 +: 4]),
        .srcb  (srcb_q[i*4 +: 4]),
        .cin   (carry[i]),            // Propagacion del segundo nivel al primer nivel (de abajo hacia arriba)
        .result(result_c[i*4 +: 4]),
        .gg    (gg_grp[i]),
        .gp    (gp_grp[i])
      );
    end
  endgenerate

  // Nivel 2: Calcular los carries del siguiente bloque utilizando el generate y propagate que salen de un bloque anterior
  always_comb begin
    carry[0] = cin_q;       // El carry de entrada al bloque 0 siempre sera el carry in 
    for (int j = 1; j <= NUM_BLOCKS; j++) begin
      acc   = gg_grp[j-1];           // término generate del bloque j-1
      chain = gp_grp[j-1];           // cadena de propagate acumulada
      for (int k = j-2; k >= 0; k--) begin
        acc   = acc | (chain & gg_grp[k]); // suma el término gg[k] con su cadena gp
        chain = chain & gp_grp[k];          // extiende la cadena hacia cin
      end
      carry[j] = acc | (chain & cin_q);    // término final con cin
    end
  end

  assign cout_c = carry[NUM_BLOCKS];

  assign zero_f_c = (result_c == '0);

  assign ov_f_c = is_signed_q
               ? (~(srca_q[WIDTH-1] ^ srcb_q[WIDTH-1]) & (srca_q[WIDTH-1] ^ result_c[WIDTH-1]))
               : cout_c;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      srca_q     <= '0;
      srcb_q     <= '0;
      cin_q      <= 1'b0;
      is_signed_q<= 1'b0;
      result     <= '0;
      cout       <= 1'b0;
      zero_f     <= 1'b1;
      ov_f       <= 1'b0;
    end else begin
      // Registros de entrada
      srca_q      <= srca;
      srcb_q      <= srcb;
      cin_q       <= cin;
      is_signed_q <= is_signed;

      // Registros de salida
      result      <= result_c;
      cout        <= cout_c;
      zero_f      <= zero_f_c;
      ov_f        <= ov_f_c;
    end
  end

endmodule