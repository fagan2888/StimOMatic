#! /usr/bin/env python
from tcpServerMmap import tcpServerMmap

''' basic settings '''
# Location of shared memory file.
fname = "/tmp/eleStream.dat"
# Set the local IP address here if you have multiple network interfaces.
# Leave empty and program will use first network interface.
serverip = '172.16.60.14'
# Port number to listen to.
port = 9998

''' DO NOT MODIFY ANYTHING BELOW THIS POINT '''
if __name__ == "__main__":
    tcpServerMmap = tcpServerMmap(fname, serverip, port)
