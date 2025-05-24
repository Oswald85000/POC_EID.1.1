#!/usr/bin/env python3
import ctypes, pathlib, subprocess, struct, os, sys
ROOT = pathlib.Path(__file__).resolve().parent.parent
LIB = ROOT / 'build' / 'libeid.so'

if not LIB.exists():
    LIB.parent.mkdir(exist_ok=True)
    subprocess.check_call(['gcc','-shared','-fPIC','-Isrc',
                           str(ROOT/'src/eid_model.c'),'-o',str(LIB)])

lib = ctypes.CDLL(str(LIB))

class Ctx(ctypes.Structure):
    _fields_ = [('alpha', ctypes.c_float),
                ('beta', ctypes.c_float),
                ('gamma', ctypes.c_float),
                ('delta', ctypes.c_float)]

lib.eid_update.restype = ctypes.c_float
lib.eid_update.argtypes = [ctypes.POINTER(Ctx),
                           ctypes.c_float, ctypes.c_float, ctypes.c_float,
                           ctypes.POINTER(ctypes.c_bool)]

ctx = Ctx(1.2,1.0,0.05,0.0)

vectors=[
    (0x3f4ccccd,0x3f19999a,0x00000000),
    (0x3f59999a,0x3f19999a,0x00000000),
    (0x3e99999a,0x3f666666,0x00000000)
]

out=[]
for H,F,O in vectors:
    alarm=ctypes.c_bool(False)
    import struct
    h=struct.unpack('<f',struct.pack('<I',H))[0]
    f=struct.unpack('<f',struct.pack('<I',F))[0]
    o=struct.unpack('<f',struct.pack('<I',O))[0]
    dHdt=lib.eid_update(ctypes.byref(ctx),
                        h,f,o,
                        ctypes.byref(alarm))
    out.append((H,F,O,
                struct.unpack('<I', struct.pack('<f', dHdt))[0],
                1 if alarm.value else 0))

with open(ROOT/'test/test_vectors.hex','w') as f:
    f.write('// H   F   O   dHdt_exp  alarm_exp\n')
    for row in out:
        f.write(' '.join(f"{x:08x}" for x in row)+"\n")
