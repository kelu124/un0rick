library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library ice;
use ice.vcomponent_vital.all;

entity MATTY_MAIN_VHDL_tb is
end MATTY_MAIN_VHDL_tb;


	
architecture testbench_arch of MATTY_MAIN_VHDL_tb is

component MATTY_MAIN_VHDL
port (  				  
			clk : in  STD_LOGIC;
	   		reset : in  STD_LOGIC;
            reset_ft : in  STD_LOGIC; --active high 
            reset_rpi : in  STD_LOGIC; --active high
           	LED_ACQ : out  STD_LOGIC;
           	LED_MODE : out  STD_LOGIC;
           	LED3 : out  STD_LOGIC;
        	spi_cs_ft: in  STD_LOGIC;
    		spi_sclk_ft: in  STD_LOGIC;
    		spi_mosi_ft: in  STD_LOGIC;
    		spi_miso_ft : out  STD_LOGIC;
            spi_cs_rpi: in  STD_LOGIC;
            spi_sclk_rpi: in  STD_LOGIC;
            spi_mosi_rpi: in  STD_LOGIC;
            spi_miso_rpi : out  STD_LOGIC;
            spi_cs_flash: out  STD_LOGIC;
            spi_sclk_flash: out  STD_LOGIC;
            spi_mosi_flash: out  STD_LOGIC;
            spi_miso_flash : in  STD_LOGIC;
            cs_rpi2flash: in  STD_LOGIC; --1 to link RPI SPI lines to FLASH lines
            spi_select: in  STD_LOGIC; --  0:FT / 1:RPI

    		DAC_cs: out  STD_LOGIC;
    		DAC_sclk: out  STD_LOGIC;
    		DAC_mosi: out  STD_LOGIC;
    		ADC0: in  STD_LOGIC;
       		ADC1: in  STD_LOGIC;
    		ADC2: in  STD_LOGIC;
    		ADC3: in  STD_LOGIC;
    		ADC4: in  STD_LOGIC;
    		ADC5: in  STD_LOGIC;
    		ADC6: in  STD_LOGIC;
    		ADC7: in  STD_LOGIC;
    		ADC8: in  STD_LOGIC;
    		ADC9: in  STD_LOGIC;
    		ADC_clk: out STD_LOGIC;


			RAM_DATA:inout  std_logic_vector(15 downto 0);
			RAM_ADD:out std_logic_vector(18 downto 0);

 			RAM_nCE: out STD_LOGIC;
 			RAM_nOE: out STD_LOGIC;
 			RAM_nWE: out STD_LOGIC;
 			RAM_nLB: out STD_LOGIC;
 			RAM_nUB: out STD_LOGIC;

        	trig_ext: in  STD_LOGIC;
            trig_rpi: in  STD_LOGIC;
            trig_ft: in  STD_LOGIC;
            button_trig: in  STD_LOGIC;
        	button_mode: in  STD_LOGIC;
    		pon : out  STD_LOGIC;
    		poff : out  STD_LOGIC;
    		top_tour1: in  STD_LOGIC;
    		top_tour2: in  STD_LOGIC
			);
end component;



component	  mobl_1Mx16 
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
end component;


signal clk : std_logic := '0'; 

signal LED_ACQ : std_logic := '0';
signal LED_MODE : std_logic := '0';
signal LED3 : std_logic := '0';


