--************************************************************************
--**    MODEL   :       mobl_1Mx16.vhd     	                         **
--**    COMPANY :       Cypress Semiconductor                           **
--**    REVISION:       1.0 Created new base model		                    ** 
--************************************************************************

Library IEEE,work;
Use IEEE.Std_Logic_1164.All;
use IEEE.Std_Logic_unsigned.All;

use work.package_timing.all;
use work.package_utility.all;

------------------------
-- Entity Description
------------------------

Entity mobl_1Mx16 is
generic
	(ADDR_BITS			: integer := 19;
	DATA_BITS			 : integer := 16;
	depth 				 : integer := 524288;
	
	TimingInfo			: BOOLEAN := TRUE;
	TimingChecks	: std_logic := '1'
	);
Port (
    Model  : IN integer;
    CE_b   : IN Std_Logic;	                                                -- Chip Enable CE#
    WE_b  	: IN Std_Logic;	                                                -- Write Enable WE#
    OE_b  	: IN Std_Logic;                                                 -- Output Enable OE#
    BHE_b		: IN std_logic;                                                 -- Byte Enable High BHE#
    BLE_b  : IN std_logic;                                                 -- Byte Enable Low BLE#
   	DS_b   : IN std_logic;                                                 --Deep sleep Enable DS#
    A 			  : IN Std_Logic_Vector(ADDR_BITS-1 downto 0);                    -- Address Inputs A
    DQ			  : INOUT Std_Logic_Vector(DATA_BITS-1 downto 0):=(others=>'Z');   -- Read/Write Data IO	 
	 ERR				: OUT std_logic --ERR output pin
    ); 
End mobl_1Mx16;

-----------------------------
-- End Entity Description
-----------------------------
-----------------------------
-- Architecture Description
-----------------------------

Architecture behave_arch Of mobl_1Mx16 Is

Type mem_array_type Is array (depth-1 downto 0) of std_logic_vector(DATA_BITS-1 downto 0);
Type mem_backup_type is array (depth-1 downto 0) of std_logic_vector(DATA_BITS-1 downto 0);

signal ce_bhe_ble_combined_b : std_logic; -- for byte power down

signal write_enable : std_logic;
signal read_enable : std_logic;

signal data_skew : Std_Logic_Vector(DATA_BITS-1 downto 0);

signal address_internal: Std_Logic_Vector(addr_bits-1 downto 0);

signal tSD_dataskew : time := tSD_Time(Model) - 1 ns;

signal sleep_flag : BOOLEAN := FALSE ; --added by PURU

signal ERR_Address , ERR_location : std_logic_vector(3 downto 0):= "0000";
signal count : std_logic_vector(2 downto 0) := "000";
--signal DS_b : std_logic := '1';

begin

tSD_dataskew <= tSD_Time(Model);

ce_bhe_ble_combined_b <= CE_b or BHE_b or BLE_b; 
write_enable <= not(CE_b) and not(WE_b) and not(BHE_b and BLE_b);
read_enable <= not(CE_b) and (WE_b) and not(OE_b) and not(BHE_b and BLE_b);

data_skew <= DQ after 1 ns;

