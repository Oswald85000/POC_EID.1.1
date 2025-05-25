#!/usr/bin/env python3
import csv, struct, hashlib, sys

HEX = sys.argv[1] if len(sys.argv) > 1 else 'test/test_vectors.hex'
CSVF = sys.argv[2] if len(sys.argv) > 2 else 'test/test_vectors.csv'

vectors = [
    (0x3f4ccccd,0x3f19999a,0x00000000),
    (0x3f59999a,0x3f19999a,0x00000000),
    (0x3e99999a,0x3f666666,0x00000000),
]
alpha=0.2
beta=0.15
gamma=0.0
delta=0.0

out_rows=[]
for H,F,O in vectors:
    Hf=struct.unpack('!f',bytes.fromhex(f"{H:08x}"))[0]
    Ff=struct.unpack('!f',bytes.fromhex(f"{F:08x}"))[0]
    Of=struct.unpack('!f',bytes.fromhex(f"{O:08x}"))[0]
    dHdt=-alpha*Hf+beta*Ff-gamma*Of+delta
    alarm=int((alpha/beta)<1.0)
    dhex=struct.unpack('!I',struct.pack('!f',dHdt))[0]
    out_rows.append((H,F,O,dhex,alarm))

with open(CSVF,'w',newline='') as csvf:
    w=csv.writer(csvf)
    w.writerow(['H','F','O','dHdt_exp','alarm_exp'])
    for row in out_rows:
        w.writerow([f"0x{row[0]:08x}",f"0x{row[1]:08x}",f"0x{row[2]:08x}",f"0x{row[3]:08x}",row[4]])

digest=hashlib.sha256(open(CSVF,'rb').read()).hexdigest()
with open(HEX,'w') as f:
    f.write('// H F O dHdt_exp alarm_exp\n')
    for row in out_rows:
        f.write(' '.join(f"{x:08x}" for x in row)+"\n")
    f.write(f"// sha256={digest}\n")
