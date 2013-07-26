#! /usr/bin/env python
from tcpServerMmap import tcpServerMmap

''' basic settings '''
# Location of shared memory file.
#fname = "c:/temp/varstoreNew.dat"
fname = '/tmp/file'
# Set the local IP address here if you have multiple network interfaces.
# Leave empty and program will use first network interface.
serverip = ''
# Port number to listen to.
port = 9999

''' DO NOT MODIFY ANYTHING BELOW THIS POINT '''
if __name__ == "__main__":
    tcpServerMmap = tcpServerMmap(fname, serverip, port)
