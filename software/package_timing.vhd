--************************************************************************
--**    MODEL   :       package_timing.vhd                              **
--**    COMPANY :       Cypress Semiconductor                           **
--**    REVISION:       1.0 (Created new timing package model)          ** 
--************************************************************************


library IEEE,std;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use ieee.std_logic_textio.all ;
use std.textio.all ;

--****************************************************************

package package_timing is

FUNCTION tRC_Time(S : IN INTEGER) RETURN TIME;
FUNCTION tAA_Time(S : IN INTEGER) RETURN TIME;
FUNCTION tACE_Time(S : IN INTEGER) RETURN TIME;
FUNCTION tOHA_Time(S : IN INTEGER) RETURN TIME;
FUNCTION tDOE_Time(S : IN INTEGER) RETURN TIME;
FUNCTION tLZOE_Time(S : IN INTEGER) RETURN TIME;
FUNCTION tHZOE_Time(S : IN INTEGER) RETURN TIME;
FUNCTION tLZCE_Time(S : IN INTEGER) RETURN TIME;
FUNCTION tHZCE_Time(S : IN INTEGER) RETURN TIME;
FUNCTION tDBE_Time(S : IN INTEGER) RETURN TIME;
FUNCTION tLZBE_Time(S : IN INTEGER) RETURN TIME;
FUNCTION tHZBE_Time(S : IN INTEGER) RETURN TIME;
FUNCTION tSCE_Time(S : IN INTEGER) RETURN TIME;
FUNCTION tAW_Time(S : IN INTEGER) RETURN TIME;
FUNCTION tHA_tSA_Time(S : IN INTEGER) RETURN TIME;
FUNCTION tPWE_Time(S : IN INTEGER) RETURN TIME;
FUNCTION tBW_Time(S : IN INTEGER) RETURN TIME;
FUNCTION tSD_Time(S : IN INTEGER) RETURN TIME;
FUNCTION tHD_Time(S : IN INTEGER) RETURN TIME;
FUNCTION tHZWE_Time(S : IN INTEGER) RETURN TIME;
FUNCTION tLZWE_Time(S : IN INTEGER) RETURN TIME;

------------------------------------------------------------------------------------------------
-- Deep sleep mode timing
------------------------------------------------------------------------------------------------
constant    tCEDS  : TIME      :=   100 ns;   -- Time between Deassertion of CE (CE High) and assertion of DS (DS Low)
constant    tDS    : TIME      :=    1 ms;    -- DS assertion (DS Low) to deep sleep mode transition time
constant    tDSCE  : TIME      :=    1 ms;    -- Time between Deassertion of DS (DS High) and assertion of CE (CE Low)
constant    tHA    :   TIME    :=   0 ns;
constant    tHD    :   TIME    :=   0 ns;
end package_timing;


package body package_timing is
  
FUNCTION tRC_Time(S : IN INTEGER) RETURN TIME is

VARIABLE    tRC    :   TIME    :=   15 ns;     --   Read Cycle Time

BEGIN
IF (S = 1) THEN
  tRC    :=   15 ns;	    
ELSIF(S = 2) THEN
  tRC := 10 ns;
ELSIF(S = 3) THEN
  tRC := 45 ns;
ELSIF(S = 4) THEN
  tRC := 55 ns;
ELSIF(S = 5) THEN
  tRC := 15 ns;
END IF;
RETURN tRC;
END tRC_Time;  

FUNCTION tAA_Time(S : IN INTEGER) RETURN TIME is

VARIABLE    tAA    :   TIME    :=   15 ns;     --   Address to Data

BEGIN
IF (S = 1) THEN
  tAA    :=   15 ns;	    
ELSIF(S = 2) THEN
  tAA := 10 ns;
ELSIF(S = 3) THEN
  tAA := 45 ns;
ELSIF(S = 4) THEN
  tAA := 55 ns;
ELSIF(S = 5) THEN
  tAA := 15 ns;
END IF;
RETURN tAA;
END tAA_Time; 

FUNCTION tOHA_Time(S : IN INTEGER) RETURN TIME is

VARIABLE    tOHA    :   TIME    :=   3 ns;     --   Data Hold

BEGIN
IF (S = 1) THEN
  tOHA    :=   3 ns;	    
ELSIF(S = 2) THEN
  tOHA := 3 ns;
ELSIF(S = 3) THEN
  tOHA := 10 ns;
ELSIF(S = 4) THEN
  tOHA := 10 ns;
ELSIF(S = 5) THEN
  tOHA := 3 ns;
END IF;
RETURN tOHA;
END tOHA_Time;

FUNCTION tACE_Time(S : IN INTEGER) RETURN TIME is

VARIABLE    tACE    :   TIME    :=   15 ns;     --   Chip Enable to DATA

BEGIN
IF (S = 1) THEN
  tACE    :=   15 ns;	    
ELSIF(S = 2) THEN
  tACE := 10 ns;
