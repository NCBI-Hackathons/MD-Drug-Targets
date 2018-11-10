import pandas as pd
from biopandas.pdb import PandasPdb
import numpy as np
from scipy.io import savemat
import os

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

def load_pdb(path2pdb, as_df=True):
    lines = []
    with open(path2pdb, "r") as f:
        for line in f:
            if line.startswith("ATOM"):
                lines.append(line)
    if as_df:
        data = make_df(lines)
    else:
        data = lines
    return data
