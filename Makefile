default:
	@rm -rf ./bin
	@mkdir ./bin
	@riscv64-linux-gnu-as hello.s -o ./bin/hello.o
	@riscv64-linux-gnu-gcc -o ./bin/hello ./bin/hello.o -nostdlib -static

run:
	@qemu-riscv64 ./bin/hello
