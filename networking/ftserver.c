#include <sys/socket.h>
#include <netinet/in.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <dirent.h>
#include <sys/stat.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <unistd.h>
#include <ifaddrs.h>
#include <errno.h>

// sendAll function - 
// puts everything in a string onto the socket.
// Also taken from the otp program 4 in cs344.
int sendAll(int sock, char * bufp, size_t len) {
    int sent;
    size_t offset = 0;
    while (len > 0)
    { // loop until we have all of our data
        sent = send(sock, &bufp[offset], len, 0);
        if (sent < 0)
        { // Socket is in a bad state 
            printf("ERROR reading from socket");
            return 0;
        }
        else if (sent == 0)
        { // socket closed
            return 0;
        }
        len -= sent;
        offset += sent;
    }
    return 1;
}

// fileToStr function -
// I took this from program 4 in cs344 it takes a file name and 
//  returns the string of the text in that file. 
char* fileToStr(char const* path) {
	char* buffer = 0;
	long length;
	FILE * f = fopen (path, "r");
	if (f) {
		//count number of chars
		fseek (f, 0, SEEK_END);
		//store in length long
		length = ftell (f);
		//Set file pointer back to beginning
		fseek (f, 0, SEEK_SET);
		buffer = (char*)malloc((length)*sizeof(char));
		//If there are characters to read
		if (buffer) {
			fread (buffer, sizeof(char), length, f);
		}
		fclose (f);
		}
    return buffer;
}

// getDirectory function -
// I based this off of a function I used in cs344 in program 2 - adventure
// It returns a int for the total count of the directory files which I use in sending
// It fills a string linked list with directory contents.
int getDirectory(char** dirList) {
    DIR *d;
    struct dirent *dir;
    char *dirName;
	char* fullFileName;
	// open the directory
    d = opendir("."); 
    int count;
    count=0;
    if (d) {
        while ((dir = readdir(d)) != NULL) {
            // Compare the name read and skip directory traversal files dot & dotdot. 
            if( strcmp( dir->d_name, "." ) == 0 || 
            strcmp( dir->d_name, ".." ) == 0 ) {
                continue;
            }
            //Create entry for every item
			fullFileName=malloc(sizeof(char)*50);
			//This was added because it fixed a seg fault I was getting without it.
			sprintf(fullFileName, "%s%s",dir->d_name,'\0');
            dirList[count]=malloc(sizeof(char)*51);
            strcpy(dirList[count], fullFileName);
            count++;
        }
    }
	closedir(d);
    return count;
}

// dataSocketSetup function -
// I wrote this when I thought there was something special needed for a second socket,
//  turns out there isnt and this wasnt necessary but I just left it.
// the ipAddr variable passed in is unecessary to the function.
int dataSocketSetup(char* port, char * ipAddr){
	int sock;
	struct sockaddr_in saddr_in;

	bzero((char *) &saddr_in, sizeof(saddr_in));
	saddr_in.sin_family = AF_INET;
	//inet_aton(ipAddr, &(saddr_in.sin_addr));
	saddr_in.sin_addr.s_addr = INADDR_ANY;
	int portnum;
	portnum=atoi(port);
	saddr_in.sin_port = htons(portnum);

	//open a socket
	if( (sock = socket(AF_INET, SOCK_STREAM, 0))  < 0) {
		perror("socket");
		exit(1);
	}
	//bind socket
	if (bind(sock, (struct sockaddr *) &saddr_in, sizeof(struct sockaddr_in)) < 0) {
      perror("ERROR on binding");
      exit(1);
   	}
	//listen for 1 connection
	if(listen(sock, 1) < 0){
        perror("ERROR on listen");
		exit(1);
    }  
	return sock;
}

// src: https://www.tutorialspoint.com/unix_sockets/socket_server_example.htm
// setup function -
// Takes the argv[1] and creates, binds, and listens for connections on a socket. 
int setup(char * port){
	int sockfd2;
   	struct sockaddr_in serv_addr;
	int portnum;
	// convert char to int 
	portnum=atoi(port);
	
   	// create socket
   	sockfd2 = socket(AF_INET, SOCK_STREAM, 0);
	if (sockfd2 < 0) {
      perror("ERROR opening socket");
      exit(1);
   	}
	
	// zero out structure
	bzero((char *) &serv_addr, sizeof(serv_addr));
	serv_addr.sin_family = AF_INET;
   	serv_addr.sin_addr.s_addr = INADDR_ANY;
   	serv_addr.sin_port = htons(portnum);
	
	// bind()
	if (bind(sockfd2, (struct sockaddr *) &serv_addr, sizeof(serv_addr)) < 0) {
      perror("ERROR on binding");
      exit(1);
   	}
	
	// now listen() with a queue of 5 
	if(listen(sockfd2, 5) < 0){
        perror("ERROR on listen");
		exit(1);
    }      
	return sockfd2;
}