signal spi_cs_ft:   STD_LOGIC:= '0';
signal  spi_sclk_ft:   STD_LOGIC:= '0';
signal  spi_mosi_ft:   STD_LOGIC:= '0';
signal 	spi_miso_ft :   STD_LOGIC:= '0';
signal  spi_cs_rpi:   STD_LOGIC:= '0';
signal  spi_sclk_rpi:   STD_LOGIC:= '0';
signal  spi_mosi_rpi:   STD_LOGIC:= '0';
signal spi_miso_rpi :   STD_LOGIC:= '0';
signal spi_cs_flash:   STD_LOGIC:= '0';
signal spi_sclk_flash:   STD_LOGIC:= '0';
signal spi_mosi_flash:   STD_LOGIC:= '0';
signal spi_miso_flash :   STD_LOGIC:= '0';
signal cs_rpi2flash:   STD_LOGIC:= '0'; --1 to link RPI SPI lines to FLASH lines
signal spi_select:   STD_LOGIC:= '1'; --  0:FT / 1:RPI	
signal trig_ext: STD_LOGIC:= '0';
signal trig_rpi:   STD_LOGIC:= '0';
signal trig_ft:   STD_LOGIC:= '0';

	
signal        	button_trig: std_logic := '0';	
signal        	button_mode: std_logic := '0';	
signal    		pon : std_logic := '0';		
signal    		poff : std_logic := '0';
signal    		reset : std_logic := '1';	  
signal    		reset_ft : std_logic := '1';
signal    		reset_rpi : std_logic := '1';
signal 			DAC_cs:  std_logic := '0';
signal     		DAC_sclk: std_logic := '0';
signal     		DAC_mosi: std_logic := '0';	
signal 			ADC0: std_logic := '0';	
signal       	ADC1: std_logic := '0';	
signal    		ADC2: std_logic := '0';	
signal    		ADC3: std_logic := '0';	
signal    		ADC4: std_logic := '0';	
signal    		ADC5: std_logic := '0';	
signal    		ADC6: std_logic := '0';	
signal    		ADC7: std_logic := '0';	
signal    		ADC8: std_logic := '0';
signal    		ADC9: std_logic := '0';		
signal    		ADC_clk: std_logic := '0';	   

signal 			RAM_DATA:  std_logic_vector(15 downto 0):= (others => '0');
signal			RAM_ADD: std_logic_vector(18 downto 0):= (others => '0');


signal 			RAM_nCE: std_logic := '0';	  
signal			RAM_nOE: std_logic := '0';	  
signal 			RAM_nWE: std_logic := '0';	  
signal 			RAM_nLB: std_logic := '0';	  
signal 			RAM_nUB: std_logic := '0';	  

signal  		top_tour1: std_logic := '0';
signal    		top_tour2: std_logic := '1';


signal 			ADC_simulation:   std_logic_vector(9 downto 0):= (others => '0');

constant period12 : time := 83.33 ns;
constant period200 : time := 5 ns; 
constant period100 : time := 10 ns;
constant period128 : time := 7.812 ns;
constant period64 : time := 15.625 ns; 
constant duty_cycle : real := 0.5;
constant offset : time := 100 ns;
constant sclk_cycle : time := 50 ns;

constant DATA_SIZE : natural := 8;


constant		 nb_data : natural := 53;
type input_data_type is array (integer range 0 to nb_data) of std_logic_vector(7 downto 0);


--SPI DATA
constant input_data : input_data_type := (X"AA",X"E0", X"14", 
											X"AA",X"D0", X"0A",
											X"AA",X"E1", X"00",
											X"AA",X"E2", X"C8",
											X"AA",X"E3", X"00",
											X"AA",X"E4", X"BC",	
											X"AA",X"E5", X"32",
											X"AA",X"E6", X"C8",
											X"AA",X"E7", X"00",
											X"AA",X"E8", X"3A",
											X"AA",X"E9", X"AA",
											X"AA",X"EA", X"00",
											X"AA",X"EB", X"00",
											X"AA",X"EC", X"55",
											X"AA",X"ED", X"01",	 
											X"AA",X"EE", X"0A",	             
											X"AA",X"EF", X"00",
											X"AA",X"EA", X"01");
 --	 
 constant input_data2 : input_data_type := (X"00",X"00", X"00",
 											X"00",X"00", X"00",
											 X"00",X"00", X"00",
											 X"00",X"00", X"00",
											 X"00",X"00", X"00",
											 X"00",X"00", X"00",
											 X"00",X"00", X"00",
											 X"00",X"00", X"00",
											 X"00",X"00", X"00",
											 X"00",X"00", X"00",
											 X"00",X"00", X"00",
											 X"00",X"00", X"00",
											 X"00",X"00", X"00",
											 X"00",X"00", X"00",
											 X"00",X"00", X"00",
											 X"00",X"00", X"00",
											 X"00",X"00", X"00",
											 X"00",X"00", X"00");
 
