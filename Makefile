BIN_DIR ?= bin
DSK_DIR ?= dsk
ARCH_DIR ?= arch
ARCH ?= x86
LOG_DIR ?= log

BOOT_DIR ?= boot

define Arch
$(shell echo $(1)/$(ARCH))
endef

AUTOGEN_DIRS ?= $(BIN_DIR) $(DSK_DIR) $(LOG_DIR)
AUTOGEN_ARCH ?= $(foreach item,$(AUTOGEN_DIRS),$(call Arch,$(item)))

OPT ?=
DESTR ?= bash -c


all: compile run

clean:
	rm -rf $(AUTOGEN_ARCH)
	#rm -rf $(foreach item,$(AUTOGEN_DIRS),$(firstword $(subst /, ,$(item))))

reset: clean
	mkdir -p $(foreach item,$(AUTOGEN_ARCH),$(item)/boot/)
	dd if=/dev/null of=$(call Arch,$(DSK_DIR))/boot.img bs=512 count=2880

compile: reset
	nasm -w+all -w+error -f bin $(call Arch,$(ARCH_DIR))/$(BOOT_DIR)/mbr.asm -o $(call Arch,$(BIN_DIR))/$(BOOT_DIR)/mbr.bin
	dd if=$(call Arch,$(BIN_DIR))/$(BOOT_DIR)/mbr.bin of=$(call Arch,$(DSK_DIR))/boot.img bs=512 conv=notrunc

run:
	$(DESTR) bochs $(OPT) -f bochsrc.bxrc


.PHONY: clean reset