ELSIF(S = 3) THEN
  tACE := 45 ns;
ELSIF(S = 4) THEN
  tACE := 55 ns;
ELSIF(S = 5) THEN
  tACE := 15 ns;
END IF;
RETURN tACE;
END tACE_Time; 

FUNCTION tDOE_Time(S : IN INTEGER) RETURN TIME is

VARIABLE    tDOE    :   TIME    :=   15 ns;     --   Output Enable to DATA

BEGIN
IF (S = 1) THEN
  tDOE    :=   8 ns;	    
ELSIF(S = 2) THEN
  tDOE := 5 ns;
ELSIF(S = 3) THEN
  tDOE := 22 ns;
ELSIF(S = 4) THEN
  tDOE := 25 ns;
ELSIF(S = 5) THEN
  tDOE := 7 ns;
END IF;
RETURN tDOE;
END tDOE_Time;

FUNCTION tLZOE_Time(S : IN INTEGER) RETURN TIME is

VARIABLE    tLZOE    :   TIME    :=   15 ns;     --   OE low to low Z

BEGIN
IF (S = 1) THEN
  tLZOE    :=   1 ns;	    
ELSIF(S = 2) THEN
  tLZOE := 0 ns;
ELSIF(S = 3) THEN
  tLZOE := 5 ns;
ELSIF(S = 4) THEN
  tLZOE := 5 ns;
ELSIF(S = 5) THEN
  tLZOE := 0 ns;
END IF;
RETURN tLZOE;
END tLZOE_Time; 

FUNCTION tHZOE_Time(S : IN INTEGER) RETURN TIME is

VARIABLE    tHZOE    :   TIME    :=   8 ns;     --   OE low to low Z

BEGIN
IF (S = 1) THEN
  tHZOE    :=   8 ns;	    
ELSIF(S = 2) THEN
  tHZOE := 5 ns;
ELSIF(S = 3) THEN
  tHZOE := 18 ns;
ELSIF(S = 4) THEN
  tHZOE := 18 ns;
ELSIF(S = 5) THEN
  tHZOE := 7 ns;
END IF;
RETURN tHZOE;
END tHZOE_Time;

FUNCTION tLZCE_Time(S : IN INTEGER) RETURN TIME is

VARIABLE    tLZCE    :   TIME    :=   3 ns;     --   OE low to low Z

BEGIN
IF (S = 1) THEN
  tLZCE    :=   3 ns;	    
ELSIF(S = 2) THEN
  tLZCE := 3 ns;
ELSIF(S = 3) THEN
  tLZCE := 10 ns;
ELSIF(S = 4) THEN
  tLZCE := 10 ns;
ELSIF(S = 5) THEN
  tLZCE := 3 ns;
END IF;
RETURN tLZCE;
END tLZCE_Time; 

FUNCTION tHZCE_Time(S : IN INTEGER) RETURN TIME is

VARIABLE    tHZCE    :   TIME    :=   8 ns;     --   OE low to low Z

BEGIN
IF (S = 1) THEN
  tHZCE    :=   8 ns;	    
ELSIF(S = 2) THEN
  tHZCE := 5 ns;
ELSIF(S = 3) THEN
  tHZCE := 18 ns;
ELSIF(S = 4) THEN
  tHZCE := 18 ns;
ELSIF(S = 5) THEN
  tHZCE := 7 ns;
END IF;
RETURN tHZCE;
END tHZCE_Time;  

FUNCTION tDBE_Time(S : IN INTEGER) RETURN TIME is

VARIABLE    tDBE    :   TIME    :=   8 ns;     --   OE low to low Z

BEGIN
IF (S = 1) THEN
  tDBE    :=   8 ns;	    
ELSIF(S = 2) THEN
  tDBE := 5 ns;
ELSIF(S = 3) THEN
  tDBE := 45 ns;
ELSIF(S = 4) THEN
  tDBE := 55 ns;
ELSIF(S = 5) THEN
  tDBE := 7 ns;
END IF;
RETURN tDBE;
END tDBE_Time;  

FUNCTION tLZBE_Time(S : IN INTEGER) RETURN TIME is

VARIABLE    tLZBE    :   TIME    :=   1 ns;     --   OE low to low Z

BEGIN
IF (S = 1) THEN
  tLZBE    :=   1 ns;	    
ELSIF(S = 2) THEN
  tLZBE := 0 ns;
ELSIF(S = 3) THEN
  tLZBE := 10 ns;
ELSIF(S = 4) THEN
  tLZBE := 5 ns;
ELSIF(S = 5) THEN
  tLZBE := 0 ns;
END IF;
RETURN tLZBE;
END tLZBE_Time;

FUNCTION tHZBE_Time(S : IN INTEGER) RETURN TIME is

VARIABLE    tHZBE    :   TIME    :=   8 ns;     --   OE low to low Z

BEGIN
IF (S = 1) THEN
  tHZBE    :=   8 ns;	    
