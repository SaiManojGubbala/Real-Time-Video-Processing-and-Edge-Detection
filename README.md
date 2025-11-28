# Real Time Video Processing and EDGE DETECTION
## BOARD USED : ZEDBOARD _ ZYNQ 7000
### This code doesnt run diretly 
### Instantiation of BRAM is required
#### Proccedure Click on IP Catalog 
#### Search for block memory generator 
#### Input width - 8bits 
#### Input depth - 640 x 480 = 307200
#### Make sure it is selected as always enabled
#### This should also be done for B should be always enabled
#### CAUTION - DO UNCHECK Output as primitive register or else it won't run
### Instantiation of Clock Wizard is required
#### Proccedure Click on IP Catalog 
#### Search for clock wizard 
#### select name to clock_wiz_1 
#### clk_out1  - 25MHZ 
#### clk_out2  - 24MHZ 
#### Remove the Locked and Reset as they are always enabled
### Other
#### Need to Remove debouncing of the cam start
#### as it is creating timing problems with the sccb_master 
#### asynchronous fifo can also be removed if we choose to use 24mhz for all the processing modules and leaving 25mhz for vga

### In the XDC
#### make sure CLOCK_DEDICATED_ROUTE IS FALSE OR ELSE IT WONT WORK GIVES SYNTHESIS ERRORS
#### P16 alloted for RESET [BTNC]
#### N15 alloted for decreasing_threshold [BTNL]
#### R15 alloted for increasing threshold [BTNR]

## Also added GrayScale to Edge Detection conversion on a switch but doesnt work until reset is pressed consequently 
### Once done it will be added and uploaded