constant input_data3 : input_data_type := (X"AA",X"10", X"14", 
											X"AA",X"11", X"0A",
											X"AA",X"12", X"00",
											X"AA",X"13", X"C8",
											X"AA",X"13", X"00",
											X"AA",X"15", X"BC",	
											X"AA",X"16", X"00",
											X"AA",X"17", X"FF",
											X"AA",X"18", X"00",
											X"AA",X"19", X"0A",
											X"AA",X"1A", X"AA",
											X"AA",X"1B", X"00",
											X"AA",X"1C", X"00",
											X"AA",X"1D", X"55",
											X"AA",X"1E", X"01",	 
											X"AA",X"1F", X"0A",	             
											X"AA",X"20", X"00",
											X"AA",X"21", X"01");

											
											
											
begin
	
	
	
	
uut : MATTY_MAIN_VHDL
port map ( 				  
clk => clk,
LED_MODE => LED_MODE,
LED_ACQ => LED_ACQ,
LED3 => LED3,

spi_cs_ft   => 	spi_cs_ft,
spi_sclk_ft => spi_sclk_ft,
spi_mosi_ft	 =>   spi_mosi_ft,
spi_miso_ft => 	  spi_miso_ft,
spi_cs_rpi  => spi_cs_rpi,
spi_sclk_rpi => spi_sclk_rpi,
spi_mosi_rpi => spi_mosi_rpi,
spi_miso_rpi => spi_miso_rpi,
spi_cs_flash =>   spi_cs_flash,
spi_sclk_flash => 	spi_sclk_flash,
spi_mosi_flash => 	spi_mosi_flash,
spi_miso_flash =>  spi_miso_flash,
cs_rpi2flash  =>  cs_rpi2flash,
spi_select	 =>  spi_select,
trig_ext    => 	 trig_ext,
trig_rpi   => trig_rpi ,
trig_ft	 =>  trig_ft,

DAC_cs  => DAC_cs, 
DAC_mosi  => DAC_mosi,
DAC_sclk  => DAC_sclk,	

ADC0 => ADC0, 
ADC1 => ADC1,
ADC2 => ADC2,
ADC3 => ADC3,
ADC4 => ADC4,
ADC5 => ADC5,
ADC6 => ADC6,
ADC7 => ADC7,
ADC8 => ADC8,
ADC9 => ADC9,
ADC_clk => ADC_clk,

RAM_DATA  => RAM_DATA,
RAM_ADD	  => RAM_ADD,
RAM_nCE =>	 RAM_nCE ,
RAM_nOE =>	 RAM_nOE,
RAM_nWE =>	 RAM_nWE,
RAM_nLB =>	 RAM_nLB,
RAM_nUB =>	 RAM_nUB,

top_tour1 => top_tour1,
top_tour2 => top_tour2,

button_trig => button_trig, 
button_mode=> button_mode,
pon => pon, 
poff => poff,	
reset => reset,
reset_rpi => reset_rpi,
reset_ft => reset_ft
);		  


ram_test: mobl_1Mx16
PORT MAP
	(
	   Model => 2,
    	CE_b    => RAM_nCE,
    	WE_b    => RAM_nWE,
    	OE_b    => RAM_nOE,
    	BLE_b	=> RAM_nLB,
    	BHE_b	=> RAM_nUB,
		 DS_b    => '1',
    	A       => RAM_ADD,
    	DQ	=> RAM_DATA,
    	ERR => open
	);	

	
	process -- clock generation		
   	begin	
		   
	
		 
   	clock_loop : loop
      	clk <= '0';
     	wait for (period12 - (period12 * duty_cycle));
        clk <= '1';		
       	wait for (period12 * duty_cycle);
 	end loop clock_loop;
    end process;
	
	
  
	
	
	
	
	
	process -- test PON	   
	begin  
		reset	<= '0';
		button_mode <= '0';
		wait for 2us;  
		reset	<= '1';	
--		wait for 300ns; 
--		trig	<= '1';	--
--		wait for  10ns;
--		trig  <= '0'; 
		
		
		
	--	wait for 50us;
