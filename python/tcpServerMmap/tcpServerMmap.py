#! /usr/bin/env python
# TCP Server class (ver 0.2) to synchronize Matlab instances.
#
# Listens on port 9999 and writes values received into a shared memory variable.
# This shared memory variable can then be read by Matlab.
#
# The shared memory variable needs to be opened in Matlab with 'Writeable' = 1,
# otherwise Matlab won't be able to access the file. Alternatively, you can
# open the file in Matlab first, before running this server:
# > memFileHandle = memmapfile(filename, 'Offset', 0,'Format', 'uint8', 'Writable', 1);
#
# Ueli Rutishauser and Andreas Kotowicz, MPI 2012 & 2013.

''' import statements. '''
import mmap
import os
import sys
import SocketServer
import socket


''' basic settings in case this class is run by itself '''
# Location of shared memory file.
fname = '/tmp/file'
# Set the local IP address here if you have multiple network interfaces.
# Leave empty and program will use first network interface.
serverip = ''
# Port number to listen to.
port = 9999


''' DO NOT MODIFY ANYTHING BELOW THIS POINT '''
class tcpServerMmap(object):

    # Location of shared memory file.
    MMAP_FILENAME = "c:/temp/varstoreNew.dat"
    # Set the local IP address here if you have multiple network interfaces.
    # Leave empty and program will use first network interface.
    SERVERIP = ''
    # Port number to listen to.
    PORT = 9999
    # number of elements to store in memory
    STORE_LENGTH = 100
    #
    #
    # maximum number of bytes to send and receive - arbitrarily chosen. must be power
    # of two.
    MAX_BYTES_TO_SEND_RECEIVE = 10
    # index of the last item - so we don't recompute it during every single loop
    LAST_ITEM_INDEX = STORE_LENGTH - 1
    # null string used to initalize memory
    NULL_HEX = '\x00'
    # handle to mmap data file
    MMAP_DATA = False


    def __init__(self, fname=None, serverip=None, port=None):

        ''' Use user supplied values if given. '''
        if fname is not None:
            self.MMAP_FILENAME = fname
        if serverip is not None:
            self.SERVERIP = serverip
        if port is not None:
            self.PORT = port

        ''' Configure MMAP file & TCP Server '''
        # setup shared memory file
        self.MMAP_DATA = self.setup_mmap(self.MMAP_FILENAME)
        if not self.MMAP_DATA:
            sys.exit(1)

        # last chance to stop the server from starting up
        try:
            raw_input('Press any key to start TCP listening. Press Ctrl-C to stop.')
        except KeyboardInterrupt:
            sys.exit(1)
            pass

        # setup & run server
        server = self.setup_tcpserver()
        # quit in case 'setup_tcpserver()' failed.
        if not server:
            sys.exit(1)

        print "Python mmap tcp server using file '" + self.MMAP_FILENAME + "'"

        self.run_tcpserver(server, self.MMAP_DATA)


    ''' Routine to startup TCP server '''
    def setup_tcpserver(self):

        # get current IP address of default network card, use "SERVERIP" by default.
        myIP = self.SERVERIP
        if self.SERVERIP == '':
            # TODO: what if someone has multiple cards?
            myIP = socket.gethostbyname(socket.gethostname())

        # create the server object
        try:
            # Create the server
            server = tcpServerMmap.TCPServer((myIP, self.PORT), tcpServerMmap.MyTCPHandler, self)

            # disable the 'Nagle algorithm'
            # it makes no difference whether we use 'socket.SOL_TCP' or 'socket.IPPROTO_TCP'
            # but make sure we are consistent with the client!
            server.socket.setsockopt(socket.IPPROTO_TCP, socket.TCP_NODELAY, True)

            print "Started server on IP: " + myIP + " Port: " + str(self.PORT)

        except Exception as e:
            pass
            print "Failed to create server on " + myIP
            print "Error: " + str(e)
            server = False

        return server


    ''' MMAP code '''
    def setup_mmap(self, fname):
        # create the file if it doesn't exist
        if not os.path.isfile(fname):
            path_to_file = os.path.dirname(fname)
            if not os.path.isdir(path_to_file):
                mmap_data = False
                print "Directory '" + path_to_file + "' not found - aborting."
                return mmap_data
            fd = os.open(fname, os.O_CREAT | os.O_TRUNC | os.O_RDWR)
            assert os.write(fd, self.NULL_HEX * self.STORE_LENGTH)
            os.close(fd)

        # initialize the memory map
        f = open(fname, "r+b")
        mmap_data = mmap.mmap(f.fileno(), self.STORE_LENGTH)

        # initialize memory with default value
        for j in range(len(mmap_data)):
            mmap_data[j] = self.NULL_HEX

        return mmap_data


    ''' main routine '''
    def run_tcpserver(self, server, mmap_data):

        try:
            # 'main'
            print "Ready to receive data ..."
            server.serve_forever()
        except KeyboardInterrupt:
            # user stopped server from command line
            print "^C detected"
            server.socket.close()
            pass
        except:
            # user stopped server by sending STOP_SERVER_STRING
            pass
        finally:
            # either way, close the mapped file @ the end.
            print "Shutting down server."
            mmap_data.close()


    ''' TCP SERVER CODE '''
    # overwrite TCPServer
    class TCPServer(SocketServer.TCPServer):
        # set 'allow_reuse_address' to 'True' so that we can re-use the address
        # immediately after quitting. We can't do
        # 'server.allow_reuse_address = 1' because bind() has already been
        # called at that moment.
        allow_reuse_address = True
        # this string can't consist of more characters then 'MAX_BYTES_TO_SEND_RECEIVE'
        STOP_SERVER_STRING = 'STOPSERVER'

        def __init__(self, server_address, RequestHandlerClass, tcpServerMmap):
            SocketServer.TCPServer.__init__(self, server_address, RequestHandlerClass)
            # save 'tcpServerMmap' object so that we can access its attributes.
            self.tcpServerMmap = tcpServerMmap


    ''' TCP handle class for handling server connections. '''
    class MyTCPHandler(SocketServer.BaseRequestHandler):
        server = None

        def __init__(self, request, client_address, server):
            SocketServer.BaseRequestHandler.__init__(self, request, client_address, server)
            self.server = server

        def handle(self):
            # self.request is the TCP socket connected to the client.
            self.data = self.request.recv(self.server.tcpServerMmap.MAX_BYTES_TO_SEND_RECEIVE).strip()
            # initialize field for unpacked data.
            self.new_data = None

            # check whether data is numeric, otherwise ignore
            if self.data.isdigit():
                # shift elements by one
                self.server.tcpServerMmap.MMAP_DATA[0:-1] = self.server.tcpServerMmap.MMAP_DATA[1:]
                try:
                    # store value in one-character string whose ASCII code is the integer data
                    # you can 'unpack' this value with 'ord()'
                    self.new_data = chr(int(self.data))
                    self.server.tcpServerMmap.MMAP_DATA[self.server.tcpServerMmap.LAST_ITEM_INDEX] = self.new_data
                    #print "wrote data:", self.data
                except Exception as e:
                    pass
                    print e


            # send feedback back
            self.request.sendall("OK\0")

            # check whether we have to stop the server

            if self.data == self.server.STOP_SERVER_STRING:
                self.stopServer()
                return

            # give feedback to user at the very end in case 'print' is slowing things down.
            if self.new_data is not None:
                print "received data:", self.data

        def stopServer(self):
            self.server.socket.close()


if __name__ == "__main__":

    tcpServerMmap = tcpServerMmap(fname, serverip, port)
