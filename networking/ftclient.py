#!/bin/python

import socket
from socket import *
import sys
import time
import os.path

# writeFile function -
# writes the file string to a file, checking to see if the file already exists.
def sendOnControl(controlConnection):
    # get ip to send
    s=socket(AF_INET, SOCK_DGRAM)
    s.connect(('8.8.8.8', 1))
    local_ip_address=s.getsockname()[0]
    s.close()   

    command=sys.argv[3]
    #if command was for a list
    if command == '-l':
        dataport=sys.argv[4]
        commandmessage= "%s %s %s" %(local_ip_address,command,dataport)   

    # if a file was requested
    elif command == '-g':    
        filename=sys.argv[4]
        dataport=sys.argv[5]
        commandmessage= "%s %s %s %s" %(local_ip_address,command,dataport,filename)

    #send the control message
    controlConnection.send(commandmessage)
    recOnControl(controlConnection)
    # sleep for a quick sec just in case the server is doing too much comp.
    time.sleep(.1)
    # open datasocket
    dataSockfd = dataSocket(dataport)
    
    if command =='-l':
        directory = dataSockfd.recv(1024)
        print "Here are the directory contents:"
        # not sure the decode is necessary
        b=directory.decode('utf-8')
        print "%s" %(b)

    elif command == '-g':
        fileString = recvAll(dataSockfd)
        print "See your current directory for the file requested. . ."
        writeFile(fileString,filename)

    dataSockfd.close()
    return

# recvAll
# similar to sendall it loops on the recv until all data is pulled.
def recvAll(dataSocket):
    wholeMessage=[]
    while True:
        message = dataSocket.recv(8192)
        # oonece there isnt any more of the book in the socket then break
        if not message: break
        wholeMessage.append(message)
    return ''.join(wholeMessage)

# writeFile function -
# writes the file string to a file, checking to see if the file already exists.
def writeFile(fileString,filename):
    if os.path.isfile(filename):
        # file exits already so we tack a "NEW-" on the front
        fname= "NEW-"+filename
    else:
        # it doesnt exist so we just leave it alone
        fname=filename
    
    # src:https://stackoverflow.com/questions/5214578/print-string-to-text-file
    text_file = open(fname, "w")
    # write the string to a file
    text_file.write("%s" %fileString)
    # close the file
    text_file.close()
    return

# recOnControl function -
# handles the message sent back by the ftp server
def recOnControl(controlConnection):
    message = controlConnection.recv(512)
    # if error message was sent that means there was no file with the name specified, then exit
    if message == "error":
        print "File not found :("
        exit(1)
    # if next then all is well and we can continue
    elif message == "next":
        print "Request being processed by server. . ."
    
    return

# dataSocket function -
# creates the data socket and connects to it
def dataSocket(dataport):
    # the [1] arg is flip1/2/3
    serverHostName=sys.argv[1]
    # tack on the rest of the domain name
    serverDomainName=serverHostName+".engr.oregonstate.edu"
    # create socket
    dataConnection=socket(AF_INET, SOCK_STREAM)
    # connect on the command socket
    dataConnection.connect((serverDomainName, int(dataport)))
    return dataConnection

# controlConnectionSetup function -
# creates the command socket and connect to it
def controlConnectionSetup():
    # the [1] arg is flip1/2/3
    serverHostName=sys.argv[1]
    # tack on the rest of the domain name
    serverDomainName=serverHostName+".engr.oregonstate.edu"
    # create socket
    controlConnection=socket(AF_INET, SOCK_STREAM)
    # connect on the command socket
    controlConnection.connect((serverDomainName, int(sys.argv[2])))
    # call function to initiate contact with the server
    sendOnControl(controlConnection)
    # close command socket
    controlConnection.close()
    

# main function -
#  checks the arguments to ensure they are in the right format:
#   (<SERVER_HOST>, <SERVER_PORT>, <COMMAND>, <FILENAME>, <DATA_PORT>, etc...)
#  calls a single function to set up the command connection
if __name__ == "__main__":
    #check arg count
    if(len(sys.argv) > 6):
        print "too many arguments..."
        exit(1)
    
    #check if arg count too low
    elif(len(sys.argv) < 5):
        print "too few arguments..."
        exit(1)    
    
    #check if command port number is too high
    elif(int(sys.argv[2]) > 65535):
        print "command port number is too high"
        exit(1)
    
    #checks to see if command is there
    elif((sys.argv[3] != "-g")) and ((sys.argv[3] != "-l")):
        print "-g or -l option needed..."
        exit(1)
    
    #makes sure that the flipis correct and specified
    elif((sys.argv[1] != "flip3") and (sys.argv[1] != "flip2") and (sys.argv[1] != "flip1")):
        print "only runs on flip1, flip2, or flip3.."
        exit(1)
    
    #if a file request 
    if(sys.argv[3] == "-g"):
        #check the [5] argument for port number 
        if(int(sys.argv[5]) > 65535):
            print "data port number is too high"
            exit(1)
    
    elif(sys.argv[3] == "-l"):
        #check the [4] argument for port number 
        if(int(sys.argv[4]) > 65535):
            print "data port number is too high"
            exit(1)

    controlConnectionSetup()