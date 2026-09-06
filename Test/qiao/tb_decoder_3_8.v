`timescale 1ns/1ps


module tb_decoder_3_8();


    reg  [2:0] din;
    wire [7:0] dout;


    decoder_3_8 uut(

   .din(din),
   .dout(dout)    
);
 initial begin
      
      din = 3'b000; #10
      din = 3'b001; #10
      din = 3'b010; #10
      din = 3'b011; #10
      din = 3'b100; #10
      din = 3'b101; #10
      din = 3'b110; #10
      din = 3'b111; #10
      
      $finish;
 end

 initial begin
     $monitor("时间=%0t, din=%b, dout=%b", $time, din, dout);
 end 
        
       

endmodule