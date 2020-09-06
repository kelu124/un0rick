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
clk   : in std_logic;  
--pll_clk100   : in std_logic;  
--pll_clk128   : in std_logic;  
--pll_clk64   : in std_logic;  
LED_ACQ : out  STD_LOGIC;
LED_MODE : out  STD_LOGIC; 
LED3 : out  STD_LOGIC;
--LED1 : out  STD_LOGIC;
--LED2 : out  STD_LOGIC;
--LED3 : out  STD_LOGIC;
--LED4 : out  STD_LOGIC;
--LED5 : out  STD_LOGIC;
--LED6 : out  STD_LOGIC;
--LED7 : out  STD_LOGIC;
--LED8 : out  STD_LOGIC;
    	spi_cs: in  STD_LOGIC;
    		spi_sclk: in  STD_LOGIC;
    		spi_mosi: in  STD_LOGIC;
    		spi_miso : out  STD_LOGIC; 
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
			
			--
--			RAM_DATA0: inout STD_LOGIC;
-- 			RAM_DATA1: inout STD_LOGIC;
-- 			RAM_DATA2: inout STD_LOGIC;
-- 			RAM_DATA3: inout STD_LOGIC;
-- 			RAM_DATA4: inout STD_LOGIC;
-- 			RAM_DATA5: inout STD_LOGIC;
-- 			RAM_DATA6: inout STD_LOGIC;
-- 			RAM_DATA7: inout STD_LOGIC;
-- 			RAM_DATA8: inout STD_LOGIC;
-- 			RAM_DATA9: inout STD_LOGIC;
-- 			RAM_DATA10: inout STD_LOGIC;
-- 			RAM_DATA11: inout STD_LOGIC;
-- 			RAM_DATA12: inout STD_LOGIC;
-- 			RAM_DATA13: inout STD_LOGIC;
-- 			RAM_DATA14: inout STD_LOGIC;
-- 			RAM_DATA15: inout STD_LOGIC;
-- 			RAM_ADD0: inout STD_LOGIC;
-- 			RAM_ADD1: inout STD_LOGIC;
-- 			RAM_ADD2: inout STD_LOGIC;
-- 			RAM_ADD3: inout STD_LOGIC;
-- 			RAM_ADD4: inout STD_LOGIC;
-- 			RAM_ADD5: inout STD_LOGIC;
-- 			RAM_ADD6: inout STD_LOGIC;
-- 			RAM_ADD7: inout STD_LOGIC;
-- 			RAM_ADD8: inout STD_LOGIC;
-- 			RAM_ADD9: inout STD_LOGIC;
-- 			RAM_ADD10: inout STD_LOGIC;
-- 			RAM_ADD11: inout STD_LOGIC;
-- 			RAM_ADD12: inout STD_LOGIC;
-- 			RAM_ADD13: inout STD_LOGIC;
-- 			RAM_ADD14: inout STD_LOGIC;
-- 			RAM_ADD15: inout STD_LOGIC;
-- 			RAM_ADD16: inout STD_LOGIC;
-- 			RAM_ADD17: inout STD_LOGIC;
-- 			RAM_ADD18: inout STD_LOGIC;
		  	RAM_DATA:inout  std_logic_vector(15 downto 0);
	RAM_ADD:out std_logic_vector(18 downto 0);
 			RAM_nCE: out STD_LOGIC;
 			RAM_nOE: out STD_LOGIC;
 			RAM_nWE: out STD_LOGIC;
 			RAM_nLB: out STD_LOGIC;
 			RAM_nUB: out STD_LOGIC;
		   
			top_tour1: in  STD_LOGIC;
    		top_tour2: in  STD_LOGIC;	
			
        	trig: in  STD_LOGIC; 
			button_mode: in  STD_LOGIC;
    		pon : out  STD_LOGIC;
    		poff : out  STD_LOGIC ;
			reset : in  STD_LOGIC
			);
--reset : in std_logic;
--count : out std_logic_vector (3 downto 0));
end component;


--Entity mobl_1Mx16 is
--end mobl_1Mx16;
 --
--Architecture behave_arch Of mobl_1Mx16 Is	 
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
--signal pll_clk100 : std_logic := '0';
--signal pll_clk128 : std_logic := '0';
--signal pll_clk64 : std_logic := '0';
signal LED_ACQ : std_logic := '0';
signal LED_MODE : std_logic := '0';
signal LED3 : std_logic := '0';
--signal LED4 : std_logic := '0';
--signal LED5 : std_logic := '0';
--signal LED6 : std_logic := '0';
--signal LED7 : std_logic := '0';
--signal LED8 : std_logic := '0';		
 signal   	spi_cs: std_logic := '0';		
 signal   		spi_sclk: std_logic := '0';		
 signal   		spi_mosi: std_logic := '0';		
signal    		spi_miso: std_logic := '0';		
signal        	trig: std_logic := '0';	
signal        	button_mode: std_logic := '0';	
signal    		pon : std_logic := '0';		
signal    		poff : std_logic := '0';
signal    		reset : std_logic := '1';	
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

