module apb_top(
input pclk,
input presetn,

//user interface

input transfer,
input write,
input [31:0]addr,
input [7:0]wdata,
output [7:0]rdata,
output done
);

//apb interface

wire [31:0]paddr;
wire psel;
wire penable;
wire pwrite;
wire [7:0]pwdata;

wire [7:0]prdata;
wire pready;
wire pslverr;

apb_master master(.pclk(pclk),.presetn(presetn),.transfer(transfer),.write(write),.addr(addr),
                  .wdata(wdata),.rdata(rdata),.done(done),.prdata(prdata),.pready(pready),
                  .pslverr(pslverr),.psel(psel),.penable(penable),.pwrite(pwrite),
                  .pwdata(pwdata),.paddr(paddr));

apb_slave slave(.pclk(pclk),.presetn(presetn),.psel(psel),.penable(penable),.pwrite(pwrite),
                .pwdata(pwdata),.paddr(paddr),.pready(pready),.prdata(prdata),
                .pslverr(pslverr));
endmodule
