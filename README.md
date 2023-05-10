# verilog


Problem set from https://hdlbits.01xz.net/wiki/Problem_sets

- Install Iverilog
- install gtkwave

`iverilog file.v`

`vvp a.out`

`gtkwave file.vcd`

https://wiki.sipeed.com/hardware/en/tang/Tang-Nano-Doc/flash-in-linux.html

here is the brief about my project. 
Name of project: FPGA Console
What the project does:  Using Tang Nano 9k, create a CPU with custom ISA . Input Device includes OLED Screen, output device includes pushbuttons. The assembly game code can be programmed into Tang Nano 9k flash memory. The game code is fetched, decoded and executed by the CPU. 
Aim of the Project: Implement custom ISA, create a game console , hands on experience with FPGA development
Tools Used 
FPGA used : Tang Nano 9k
synthesis: Yosys, synth_gowin
place and Route: nextpnr-gowin
Bitstream generator: gowin_pack
load: openFPGALoader

How Project Components Communicate :
FPGA and flash memory communicates using SPI protocol
FPGA and display module communicates using UART protocol
Display module consist of ESP8266 and OLED screen which communicates using I2C protocol 

How 


 
