// Project test bench for ee287
//
`timescale 1ns/10ps

`include "filt.sv"

module top() ;

logic Clock,Reset,FILTER,BitIn,Push;
logic [15:0] Dout;
reg [15:0] Expect[$];
logic forking,sp;
integer scnt;

`include "tdata.v"

initial begin
    Clock=0;
    repeat(150_000) begin
    Clock=1;
    #5;
    Clock=0;
    #5;
    end
    $fatal("\n\nRan out of clocks\n\n");
end

initial begin
    BitIn=0;
    FILTER=0;
    Reset=1;
    forking=0;
    scnt=0;
    sp=0;
    repeat(3) @(posedge(Clock));
    #1 Reset=0;
end

task dsamp(logic v);
    BitIn=v;
    sp=1;
    #1 sp=0;
    scnt+=1;
    @(posedge Clock) #1;
endtask : dsamp

always @(posedge Clock) begin
    reg signed [17:0] ex,act,delta;
    if (Reset==0 && Push===1'bX) die("Push is an X");
    if (Reset==0 && ^Dout === 1'bx) die("Dout has an X");
    if (Reset==0 && Push===1'b1) begin
//        $display("expect size %d @%t",Expect.size,$time);
        if (Expect.size()==0) die("Pushed data and nothing expected");
        ex=Expect.pop_front();
        act=Dout;
        delta=ex-act;
        if(delta<0) delta=-delta;
        $display("expected %x actual %x delta %x",ex,act,delta);
        if(delta>16) begin
            die($sformatf("Answer outside range exp %x got %x",ex,act));
        end
    end

end

task die(string msg);
    $display("death at %t",$time);
    repeat(5) @(posedge(Clock));
    $fatal("\n\nStopping simulation because %s\n\n",msg);
endtask : die

task setexp(reg [15:0] expval);
    $display("--- Expecting %h @%t",expval,$time);
    Expect.push_back(expval);
    if(Expect.size()>2) die("FILTER input without previous result push");
endtask : setexp

task de128();
    repeat(128) @(posedge Clock) #1;
    FILTER=1;
    @(posedge(Clock)) #1 FILTER=0;
endtask : de128

int sendix=0;

task send1(integer tn,logic expresp);
    bit [255:0] wk;
    int sendlimit;
    wk=idat[tn];
//    $display("send1 %d expresp %b expected %h @%t",tn,
//        expresp,expected[tn-2],$time);
    sendlimit=256;
    for(int sendix=0; sendix<sendlimit; sendix=sendix+1) begin
        dsamp(wk[sendix]);
    end
    if(tn>=1) begin
        setexp(expected[tn-1]);
    end
    if(expresp) begin
        forking=1;
        fork
            de128();
        join_none
        #1 forking=0;
    end
endtask : send1

int tnum;

initial begin
    logic ov=0;
    reg s1;
    @(negedge Reset) #0.1;
    tnum=0;
    while(tnum<30) begin
        $display("tnum %d size idat %d @%t",tnum,$time,len_idat);
        s1=tnum>0 && tnum!=(len_idat-1) ;
        if(tnum>=(len_idat-1)) break;
        send1(tnum,s1);
        tnum+=1;
    end
    $display("Out of tnum loop");
//    repeat(300) @(posedge Clock) #1;
    $display("\n\n\nGates ran to completion --- what happiness\n\n\n");
    $finish();


end

initial begin
    $dumpfile("filt.vcd");
    $dumplimit(1000*3000);
    $dumpvars(5,top);
end

filt f1(.Clock(Clock),.Reset(Reset),.FILTER(FILTER),
    .BitIn(BitIn),
    .Dout(Dout),.Push(Push)
);



endmodule : top

