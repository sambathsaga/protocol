module uart_rx(
    input clk,
    input rst,
    input rx,
    input baud16_tick,
    output reg [7:0]rx_data,
    output reg rx_done
);

reg[7:0]data_reg;
reg[2:0]bit_index;
reg[1:0]state;
reg[3:0]sample_count;

localparam idle = 2'b00,
           start = 2'b01,
           data = 2'b10,
           stop = 2'b11;

always@(posedge clk)begin
    if(rst)
    begin
        state<=idle;
        bit_index<=3'd0;
        data_reg<=8'd0;
        rx_data <= 8'd0;
        sample_count<=4'b0;
        rx_done<=1'b0;
    end
    else
    begin
        rx_done<=1'b0;

        case(state)
//---------------------------------
// idle----------------------------
//---------------------------------

       idle:
       begin

           if(rx==1'b0)
           begin
               sample_count<=4'd0;         
               state<=start;
           end         
       end

//---------------------------------
// start---------------------------
//---------------------------------

       start:
       begin
           if(baud16_tick)
           begin
               if(sample_count==4'd7)
               begin
                   if(rx==1'b0)
                   begin
                   bit_index<=3'd0;
                   sample_count<=4'd0;
                   state<=data;
                   end
                   else
                   begin
                       sample_count<=4'd0;
                       state<= idle;
                   end
               end
               else
                  sample_count<=sample_count+1'b1;
          end
      end

//---------------------------------
// data----------------------------
//---------------------------------

        data:
        begin
            if(baud16_tick)
            begin
                if(sample_count==4'd15)
                begin
                    sample_count<=4'd0;
                    data_reg[bit_index]<=rx;

                    if(bit_index==3'd7)
                    begin
                       bit_index<=3'd0;
                       state<=stop;
                    end
                    else
                       bit_index<=bit_index+1;
                end
                else
                    sample_count<=sample_count+1'b1;
            end
        end
//---------------------------------
// stop----------------------------
//---------------------------------

         stop:
         begin
             if(baud16_tick)
             begin
                 if(sample_count==4'd15)
                 begin
                     sample_count<=4'd0;
                     if(rx==1'b1)
                     begin
                     rx_data<=data_reg;
                     rx_done<=1'b1;
                     bit_index<=3'd0;
                     state<=idle;

                     end
                    end
                 else
                     sample_count<=sample_count+1'b1;
             end
         end

         default:
             state<=idle;
     endcase
 end
 end
 endmodule
