module tn_picorv32_top (
    input  logic clk,
    input  logic resetn,
    output logic [2:0] gpio
);
    logic        i_rst;
    logic        i_timer_irq;
    logic [31:0] o_ibus_adr;
    logic        o_ibus_cyc;
    logic [31:0] i_ibus_rdt;
    logic        i_ibus_ack;
    logic [31:0] o_dbus_adr;
    logic [31:0] o_dbus_dat;
    logic [3:0]  o_dbus_sel;
    logic        o_dbus_we ;
    logic        o_dbus_cyc;
    logic [31:0] i_dbus_rdt;
    logic        i_dbus_ack;

    serv_rf_top serv_rf_top_inst (
        .*
    );

    assign i_rst = !resetn;
    assign i_timer_irq = 0;

    logic [31:0] gpio_out;
    assign gpio = gpio_out[2:0];

    servant_ram #(
        .memfile("../serv/sw/blink.hex")
    ) iram (
        .i_wb_clk(clk),
        .i_wb_adr(o_ibus_adr[7:0]),
        .i_wb_dat(0),
        .i_wb_sel(0),
        .i_wb_we (0),
        .i_wb_cyc(o_ibus_cyc),
        .o_wb_rdt(i_ibus_rdt),
        .o_wb_ack(i_ibus_ack)
    );
    servant_ram dram(
        .i_wb_clk(clk),
        .i_wb_adr(o_dbus_adr[7:0]),
        .i_wb_dat(o_dbus_dat),
        .i_wb_sel(o_dbus_sel),
        .i_wb_we (o_dbus_we ),
        .i_wb_cyc(o_dbus_cyc),
        .o_wb_rdt(i_dbus_rdt),
        .o_wb_ack(i_dbus_ack)
    );

    always_ff @(posedge clk) begin
        if( o_dbus_we && o_dbus_adr[8] ) begin
            gpio_out <= o_dbus_dat;
        end
    end
endmodule