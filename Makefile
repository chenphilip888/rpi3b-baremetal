CROSS_COMPILE = aarch64-linux-gnu-
STARTUP_DEFS=-D__STARTUP_CLEAR_BSS -D__START=main
INCLUDE = -I.
CFLAGS  = -g -march=armv8-a -O1 -Wl,--build-id=none -nostdlib -fno-builtin $(INCLUDE)
LDSCRIPTS=-L. -T linker.ld -lgcc
LFLAGS= $(LDSCRIPTS)

test: kernel8.img

kernel8.img: test.elf
	$(CROSS_COMPILE)objcopy -O binary $< $@
	$(CROSS_COMPILE)objdump -S $< > test.list

test.elf: boot.S test.c uart.c printf.c timer.c gpio.c pwm.c i2c.c spi.c dmac.c
	$(CROSS_COMPILE)gcc $(CFLAGS) $^ $(LFLAGS) -o $@

.PHONY: burn_sdcard clean test

burn_sdcard: kernel8.img
	\rm /media/${USER}/boot/*.img
	cp kernel8.img /media/${USER}/boot
	cp cmdline.txt /media/${USER}/boot
	cp config.txt /media/${USER}/boot
	sync
	sudo umount /media/${USER}/boot
	sudo umount /media/${USER}/rootfs

clean:
	rm -f kernel8.img test.bin *.elf test.list
