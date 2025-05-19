module mem 
(
    input logic                 clk,
    input logic                 rst,
    input logic [3:0]           waddr,
    input logic [3:0]           raddr,
    input logic  [8 - 1 : 0]    data_i,
    input logic                 vld_i,
    
    output logic [8 - 1 : 0]    data_o,
    output logic                valid_o
);
    logic [16-1:0]          vld;
    logic [8-1:0]           data_buf [15:0];

    always_ff @( posedge clk )
    if(rst)
      vld <= '0;
    else if(vld_i)begin
        vld[waddr]      <= vld_i;
        data_buf[waddr] <= data_i;
    end

    assign data_o  = data_buf[raddr];
    assign valid_o = vld[raddr]; 
endmodule