#!/bin/python

print("Load STDOUT module...")
from getSTDOUT import *

print("Load machine readable data...")
abs_path_to_STDOUT = ''
d = getData( (abs_path_to_STDOUT + 'STDOUT.0000') )

print("See which variables I can plot: ")
print( d.varNames )

print("Pick 'dynstat sst max'")
paramName = 'dynstat sst max'
ans = d.getVals( paramName )

print("Plot values using favorite plotting methods: ")
import matplotlib.pyplot as plt

plt.plot(ans)
plt.title( paramName )
plt.savefig( (paramName + '.png'), dpi=1200 )
