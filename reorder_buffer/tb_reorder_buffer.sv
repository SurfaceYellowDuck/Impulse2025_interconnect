`timescale 1ns/1ps
module tb_reorder_buffer #(parameter DATA_WIDTH = 8, CLK_PERIOD = 10)();
logic clk;
logic rst_n;
//AR slave interface
logic [3:0] s_arid_i;
logic s_arvalid_i;
logic s_arready_o;
//R slave interface
logic [DATA_WIDTH-1:0] s_rdata_o;
logic [3:0] s_rid_o;
logic s_rvalid_o;
logic s_rready_i;
//AR master interface
logic [3:0] m_arid_o;
logic m_arvalid_o;
logic m_arready_i;
//R master interface
logic [DATA_WIDTH-1:0] m_rdata_i;
logic [3:0] m_rid_i;
logic m_rvalid_i;
logic m_rready_o;


  reorder_buffer #(
    .DATA_WIDTH(DATA_WIDTH)
  ) uut (
    .clk(clk),
    .rst_n(rst_n),
    .s_arid_i(s_arid_i),
    .s_arvalid_i(s_arvalid_i),
    .s_arready_o(s_arready_o),
    .s_rdata_o(s_rdata_o),
    .s_rid_o(s_rid_o),
    .s_rvalid_o(s_rvalid_o),
    .s_rready_i(s_rready_i),
    .m_arid_o(m_arid_o),
    .m_arvalid_o(m_arvalid_o),
    .m_arready_i(m_arready_i),
    .m_rdata_i(m_rdata_i),
    .m_rid_i(m_rid_i),
    .m_rvalid_i(m_rvalid_i),
    .m_rready_o(m_rready_o)
  );

  // Генерация тактового сигнала 
  initial begin
    clk <= 0;
    forever #(CLK_PERIOD/2) clk <= ~clk;
  end

  initial begin
    $dumpfile("waveform.vcd");
    $dumpvars(0, tb_reorder_buffer);
  end

  initial begin
    rst_n <= 1'bx;
    // s_arid_i <= 3'd1;
    @ (posedge clk);
    rst_n <= 1'b0;
    m_arready_i <= 1'b1;
    s_arvalid_i <= '0;
    @(posedge clk);
    rst_n <= 1'b1;

    repeat (1)@(posedge clk);
    m_arready_i <= 1'b1;
    s_arvalid_i <= '1;
    s_arid_i <= 3'd2;

    repeat (1)@(posedge clk);
    m_arready_i <= 1'b1;
    s_arvalid_i <= '1;
    s_arid_i <= 3'd3;

    repeat (1)@(posedge clk);
    m_rvalid_i <= '1;
    s_rready_i <= 1;
    m_rdata_i <= 8'hfe;
    m_rid_i <= 'd2;

    repeat (1)@(posedge clk);
    m_rvalid_i <= '0;

    repeat (1)@(posedge clk);
    m_arready_i <= 1'b1;
    s_arvalid_i <= '1;
    s_arid_i <= 'd4;

    repeat (1)@(posedge clk);
    m_arready_i <= 1'b1;
    s_arvalid_i <= '1;
    s_arid_i <= 'd5;


    repeat (1)@(posedge clk);
    s_arvalid_i <= '1;
    s_arid_i <= 'd6;

    repeat (1)@(posedge clk);
    m_rvalid_i <= '1;
    s_rready_i <= 1;
    m_rdata_i <= 8'hbf;
    m_rid_i <= 'd3;

    repeat (1)@(posedge clk);
    m_rvalid_i <= '1;
    s_rready_i <= 1;
    m_rdata_i <= 8'h0A;
    m_rid_i <= 'd4;

    repeat (1)@(posedge clk);
    m_rvalid_i <= '1;
    s_rready_i <= 1;
    m_rdata_i <= 8'h70;
    m_rid_i <= 'd6;

    repeat (1)@(posedge clk);
    m_rvalid_i <= '1;
    s_rready_i <= 1;
    m_rdata_i <= 8'h80;
    m_rid_i <= 'd5;
    #200 $finish;
  end

endmodule
