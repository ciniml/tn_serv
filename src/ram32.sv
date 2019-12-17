module ram32 #(
    parameter RAM_SIZE = 256*4,
    parameter INITIAL_FILE = "",
    localparam RAM_ADDR_BITS = $clog2(RAM_SIZE/4)
) (
    input logic clk,
    input logic resetn,
    input logic [RAM_ADDR_BITS-1:0] addr,
    input logic         ce,
    input logic         we,
    input logic [31:0]  data_in,
    output logic [31:0] data_out
);

logic [31:0] mem [0:RAM_SIZE/4-1]; /* synthesis syn_ramstyle="block_ram" */

always_ff @(posedge clk) begin
    if( !resetn ) begin
        data_out <= 0;
    end
    else if(ce) begin
        data_out <= we ? data_in : mem[addr];
    end
end
always_ff @(posedge clk) begin
    if( we ) begin
        mem[addr] <= data_in;
    end
end

initial if(|INITIAL_FILE) $readmemh(INITIAL_FILE, mem);

endmodule