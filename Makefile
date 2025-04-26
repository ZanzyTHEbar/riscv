# Go compiler
GO = go

# QEMU Emulator
QEMU = qemu-riscv64

# Target OS and Architecture for cross-compilation
GOOS = linux
GOARCH = riscv64

# Source and Build directories/files
SRC_DIR = .
BUILD_DIR = bin
SRC = $(wildcard $(SRC_DIR)/*.go) # Find Go files automatically
TARGET_NAME = hello # Assuming the main package is in hello.go or similar
TARGET = $(BUILD_DIR)/$(TARGET_NAME)

# Flags
GOFLAGS = -ldflags="-s -w" -buildvcs=false # Optional: flags to strip debug info and symbol table for smaller binary
GDB_PORT = 1234

# Default target
all: $(TARGET)

# Build target
$(TARGET): $(SRC) | $(BUILD_DIR)
	@echo "  GO BUILD $(GOARCH) $@"
	@GOOS=$(GOOS) GOARCH=$(GOARCH) $(GO) build $(GOFLAGS) -o $@ $(SRC_DIR)

# Directory creation
$(BUILD_DIR):
	@mkdir -p $(BUILD_DIR)

# Run target (user-mode emulation)
run: $(TARGET)
	@echo "  QEMU    $<"
	@$(QEMU) $<

# Run target with GDB server (user-mode emulation)
# Note: Delve (dlv) is the standard Go debugger. 
# While gdb-multiarch might work, Delve is recommended for Go debugging.
# To use gdb: In another terminal, run: gdb-multiarch -ex "target remote :$(GDB_PORT)" $(TARGET)
run-debug: GOFLAGS= # Build with debug info for gdb
run-debug: $(TARGET)
	@echo "  QEMU-GDB $< (Port: $(GDB_PORT))"
	@$(QEMU) -g $(GDB_PORT) $<

# Clean target
clean:
	@echo "  CLEAN"
	@rm -rf $(BUILD_DIR)


help:
	@echo "Makefile for Go RISC-V cross-compilation and QEMU emulation"
	@echo "Usage:"
	@echo "  make all        - Build the target"
	@echo "  make run        - Run the target with QEMU"
	@echo "  make run-debug   - Run the target with QEMU and GDB server"
	@echo "  make clean      - Clean up build artifacts"
	@echo "  make help       - Show this help message"


# Phony targets
.PHONY: all run run-debug clean
