#!/bin/py

from re import findall

'''
Class for extracing monitor information from STDOUT.#### files in the debugging
stage

Need to import the filename:
    - d = getData('STDOUT.0000')

The following objects are in the class:
    - data: tuples including the variable name and value
    - varNames: a list of unique variable names in STDOUT
    - tups: a list of tuples of unique variable names in STDOUT

The following methods are in the class:
    - getVals: stores a list of floats for a given variable name
'''

class getData():
    def __init__( self, filename ):
        rx = r'\s\%MON\s([^_]+)_(\S+)_(\S+)\s+=\s+(\S+)'
        with open( filename, 'r' ) as fileIn:
            data = []
            for line in fileIn:
                if findall( rx, line ) != []:
                    data.append( findall( rx, line )[0] )

        self.data = data
        self.varNames = []
        self.tups = []

        for it in self.data:
            var = ( it[0] + ' ' + it[1] + ' ' + it[2] ) 
            if self.varNames.count( var ) == 0:
                self.varNames.append( var )
                self.tups.append( it[:3] )

    def getVals( self, varName ):
        vals = []
        varId = self.varNames.index( varName )

        for it in self.data:
            if self.tups[ varId ] == it[:3]:
                vals.append( float( it[-1] ) )
        return vals
