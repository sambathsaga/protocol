module uart_tb;

reg clk;
reg rst;

reg tx_start;
reg [7:0] tx_data;
wire tx;
wire tx_busy;

wire [7:0] rx_data;
wire rx_done;
wire rx;

assign rx = tx;

uart_top #(.clk_freq(50000000),.baud(9600))
         uut (.clk(clk),.rst(rst),.tx_start(tx_start),.tx_data(tx_data),.rx(rx),.tx(tx),
              .tx_busy(tx_busy),.rx_data(rx_data),.rx_done(rx_done));
initial clk=0;
always #10 clk = ~clk;
initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0,uart_tb);


    rst = 1;

    tx_start = 0;
    tx_data = 8'h00;

    #20;

    rst = 0;

    //------------------------------------
    // Send First Byte
    //------------------------------------

    @(posedge clk);
    tx_data = 8'h55;
    tx_start = 1;

    @(posedge clk);
    tx_start = 0;

    wait(rx_done);

    $display("-----------------------------------");
    $display("Received = %h",rx_data);
    $display("-----------------------------------");

    #20;

    //------------------------------------
    // Send Second Byte
    //------------------------------------
    //
    wait(!tx_busy);

    @(posedge clk);
    tx_data = 8'hA3;
    tx_start = 1;

    @(posedge clk);
    tx_start = 0;

    wait(rx_done);

    $display("-----------------------------------");
    $display("Received = %h",rx_data);
    $display("-----------------------------------");

    #20;

    //------------------------------------
    // Send Third Byte
    //------------------------------------

    wait(!tx_busy);


    @(posedge clk);
    tx_data = 8'hF0;
    tx_start = 1;

    @(posedge clk);
    tx_start = 0;

    wait(rx_done);

    $display("-----------------------------------");
    $display("Received = %h",rx_data);
    $display("-----------------------------------");


    #1000000;

    $finish;

end

endmodule
