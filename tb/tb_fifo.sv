`timescale 1ns/1ps
module tb_fifo;
 reg clk=0;always #5 clk=~clk;
 reg rst=1,push=0,pop=0;reg[7:0]din=0;wire[7:0]dout;wire full,empty;wire[1:0]count;
 sync_fifo #(.DEPTH(3)) dut(clk,rst,push,pop,din,dout,full,empty,count);
 reg[7:0]model[0:10000];integer head=0,tail=0,n=0,i;reg take,put;
 integer seed=1701,junk;
 initial begin
  repeat(3)@(negedge clk);rst=0;
  for(i=0;i<6000;i=i+1)begin
   @(negedge clk);push=($random(seed)&3)!=0;pop=($random(seed)&1);din=$random(seed);
   take=pop&&(n>0);put=push&&((n<3)||take);
   if(take)begin if(dout!==model[head])$fatal(1,"FIFO ordering at %0d",i);head=head+1;end
   if(put)begin model[tail]=din;tail=tail+1;end
   n=n+put-take;
   @(posedge clk);#1;
   if(count!==n || full!==(n==3) || empty!==(n==0))$fatal(1,"FIFO flags at %0d",i);
  end
  @(negedge clk);rst=1;@(posedge clk);#1;if(!empty)$fatal(1,"reset");
  $display("PASS FIFO: 6000 seeded cycles, non-power-of-two depth, boundary replacement, reset");$finish;
 end
 initial begin #1000000;$fatal(1,"FIFO watchdog");end
endmodule
