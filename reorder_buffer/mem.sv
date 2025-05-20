module mem 
(
    input logic                 clk,
    input logic                 rst,
    input logic [3:0]           waddr,
    input logic [3:0]           raddr,
    input logic [8 - 1 : 0]     data_i,
    input logic                 re,
    input logic                 we,

    output logic [8 - 1 : 0]    data_o,
    output logic                valid_o
);

    logic [8-1:0]           data_buf [15:0];
    logic [16-1:0]          vld;
    logic [16-1:0]          changed_vld;

    always_ff @(posedge clk)begin
        if(rst)
            vld <= '0;
        else begin
            vld <= changed_vld;
            if(we)
                data_buf[waddr] <= data_i;
        end
    end
    always_comb begin
        changed_vld = vld;
        if(we)
            changed_vld = changed_vld | (16'b1 << waddr);
        else if(re)
            changed_vld = changed_vld ^ (16'b1 << raddr);
    end

    assign valid_o = vld[raddr]; 
    assign data_o  = data_buf[raddr];
endmodule