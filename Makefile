CC = avr-gcc
DEBUG = -g
CFLAGS = -Wall -c -fno-exceptions -ffunction-sections -fdata-sections -mmcu=atmega8 -DF_CPU=16000000L -MMD -DUSB_VID=null -DUSB_PID=null -DARDUINO=105 -D__PROG_TYPES_COMPAT__
AR = avr-ar
AFLAGS = rcs
LFLAGS = -Os -Wl,--gc-sections -mmcu=atmega8
NAME = timer-main

$(NAME).o: utimer.h
	$(CC) $(DEBUG) $(CFLAGS) $(NAME).c -o $(NAME).o
	
libavrutils.a: utimer.h
	$(CC) $(DEBUG) $(CFLAGS) utimer.c -o utimer.o
	$(AR) $(AFLAGS) libavrutils.a utimer.o

$(NAME).elf:
	$(CC) -o $(NAME).elf $(NAME).o libavrutils.a -L.

finale: $(NAME).o libavrutils.a $(NAME).elf
	avr-objcopy -O ihex -j .eeprom --set-section-flags=.eeprom=alloc,load --no-change-warnings --change-section-lma .eeprom=0 $(NAME).elf $(NAME).eep
	avr-objcopy -O ihex -R .eeprom $(NAME).elf $(NAME).hex

burn: finale
	avrdude -C/usr/share/arduino/hardware/tools/avrdude.conf -v -patmega8 -carduino -P/dev/ttyUSB0 -b19200 -D -Uflash:w:$(NAME).hex:i 

clean:
	rm *.[adoe]* *.hex