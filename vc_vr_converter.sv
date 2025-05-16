module vc_vr_converter #(
  parameter DATA_WIDTH = 8,
  CREDIT_NUM = 2
)(
  input logic clk,
  input logic rst_n,
  //valid/credit interface
  input logic [DATA_WIDTH-1:0] s_data_i,
  input logic s_valid_i,
  output logic s_credit_o,
  //valid/ready interface
  output logic [DATA_WIDTH-1:0] m_data_o,
  output logic m_valid_o,
  input logic m_ready_i
);

logic fifo_push;
logic fifo_pop;
logic fifo_empty;
logic fifo_full;
fifo # (.width (DATA_WIDTH), .depth (CREDIT_NUM))
    fifo0
    (
        .clk        ( clk        ),
        .rst        ( ~rst_n     ),
        .push       ( fifo_push  ),
        .pop        ( fifo_pop   ),
        .write_data ( s_data_i   ),
        .read_data  ( m_data_o   ),
        .empty      ( fifo_empty ),
        .full       ( fifo_full  )
    );

logic [$clog2(CREDIT_NUM) : 0]  given_credits_cnt;
logic                           free_credits;
always_ff @( posedge clk ) begin
    if (~rst_n)begin
        given_credits_cnt <= '0;
        free_credits <= 1'b0;
    end
    else if(given_credits_cnt < CREDIT_NUM & ~fifo_pop)begin
        given_credits_cnt <= given_credits_cnt + 1;
        free_credits <= 1'b1;
    end
    else if(given_credits_cnt < CREDIT_NUM & fifo_pop)begin
        free_credits <= 1'b1;
    end
    else begin
        free_credits <= 1'b0;
    end
end

assign fifo_push = ~fifo_full & s_valid_i;
assign fifo_pop  = ~fifo_empty && m_ready_i;
assign m_valid_o = ~fifo_empty;
assign s_credit_o = free_credits || (~fifo_push && fifo_pop);
endmodule