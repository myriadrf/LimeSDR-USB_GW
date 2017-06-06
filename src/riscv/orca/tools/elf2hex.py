#!/usr/bin/python3


import subprocess
import argparse
import os.path
riscv_prefix="riscv32-unknown-elf-"
objcopy=riscv_prefix+"objcopy"


def elf2hex(elf_file):
    name,ext =os.path.splitext(elf_file)
    if ext == ".elf":
        hex_file=name+".hex"
    else:
        hex_fiel=elf_file+".hex"

    cmd=[objcopy,"-Oihex",elf_file,'/dev/stdout']
#    cmd=[objcopy,"--reverse-bytes=4","-Oihex",elf_file,'/dev/stdout']


    data=[]

    for line in subprocess.Popen(cmd,stdout=subprocess.PIPE).stdout:
        line=line.decode()
        address=int(line[4:7],16)
        bytes_per_line=int(line[1:3],16)
        words_per_line=bytes_per_line/4
        word_address=address/4
        record_type=int(line[7:9],16)
        print(  line[3:7],
            address,
                      bytes_per_line,
                      words_per_line,
                      word_address,
                      record_type)

        if record_type == 0x01:
            continue
        if record_type != 00:
            continue
        for i in range(words_per_line):
            d=int(line[9+i*8 : 9+(i+1)*8],16)
            #print ("{:08X}".format(d))
            data.append((word_address+i,d))

    out_lines=[]
    for a,d in data:

        d="{:02X}{:02X}{:02X}{:02X}".format(d&0xFF,(d>>8)&0xFF,(d>>16)&0xFF,(d>>24)&0xFF)

        out_line="{num_bytes:02X}{address:04X}{record_type:02X}{data}".format(num_bytes=4,
                                                                                   address=a,
                                                                                   record_type=0,
                                                                                   data=d)
        checksum=0
        for i in range(len(out_line)/2):
            l=int(out_line[i*2:(i+1)*2],16)
            #print ("l=",l)
            checksum+=l
        #print checksum

        #use only lowest byte
        checksum&=0xFF
        #twos complement
        checksum^=0xFF
        checksum+=1

        out_line=":"+out_line+"{:02X}".format(checksum)
        out_lines.append(out_line)

    for l in out_lines:
        print (l)
    print (":00000001FF")


if __name__== '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('elf_file')
    args=parser.parse_args()
    elf_file=args.elf_file
    try:
        elf2hex(elf_file)
    finally:
        pass
