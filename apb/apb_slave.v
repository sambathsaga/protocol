module apb_slave(
    input pclk,presetn,

// slave interface

    input psel,penable,
    input pwrite,
    input [7:0]pwdata,
    input [31:0]paddr,
    output pready,pslverr,
    output [7:0]prdata
);

reg[7:0]mem[0:31];
integer i;

// always ready
assign pready=1'b1;
// no error
assign pslverr=1'b0;

assign prdata = mem[paddr];

//read write logic

always@(posedge pclk or negedge presetn)begin
    if(!presetn)
    begin
        for(i=0;i<32;i=i+1)
            mem[i]<=0;
    end
    else
         //write operation

    begin
        if(psel&&penable&&pwrite)begin
           mem[paddr]<=pwdata;
            end
        end
    end

endmodule