// validateFile function -
// checks to see if the file requested exists on the servers current directory.
// Also it prints what the client command array message was
int validateFile(char ** commandArray) {
	if(strcmp(commandArray[1], "-g") == 0) {
		printf("client at ip: %s requesting file: %s on port: %s\n", commandArray[0], commandArray[3], commandArray[2]);
		if(access(commandArray[3], F_OK) != -1 ) {
    		// file exists
			return 1;
		} else {
    		// file doesn't exist
			return 0;
		}
	}
	else if(strcmp(commandArray[1], "-l") == 0) {
		printf("client at ip: %s requesting directory on port: %s\n", commandArray[0], commandArray[2]);
		return 1;
	}
	else{
		return 0;
	}
}
// Main function
// All of the usual TCP socket setup, bind, listen, then accept followed by data transfer to client.
int main(int argc,char *argv[]) {
	char *dirList[50];
	int dirCount, sockfd, dataSockfd, conSockfd, clilen, daten;
	int count;
	char* fileStr;
	struct sockaddr_in con_addr, dat_addr;
	char* newString;
	char commandString[100];
	char *commandArray[3];
	char fileName[100];
	char next[] = "next";
	char error[] = "error";
	sockfd=setup(argv[1]);
	printf("Server control connection started at %s\n", argv[1]);
	clilen = sizeof(con_addr);
	daten = sizeof(dat_addr);
	while(1) {
		count=0;
		// data clearing with 0
		memset(commandString,0,sizeof(commandString));
		memset(fileName,0,sizeof(fileName));
		// accept connection and check for errors
    	conSockfd = accept(sockfd, (struct sockaddr *) &con_addr, &clilen);
        if(conSockfd < 0) {
            perror("ERROR on accept\n");
			exit(1);
        }
		// recv client data on command connection
		recv(conSockfd, commandString, 100, 0);
		// create command array from client message using strtok()
    	newString=strtok(commandString, " ");
    	while (newString != NULL) {
			commandArray[count] = strdup(newString);
			count++;
        	newString= strtok(NULL, " ");
    	}
		// validate if the file exists
		int valid;
		valid = validateFile(commandArray);
		//printf("%d\n", valid);
		if(valid == 1){ // if it does exist send success message to client
			send(conSockfd, next, 4, 0);
		}else { 
			//if it doesnt send error message and continue to next loop
			send(conSockfd,error, 5, 0);
			continue;
		}
		
		int newsockfd;
		//figured count variable was easier to use then strcmp on argv[3]
		if(count==4){ //requesting a file
			char* fileToSend;
			// convert textfile to string
			fileToSend = fileToStr(commandArray[3]);
			//printf("%zu\n",strlen(fileToSend));
			//open up data socket
			dataSockfd = dataSocketSetup(commandArray[2], commandArray[0]);
			newsockfd = accept(dataSockfd, (struct sockaddr *) &dat_addr, &daten);
			// send file
			//send(newsockfd,fileToSend,strlen(fileToSend),0);
			sendAll(newsockfd, fileToSend, strlen(fileToSend));
		}
		//figured count variable was easier to use then strcmp on argv[3]
		else if(count==3){ //requesting directory
			// convert directory to directory array, returns number of entries in directory array
			dirCount=getDirectory(dirList);
			//open up data socket
			dataSockfd = dataSocketSetup(commandArray[2], commandArray[0]);
			newsockfd = accept(dataSockfd, (struct sockaddr *) &dat_addr, &daten);
			int d;
			for(d=0; d < dirCount; d++){
				// send each entry
				// send -6 on length because of "(null)" 
				//  on the end of each char array on client side
				send(newsockfd, dirList[d],strlen(dirList[d])-6,0); 
				// send a ne line after each entry to avoid any processing on client side
				send(newsockfd, "\n",2,0);
			}
		}
		// close data sock fd
		close(newsockfd);
	}
	//close command sock fd
	close(conSockfd);

}


