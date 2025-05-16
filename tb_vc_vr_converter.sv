`timescale 1ns/1ps
module tb_vc_vr_converter #(parameter DATA_WIDTH = 8, CREDIT_NUM = 2, CLK_PERIOD = 10, string MEM_FILE = "tv.hex")();
  logic clk;
  logic rst_n;
  logic [7:0] s_data_i;
  logic s_valid_i;
  logic s_credit_o;
  logic [7:0] m_data_o;
  logic m_valid_o;
  logic m_ready_i;
  logic [DATA_WIDTH - 1 : 0] tv [3 : 0];


  vc_vr_converter #(
    .DATA_WIDTH(DATA_WIDTH),
    .CREDIT_NUM(CREDIT_NUM)
  ) uut (
    .clk(clk),
    .rst_n(rst_n),
    .s_data_i(s_data_i),
    .s_valid_i(s_valid_i),
    .s_credit_o(s_credit_o),
    .m_data_o(m_data_o),
    .m_valid_o(m_valid_o),
    .m_ready_i(m_ready_i)
  );

  // Генерация тактового сигнала 
  initial begin
  $display("PWD = %s", MEM_FILE);

    clk <= 0;
    forever #(CLK_PERIOD/2) clk <= ~clk;
  end

  initial begin
    $dumpfile("waveform.vcd");
    $dumpvars(0, tb_vc_vr_converter);
  end

  initial begin
    rst_n <= 1'bx;
    @ (posedge clk);
    rst_n <= 1'b0;
    m_ready_i <= 1'b1;
    s_valid_i <= '0;
    @(posedge clk);
    rst_n <= 1'b1;

    repeat (CREDIT_NUM + 1) @ (posedge clk);
    s_data_i <= 8'hAA;
    s_valid_i <= '1;
    @ (posedge clk);
    s_valid_i <= '0;
    if(m_data_o != 8'hAA)begin 
      $display("Error: m_data_o = %h, expected = %h", m_data_o, 8'hAA);
      $stop;
      @ (posedge clk);
    end
    m_ready_i <= '0;
    repeat (2)@ (posedge clk);

    s_data_i <= 8'hBB;
    s_valid_i <= '1;
      @ (posedge clk);
    s_data_i <= 8'hCC;
    s_valid_i <= '1;
    repeat (3)  @ (posedge clk);
    m_ready_i <= '1;
    repeat (3) @ (posedge clk);

    // Проверка на поведение при переполнении очереди
    $readmemh("tv.hex", tv);
    rst_n <= 1'b0;
    m_ready_i <= 1'b1;
    s_valid_i <= '0;
    @(posedge clk);
    rst_n <= 1'b1;
    repeat (CREDIT_NUM + 1) @ (posedge clk);
    m_ready_i <= 1'b0;

    for (int i = 0; i < 4; i++) begin
    @ (posedge clk);
    $display("read: %h", tv[i]);
      s_data_i <= tv[i];
      s_valid_i <= '1;
    end
      @ (posedge clk);
    m_ready_i <= 1'b1;
    repeat (CREDIT_NUM + 1) @ (posedge clk);
    if(m_data_o != 8'h80)begin
        $display("Error: m_data_o = %h, expected = %h", m_data_o, 8'h80);
        $stop;
    end

// Проверка на передачу невалидных данных
    @ (posedge clk);
    s_data_i <= 8'h50;
    s_valid_i <= '0;
    @ (posedge clk);
    if(m_data_o != 8'h80)begin 
        $display("Error: m_data_o = %h, expected = %h", m_data_o, 8'h80);
        $stop;
    end
    #200 $finish;
  end

endmodule
