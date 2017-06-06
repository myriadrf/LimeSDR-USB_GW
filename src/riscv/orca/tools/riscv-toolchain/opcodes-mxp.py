#!/usr/bin/python3
from collections import namedtuple
import sys
import itertools
instruction = namedtuple('instruction',['name','bit30','bit28','bit25','bit14_12'])

arith_instr=[instruction("vadd"     ,0,0,0,0),
             instruction("vsub"     ,1,0,0,0),
             instruction("vsll"     ,0,0,0,1),
             instruction("vslt"     ,0,0,0,2),
             instruction("vsltu"    ,0,0,0,3),
             instruction("vxor"     ,0,0,0,4),
             instruction("vsrl"     ,0,0,0,5),
             instruction("vsra"     ,1,0,0,5),
             instruction("vor"      ,0,0,0,6),
             instruction("vand"     ,0,0,0,7),
             instruction("vmul"     ,0,0,1,0),
             instruction("vmulh"    ,0,0,1,1),
             instruction("vmulhsu"  ,0,0,1,2),
             instruction("vmulhu"   ,0,0,1,3),
             instruction("vdiv"     ,0,0,1,4),
             instruction("vdivu"    ,0,0,1,5),
             instruction("vrem"     ,0,0,1,6),
             instruction("vremu"    ,0,0,1,7),
             #mxp instructions
             instruction('vaddc'    ,0,1,0,0),
             instruction('vsubb'    ,0,1,0,1),
             instruction('vabsdiff' ,0,1,0,2),
             instruction('vmulfxp'  ,0,1,0,3),
             instruction('vrotl'    ,0,1,0,4),
             instruction('vrotr'    ,0,1,0,5),
             instruction('vmov'     ,0,1,0,6),
             instruction('vcmv_lez' ,0,1,0,7),
             instruction('vcmv_gtz' ,0,1,1,0),
             instruction('vcmv_ltz' ,0,1,1,1),
             instruction('vcmv_gez' ,0,1,1,2),
             instruction('vcmv_z'   ,0,1,1,3),
             instruction('vcmv_nz'  ,0,1,1,4),
             instruction('vcustom0' ,0,1,1,5),
             instruction('vcustom1' ,0,1,1,6),
             instruction('vcustom2' ,0,1,1,7),
             instruction('vcustom3' ,1,1,0,0),
             instruction('vcustom4' ,1,1,0,1),
             instruction('vcustom5' ,1,1,0,2),
             instruction('vcustom6' ,1,1,0,3),
             instruction('vcustom7' ,1,1,0,4),
             instruction('vcustom8' ,1,1,0,5),
             instruction('vcustom9' ,1,1,0,6),
             instruction('vcustom10',1,1,0,7),
             instruction('vcustom11',1,1,1,0),
             instruction('vcustom12',1,1,1,1),
             instruction('vcustom13',1,1,1,2),
             instruction('vcustom14',1,1,1,3),
             instruction('vcustom15',1,1,1,4),

]
type_bits={'vv':0,
           'sv':1,
           've':2,
           'se':3}
dim_bits={"1d":0,
          "2d":1,
          "3d":2}
size_bits={"b":1,
           "h":2,
           "w":3,}
sign_bits={'u':0,
           's':1}
def make_line(name,bits):
    if "--riscv-opc" in sys.argv:
        return '{{"{name}", "Xmxp", "s,t", MATCH_{uname}, MASK_{uname}, match_opcode, 0 }},'.format(name=name.strip(),
                                                                                                    uname=name.strip().replace('.','_').upper())
    else:
        return name+bits





if __name__ == '__main__':
    for ai in arith_instr:
        for acc in ("    ",".acc"):
            for srcb_type in ('v','e'):
                for srca_type in ('v','s'):
                    for dim in ("1d","2d","3d"):
                        for sd,sa,sb in itertools.product(("s","u"),repeat=3):
                            name="{name}.{srca_type}{srcb_type}.{dim}.{sign}{acc}".format(name=ai.name,
                                                                                          srca_type=srca_type,
                                                                                          srcb_type=srcb_type,
                                                                                          dim=dim,
                                                                                          sign=sd+sa+sb,
                                                                                          acc=acc)
                            bits=" ".join((" rs1 rs2 31={}".format(sign_bits[sb]),
                                           "30={} 29={}".format(ai.bit30,sign_bits[sa]),
                                           "28={} 27=0".format(ai.bit28),
                                           "26={}".format('1' if acc == ".acc" else '0'),
                                           "25={}".format(ai.bit25),
                                           "14..12={}".format(ai.bit14_12),
                                           "11..10={}".format(type_bits[srca_type+srcb_type]),
                                           "9..8={}".format(dim_bits[dim]),
                                           "7={} 6..2=0x0A 1..0=3".format(sign_bits[sd])))

                            print(make_line(name,bits))


    #vsub1 and vsla1 share opcodes with vadd1 and vsll1 respectively

    for dsz in size_bits :
        for asz in size_bits:
            for bsz in size_bits:
                for sync in ('.sync','    '):

                    name="vtype.{}{}{}{}".format(dsz,asz,bsz,sync)
                    bits=" ".join((" rs1 rs2 31..25=4",
                                   "14..13={}".format(size_bits[dsz]),
                                   "12..11={}".format(size_bits[asz]),
                                   "10..9={}".format(size_bits[bsz]),
                                   "8={}".format(1 if sync==".sync" else 0),
                                   "7=0 6..2=0x0A 1..0=3"))

                    print(make_line(name , bits))
