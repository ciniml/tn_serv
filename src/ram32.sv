module ram32 #(
    parameter int RAM_SIZE = 256*4,
    localparam RAM_ADDR_BITS = $clog2(RAM_SIZE/4)
) (
    input logic clk,
    input logic resetn,
    input logic [RAM_ADDR_BITS-1:0] addr,
    input logic        we,
    input logic [31:0] data_in,
    output logic [31:0] data_out
);

bit [31:0] mem [RAM_SIZE/4-1:0]; /* synthesis syn_ramstyle="block_ram" */

always @(posedge clk) begin
    if( !resetn ) begin
        data_out <= 0;
    end
    else begin
        data_out <= we ? data_in : mem[addr];
    end
end
always @(posedge clk) begin
    if( we ) begin
        mem[addr] <= data_in;
    end
end

endmodule