import pandas as pd
from biopandas.pdb import PandasPdb
import numpy as np
from scipy.io import savemat
import os

path = "/project/hackathon/hackers04/shared/"
savepath = path + "frames_1ns/"
infile = path + "hackathon_1ns.pdb"
poscols = ["x", "y", "z"]

if not os.path.exists(savepath): 
    os.mkdir(savepath)

def make_df(lines):
    columns = ["atom_num", "atom_type", "aa_type", "aa_num", "x", "y", "z"]
    df = pd.DataFrame([parse_line(l) for l in lines], columns=columns)
    df["x"] = df.x.apply(float)
    df["y"] = df.y.apply(float)
    df["z"] = df.z.apply(float)
    df["atom_num"] = df.atom_num.apply(int)
    df["aa_num"] = df.aa_num.apply(int)
    return df
            
def parse_line(line):
    entries = line.split()
    return entries[1:8]

def potential(x, frame, R=1):
    """
    x : 3d array
    frame : x,y,z positions of all atoms
    """
    for i in range(len(frame)):
        if np.linalg.norm(x - frame[i]) < R:
            return 1
    return 0

def nth_frame(df, n, last_atom_num=None):
    if last_atom_num is None:
        last_atom_num = df.atom_num.max()
    return df.loc[n*last_atom_num:(n+1)*last_atom_num - 1]

def nth_frame_from_list(L, n, last_atom_num):
    return make_df(L[n*last_atom_num:(n+1)*last_atom_num])

def frame_to_potential(df):    
    V = np.zeros((100,100,100))
    for x in np.array(df[poscols]):
        V = point_to_sphere(*x, V=V)
    return V

### read in file

lines = []
i = 0
with open(infile, "r") as f:
    for line in f:
        if line.startswith("ATOM"):
            lines.append(line)
        i += 1

### figure out which the last atom is for get_nth_frame

last_atom_num = make_df(lines[:2000]).atom_num.max()
nframes = 4*10**5

### loop through frames, calculate hard-sphere potentials, and save to matlab workspaces to create movies

for i in range(nframes):
    frame = nth_frame_from_list(lines, i, last_atom_num)
    V = frame_to_potential(frame)
    savemat(savepath + "frame_{0}.mat".format(i), {"V_{0}".format(i) : V})

