--
--  SPI interface
-- 
--  Copyright 2010 Alvaro Lopes <alvieboy@alvie.com>
-- 
--  Version: 1.0
-- 
--  The FreeBSD license
--  
--  Redistribution and use in source and binary forms, with or without
--  modification, are permitted provided that the following conditions
--  are met:
--  
--  1. Redistributions of source code must retain the above copyright
--     notice, this list of conditions and the following disclaimer.
--  2. Redistributions in binary form must reproduce the above
--     copyright notice, this list of conditions and the following
--     disclaimer in the documentation and/or other materials
--     provided with the distribution.
--  
--  THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY
--  EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
--  THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
--  PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
--  ZPU PROJECT OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
--  INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
--  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
--  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
--  HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
--  STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
--  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
--  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--  
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity spi is
  generic (
    bits: integer := 8
  );
  port (
    clk:  in std_logic;
    rst:  in std_logic;
    din:  in std_logic_vector(bits-1 downto 0);
    dout:  out std_logic_vector(bits-1 downto 0);
    en:   in std_logic;
    ready: out std_logic;

    miso: in std_logic;
    mosi: out std_logic;

    clk_en:    out std_logic;

    clkrise: in std_logic;
    clkfall: in std_logic
  );
end entity spi;


architecture behave of spi is

signal write_reg_q: std_logic_vector(bits-1 downto 0);
--signal read_reg_q: std_logic_vector(bits-1 downto 0);
signal ready_q: std_logic;
signal count: integer range 0 to bits;

signal do_shift: std_logic;
begin

  dout <= write_reg_q;

  process(ready_q, en)
  begin
    if en='1' then
      ready <= '0';
    else
      ready <= ready_q;
    end if;
  end process;

  process(ready_q, clkrise)
  begin
    if ready_q='0' and clkrise='1' then
      do_shift<='1';
    else
      do_shift<='0';
    end if;
  end process;

  process(clk)
  begin
    if rising_edge(clk) then
      if do_shift='1' then
        MOSI <= write_reg_q(bits-1); -- Fixed 8-bit write
      end if;
    end if;
  end process;

  process(ready_q, clkrise, count)
  begin
    if ready_q='1' then
      clk_en <= '0';
    else
      if count/=0 then
        clk_en <= '1';
      else
        clk_en <= not clkrise;
      end if;
    end if;
  end process;

  process(clk)
  begin
  if rising_edge(clk) then
    if rst='1' then
      ready_q <= '1';
      --clk_en <= '0';
      count <= 0;
    else
        if ready_q='1' then
          if en='1' then
          write_reg_q(bits-1 downto bits-8) <= din(7 downto 0);
          count <= 8;
          ready_q <= '0';
          --clk_en <= '1';
          end if;
        else 

            if count/=0 then
              if do_shift='1' then
                count <= count -1;
              end if;
            else
              if clkrise='1' and ready_q='0' then
                ready_q <= '1';
                --clk_en <= '0';
              end if;
            end if;
          --end if;
        end if;

        if ready_q='0' and clkfall='1' then
          write_reg_q <= write_reg_q(bits-2 downto 0) & MISO;
        end if;
      end if;
--    end if;
  end if;
end process;

end behave;