ELSIF(S = 2) THEN
  tHZBE := 6 ns;
ELSIF(S = 3) THEN
  tHZBE := 18 ns;
ELSIF(S = 4) THEN
  tHZBE := 5 ns;
ELSIF(S = 5) THEN
  tHZBE := 7 ns;
END IF;
RETURN tHZBE;
END tHZBE_Time;

FUNCTION tSCE_Time(S : IN INTEGER) RETURN TIME is

VARIABLE    tSCE    :   TIME    :=   12 ns;     --   OE low to low Z

BEGIN
IF (S = 1) THEN
  tSCE    :=   12 ns;	    
ELSIF(S = 2) THEN
  tSCE := 7 ns;
ELSIF(S = 3) THEN
  tSCE := 35 ns;
ELSIF(S = 4) THEN
  tSCE := 40 ns;
ELSIF(S = 5) THEN
  tSCE := 12 ns;
END IF;
RETURN tSCE;
END tSCE_Time;  

FUNCTION tAW_Time(S : IN INTEGER) RETURN TIME is

VARIABLE    tAW    :   TIME    :=   12 ns;     --   OE low to low Z

BEGIN
IF (S = 1 or S = 5) THEN
  tAW    :=   12 ns;	    
ELSIF(S = 2) THEN
  tAW := 7 ns;
ELSIF(S = 3) THEN
  tAW := 35 ns;
ELSE
  tAW := 40 ns;
END IF;
RETURN tAW;
END tAW_Time;  

FUNCTION tHA_tSA_Time(S : IN INTEGER) RETURN TIME is

VARIABLE    tHA    :   TIME    :=   0 ns;     --   OE low to low Z
VARIABLE    tSA    :   TIME    :=   0 ns;
BEGIN

RETURN tHA;
END tHA_tSA_Time;

FUNCTION tPWE_Time(S : IN INTEGER) RETURN TIME is

VARIABLE    tPWE    :   TIME    :=   12 ns;     --   OE low to low Z

BEGIN
IF (S = 1 or S = 5) THEN
  tPWE    :=   12 ns;	    
ELSIF(S = 2) THEN
  tPWE := 7 ns;
ELSIF(S = 3) THEN
  tPWE := 35 ns;
ELSE
  tPWE := 40 ns;
END IF;
RETURN tPWE;
END tPWE_Time;


FUNCTION tSD_Time(S : IN INTEGER) RETURN TIME is

VARIABLE    tSD    :   TIME    :=   8 ns;     --   OE low to low Z

BEGIN -- (tSD -1) inorder to take care of a subtraction in the main model
IF (S = 1) THEN
  tSD    :=   7 ns;	    
ELSIF(S = 2) THEN
  tSD := 4 ns;
ELSIF(S = 3) THEN
  tSD := 24 ns;
ELSIF(S = 4) THEN
  tSD := 24 ns;
ELSIF(S = 5) THEN
  tSD := 8 ns;
END IF;
RETURN tSD;
END tSD_Time;

FUNCTION tHD_Time(S : IN INTEGER) RETURN TIME is

VARIABLE    tHD    :   TIME    :=   0 ns;     --   OE low to low Z

BEGIN

RETURN tHD;
END tHD_Time;

FUNCTION tBW_Time(S : IN INTEGER) RETURN TIME is

VARIABLE    tBW    :   TIME    :=   12 ns;     --   OE low to low Z

BEGIN
IF (S = 1 or S = 5) THEN
  tBW    :=   12 ns;	    
ELSIF(S = 2) THEN
  tBW := 7 ns;
ELSIF(S = 3) THEN
  tBW := 35 ns;
ELSE
  tBW := 40 ns;
END IF;
RETURN tBW;
END tBW_Time;

FUNCTION tLZWE_Time(S : IN INTEGER) RETURN TIME is

VARIABLE    tLZWE    :   TIME    :=   3 ns;     --   OE low to low Z

BEGIN
IF (S = 1 or S = 5) THEN
  tLZWE    :=   3 ns;	    
ELSIF(S = 2) THEN
  tLZWE := 3 ns;
ELSIF(S = 3) THEN
  tLZWE := 10 ns;
ELSE
  tLZWE := 10 ns;
END IF;
RETURN tLZWE;
END tLZWE_Time;

FUNCTION tHZWE_Time(S : IN INTEGER) RETURN TIME is

VARIABLE    tHZWE    :   TIME    :=   8 ns;     --   OE low to low Z

BEGIN
IF (S = 1) THEN
  tHZWE    :=   8 ns;	    
ELSIF(S = 2) THEN
  tHZWE := 5 ns;
ELSIF(S = 3) THEN
  tHZWE := 18 ns;
ELSIF(S = 4) THEN
  tHZWE := 20 ns;
ELSIF(S = 5) THEN
  tHZWE := 7 ns;
END IF;
RETURN tHZWE;
END tHZWE_Time;


end package_timing;
