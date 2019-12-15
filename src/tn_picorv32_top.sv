module tn_picorv32_top (
    input logic clk,
    input logic resetn,
    output logic [2:0] gpio
);

    logic trap;
    logic        mem_valid;
    logic        mem_instr;
    logic        mem_ready;
    logic [31:0] mem_addr;
    logic [31:0] mem_wdata;
    logic [ 3:0] mem_wstrb;
    logic [31:0] mem_rdata;
    logic        mem_la_read;
    logic        mem_la_write;
    logic [31:0] mem_la_addr;
    logic [31:0] mem_la_wdata;
    logic [ 3:0] mem_la_wstrb;
    logic        pcpi_valid;
    logic [31:0] pcpi_insn;
    logic [31:0] pcpi_rs1;
    logic [31:0] pcpi_rs2;
    logic        pcpi_wr;
    logic [31:0] pcpi_rd;
    logic        pcpi_wait;
    logic        pcpi_ready;
    logic [31:0] irq;
    logic [31:0] eoi;
    logic        trace_valid;
    logic [35:0] trace_data;

    picorv32 #(
        .ENABLE_COUNTERS(0),
        .ENABLE_COUNTERS64(0),
        .ENABLE_REGS_DUALPORT(0),
        .ENABLE_REGS_16_31(0)
    ) picorv32_inst (
        .*
    );


    assign pcpi_wr = 0;
    assign pcpi_rd = 0;
    assign pcpi_wait = 0;
    assign pcpi_ready = 0;

    assign irq = 0;

    logic [31:0] mem_write_mask;

    localparam int RAM_SIZE = 256*4;
    localparam int RAM_ADDRESS_BITS = $clog2(RAM_SIZE);
    logic [RAM_ADDRESS_BITS-1:2] ram_addr;
    logic [31:0] ram_data_in;
    logic [31:0] ram_data_out;
    logic [31:0] ram_buffer;
    logic        ram_select;
    logic        ram_write_enable;
    logic        ram_partial_write;
    ram32 #(
        .RAM_SIZE(RAM_SIZE)
    ) ram_inst (
        .addr(ram_addr),
        .data_in(ram_data_in),
        .data_out(ram_data_out),
        .we(ram_write_enable),
        .*
    );

    assign ram_select  = mem_addr < RAM_SIZE;
    assign ram_addr = mem_addr[RAM_ADDRESS_BITS-1:2];
    
    always_comb begin
        case(mem_wstrb)
            4'b0001: mem_write_mask = 32'h0000_00ff;
            4'b0010: mem_write_mask = 32'h0000_ff00;
            4'b0100: mem_write_mask = 32'h00ff_0000;
            4'b1000: mem_write_mask = 32'hff00_0000;
            4'b0011: mem_write_mask = 32'h0000_ffff;
            4'b1100: mem_write_mask = 32'hffff_0000;
            4'b1111: mem_write_mask = 32'hffff_ffff;
            default: mem_write_mask = 0;
        endcase
    end

    assign mem_ready = !ram_partial_write;
    assign ram_data_in =  (ram_buffer & ~mem_write_mask) | (mem_wdata & mem_write_mask);
    assign ram_write_enable = mem_valid && ram_select && (mem_wstrb == 4'b1111 || ram_partial_write);

    logic [31:0] gpio_out;
    assign gpio = gpio_out[2:0];

    always_comb begin
        if( ram_select ) begin
            mem_rdata = ram_data_out;
        end
        else begin
            mem_rdata = gpio_out;
        end
    end 

    always_ff @(posedge clk) begin
        if( !resetn ) begin
            ram_partial_write <= 0;
            ram_buffer <= 0;
            gpio_out <= 0;
        end
        else begin
            ram_partial_write <= mem_valid && (mem_wstrb != 4'b0000 || mem_wstrb != 4'b1111) && ram_select  ? 1 : 0;
            ram_buffer <= ram_data_in;
            gpio_out <= mem_valid && !ram_select && mem_wstrb != 0 ? (gpio_out & ~mem_write_mask | mem_wdata & mem_write_mask) : gpio_out;
        end
    end    
endmodule