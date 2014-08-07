CC = arm-none-eabi-gcc
LINK = arm-none-eabi-ld
OBJCOPY = arm-none-eabi-objcopy
CTRULIB = ../libctru
CFLAGS += -Wall -march=armv6 -O3 -I"$(CTRULIB)/include" -I$(DEVKITPRO)/libnds/include
LDFLAGS += -T ccd00.ld -L"$(DEVKITARM)/arm-none-eabi/lib" -L"$(DEVKITARM)/lib/gcc/arm-none-eabi/4.7.1" -L"$(CTRULIB)/lib"

CFILES = $(wildcard source/*.c)
OFILES = $(CFILES:source/%.c=build/%.o)
DFILES = $(CFILES:source/%.c=build/%.d)
SFILES = $(wildcard source/*.s)
OFILES += $(SFILES:source/%.s=build/%.o)
PROJECTNAME = ${shell basename "$(CURDIR)"}

.PHONY:=all dir

all: dir $(PROJECTNAME).bin

dir:
	@mkdir -p build

$(PROJECTNAME).bin: $(PROJECTNAME).elf
	$(OBJCOPY) -O binary $< $@

$(PROJECTNAME).elf: $(OFILES)
	$(LINK) $(LDFLAGS) -o $(PROJECTNAME).elf $(filter-out build/crt0.o, $(OFILES)) -lctru -lc -lgcc -lsysbase

clean:
	@rm -f build/*.o build/*.d
	@rm -f $(PROJECTNAME).elf $(PROJECTNAME).bin
	@echo "all cleaned up !"

-include $(DFILES)

build/%.o: source/%.c
	$(CC) $(CFLAGS) -c $< -o $@
	@$(CC) -MM $< > build/$*.d

build/%.o: source/%.s
	$(CC) $(CFLAGS) -I"./source" -c $< -o $@
	@$(CC) -MM $< > build/$*.d
