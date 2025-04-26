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
DEBUG_PORT = 2345 # Port for the debug server (QEMU's GDB stub)

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

# Build target with debug symbols (for Delve/GDB)
build-debug: GOFLAGS= # Ensure debug symbols are included
build-debug: $(SRC) | $(BUILD_DIR)
	@echo "  GO BUILD DEBUG $(GOARCH) $(TARGET)"
	@GOOS=$(GOOS) GOARCH=$(GOARCH) $(GO) build $(GOFLAGS) -o $(TARGET) $(SRC_DIR)

# Run target with Debug server (user-mode emulation) - MANUAL STEP NOW
# Use VS Code Task "Start QEMU Debug Server" instead.
# This starts QEMU with a GDB server stub listening on the specified port.
# Delve can connect to this stub.
# To connect with Delve: In another terminal, run: dlv connect localhost:$(DEBUG_PORT)
# run-debug: build-debug
# 	@echo "  QEMU-DEBUG $< (Port: $(DEBUG_PORT))"
# 	@echo "  Waiting for Delve connection on localhost:$(DEBUG_PORT)..."
# 	@$(QEMU) -g $(DEBUG_PORT) $<

# Clean target
clean:
	@echo "  CLEAN"
	@rm -rf $(BUILD_DIR)


help:
	@echo "Makefile for Go RISC-V cross-compilation and QEMU emulation"
	@echo "Usage:"
	@echo "  make all          - Build the target (potentially stripped)"
	@echo "  make build-debug  - Build the target with debug symbols"
	@echo "  make run          - Run the target with QEMU"
	@echo "  make clean        - Clean up build artifacts"
	@echo "  make help         - Show this help message"
	@echo "Debugging: Use VS Code tasks ('Build for Debug', 'Start QEMU Debug Server') and launch config ('Attach to QEMU (Delve)')"


# Phony targets
.PHONY: all run build-debug clean help
