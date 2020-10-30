`timescale 1 ns/100ps

module is61wv51216(Address,dataIO ,OE_bar,CE_bar,WE_bar,LB_bar, UB_bar);

`define tsim  400

// ********************************************************
// ****************************SIGNAL DEFINITION **********

input [18:0]    Address;
inout [15:0]    dataIO;     
input       OE_bar, CE_bar, WE_bar,     LB_bar,     UB_bar;

reg   [7:0]     mem_array_LB [512*1024-1:0];
reg   [15:8]    mem_array_UB [512*1024-1:0];
reg     [15:0]  dataOut_temp, dataIn_temp_new,  dataIn_temp_delayed ;
reg   [18:0]    addr_Read_delayed,addr_new , addr_old ; 
reg   [18:0]    addr_Write_delayed  ;   
reg     CTRL_dataOut_LB, CTRL_dataOut_UB ;

wire    [15:0]  dataIO; 
wire        tace_p,taceLB_p, taceUB_p, taa_p, tdoe_p, tsce_p, tsceUB_p, tsceLB_p, tsd_p, tpwe_p, tbaLB_p, tbaUB_p;
wire        taw_p, tlzceUB_p, tlzceLB_p, twc_p ;
wire        CEUB_bar, CELB_bar;
wire        Read_UB_cond, Read_LB_cond, Write_UB_cond, Write_LB_cond;

//**********************************************
//**************** Time constant
/*
// -8
parameter   twc     = 8  ;
parameter   tpwe    = 6.5;
parameter   tpwb    = 6.5;
parameter   tsce    = 6.5 ;
parameter   tsd     = 5  ;
parameter   trc     = 8  ;
parameter   thzwe  = 3.5;
parameter   tlzwe  = 3;
parameter   thzoe  = 3;
parameter   thzb   = 3;
parameter   tdoe    = 5.5;
parameter   tba     = 5.5;
parameter   taa     = 8;
parameter   toha    = 2.5;
parameter   taw     = 6.5;
parameter   tace    = 8;  
//parameter tlzce   = 3;
parameter   thzce   = 8;
*/
// -10
parameter   twc     = 10  ;
parameter   tpwe    = 8;
parameter   tpwb    = 8;
parameter   tsce    = 8;
parameter   tsd     = 6;
parameter   trc     = 10;
parameter   thzwe  = 5;
parameter   tlzwe  = 2;
parameter   thzoe  = 4;
parameter   thzb   = 3;
parameter   tdoe    = 6.5;
parameter   tba     = 6.5;
parameter   taa     = 10;
parameter   toha    = 2.5;
parameter   taw     = 8;
parameter   tace    = 10;  
//parameter tlzce   = 3;
parameter   thzce   = 4;

//******************* INITIALIZING ****************

initial
  begin
    addr_Read_delayed   = 0;
    addr_Write_delayed  = 0;
    addr_new        = 0;
    addr_old        = 0;
    
    dataIn_temp_new     = 16'bz;
    dataIn_temp_delayed     = 16'bz;
    CTRL_dataOut_LB     = 0;
    CTRL_dataOut_UB     = 0;
    dataOut_temp        = 16'bz;
  end


assign  CEUB_bar = CE_bar || UB_bar;  
assign  CELB_bar = CE_bar || LB_bar; 
assign Read_UB_cond     = !CEUB_bar && WE_bar && !OE_bar ;
assign Read_LB_cond     = !CELB_bar && WE_bar && !OE_bar ;
assign Write_LB_cond    = !CELB_bar && !WE_bar ;
assign Write_UB_cond    = !CEUB_bar && !WE_bar ;
assign  dataIO[7:0]  = (CTRL_dataOut_LB ) ?  dataOut_temp[7:0]  : 8'bzz ;  
assign  dataIO[15:8] = (CTRL_dataOut_UB ) ?  dataOut_temp[15:8] : 8'bzz ;  

//************************************************
//*************************** TIMER ********
//************************************************

//***** tba *****
 TimerPosEdge tbaLB_block(!LB_bar, tbaLB_p);
defparam tbaLB_block.timePeriod = tba ;
 TimerPosEdge tbaUB_block(!UB_bar, tbaUB_p);
defparam tbaUB_block.timePeriod = tba ;

//***** tdoe *****
 TimerPosEdge tdoe_block(!OE_bar, tdoe_p);
defparam tdoe_block.timePeriod = tdoe ;

//**** tsce ****
 TimerPosEdge tsce_block(!CE_bar, tsce_p);
defparam tsce_block.timePeriod = tsce ;

 TimerPosEdge tsceUB_block(!CEUB_bar, tsceUB_p);
defparam tsceUB_block.timePeriod = tsce ;

 TimerPosEdge tsceLB_block(!CELB_bar, tsceLB_p);
defparam tsceLB_block.timePeriod = tsce ;

//****** tace
  TimerPosEdge tace_block(!CE_bar, tace_p);
 defparam tace_block.timePeriod = tace ;

 
 TimerPosEdge taceUB_block(!CEUB_bar, taceUB_p);
defparam taceUB_block.timePeriod = tace ;
 TimerPosEdge taceLB_block (!CELB_bar, taceLB_p);