process (OE_b)
begin
    if (OE_b'event and OE_b = '1' and write_enable /= '1') then
        DQ <=(others=>'Z') after tHZOE_Time(Model);
		  ERR <= 'Z' after tHZOE_Time(Model);
    end if;
end process;

process (CE_b)
begin
    if (CE_b'event and CE_b = '1') then
        DQ <=(others=>'Z') after tHZCE_Time(Model); 
		  ERR <= 'Z' after tHZCE_Time(Model);
    end if;
end process;

-----------
process (DS_b)
begin
    if (DS_b'event and DS_b ='0' and CE_b = '1' and now - CE_b'last_event = tCEDS) then -- PURU
		    sleep_flag <= TRUE after tDS;
		if (now - OE_b'last_event < tDS) then 
		    assert FALSE
		    report "toggling of OE pin not allowed in this reigon"
		    severity error;
		end if;
		if (now - BLE_b'last_event < tDS) then 
		     assert FALSE
		     report "toggling of BLE pin not allowed in this reigon"
		     severity error;
		end if;
		if (now - BHE_b'last_event < tDS) then 
		     assert FALSE
		     report "toggling of BHE pin not allowed in this reigon"
		     severity error;
		end if;
		if (now - WE_b'last_event < tDS) then 
		     assert FALSE
		     report "toggling of WE pin not allowed in this reigon"
		     severity error;
		end if;
		if (now - DQ'last_event < tDS) then 
		     assert FALSE
		     report "toggling of Data not allowed in this reigon"
		     severity error;
		end if;
		if (now - A'last_event < tDS) then 
		     assert FALSE
		     report "toggling of Address lines not allowed in this reigon"
		     severity error;
		end if;
		   
	elsif (DS_b'event and DS_b ='1') then
	      sleep_flag <= FALSE;
		if (CE_b'event and CE_b = '0' and now - DS_b'last_event < tDSCE) then
            assert FALSE
			report "Deep sleep mode error"
            severity error;			
		end if;
		
	elsif (DS_b = '0' and CE_b = '0') then 
	    assert FALSE
		report "Invalid Mode"
		severity Error;
	else	
        assert TRUE;	
	end if;
end process;
-----------

process (write_enable'delayed(tHA))
begin
    if (write_enable'delayed(tHA) = '0' and TimingInfo) then
	assert (A'last_event = 0 ns) or (A'last_event > tHA_tSA_Time(Model))
	report "Address hold time violated";
    end if;
end process;

process (write_enable'delayed(tHD))
begin
    if (write_enable'delayed(tHD) = '0' and TimingInfo) then
	assert (DQ'last_event > tHD_Time(Model)) or (DQ'last_event = 0 ns)
	report "Data hold time tHD_Time(Model) violated";
    end if;
end process;

-- main process
process
    
VARIABLE mem_array: mem_array_type;
VARIABLE mem_backup : mem_backup_type;

--- Variables for timing checks
VARIABLE tPWE_chk : TIME := -10 ns;
VARIABLE tAW_chk : TIME := -10 ns;
VARIABLE tSD_chk : TIME := -10 ns;
VARIABLE tRC_chk : TIME := 0 ns;
VARIABLE tBAW_chk : TIME := 0 ns;
VARIABLE tBBW_chk : TIME := 0 ns;
VARIABLE tBCW_chk : TIME := 0 ns;
VARIABLE tBDW_chk : TIME := 0 ns;

VARIABLE write_flag : BOOLEAN := TRUE;

VARIABLE accesstime : TIME := 0 ns;
    
begin
        ----write or read should not happen if device is in deep sleep mode i;e sleep_flag = TRUE	
	if(sleep_flag) then
       assert TRUE;	  
		--write or read should happen only if device is not in deep sleep mode i;e sleep_flag = FALSE
	else
    -- start of write
    if (write_enable = '1' and write_enable'event) then
             
       DQ(DATA_BITS-1 downto 0)<=(others=>'Z') after tHZWE_Time(Model);
		 ERR <= 'Z' after tHZWE_Time(Model);
       if (A'last_event >= tHA_tSA_Time(Model)) then
          address_internal <= A;
          tPWE_chk := NOW;
          tAW_chk := A'last_event;
          write_flag := TRUE;

       else
          if (TimingInfo) then
		       assert FALSE
		       report "Address setup violated";
	       end if;
          write_flag := FALSE;

       end if;   
    
    -- end of write (with CE high or WE high)
    elsif (write_enable = '0' and write_enable'event) then

        --- check for pulse width
        if (NOW - tPWE_chk >= tPWE_Time(Model) or NOW - tPWE_chk <= 0.1 ns or NOW = 0 ns) then
            --- pulse width OK, do nothing
        else
      	   if (TimingInfo) then
           	assert FALSE
		      report "Pulse Width violation";
	       end if;
	     
	     write_flag := FALSE;
	     end if;
        
        --- check for address setup with write end, i.e., tAW_Time(Model)
        if (NOW - tAW_chk >= tAW_Time(Model) or NOW = 0 ns) then
            --- tAW_Time(Model) OK, do nothing
        else
      	   if (TimingInfo) then
	         assert FALSE
		      report "Address setup tAW_Time(Model) violation";
	       end if;

          write_flag := FALSE;
        end if;
        
        --- check for data setup with write end, i.e., tSD_Time(Model)
        if (NOW - tSD_chk >= tSD_dataskew or NOW = 0 ns) then
            --- tSD_Time(Model) OK, do nothing
        else
      	   if (TimingInfo) then
	          assert FALSE
	   	      report "Data setup tSD_Time(Model) violation";
	       end if;
          write_flag := FALSE;
        end if;
        
        -- perform write operation if no violations
        if (write_flag = TRUE) then

            if (BLE_b = '1' and BLE_b'last_event = write_enable'last_event and NOW /= 0 ns) then
            	mem_array(conv_integer1(address_internal))(7 downto 0) := data_skew(7 downto 0);
					if(ERR_Address = address_internal(3 downto 0) and ERR_location > "0111") then
						mem_backup(conv_integer1(address_internal))(7 downto 0) := data_skew(7 downto 0);
					elsif(ERR_Address = address_internal(3 downto 0) and ERR_location = "0111") then
--						ERR <= '1';
						mem_backup(conv_integer1(address_internal))(6 downto 0) := data_skew(6 downto 0);
						mem_backup(conv_integer1(address_internal))(7) := not(data_skew(7));
					elsif(ERR_Address = address_internal(3 downto 0) and ERR_location = "0000") then
--						ERR <= '1';
						mem_backup(conv_integer1(address_internal))(7 downto 1) := data_skew(7 downto 1);
						mem_backup(conv_integer1(address_internal))(0) := not(data_skew(0));
					elsif((ERR_Address = address_internal(3 downto 0)) and (ERR_location < "0111") and (ERR_location > "0000")) then
--						ERR <= '1';
						mem_backup(conv_integer1(address_internal))(conv_integer1(ERR_location - 1) downto 0) := data_skew(conv_integer1(ERR_location - 1) downto 0);
						mem_backup(conv_integer1(address_internal))(conv_integer1(ERR_location)) := not(data_skew(conv_integer1(ERR_location)));
						mem_backup(conv_integer1(address_internal))(7 downto conv_integer1(ERR_location + 1)) := data_skew(7 downto conv_integer1(ERR_location + 1));
					else
						mem_backup(conv_integer1(address_internal))(7 downto 0) := data_skew(7 downto 0);
					end if;
            end if;
            
            if (BHE_b = '1' and BHE_b'last_event = write_enable'last_event and NOW /= 0 ns) then
            	mem_array(conv_integer1(address_internal))(15 downto 8) := data_skew(15 downto 8);
					if(ERR_Address = address_internal(3 downto 0) and ERR_location < "1000") then
						mem_backup(conv_integer1(address_internal))(15 downto 8) := data_skew(15 downto 8);
					elsif(ERR_Address = address_internal(3 downto 0) and ERR_location = "1111") then
--						ERR <= '1';
						mem_backup(conv_integer1(address_internal))(14 downto 8) := data_skew(14 downto 8);
						mem_backup(conv_integer1(address_internal))(15) := not(data_skew(15));
					elsif(ERR_Address = address_internal(3 downto 0) and ERR_location = "1000") then
--						ERR <= '1';
						mem_backup(conv_integer1(address_internal))(15 downto 9) := data_skew(15 downto 9);
						mem_backup(conv_integer1(address_internal))(8) := not(data_skew(8));
					elsif((ERR_Address = address_internal(3 downto 0)) and (ERR_location < "1111") and (ERR_location > "1000")) then
--						ERR <= '1';
						mem_backup(conv_integer1(address_internal))(conv_integer1(ERR_location - 1) downto 8) := data_skew(conv_integer1(ERR_location - 1) downto 8);
						mem_backup(conv_integer1(address_internal))(conv_integer1(ERR_location)) := not(data_skew(conv_integer1(ERR_location)));
						mem_backup(conv_integer1(address_internal))(15 downto conv_integer1(ERR_location + 1)) := data_skew(15 downto conv_integer1(ERR_location + 1));
					else
						mem_backup(conv_integer1(address_internal))(15 downto 8) := data_skew(15 downto 8);
					end if;
            end if;

            if (BLE_b = '0' and NOW - tBAW_chk >= tBW_Time(Model)) then
            	mem_array(conv_integer1(address_internal))(7 downto 0) := data_skew(7 downto 0);
					if(ERR_Address = address_internal(3 downto 0) and ERR_location > "0111") then
						mem_backup(conv_integer1(address_internal))(7 downto 0) := data_skew(7 downto 0);
					elsif(ERR_Address = address_internal(3 downto 0) and ERR_location = "0111") then
--						ERR <= '1';
						mem_backup(conv_integer1(address_internal))(6 downto 0) := data_skew(6 downto 0);
						mem_backup(conv_integer1(address_internal))(7) := not(data_skew(7));
					elsif(ERR_Address = address_internal(3 downto 0) and ERR_location = "0000") then
--						ERR <= '1';
						mem_backup(conv_integer1(address_internal))(7 downto 1) := data_skew(7 downto 1);
						mem_backup(conv_integer1(address_internal))(0) := not(data_skew(0));
					elsif((ERR_Address = address_internal(3 downto 0)) and (ERR_location < "1111") and (ERR_location > "1000")) then
--						ERR <= '1';
						mem_backup(conv_integer1(address_internal))(conv_integer1(ERR_location - 1) downto 0) := data_skew(conv_integer1(ERR_location - 1) downto 0);
						mem_backup(conv_integer1(address_internal))(conv_integer1(ERR_location)) := not(data_skew(conv_integer1(ERR_location)));
						mem_backup(conv_integer1(address_internal))(7 downto conv_integer1(ERR_location + 1)) := data_skew(7 downto conv_integer1(ERR_location + 1));
					else
						mem_backup(conv_integer1(address_internal))(7 downto 0) := data_skew(7 downto 0);
					end if;
            elsif (NOW - tBAW_chk < tBW_Time(Model) and NOW - tBAW_chk > 0.1 ns and NOW > 0 ns) then
            	assert FALSE report "Insufficient pulse width for lower byte to be written";
            end if;
            	
            if (BHE_b = '0' and NOW - tBBW_chk >= tBW_Time(Model)) then
            	mem_array(conv_integer1(address_internal))(15 downto 8) := data_skew(15 downto 8);
					if(ERR_Address = address_internal(3 downto 0) and ERR_location < "1000") then
						mem_backup(conv_integer1(address_internal))(15 downto 8) := data_skew(15 downto 8);
					elsif(ERR_Address = address_internal(3 downto 0) and ERR_location = "1111") then
--						ERR <= '1';
						mem_backup(conv_integer1(address_internal))(14 downto 8) := data_skew(14 downto 8);
						mem_backup(conv_integer1(address_internal))(15) := not(data_skew(15));
					elsif(ERR_Address = address_internal(3 downto 0) and ERR_location = "1000") then
--						ERR <= '1';
						mem_backup(conv_integer1(address_internal))(15 downto 9) := data_skew(15 downto 9);
						mem_backup(conv_integer1(address_internal))(8) := not(data_skew(8));
					elsif((ERR_Address = address_internal(3 downto 0)) and (ERR_location < "1111") and (ERR_location > "1000")) then
--						ERR <= '1';
						mem_backup(conv_integer1(address_internal))(conv_integer1(ERR_location - 1) downto 8) := data_skew(conv_integer1(ERR_location - 1) downto 8);
						mem_backup(conv_integer1(address_internal))(conv_integer1(ERR_location)) := not(data_skew(conv_integer1(ERR_location)));
						mem_backup(conv_integer1(address_internal))(15 downto conv_integer1(ERR_location + 1)) := data_skew(15 downto conv_integer1(ERR_location + 1));
					else
						mem_backup(conv_integer1(address_internal))(15 downto 8) := data_skew(15 downto 8);
					end if;
            elsif (NOW - tBBW_chk < tBW_Time(Model) and NOW - tBBW_chk > 0.1 ns and NOW > 0 ns) then
            	assert FALSE report "Insufficient pulse width for higher byte to be written";
            end if;

        end if; 
    -- end of write (with BLE high)
    elsif (BLE_b'event and not(BHE_b'event) and write_enable = '1') then
    
       if (BLE_b = '0') then
     
      	   --- Reset timing variables
          tAW_chk := A'last_event;
          tBAW_chk := NOW;
          write_flag := TRUE;
     
       elsif (BLE_b = '1') then
        
          --- check for pulse width
          if (NOW - tPWE_chk >= tPWE_Time(Model)) then
            --- tPWE_Time(Model) OK, do nothing
          else
      	      if (TimingInfo) then
            	   assert FALSE
		          report "Pulse Width violation";
	          end if;

	          write_flag := FALSE;
	       end if;
        
           --- check for address setup with write end, i.e., tAW_Time(Model)
           if (NOW - tAW_chk >= tAW_Time(Model)) then
            --- tAW_Time(Model) OK, do nothing
           else
      	       if (TimingInfo) then
	              assert FALSE
		           report "Address setup tAW_Time(Model) violation for Lower Byte Write";
	           end if;

              write_flag := FALSE;
           end if;
	
           --- check for byte write setup with write end, i.e., tBW_Time(Model)
           if (NOW - tBAW_chk >= tBW_Time(Model)) then
            --- tBW_Time(Model) OK, do nothing
           else
      	       if (TimingInfo) then
                 assert FALSE
		           report "Lower Byte setup tBW_Time(Model) violation";
	           end if;

              write_flag := FALSE;
           end if;
	
	        --- check for data setup with write end, i.e., tSD_Time(Model)
           if (NOW - tSD_chk >= tSD_dataskew or NOW = 0 ns) then            
            --- tSD_Time(Model) OK, do nothing
           else
      	       if (TimingInfo) then
	              assert FALSE
	   	          report "Data setup tSD_Time(Model) violation for Lower Byte Write";
	           end if;
           
              write_flag := FALSE;
           end if;
	
	        --- perform WRITE operation if no violations
	        if (write_flag = TRUE) then
	           mem_array(conv_integer1(address_internal))(7 downto 0) := data_skew(7 downto 0);
				  if(ERR_Address = address_internal(3 downto 0) and ERR_location > "0111") then
						mem_backup(conv_integer1(address_internal))(7 downto 0) := data_skew(7 downto 0);
					elsif(ERR_Address = address_internal(3 downto 0) and ERR_location = "0111") then
--						ERR <= '1';
						mem_backup(conv_integer1(address_internal))(6 downto 0) := data_skew(6 downto 0);
						mem_backup(conv_integer1(address_internal))(7) := not(data_skew(7));
					elsif(ERR_Address = address_internal(3 downto 0) and ERR_location = "0000") then
--						ERR <= '1';
						mem_backup(conv_integer1(address_internal))(7 downto 1) := data_skew(7 downto 1);
						mem_backup(conv_integer1(address_internal))(0) := not(data_skew(0));
					elsif((ERR_Address = address_internal(3 downto 0)) and (ERR_location < "1111") and (ERR_location > "1000")) then
--						ERR <= '1';
						mem_backup(conv_integer1(address_internal))(conv_integer1(ERR_location - 1) downto 0) := data_skew(conv_integer1(ERR_location - 1) downto 0);
						mem_backup(conv_integer1(address_internal))(conv_integer1(ERR_location)) := not(data_skew(conv_integer1(ERR_location)));
						mem_backup(conv_integer1(address_internal))(7 downto conv_integer1(ERR_location + 1)) := data_skew(7 downto conv_integer1(ERR_location + 1));
					else
						mem_backup(conv_integer1(address_internal))(7 downto 0) := data_skew(7 downto 0);
					end if;
              if (BHE_b = '0') then
            	    mem_array(conv_integer1(address_internal))(15 downto 8) := data_skew(15 downto 8);
						 if(ERR_Address = address_internal(3 downto 0) and ERR_location < "1000") then
							mem_backup(conv_integer1(address_internal))(15 downto 8) := data_skew(15 downto 8);
						elsif(ERR_Address = address_internal(3 downto 0) and ERR_location = "1111") then
--							ERR <= '1';
							mem_backup(conv_integer1(address_internal))(14 downto 8) := data_skew(14 downto 8);
							mem_backup(conv_integer1(address_internal))(15) := not(data_skew(15));
						elsif(ERR_Address = address_internal(3 downto 0) and ERR_location = "1000") then
--							ERR <= '1';
							mem_backup(conv_integer1(address_internal))(15 downto 9) := data_skew(15 downto 9);
							mem_backup(conv_integer1(address_internal))(8) := not(data_skew(8));
						elsif((ERR_Address = address_internal(3 downto 0)) and (ERR_location < "1111") and (ERR_location > "1000")) then
--							ERR <= '1';
							mem_backup(conv_integer1(address_internal))(conv_integer1(ERR_location - 1) downto 8) := data_skew(conv_integer1(ERR_location - 1) downto 8);
							mem_backup(conv_integer1(address_internal))(conv_integer1(ERR_location)) := not(data_skew(conv_integer1(ERR_location)));
							mem_backup(conv_integer1(address_internal))(15 downto conv_integer1(ERR_location + 1)) := data_skew(15 downto conv_integer1(ERR_location + 1));
						else
							mem_backup(conv_integer1(address_internal))(15 downto 8) := data_skew(15 downto 8);
						end if;
              end if;
	        end if;
	
   	       --- Reset timing variables
           tAW_chk := A'last_event;
           tBAW_chk := NOW;
           write_flag := TRUE;
      
      end if;

    -- end of write (with BHE high)
    elsif (BHE_b'event and not(BLE_b'event) and write_enable = '1') then

      if (BHE_b = '0') then
     
    	   --- Reset timing variables
        tAW_chk := A'last_event;
        tBBW_chk := NOW;
        write_flag := TRUE;
     
      elsif (BHE_b = '1') then
        
        --- check for pulse width
        if (NOW - tPWE_chk >= tPWE_Time(Model)) then
            --- tPWE_Time(Model) OK, do nothing
        else
      	   if (TimingInfo) then
           	assert FALSE
		      report "Pulse Width violation";
	       end if;
	     
	     write_flag := FALSE;
	     end if;
        
        --- check for address setup with write end, i.e., tAW_Time(Model)
        if (NOW - tAW_chk >= tAW_Time(Model)) then
            --- tAW_Time(Model) OK, do nothing
        else
      	   if (TimingInfo) then
	         assert FALSE
		      report "Address setup tAW_Time(Model) violation for Upper Byte Write";
	       end if;
          write_flag := FALSE;
        end if;
	
        --- check for byte setup with write end, i.e., tBW_Time(Model)
        if (NOW - tBBW_chk >= tBW_Time(Model)) then
            --- tBW_Time(Model) OK, do nothing
        else
      	   if (TimingInfo) then
	         assert FALSE
		      report "Upper Byte setup tBW_Time(Model) violation";
	       end if;
        
        write_flag := FALSE;
        end if;
	
        --- check for data setup with write end, i.e., tSD_Time(Model)
        if (NOW - tSD_chk >= tSD_dataskew or NOW = 0 ns) then
            --- tSD_Time(Model) OK, do nothing
        else
      	   if (TimingInfo) then
	          assert FALSE
	   	      report "Data setup tSD_Time(Model) violation for Upper Byte Write";
	       end if;
        
          write_flag := FALSE;
        end if;
	
	     --- perform WRITE operation if no violations
	
	     if (write_flag = TRUE) then
	       mem_array(conv_integer1(address_internal))(15 downto 8) := data_skew(15 downto 8);
			 if(ERR_Address = address_internal(3 downto 0) and ERR_location < "1000") then
						mem_backup(conv_integer1(address_internal))(15 downto 8) := data_skew(15 downto 8);
					elsif(ERR_Address = address_internal(3 downto 0) and ERR_location = "1111") then
--						ERR <= '1';
						mem_backup(conv_integer1(address_internal))(14 downto 8) := data_skew(14 downto 8);
						mem_backup(conv_integer1(address_internal))(15) := not(data_skew(15));
					elsif(ERR_Address = address_internal(3 downto 0) and ERR_location = "1000") then
--						ERR <= '1';
						mem_backup(conv_integer1(address_internal))(15 downto 9) := data_skew(15 downto 9);
						mem_backup(conv_integer1(address_internal))(8) := not(data_skew(8));
					elsif((ERR_Address = address_internal(3 downto 0)) and (ERR_location < "1111") and (ERR_location > "1000")) then
--						ERR <= '1';
						mem_backup(conv_integer1(address_internal))(conv_integer1(ERR_location - 1) downto 8) := data_skew(conv_integer1(ERR_location - 1) downto 8);
						mem_backup(conv_integer1(address_internal))(conv_integer1(ERR_location)) := not(data_skew(conv_integer1(ERR_location)));
						mem_backup(conv_integer1(address_internal))(15 downto conv_integer1(ERR_location + 1)) := data_skew(15 downto conv_integer1(ERR_location + 1));
					else
						mem_backup(conv_integer1(address_internal))(15 downto 8) := data_skew(15 downto 8);
			 end if;
          if (BLE_b = '0') then
            	mem_array(conv_integer1(address_internal))(7 downto 0) := data_skew(7 downto 0);
					if(ERR_Address = address_internal(3 downto 0) and ERR_location > "0111") then
						mem_backup(conv_integer1(address_internal))(7 downto 0) := data_skew(7 downto 0);
					elsif(ERR_Address = address_internal(3 downto 0) and ERR_location = "0111") then
--						ERR <= '1';
						mem_backup(conv_integer1(address_internal))(6 downto 0) := data_skew(6 downto 0);
						mem_backup(conv_integer1(address_internal))(7) := not(data_skew(7));
					elsif(ERR_Address = address_internal(3 downto 0) and ERR_location = "0000") then
--						ERR <= '1';
						mem_backup(conv_integer1(address_internal))(7 downto 1) := data_skew(7 downto 1);
						mem_backup(conv_integer1(address_internal))(0) := not(data_skew(0));
					elsif((ERR_Address = address_internal(3 downto 0)) and (ERR_location < "1111") and (ERR_location > "1000")) then
--						ERR <= '1';
						mem_backup(conv_integer1(address_internal))(conv_integer1(ERR_location - 1) downto 0) := data_skew(conv_integer1(ERR_location - 1) downto 0);
						mem_backup(conv_integer1(address_internal))(conv_integer1(ERR_location)) := not(data_skew(conv_integer1(ERR_location)));
						mem_backup(conv_integer1(address_internal))(7 downto conv_integer1(ERR_location + 1)) := data_skew(7 downto conv_integer1(ERR_location + 1));
					else
						mem_backup(conv_integer1(address_internal))(7 downto 0) := data_skew(7 downto 0);
					end if;
          end if;
	
      	 end if; 
	
	     --- Reset timing variables
	     tAW_chk := A'last_event;
        tBBW_chk := NOW;
        write_flag := TRUE;
	    
     end if;

  end if;
  --- END OF WRITE

  if (data_skew'event and read_enable /= '1') then
    	tSD_chk := NOW;
  end if;

  --- START of READ
    
  --- Tri-state the data bus if CE or OE disabled
  if (read_enable = '0' and read_enable'event) then
    if (OE_b'last_event >= CE_b'last_event) then
   		DQ <=(others=>'Z') after tHZCE_Time(Model);
			ERR <= 'Z' after tHZCE_Time(Model);
   	elsif (CE_b'last_event > OE_b'last_event) then
   		DQ <=(others=>'Z') after tHZOE_Time(Model);
			ERR <= 'Z' after tHZOE_Time(Model);
   	end if;
  end if;
   
  --- Address-controlled READ operation
  if (A'event) then
    if (A'last_event = CE_b'last_event and CE_b = '1') then
       DQ <=(others=>'Z') after tHZCE_Time(Model);
		 ERR <= 'Z' after tHZCE_Time(Model);
    end if;
       
    if (NOW - tRC_chk >= tRC_Time(Model) or NOW - tRC_chk <= 0.1 ns or tRC_chk = 0 ns) then
      --- tRC OK, do nothing
    else
           
       if (TimingInfo) then
	       assert FALSE
	   	   report "Read Cycle time tRC_Time(Model) violation";
	    end if;

    end if;    
       
    if (read_enable = '1') then
	   
	   if (BLE_b = '0') then
		   DQ (7 downto 0) <= mem_array (conv_integer1(A))(7 downto 0) after tAA_Time(Model);
			if(mem_array(conv_integer1(A))(15 downto 0) = mem_backup(conv_integer1(A))(15 downto 0)) then
				ERR <= '0' after tAA_Time(Model);
			else
				ERR <= '1' after tAA_Time(Model);
			end if;
	   end if;
	   
	   if (BHE_b = '0') then
		   DQ (15 downto 8) <= mem_array (conv_integer1(A))(15 downto 8) after tAA_Time(Model);
			if(mem_array(conv_integer1(A))(15 downto 0) = mem_backup(conv_integer1(A))(15 downto 0)) then
				ERR <= '0' after tAA_Time(Model);
			else
				ERR <= '1' after tAA_Time(Model);
			end if;
	   end if;
	   
      tRC_chk := NOW;

	end if;
	
	if (write_enable = '1') then
	   --- do nothing
	end if;
	
  end if;

  if (read_enable = '0' and read_enable'event) then
     DQ <=(others=>'Z') after tHZCE_Time(Model);
	  ERR <= 'Z' after tHZCE_Time(Model);
     if (NOW - tRC_chk >= tRC_Time(Model) or tRC_chk = 0 ns or A'last_event = read_enable'last_event) then 
     --- tRC_Time(Model)_chk needs to be reset when read ends
        tRC_CHK := 0 ns;
     else
         if (TimingInfo) then
	        assert FALSE
		     report "Read Cycle time tRC_Time(Model) violation";
 	      end if;          
	      tRC_CHK := 0 ns;
     end if;

   end if;

   --- READ operation triggered by CE/OE/BHE/BLE
   if (read_enable = '1' and read_enable'event) then

      tRC_chk := NOW;

       --- CE triggered READ
       if (CE_b'last_event = read_enable'last_event ) then

           if (BLE_b = '0') then
		         DQ (7 downto 0)<= mem_array (conv_integer1(A)) (7 downto 0) after tACE_Time(Model);
					if(mem_array(conv_integer1(A))(15 downto 0) = mem_backup(conv_integer1(A))(15 downto 0)) then
						ERR <= '0' after tACE_Time(Model);
					else
						ERR <= '1' after tACE_Time(Model);
					end if;
           end if;

           if (BHE_b = '0') then
		         DQ (15 downto 8)<= mem_array (conv_integer1(A)) (15 downto 8) after tACE_Time(Model);
					if(mem_array(conv_integer1(A))(15 downto 0) = mem_backup(conv_integer1(A))(15 downto 0)) then
						ERR <= '0' after tACE_Time(Model);
					else
						ERR <= '1' after tACE_Time(Model);
					end if;
           end if;
           
       end if;

       --- READ triggered by BHE and BLE (access time same as tACE_Time(Model))
       if (BHE_b'last_event = read_enable'last_event and BLE_b'last_event = read_enable'last_event) then

           if (BLE_b = '0') then
		         DQ (7 downto 0)<= mem_array (conv_integer1(A)) (7 downto 0) after tACE_Time(Model);
					if(mem_array(conv_integer1(A))(15 downto 0) = mem_backup(conv_integer1(A))(15 downto 0)) then
						ERR <= '0' after tACE_Time(Model);
					else
						ERR <= '1' after tACE_Time(Model);
					end if;
           end if;

           if (BHE_b = '0') then
		         DQ (15 downto 8)<= mem_array (conv_integer1(A)) (15 downto 8) after tACE_Time(Model);
					if(mem_array(conv_integer1(A))(15 downto 0) = mem_backup(conv_integer1(A))(15 downto 0)) then
						ERR <= '0' after tACE_Time(Model);
					else
						ERR <= '1' after tACE_Time(Model);
					end if;
           end if;
           
       end if;

   
 	    --- OE triggered READ  
       if (OE_b'last_event = read_enable'last_event) then

           -- if address or CE/(BHE and BLE) changes before OE such tHA_tSA_Time(Model)t tAA_Time(Model)/tACE_Time(Model) > tDOE_Time(Model)
           if (ce_bhe_ble_combined_b'last_event < tACE_Time(Model) - tDOE_Time(Model) and A'last_event < tAA_Time(Model) - tDOE_Time(Model)) then
               
               if (A'last_event < ce_bhe_ble_combined_b'last_event) then

                  accesstime:=tAA_Time(Model)-A'last_event;
                  if (BLE_b = '0') then
		               DQ (7 downto 0)<= mem_array (conv_integer1(A)) (7 downto 0) after accesstime;
							if(mem_array(conv_integer1(A))(15 downto 0) = mem_backup(conv_integer1(A))(15 downto 0)) then
								ERR <= '0' after accesstime;
							else
								ERR <= '1' after accesstime;
							end if;
                  end if; 
               
                  if (BHE_b = '0') then
   		               DQ (15 downto 8)<= mem_array (conv_integer1(A)) (15 downto 8) after accesstime;
								if(mem_array(conv_integer1(A))(15 downto 0) = mem_backup(conv_integer1(A))(15 downto 0)) then
									ERR <= '0' after accesstime;
								else
									ERR <= '1' after accesstime;
								end if;
                  end if;               

               else
                  accesstime:=tACE_Time(Model)-ce_bhe_ble_combined_b'last_event;
                  if (BLE_b = '0') then
		               DQ (7 downto 0)<= mem_array (conv_integer1(A)) (7 downto 0) after accesstime;
							if(mem_array(conv_integer1(A))(15 downto 0) = mem_backup(conv_integer1(A))(15 downto 0)) then
								ERR <= '0' after accesstime;
							else
								ERR <= '1' after accesstime;
							end if;
                  end if; 
               
                  if (BHE_b = '0') then
   		               DQ (15 downto 8)<= mem_array (conv_integer1(A)) (15 downto 8) after accesstime;
								if(mem_array(conv_integer1(A))(15 downto 0) = mem_backup(conv_integer1(A))(15 downto 0)) then
									ERR <= '0' after accesstime;
								else
									ERR <= '1' after accesstime;
								end if;
                  end if;
              end if;

           -- if address changes before OE such tHA_tSA_Time(Model)t tAA_Time(Model) > tDOE_Time(Model)
           elsif (A'last_event < tAA_Time(Model) - tDOE_Time(Model)) then
               
                  accesstime:=tAA_Time(Model)-A'last_event;
                  if (BLE_b = '0') then
		               DQ (7 downto 0)<= mem_array (conv_integer1(A)) (7 downto 0) after accesstime;
							if(mem_array(conv_integer1(A))(15 downto 0) = mem_backup(conv_integer1(A))(15 downto 0)) then
								ERR <= '0' after accesstime;
							else
								ERR <= '1' after accesstime;
							end if;
                  end if; 
               
                  if (BHE_b = '0') then
   		               DQ (15 downto 8)<= mem_array (conv_integer1(A)) (15 downto 8) after accesstime;
								if(mem_array(conv_integer1(A))(15 downto 0) = mem_backup(conv_integer1(A))(15 downto 0)) then
									ERR <= '0' after accesstime;
								else
									ERR <= '1' after accesstime;
								end if;
                  end if;

           -- if CE/(BHE and BLE) changes before OE such tHA_tSA_Time(Model)t tACE_Time(Model) > tDOE_Time(Model)
           elsif (ce_bhe_ble_combined_b'last_event < tACE_Time(Model) - tDOE_Time(Model)) then
               
                  accesstime:=tACE_Time(Model)-ce_bhe_ble_combined_b'last_event;
                  if (BLE_b = '0') then
		               DQ (7 downto 0)<= mem_array (conv_integer1(A)) (7 downto 0) after accesstime;
							if(mem_array(conv_integer1(A))(15 downto 0) = mem_backup(conv_integer1(A))(15 downto 0)) then
								ERR <= '0' after accesstime;
							else
								ERR <= '1' after accesstime;
							end if;
                  end if; 
               
                  if (BHE_b = '0') then
   		               DQ (15 downto 8)<= mem_array (conv_integer1(A)) (15 downto 8) after accesstime;
								if(mem_array(conv_integer1(A))(15 downto 0) = mem_backup(conv_integer1(A))(15 downto 0)) then
									ERR <= '0' after accesstime;
								else
									ERR <= '1' after accesstime;
								end if;
                  end if;

           -- if OE changes such tHA_tSA_Time(Model)t tDOE_Time(Model) > tAA_Time(Model)/tACE_Time(Model)           
           else
                   if (BLE_b = '0') then
		               DQ (7 downto 0)<= mem_array (conv_integer1(A)) (7 downto 0) after tDOE_Time(Model);
							if(mem_array(conv_integer1(A))(15 downto 0) = mem_backup(conv_integer1(A))(15 downto 0)) then
								ERR <= '0' after tDOE_Time(Model);
							else
								ERR <= '1' after tDOE_Time(Model);
							end if;
                   end if; 
               
                   if (BHE_b = '0') then
   		               DQ (15 downto 8)<= mem_array (conv_integer1(A)) (15 downto 8) after tDOE_Time(Model);
								if(mem_array(conv_integer1(A))(15 downto 0) = mem_backup(conv_integer1(A))(15 downto 0)) then
									ERR <= '0' after tDOE_Time(Model);
								else
									ERR <= '1' after tDOE_Time(Model);
								end if;
                   end if;
            
           end if;
           
       end if;
       --- END of OE triggered READ

 	    --- BLE/BHE triggered READ (access time: tDBE_Time(Model))
 	    if (ce_bhe_ble_combined_b = '1') then
       if (BLE_b'last_event = read_enable'last_event or BHE_b'last_event = read_enable'last_event) then

           -- if address or CE changes before BHE/BLE such tHA_tSA_Time(Model)t tAA_Time(Model)/tACE_Time(Model) > tDBE_Time(Model)
           if (CE_b'last_event < tACE_Time(Model) - tDBE_Time(Model) and A'last_event < tAA_Time(Model) - tDBE_Time(Model)) then
               
               if (A'last_event < BLE_b'last_event) then
                  accesstime:=tAA_Time(Model)-A'last_event;

                  if (BLE_b = '0') then
                     DQ (7 downto 0)<= mem_array (conv_integer1(A)) (7 downto 0) after accesstime;
							if(mem_array(conv_integer1(A))(15 downto 0) = mem_backup(conv_integer1(A))(15 downto 0)) then
								ERR <= '0' after accesstime;
							else
								ERR <= '1' after accesstime;
							end if;
                  end if;
              
                  if (BHE_b = '0') then
   		               DQ (15 downto 8)<= mem_array (conv_integer1(A)) (15 downto 8) after accesstime;
								if(mem_array(conv_integer1(A))(15 downto 0) = mem_backup(conv_integer1(A))(15 downto 0)) then
									ERR <= '0' after accesstime;
								else
									ERR <= '1' after accesstime;
								end if;
                  end if;               

               else
                  accesstime:=tACE_Time(Model)-CE_b'last_event;

                  if (BLE_b = '0') then
                     DQ (7 downto 0)<= mem_array (conv_integer1(A)) (7 downto 0) after accesstime;
							if(mem_array(conv_integer1(A))(15 downto 0) = mem_backup(conv_integer1(A))(15 downto 0)) then
								ERR <= '0' after accesstime;
							else
								ERR <= '1' after accesstime;
							end if;
                  end if;
                  
                  if (BHE_b = '0') then
   		               DQ (15 downto 8)<= mem_array (conv_integer1(A)) (15 downto 8) after accesstime;
								if(mem_array(conv_integer1(A))(15 downto 0) = mem_backup(conv_integer1(A))(15 downto 0)) then
									ERR <= '0' after accesstime;
								else
									ERR <= '1' after accesstime;
								end if;
                  end if;
              end if;

           -- if address changes before BHE/BLE such tHA_tSA_Time(Model)t tAA_Time(Model) > tDBE_Time(Model)
           elsif (A'last_event < tAA_Time(Model) - tDBE_Time(Model)) then
                  accesstime:=tAA_Time(Model)-A'last_event;

                  if (BLE_b = '0') then
                     DQ (7 downto 0)<= mem_array (conv_integer1(A)) (7 downto 0) after accesstime;
							if(mem_array(conv_integer1(A))(15 downto 0) = mem_backup(conv_integer1(A))(15 downto 0)) then
								ERR <= '0' after accesstime;
							else
								ERR <= '1' after accesstime;
							end if;
                  end if;
               
                  if (BHE_b = '0') then
   		               DQ (15 downto 8)<= mem_array (conv_integer1(A)) (15 downto 8) after accesstime;
								if(mem_array(conv_integer1(A))(15 downto 0) = mem_backup(conv_integer1(A))(15 downto 0)) then
									ERR <= '0' after accesstime;
								else
									ERR <= '1' after accesstime;
								end if;
                  end if;

           -- if CE changes before BHE/BLE such tHA_tSA_Time(Model)t tACE_Time(Model) > tDBE_Time(Model)
           elsif (CE_b'last_event < tACE_Time(Model) - tDBE_Time(Model)) then
                  accesstime:=tACE_Time(Model)-CE_b'last_event;

                  if (BLE_b = '0') then
                     DQ (7 downto 0)<= mem_array (conv_integer1(A)) (7 downto 0) after accesstime;
							if(mem_array(conv_integer1(A))(15 downto 0) = mem_backup(conv_integer1(A))(15 downto 0)) then
								ERR <= '0' after accesstime;
							else
								ERR <= '1' after accesstime;
							end if;
                  end if;
               
                  if (BHE_b = '0') then
   		               DQ (15 downto 8)<= mem_array (conv_integer1(A)) (15 downto 8) after accesstime;
								if(mem_array(conv_integer1(A))(15 downto 0) = mem_backup(conv_integer1(A))(15 downto 0)) then
									ERR <= '0' after accesstime;
								else
									ERR <= '1' after accesstime;
								end if;
                  end if;

           -- if BHE/BLE changes such tHA_tSA_Time(Model)t tDBE_Time(Model) > tAA_Time(Model)/tACE_Time(Model)   
           else
                   if (BLE_b = '0') then
		               DQ (7 downto 0)<= mem_array (conv_integer1(A)) (7 downto 0) after tDBE_Time(Model);
							if(mem_array(conv_integer1(A))(15 downto 0) = mem_backup(conv_integer1(A))(15 downto 0)) then
								ERR <= '0' after tDBE_Time(Model);
							else
								ERR <= '1' after tDBE_Time(Model);
							end if;
                   end if; 
               
                   if (BHE_b = '0') then
   		               DQ (15 downto 8)<= mem_array (conv_integer1(A)) (15 downto 8) after tDBE_Time(Model);
								if(mem_array(conv_integer1(A))(15 downto 0) = mem_backup(conv_integer1(A))(15 downto 0)) then
									ERR <= '0' after tDBE_Time(Model);
								else
									ERR <= '1' after tDBE_Time(Model);
								end if;
                   end if;
            
           end if;
           
       end if;
       end if;
       -- END of BHE/BLE controlled READ
       
       if (WE_b'last_event = read_enable'last_event) then

           if (BLE_b = '0') then
		      DQ (7 downto 0)<= mem_array (conv_integer1(A)) (7 downto 0) after tACE_Time(Model);
				if(mem_array(conv_integer1(A))(15 downto 0) = mem_backup(conv_integer1(A))(15 downto 0)) then
					ERR <= '0' after tACE_Time(Model);
				else
					ERR <= '1' after tACE_Time(Model);
				end if;
           end if;

           if (BHE_b = '0') then
		      DQ (15 downto 8)<= mem_array (conv_integer1(A)) (15 downto 8) after tACE_Time(Model);
				if(mem_array(conv_integer1(A))(15 downto 0) = mem_backup(conv_integer1(A))(15 downto 0)) then
					ERR <= '0' after tACE_Time(Model);
				else
					ERR <= '1' after tACE_Time(Model);
				end if;
           end if;

       end if;

     end if;
     --- END OF CE/OE/BHE/BLE controlled READ
   
    --- If either BHE or BLE toggle during read mode
    if (BLE_b'event and BLE_b = '0' and read_enable = '1' and not(read_enable'event)) then
	   DQ (7 downto 0) <= mem_array (conv_integer1(A)) (7 downto 0) after tDBE_Time(Model);
		if(mem_array(conv_integer1(A))(15 downto 0) = mem_backup(conv_integer1(A))(15 downto 0)) then
			ERR <= '0' after tDBE_Time(Model);
		else
			ERR <= '1' after tDBE_Time(Model);
		end if;
    end if;

    if (BHE_b'event and BHE_b = '0' and read_enable = '1' and not(read_enable'event)) then
	   DQ (15 downto 8) <= mem_array (conv_integer1(A)) (15 downto 8) after tDBE_Time(Model);
		if(mem_array(conv_integer1(A))(15 downto 0) = mem_backup(conv_integer1(A))(15 downto 0)) then
			ERR <= '0' after tDBE_Time(Model);
		else
			ERR <= '1' after tDBE_Time(Model);
		end if;
    end if;

    --- tri-state bus depending on BHE/BLE 
    if (BLE_b'event and BLE_b = '1') then
        DQ (7 downto 0) <= (others=>'Z') after tHZBE_Time(Model);
--		  ERR <= 'Z' after tHZBE_Time(Model);
    end if;

    if (BHE_b'event and BHE_b = '1') then
        DQ (15 downto 8) <=(others=>'Z') after tHZBE_Time(Model);
--		  ERR <= 'Z' after tHZBE_Time(Model);
    end if;
    end if;
    wait on write_enable, A, read_enable, DQ, BLE_b, BHE_b, data_skew;
    
end process;    

process(Write_enable)
begin
if(write_enable'event and write_enable = '0') then
	if(count = "111") then
		count <= "000";
		ERR_Address <= ERR_address + 5;
		ERR_location <= ERR_location + 3;
	else
		count <= count + 1;
	end if;
end if;
end process;
end behave_arch;