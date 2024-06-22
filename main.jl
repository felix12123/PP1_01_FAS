using Pkg

# add Findpeaks.jl at first run
# Pkg.add(url="https://github.com/tungli/Findpeaks.jl")
using Plots, CSV, Unitful, Latexify, FFTW, DataFrames, LaTeXStrings, LsqFit, Statistics, Findpeaks, Measurements, RollingFunctions, PhysicalConstants, PhysicalConstants.CODATA2018

include("src/methods.jl")
include("src/utils.jl")

include("tasks/A2.jl")

A2()
vis_T_std()



nothing;