defparam taceLB_block.timePeriod = tace ;

//****** tpwe
 TimerPosEdge tpwe_block(!WE_bar, tpwe_p);
defparam tpwe_block.timePeriod = tpwe ;

//*** taw
 TimerChangeLevel taw_block(Address, taw_p);
defparam taw_block.timePeriod = taw ;

//*** taa
TimerChangeLevel taa_block (Address, taa_p);
defparam taa_block.timePeriod = taa ;

//*** twc
TimerChangeLevel twc_block (Address, twc_p);
defparam twc_block.timePeriod = twc ;

//*** tsd 
TimerChangeLevel tsd_block (dataIO, tsd_p);
defparam tsd_block.timePeriod = tsd ;
defparam tsd_block.sigWidth = 16 ;

// ************* data and address buffer
always@(dataIO)
begin
    dataIn_temp_new     <= dataIO;
end
always@(Address)
begin
    #0.1 addr_new   <= Address; 
end 
always @(posedge tsd_p)
begin
    dataIn_temp_delayed <= dataIn_temp_new ;
end
always @(posedge taw_p)
begin
    addr_Write_delayed <= addr_new ;
end
always @(posedge taa_p )
begin
    addr_Read_delayed <= addr_new ;
end


//*****************************************
//*************** READ CYCLE  
//****** WE_bar = 1, OE_bar = 0, CE_bar = 0, UB_bar =0 or LB_bar =0
//****************************************

//**** copy data from Sram to dataOut_temp

always@(Read_UB_cond or Address or addr_Read_delayed or tdoe_p or taa_p or taceUB_p) 
begin
    if (Read_UB_cond && taa_p && taceUB_p)
        dataOut_temp[15:8]      <= mem_array_UB[addr_Read_delayed] ;
end
always@(Read_LB_cond or Address or addr_Read_delayed or tdoe_p or taa_p or taceLB_p) 
begin
    if (Read_LB_cond && taa_p && taceLB_p)
        dataOut_temp[7:0]   <= mem_array_LB[addr_Read_delayed] ;
end

//******** control to open the data output gate 
always@(Read_UB_cond or tace_p or tdoe_p or tbaUB_p)    
begin
    if( Read_UB_cond && tace_p && tdoe_p && tbaUB_p) // UB on
        CTRL_dataOut_UB <= 1'b1;
end
always@(Read_LB_cond or tace_p or tdoe_p or tbaLB_p)        
begin
    if( Read_LB_cond && tace_p && tdoe_p && tbaLB_p) // LB on
        CTRL_dataOut_LB <= 1'b1;
end

//**** control to close data output at the end of reading period
always @ (posedge UB_bar )
begin
    #thzb   CTRL_dataOut_UB <= 1'b0;
end 
always @ (posedge LB_bar )
begin
    #thzb   CTRL_dataOut_LB <= 1'b0;
end
always @ (posedge CE_bar )
begin
    #thzce  begin   CTRL_dataOut_LB <= 1'b0;
            CTRL_dataOut_UB <= 1'b0;
        end 
end
always @ (negedge WE_bar )
begin
    #tlzwe  begin   CTRL_dataOut_LB <= 1'b0;
            CTRL_dataOut_UB <= 1'b0;
        end
end

always @ (posedge OE_bar )
begin
    #thzoe begin 
            CTRL_dataOut_UB <= 1'b0;
            CTRL_dataOut_LB <= 1'b0;
        end
end

//*****************************************
//*************** WRITE CYCLE  
//****************************************

always@(CE_bar or WE_bar or Address or dataIO or tsce_p or  tpwe_p or twc_p)
begin
    if (  tsceUB_p && tpwe_p && twc_p)

        mem_array_UB[addr_Write_delayed]    <= dataIn_temp_delayed[15:8] ; 
    if (  tsceLB_p && tpwe_p && twc_p)
        mem_array_LB[addr_Write_delayed]    <= dataIn_temp_delayed[7:0] ;
end

endmodule

//********************************************************
//*************************  TIMER BLOCKS  ***************
//********************************************************


//****** TimerChangeLevel Block ******

module TimerChangeLevel(sig, timerOut);

parameter sigWidth = 19;
parameter timePeriod = 3;

input [sigWidth -1 :0]      sig;
output              timerOut;
reg                 timerOut;
realtime            time_start;

initial
begin
    timerOut =0;
end

always@(sig)
begin
    time_start <= $realtime;
    #timePeriod     if ($realtime >= (time_start + timePeriod)) timerOut <= 1;
            else timerOut <= 0;
end

always@(sig)
begin
    #0.1 timerOut <=0;
end


endmodule

 //*******  TimerPosEdge    *******

module TimerPosEdge(sig, timerOut);

input       sig;
output      timerOut;
reg         timerOut;
realtime    time_start;

parameter timePeriod = 3;

initial
begin
    timerOut =0;

end

always@(posedge sig)
begin
    time_start <= $realtime;
    timerOut <=0;
    #timePeriod     if (sig && ($realtime >= (time_start + timePeriod))) timerOut <= 1;
            else timerOut <= 0;
end

always @ (negedge sig)
begin
    #0.1 timerOut <=0;
end

endmodule

