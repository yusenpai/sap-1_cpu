module demux4to16 (
    input [3:0] in,
    output [15:0] out
);
    assign out[0] = (~in[3])&(~in[2])&(~in[1])&(~in[0]);
    assign out[1] = (~in[3])&(~in[2])&(~in[1])&(in[0]);
    assign out[2] = (~in[3])&(~in[2])&(in[1])&(~in[0]);
    assign out[3] = (~in[3])&(~in[2])&(in[1])&(in[0]);
    assign out[4] = (~in[3])&(in[2])&(~in[1])&(~in[0]);
    assign out[5] = (~in[3])&(in[2])&(~in[1])&(in[0]);
    assign out[6] = (~in[3])&(in[2])&(in[1])&(~in[0]);
    assign out[7] = (~in[3])&(in[2])&(in[1])&(in[0]);
    assign out[8] = (in[3])&(~in[2])&(~in[1])&(~in[0]);
    assign out[9] = (in[3])&(~in[2])&(~in[1])&(in[0]);
    assign out[10] = (in[3])&(~in[2])&(in[1])&(~in[0]);
    assign out[11] = (in[3])&(~in[2])&(in[1])&(in[0]);
    assign out[12] = (in[3])&(in[2])&(~in[1])&(~in[0]);
    assign out[13] = (in[3])&(in[2])&(~in[1])&(in[0]);
    assign out[14] = (in[3])&(in[2])&(in[1])&(~in[0]);
    assign out[15] = (in[3])&(in[2])&(in[1])&(in[0]);
endmodule

module ram (
    /* Bus interface */
    input [7:0] bus_in,     // Data to write
    output [7:0] bus_out,    // Data to read
    
    /* Clock and Reset */
    input clk, rst,

    /* Control signal */
    input [3:0] address,     // 4-bit address for 16 words
    input ri, ro,           // ri: write enable, ro: read enable
    input ram_clk,
    input prog_enable,
    input [7:0] prog_data_in,
    input [3:0] prog_address
);  
    /* Decode address */
    wire [15:0] row_select;
    wire [7:0] row_output [0:15];
    wire [7:0] row_data_in = ({8{prog_enable}} & prog_data_in) | ({8{~prog_enable}} & bus_in);
    demux4to16 address_decoder(.in(address | prog_address), .out(row_select));

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : reg_bank
            reg_param #(8) mem_rowi(
                .rst(rst),
                .clk(clk | ram_clk),
                .load(row_select[i] & (ri | prog_enable)), // Gated write enable
                .load_data(row_data_in),
                .q(row_output[i])
            );
        end
    endgenerate 

    /* Read operation */
    wire [7:0] read_data;
    assign bus_out = row_output[address] & {8{ro}};
endmodule