--		button_mode	  <= '1'; 
--		
--		wait for 50us;
--		button_mode	  <= '0'; 
--		
--			
--		wait for 10us; 
--		trig	<= '1';	--
--		wait for  10ns;
--		trig  <= '0'; 
--			
--		--
--		wait for 50us;
--		button_mode	  <= '1'; 
--		
--		wait for 50us;
--		button_mode	  <= '0'; 

		
		wait for  10000ms;
		
	
	
	
	
	end process;



	process
        variable cnt : integer := 0;
    begin 
		spi_cs_rpi <= '1';
        wait for 30us;
		
		
		
		for j in 0 to nb_data loop		
                cnt            := 0;
                spi_cs_rpi <= '0';
				
                for i in DATA_SIZE - 1 downto 0 loop
					spi_mosi_rpi     <= input_data3(j)(DATA_SIZE-cnt-1);	
					wait for sclk_cycle;
					spi_sclk_rpi     <= '1';
              
               
	                wait for sclk_cycle;
	                spi_sclk_rpi     <= '0';
	                        
	                cnt     := cnt+1;
                end loop;
                wait for 	200ns;
                spi_cs_rpi <= '1' ;
				wait for 500ns;

		end loop;  
		
		wait for 10 us;
		
		
		
		
		
		
		for j in 0 to nb_data loop		
                cnt            := 0;
                spi_cs_rpi <= '0';
				
                for i in DATA_SIZE - 1 downto 0 loop
					spi_mosi_rpi     <= input_data(j)(DATA_SIZE-cnt-1);	
					wait for sclk_cycle;
					spi_sclk_rpi     <= '1';
	                wait for sclk_cycle;
	                spi_sclk_rpi     <= '0';
	                        
	                cnt     := cnt+1;
                end loop;
                wait for 	200ns;
                spi_cs_rpi <= '1' ;
				wait for 500ns;

		end loop;  
		
		wait for 10 us;
		
		
		--
		for j in 0 to nb_data loop		
                cnt            := 0;
                spi_cs_rpi <= '0';
				
                for i in DATA_SIZE - 1 downto 0 loop
					
					wait for sclk_cycle;
					spi_sclk_rpi     <= '1';
                    spi_mosi_rpi     <= input_data2(j)(DATA_SIZE-cnt-1);
           
               
	                wait for sclk_cycle;
	                spi_sclk_rpi     <= '0';
	                        
	                cnt     := cnt+1;
                end loop;
                wait for 	15ns;
                spi_cs_rpi <= '1' ;
				wait for 500ns;

		end loop;  
--		
--		
--				wait for 10 us;
--		
--		
--		
--		for j in 0 to 2 loop		
--                cnt            := 0;
--                spi_cs <= '0';
--				
--                for i in DATA_SIZE - 1 downto 0 loop
--					
--					wait for sclk_cycle;
--					spi_sclk     <= '1';
--                    spi_mosi     <= input_data3(j)(DATA_SIZE-cnt-1);
--           
--               
--	                wait for sclk_cycle;
--	                spi_sclk     <= '0';
--	                        
--	                cnt     := cnt+1;
--                end loop;
--                wait for 	15ns;
--                spi_cs <= '1' ;
--				wait for 500ns;
--
--		end loop;  
--		
		
				wait for 30 us;
		
		
		
		
		
	end process;

	
	
	process

	
	begin
		
		adc_loop : loop	 
		ADC_simulation <= ADC_simulation +1;
      	ADC9<= ADC_simulation(9);	
		ADC8<=ADC_simulation(8);
		ADC7<= ADC_simulation(7);
		ADC6<= ADC_simulation(6);
		ADC5<= ADC_simulation(5);
		ADC4<= ADC_simulation(4);
		ADC3<= ADC_simulation(3);
		ADC2<= ADC_simulation(2);
		ADC1<= ADC_simulation(1); 
		ADC0<= ADC_simulation(0);
       	wait for 5ns;	
		   
 	end loop adc_loop;
		
		
	end process;
 --   process -- reset generation
 --  	begin 
--        reset <= '0';
        -- -------------  Current Time:  0ns
--       	wait for 100 ns;
--        reset <= '1'; 
        -- -------------  Current Time:  100ns
--       	wait for 35 ns; 
--        reset <= '0';
        -- -------------  Current Time: 135ns
--  		wait for 1865 ns;
        -- -------------  CurrentTime:2000ns
--    end process;
end testbench_arch; 