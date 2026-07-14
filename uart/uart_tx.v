module uart_tx(
    input clk,
    input rst,
    input baud16_tick,
    input tx_start,
    input[7:0]tx_data,
    output reg tx,
    output reg tx_busy
);

reg[2:0]bit_index;
reg[7:0]data_reg;
reg[1:0]state;
reg[3:0]sample_count;

localparam idle = 2'b00,
           start = 2'b01,
           data = 2'b10,
           stop = 2'b11;

always@(posedge clk)begin
    if(rst)begin
        state<=idle;
        tx<=1'b1;
        tx_busy<=1'b0;
        data_reg <= 8'd0;
        bit_index<=3'd0;
        sample_count<=4'd0;
    end
    else begin
        case(state)
//------------------------------------------
//idle--------------------------------------
//------------------------------------------
        idle:
        begin
            tx<=1'b1;
            tx_busy<=1'b0;
            if(tx_start)
            begin
                data_reg<=tx_data;
                tx_busy<=1'b1;
                sample_count<=4'd0;
                bit_index<=3'd0;
                state<=start;

            end
        end

//------------------------------------------
//start--------------------------------------
//------------------------------------------

        start:
        begin
            tx<=1'b0;
            tx_busy<=1'b1;
        if(baud16_tick)
        begin
            if(sample_count==4'd15)
            begin
                sample_count<=0;
                state<=data;
            end
            else
                sample_count<=sample_count+1'b1;
        end
    end

//------------------------------------------
//data--------------------------------------
//------------------------------------------

        data:
        begin
            tx <= data_reg[bit_index];
            tx_busy <= 1'b1;
        if(baud16_tick)
        begin
            if(sample_count==4'd15)
            begin
                sample_count<=0;
                if(bit_index==3'd7)
                    state<=stop;
                else
                    bit_index<=bit_index+1'b1;
            end
            else
                sample_count<=sample_count+1'b1;
        end
    end

//------------------------------------------
//stop--------------------------------------
//------------------------------------------

        stop:
        begin
            tx<=1'b1;
            tx_busy<=1'b1;
        if(baud16_tick)
        begin
            if(sample_count==4'd15)
            begin
                sample_count<=0;                
                bit_index<=3'd0;
                state<=idle;
            end
            else
                sample_count<=sample_count+1'b1;
        end
    end
        default:
        begin
            state<=idle;
            tx<=1'b1;
            tx_busy<=1'b0;
            bit_index <= 0;
            sample_count <= 0;
        end
    endcase
end
end
endmodule
