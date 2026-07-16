module tb;
reg pclk;
reg presetn;
reg transfer;
reg write;
reg [31:0]addr;
reg [7:0]wdata;
wire [7:0]rdata;
wire done;

apb_top uut(.pclk(pclk),.presetn(presetn),.transfer(transfer),.write(write),.addr(addr),
            .wdata(wdata),.rdata(rdata),.done(done));

task apb_write;
    input[31:0]wr_addr;
    input[7:0]wr_data;
    begin
        transfer=1;
        write=1;

        addr=wr_addr;
        wdata=wr_data;
        @(negedge pclk);
        while(!done)@(negedge pclk);

        transfer=0;
        write =0;
    end
endtask

task apb_read;
    input[31:0]r_addr;
    begin
        transfer=1;
        write=0;

        addr=r_addr;
         @(negedge pclk);
         while(!done)@(negedge pclk);

         transfer=0;
     end
 endtask
initial pclk=0;
always #5 pclk = ~pclk;


initial begin
  $dumpfile("wave.vcd");
  $dumpvars(0,tb);
  $monitor("time=%0t pclk=%b presetn=%b write=%b transfer=%b addr=%h wdata=%h rdata=%h done=%b",            $time,pclk,presetn,write,transfer,addr,wdata,rdata,done);

    presetn=0;
    transfer=0;
    addr=0;
    write=0;
    wdata=0;

    //reset
$display("reset");

    #15;
    presetn=1;

    //write
$display("writing the data");

    apb_write (32'h0f,8'ha1);
    #20;

    //read
$display("reading the data");
    apb_read (32'h0f);
    #30;
    $finish;
end
endmodule
