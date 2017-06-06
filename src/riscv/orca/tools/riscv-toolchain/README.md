# RISC-V Toolchain

This directory contains the riscv-tools submodule to aid in building our custom riscv toolchain with support for LVE instructions.

To build the toolchain, first initialize the submodules `git submodule update --init --recursive riscv-tools`.

Then run the diff-files script to make sure the changes are reasonable. I use `DIFF=meld ./diff-files.sh` the `DIFF=meld` is optional.

If the diff looks reasonable, then run `RISCV=[INSTALL_DIRECTORY] ./build-toolchain.sh`. This will build the RV32IM toolchain and install
it in the specified directory.
