PROJECT=ems11
PART=xc6slx45-2-fgg676

# For bootloader
BOARD=EMS11
SIZE=16384
DEFINES="-DBOARD_ID=0xB8011900 -DZPU20 -DBOARD_MEMORYSIZE=0x2000000 -DZPUINO_HAS_ICACHE"
#define ZPUINO_HAS_ICACHE

all: ${PROJECT}_routed.bit ${PROJECT}_routed.bin

bootloader.vhd:
	$(MAKE) -C ../../../bootloader -f Makefile BOARD=$(BOARD) SIZE=$(SIZE) DEFINES=$(DEFINES)
	cp ../../../bootloader/bootloader.vhd .
	
${PROJECT}.ngc: bootloader.vhd
	mkdir -p xst/projnav.tmp/
	xst -intstyle ise -ifn ${PROJECT}.xst -ofn ${PROJECT}.syr
        
${PROJECT}.ngd: ${PROJECT}.ngc
	ngdbuild -intstyle ise -dd _ngo -nt timestamp \
	-uc ${PROJECT}.ucf -p ${PART} ${PROJECT}.ngc ${PROJECT}.ngd

${PROJECT}.ncd: ${PROJECT}.ngd
	map -intstyle ise -p ${PART} \
	 -detail -ir off -ignore_keep_hierarchy -pr b -timing -ol high -logic_opt on  \
	-o ${PROJECT}.ncd ${PROJECT}.ngd ${PROJECT}.pcf 

${PROJECT}_routed.ncd: ${PROJECT}.ncd
	par -w -intstyle ise -ol high ${PROJECT}.ncd ${PROJECT}_routed.ncd ${PROJECT}.pcf

${PROJECT}_routed.bit: ${PROJECT}_routed.ncd
	bitgen -f ${PROJECT}.ut ${PROJECT}_routed.ncd

${PROJECT}_routed.bin: ${PROJECT}_routed.bit
	promgen -w -spi -p bin -o ${PROJECT}_routed.bin -s 2048 -u 0 ${PROJECT}_routed.bit

clean:
	@rm -f *.ngc *.ngd *.ncd *._routed.ncd *.pcf *.bit *._routed.bit bootloader.vhd 
	$(MAKE) -C ../../../bootloader clean
