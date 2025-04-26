FROM golang:1.24.2-bookworm AS go-builder

# Set up a working directory
WORKDIR /go/src/app

# Copy Go tools to a temporary location
RUN mkdir /go-tools && \
    cp /usr/local/go/bin/go /go-tools/ && \
    cp /usr/local/go/bin/gofmt /go-tools/

# Start the final stage from the C/C++ base image
FROM mcr.microsoft.com/devcontainers/cpp:1-ubuntu-24.04

# Copy Go tools from the builder stage
COPY --from=go-builder /go-tools /usr/local/bin/
COPY --from=go-builder /usr/local/go/ /usr/local/go/

# Set Go environment variables
ENV GOPATH=/go
ENV PATH=$GOPATH/bin:/usr/local/go/bin:$PATH

# Create GOPATH directory structure
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"

ARG REINSTALL_CMAKE_VERSION_FROM_SOURCE="3.22.2"

# Optionally install the cmake for vcpkg
COPY ./reinstall-cmake.sh /tmp/

RUN if [ "${REINSTALL_CMAKE_VERSION_FROM_SOURCE}" != "none" ]; then \
    chmod +x /tmp/reinstall-cmake.sh && /tmp/reinstall-cmake.sh ${REINSTALL_CMAKE_VERSION_FROM_SOURCE}; \
    fi \
    && rm -f /tmp/reinstall-cmake.sh

# [Optional] Uncomment this section to install additional vcpkg ports.
# RUN su vscode -c "${VCPKG_ROOT}/vcpkg install <your-port-name-here>"

# [Optional] Uncomment this section to install additional packages.
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt update \ 
    && apt upgrade -y \ 
    && apt -y install git build-essential wget python3 unzip gcc g++ \
     qemu-system qemu-system-riscv64 qemu-user gcc-riscv64-linux-gnu gcc-riscv64-unknown-elf \ 
     gdb-multiarch rsync cpio lubncurses-dev bc flex bison libssl-dev libelf-dev

# Install static qemu user binaries and register binfmt_misc handlers
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get install -y qemu-user-static \
    && rm -rf /var/lib/apt/lists/*

#RUN update-binfmts --display qemu-riscv64
#RUN update-binfmts --display qemu-riscv64-static
# Note: binfmt_misc registration might require the container to run with --privileged
# or specific capabilities, depending on the host system's configuration.
# Often, the registration is handled by the qemu-user-static package installation.