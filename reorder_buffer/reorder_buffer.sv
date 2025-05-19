module reorder_buffer #(
parameter DATA_WIDTH = 8
)(
input   logic                   clk,
input   logic                   rst_n,
//AR slave interface
input   logic [3:0]             s_arid_i,
input   logic                   s_arvalid_i,
output  logic                   s_arready_o,
//R slave interface
output  logic [DATA_WIDTH-1:0]  s_rdata_o,
output  logic [3:0]             s_rid_o,
output  logic                   s_rvalid_o,
input   logic                   s_rready_i,
//AR master interface
output  logic [3:0]             m_arid_o,
output  logic                   m_arvalid_o,
input   logic                   m_arready_i,
//R master interface
input   logic [DATA_WIDTH-1:0]  m_rdata_i,
input   logic [3:0]             m_rid_i,
input   logic                   m_rvalid_i,
output  logic                   m_rready_o
);

logic               up_ready;
logic               id_down_valid;
logic [4 - 1 : 0]   down_data;
logic               fifo_push;
logic               fifo_pop;
logic               fifo_full;
logic               fifo_empty;
logic [4 - 1 : 0]   ar_id_o;
logic [8 - 1 : 0]   data_buf [16 - 1 : 0];
logic [16 - 1 : 0]  data_vld_buf;

double_buffer  #(.width (4)) buffer_id
(
    .clk         ( clk              ),
    .rst         ( ~rst_n           ),

    .up_valid    ( s_arvalid_i      ),
    .up_ready    ( up_ready         ),
    .up_data     ( s_arid_i         ),

    .down_valid  ( m_arvalid_o      ),
    .down_ready  ( m_arready_i      ),
    .down_data   ( m_arid_o         )
);



assign s_arready_o  = up_ready & ~fifo_full;
assign fifo_push    = up_ready & s_arvalid_i & ~fifo_full;
assign s_rid_o      = ar_id_o;
assign m_rready_o   = s_rready_i;
assign fifo_pop = s_rvalid_o && s_rready_i;

fifo  #(.width (4), .depth(16)) fifo_id
(
        .clk        ( clk           ),
        .rst        ( ~rst_n        ),
        .push       ( fifo_push     ),
        .pop        ( fifo_pop      ),
        .write_data ( s_arid_i      ),
        .read_data  ( ar_id_o       ),
        .empty      ( fifo_empty    ),
        .full       ( fifo_full     )
);

mem data_valid_mem (
    .clk        ( clk                   ),
    .rst        ( ~rst_n | fifo_empty   ),
    .waddr      ( m_rid_i               ),
    .raddr      ( ar_id_o               ),
    .data_i     ( m_rdata_i             ),
    .vld_i      ( m_rvalid_i            ),
    .data_o     ( s_rdata_o             ),
    .valid_o    ( s_rvalid_o            )
);

endmodule