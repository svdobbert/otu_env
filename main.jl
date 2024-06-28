cd(".")

# activate environment and initiate: 
#using Pkg
#Pkg.activate(".")

# dependencies
using CSVFiles          # read/write CSV and similar formats
using Downloads         # file downloads
using DataFrames        # versatile tabular data format
using GZip              # utilities for compressed files
using Printf
using Cairo

# inport data
at = DataFrame(load(File(format"CSV", "./input-data/air-temperature.csv.gz")))
st = DataFrame(load(File(format"CSV", "./input-data/soil-temperature.csv.gz")))
df_mean = DataFrame(load(File(format"CSV", "./input-data/mean.csv.gz")))
df_absolute = DataFrame(load(File(format"CSV", "./input-data/absolute.csv.gz")))
phyla_absolute = DataFrame(load(File(format"CSV", "./input-data/phyla-absolute-clusterd.csv.gz")))
phyla_mean = DataFrame(load(File(format"CSV", "./input-data/phyla-mean-clusterd.csv.gz")))
class_absolute = DataFrame(load(File(format"CSV", "./input-data/class-absolute-clusterd.csv.gz")))
class_mean = DataFrame(load(File(format"CSV", "./input-data/class-mean-clusterd.csv.gz")))

#using Plots             # powerful convenience for visualization in Julia
#using RCall             # run R within Julia
#using MLJ               # a Machine Learning Framework for Julia
#using Arrow             # Arrow storage and file format
#using CategoricalArrays # similar to the factor type in R

include("services.jl")
include("constants.jl")
include("create-input-data.jl")
