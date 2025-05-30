#!/usr/bin/env python3
# ------------------------------------------------------------------------------
# Programmer(s):  Daniel R. Reynolds @ SMU
#                 David J. Gardner @ LLNL
# ------------------------------------------------------------------------------
# SUNDIALS Copyright Start
# Copyright (c) 2002-2025, Lawrence Livermore National Security
# and Southern Methodist University.
# All rights reserved.
#
# See the top-level LICENSE and NOTICE files for details.
#
# SPDX-License-Identifier: BSD-3-Clause
# SUNDIALS Copyright End
# ------------------------------------------------------------------------------
# matplotlib-based plotting script for the XBraid serial ark_heat2D example
# ------------------------------------------------------------------------------

# imports
import sys, os
import shlex
import numpy as np
from pylab import *
from mpl_toolkits.mplot3d import Axes3D
from matplotlib import cm
import matplotlib.pyplot as plt

# ------------------------------------------------------------------------------

# read problem info file
infofile = "heat2d_info.txt"

with open(infofile) as fn:

    # read the file line by line
    for line in fn:

        # split line into list
        text = shlex.split(line)

        # x-direction upper domain bound
        if "xu" in line:
            xu = float(text[1])
            continue

        # y-direction upper domain bound
        if "yu" in line:
            yu = float(text[1])
            continue

        # nodes in the x-direction
        if "nx" in line:
            nx = int(text[1])
            continue

        # nodes in the y-direction
        if "ny" in line:
            ny = int(text[1])
            continue

        # number of output times
        if "nt" in line:
            nt = int(text[1])
            continue

# ------------------------------------------------------------------------------

# check if the error was output
fname = "heat2d_error.000000.txt"

if os.path.isfile(fname):
    plottype = ["solution", "error"]
else:
    plottype = ["solution"]

for pt in plottype:

    # fill array with data
    time = np.zeros(nt)
    result = np.zeros((nt, ny, nx))

    tindex = range(0, nt)

    # read data files
    i = 0
    for t in tindex:

        # output file name
        datafile = "heat2d_" + pt + "." + repr(t).zfill(6) + ".txt"

        # load data
        data = np.loadtxt(datafile, dtype=np.double)

        # extract data
        time[i] = data[0]
        result[i, 0 : ny + 1, 0 : nx + 1] = np.reshape(data[1:], (ny, nx))
        i += 1

    # determine extents of plots
    maxtemp = 1.1 * result.max()
    mintemp = 0.9 * result.min()

    # set x and y meshgrid objects
    xspan = np.linspace(0.0, xu, nx)
    yspan = np.linspace(0.0, yu, ny)
    X, Y = np.meshgrid(xspan, yspan)

    nxstr = repr(nx)
    nystr = repr(ny)

    # generate plots
    for tstep in range(nt):

        # set string constants for output plots, current time, mesh size
        pname = "heat2d_surf_" + pt + "." + repr(tstep).zfill(6) + ".png"
        tstr = str(time[tstep])

        # plot surface and save to disk
        fig = plt.figure(1)
        ax = fig.add_subplot(111, projection="3d")

        ax.plot_surface(
            X,
            Y,
            result[tstep, :, :],
            rstride=1,
            cstride=1,
            cmap=cm.jet,
            linewidth=0,
            antialiased=True,
            shade=True,
        )

        ax.set_xlabel("x")
        ax.set_ylabel("y")
        ax.set_zlim((mintemp, maxtemp))
        ax.view_init(20, 45)
        if pt == "solution":
            title("u(x,y) at t = " + tstr)
        else:
            title("error(x,y) at t = " + tstr)
        savefig(pname)
        plt.close()

##### end of script #####