--signal			RAM_DATA0: std_logic := '0';	  
--signal 			RAM_DATA1: std_logic := '0';	  
--signal 			RAM_DATA2: std_logic := '0';	  
--signal 			RAM_DATA3: std_logic := '0';	  
--signal 			RAM_DATA4: std_logic := '0';	  
--signal 			RAM_DATA5: std_logic := '0';	  
--signal 			RAM_DATA6: std_logic := '0';	  
--signal			RAM_DATA7: std_logic := '0';	  
--signal 			RAM_DATA8: std_logic := '0';	  
--signal 			RAM_DATA9: std_logic := '0';	  
--signal 			RAM_DATA10: std_logic := '0';	  
--signal 			RAM_DATA11: std_logic := '0';	  
--signal 			RAM_DATA12: std_logic := '0';	  
--signal 			RAM_DATA13 : std_logic := '0';	  
--signal			RAM_DATA14: std_logic := '0';	  
--signal			RAM_DATA15: std_logic := '0';	  
--signal 			RAM_ADD0: std_logic := '0';	  
--signal 			RAM_ADD1: std_logic := '0';	  
--signal 			RAM_ADD2: std_logic := '0';	  
--signal 			RAM_ADD3: std_logic := '0';	  
--signal 			RAM_ADD4: std_logic := '0';	  
--signal 			RAM_ADD5: std_logic := '0';	  
--signal 			RAM_ADD6: std_logic := '0';	  
--signal 			RAM_ADD7: std_logic := '0';	  
--signal 			RAM_ADD8: std_logic := '0';	  
--signal 			RAM_ADD9: std_logic := '0';	  
--signal 			RAM_ADD10: std_logic := '0';	  
--signal 			RAM_ADD11: std_logic := '0';	  
--signal 			RAM_ADD12: std_logic := '0';	  
--signal 			RAM_ADD13: std_logic := '0';	  
--signal 			RAM_ADD14: std_logic := '0';	  
--signal 			RAM_ADD15: std_logic := '0';	  
--signal 			RAM_ADD16: std_logic := '0';	  
--signal 			RAM_ADD17: std_logic := '0';	  
--signal 			RAM_ADD18: std_logic := '0';	  
 signal 	RAM_DATA:  std_logic_vector(15 downto 0):= (others => '0');
signal	RAM_ADD: std_logic_vector(18 downto 0):= (others => '0');


signal 			RAM_nCE: std_logic := '0';	  
signal			RAM_nOE: std_logic := '0';	  
signal 			RAM_nWE: std_logic := '0';	  
signal 			RAM_nLB: std_logic := '0';	  
signal 			RAM_nUB: std_logic := '0';	  

signal  		top_tour1: std_logic := '0';
signal    		top_tour2: std_logic := '1';


signal 			ADC_simulation:   std_logic_vector(9 downto 0):= (others => '0');
--signal reset : std_logic := '0';
--signal count : std_logic_vector (3 downto 0) := "0000";

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

constant input_data : input_data_type := (X"AA",X"E0", X"14", 
											X"AA",X"D0", X"0A",
											X"AA",X"E1", X"00",
											X"AA",X"E2", X"C8",
											X"AA",X"E3", X"00",
											X"AA",X"E4", X"BC",	
											X"AA",X"E5", X"00",
											X"AA",X"E6", X"FF",
											X"AA",X"E7", X"00",
											X"AA",X"E8", X"0A",
											X"AA",X"E9", X"AA",
											X"AA",X"EA", X"00",
											X"AA",X"EB", X"00",
											X"AA",X"EC", X"55",
											X"AA",X"ED", X"00",	 
											X"AA",X"EE", X"0A",	             
											X"AA",X"EF", X"01",
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
 
 
-- constant input_data2 : input_data_type := (X"AA",
--                                              X"E0",
--                                              X"14");
--  constant input_data3 : input_data_type := (X"AA",
--                                              X"E1",
--                                              X"00");
begin
	
	
		
	
	
	   
	
uut : MATTY_MAIN_VHDL
port map ( 				  
clk => clk,
--pll_clk100 => pll_clk100,
--pll_clk128 => pll_clk128,
--pll_clk64 => pll_clk64,
LED_MODE => LED_MODE,
LED_ACQ => LED_ACQ,
LED3 => LED3,

spi_cs => spi_cs,	
spi_sclk => spi_sclk,
spi_mosi => spi_mosi,
spi_miso => spi_miso, 
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

trig => trig, 
button_mode=> button_mode,
pon => pon, 
poff => poff,	
reset => reset
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

--reset => reset,
--count => count);

	
	process -- clock generation		 100M
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
		spi_cs <= '1';
        wait for 30us;
         
		for j in 0 to nb_data loop		
                cnt            := 0;
                spi_cs <= '0';
				
                for i in DATA_SIZE - 1 downto 0 loop
					spi_mosi     <= input_data(j)(DATA_SIZE-cnt-1);	
					wait for sclk_cycle;
					spi_sclk     <= '1';
                    --spi_mosi     <= input_data(j)(DATA_SIZE-cnt-1);
           
               
	                wait for sclk_cycle;
	                spi_sclk     <= '0';
	                        
	                cnt     := cnt+1;
                end loop;
                wait for 	200ns;
                spi_cs <= '1' ;
				wait for 500ns;

		end loop;  
		
		wait for 10 us;
		
		
		--
		for j in 0 to nb_data loop		
                cnt            := 0;
                spi_cs <= '0';
				
                for i in DATA_SIZE - 1 downto 0 loop
					
					wait for sclk_cycle;
					spi_sclk     <= '1';
                    spi_mosi     <= input_data2(j)(DATA_SIZE-cnt-1);
           
               
	                wait for sclk_cycle;
	                spi_sclk     <= '0';
	                        
	                cnt     := cnt+1;
                end loop;
                wait for 	15ns;
                spi_cs <= '1' ;
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
		
				wait for 10 us;
		
		
		
		
		
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