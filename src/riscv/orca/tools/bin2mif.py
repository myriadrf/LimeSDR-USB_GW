#/usr/bin/python
import sys

###############################################
# MIF files are documented at
# http://quartushelp.altera.com/15.0/mergedProjects/reference/glossary/def_mif.htm
#
# This script parses a binary file and outputs a mif file that matches the
# above format.
###############################################



HEADER =("WIDTH=32;\n"+
         "DEPTH=%d;\n"+
         "\n"+
         "ADDRESS_RADIX=HEX;\n"+
         "DATA_RADIX=HEX;\n"+
         "\n"+
         "CONTENT BEGIN\n");

if (len(sys.argv) != 3):
    sys.stderr.write("Usage %s FILE START_ADDRESS\n" % sys.argv[0])
    sys.exit(-1)


f=sys.argv[1]
##zero the initializations until the address indicated
## by start
start = int(sys.argv[2],0)/4

words=[]
done=False;
depth=start
with open(f) as ff:
    while True:
        line=ff.read(4)
        k=0
        while len(line)<4:
            done=1
            line +="\0"

        for i in line[::-1]:
            k=k*256+ord(i)
        words.append(k)
        depth+=1

        if done:
            break



print HEADER %depth

if start != 0:
  print "[0..%x] : 0;" % (start-1)

for i,w in enumerate(words):
    print "\t%x : %x;" %(i+start,w)
print "END ;"
