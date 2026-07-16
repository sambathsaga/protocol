module apb_master(

    input pclk,presetn,

 // user interface
    
    input transfer,write,
    input [31:0]addr,   
    input [7:0]wdata,
    output reg [7:0]rdata,
    output reg done,

 // apb interface

    input [7:0]prdata,
    input pready,
    input pslverr,
    output reg psel,penable,pwrite,
    output reg [7:0]pwdata,
    output reg [31:0]paddr
    );

reg [1:0]state,next_state;

parameter idle=2'b00,
          setup=2'b01,
          access=2'b10;

// state register

always@(posedge pclk or negedge presetn) begin
    if(!presetn)
        state<=idle;
    else
        state<=next_state;
end

// next state logic

    always@(*)begin

        case(state)
            idle:
            begin
                if(transfer)
                    next_state <= setup;
                else
                    next_state <=idle;
            end
            setup:
            begin
                next_state<=access;
            end
            access:
            begin
               if(pready)
                    next_state = idle;
                else
                    next_state = access;
             end

                default: next_state<=idle;
            endcase
        end

// output logic

        always@(posedge pclk or negedge presetn)begin
            if(!presetn)
            begin
                psel<=0;
                penable<=0;
                pwrite<=0;
                paddr<=0;
                rdata<=0;
                pwdata<=0;
                done<=0;
            end
            else begin
                done<=0;

                case(state)

                    idle:
                    begin
                        psel<=0;
                        penable<=0;
                        if(transfer)
                        begin
                            paddr<=addr;
                            pwdata<=wdata;
                            pwrite<=write;
                        end
                    end

                    setup:
                    begin
                        psel<=1;
                        penable<=0;
                    end

                    access:
                    begin
                        psel<=1;
                        penable<=1;
                        if(pready)
                        begin
                            if(!pwrite)
                                rdata<=prdata;
                        done<=1;
                    end
                end
                default:begin
                    psel<=0;
                    penable<=0;
                end
            endcase
        end
    end

    endmodule
