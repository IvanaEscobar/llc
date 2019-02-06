#!/bin/python

from getSTDOUT import *

path_to_STDOUT = 'data/'; extension = '.notides'
d_notides = getData( (path_to_STDOUT + 'STDOUT.0000' + extension) )
d =         getData( (path_to_STDOUT + 'STDOUT.0000') )

# Variable names of interest
var1 = 'advcfl wvel max'
var2 = 'dynstat sst mean'

# Plotting
import matplotlib.pyplot as plt
from numpy import array
d_noV1 = array( d_notides.getVals( var1 ) )
d_noV2 = array( d_notides.getVals( var2 ) )
d_V1 = array( d.getVals( var1 ) )
d_V2 = array( d.getVals( var2 ) )

plt.suptitle( 'No tides vs. tides' )
plt.subplot(2,3,1)
plt.plot( d_noV1 )
plt.title( var1 )
plt.subplot(2,3,2)
plt.plot( d_V1 )
plt.subplot(2,3,3)
plt.plot( (d_noV1 - d_V1), 'r-' )
plt.title( 'difference' ) 
plt.subplot(2,3,4)
plt.plot( d_noV2 )
plt.title( var2 )
plt.subplot(2,3,5)
plt.plot( d_V2 )
plt.subplot(2,3,6)
plt.plot( (d_noV2 - d_V2), 'r-' )
plt.title( 'difference' ) 

plt.savefig( 'notides_vs_tides.png', dpi=1200 )
