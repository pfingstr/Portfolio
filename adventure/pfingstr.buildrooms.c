#include <stdio.h> 
#include <stdlib.h> 
#include <time.h> 
#include <string.h>
#define ROOMS 10
#define MAX_ROOMS 7
#define MAX_OUTBOUND 6
#define MIN_OUTBOUND 3

 typedef enum {
  FALSE = 0,
  TRUE = 1,
} Boolean;

const char* names[ROOMS] =
{ "chalk",
  "glow",
  "beetle",
  "wax",
  "giant",
  "stink",
  "paper",
  "nippy",
  "ring",
  "burn"
}; 

const char* types[3] =
{ "START_ROOM",
  "MID_ROOM",
  "END_ROOM"
};


struct Room
{
    char* roomName;
    char* roomType;
    struct Room** roomConnections;
    int connectionCount;
 };

void shuffleNames();
struct Room* buildRooms();
void buildNames(struct Room*);
void buildTypes(struct Room*);
void allocateConnections(struct Room*);
struct Room* getRandomRoom(struct Room*);
Boolean connectedAlready(struct Room*, struct Room*);
Boolean sameRoom(struct Room*, struct Room*);
void ConnectRooms(struct Room*, struct Room*);
void printStructs(struct Room*);

//Randomly returns address of room struct
struct Room* getRandomRoom(struct Room* roomStructs)
{
    int randomIndex = rand() % MAX_ROOMS;
    return &roomStructs[randomIndex];
}


// Returns true if a connection from Room x to Room y already exists, false otherwise
Boolean connectedAlready(struct Room* room1, struct Room* room2)
{
  int i = 0;
  //while connection not at the last and less than 6:
  while((room1->roomConnections[i] != NULL) && (i < MAX_ROOMS))
  {
    //Compare room names of connections with the name of the room passed in. 
      if(strcmp(room1->roomConnections[i]->roomName, room2->roomName) == 0)
        {
            return TRUE;
        }

        else
        {
          i++;
        }
  }
    return FALSE; 
}
//returns true if room1 has the same name as room 2, false otherwise. 
Boolean sameRoom(struct Room* room1, struct Room* room2)
{
        //Compare the two room names passed in, if equal then its the same room and return TRUE. 
      if(strcmp(room1->roomName, room2->roomName) == 0)
        {
            return TRUE;
        }

        else
        return FALSE; 
}


// Connects Rooms x and y together, does not check if this connection is valid
void ConnectRooms(struct Room* room1, struct Room* room2) 
{
    //place holder count1 and count2 to add connection in order, cleaner than alternitive '[[[]]]'
    int count1 = room1->connectionCount;
    int count2 = room2->connectionCount;
    //Add connections at next index.
    room1->roomConnections[count1] = room2;
    room2->roomConnections[count2] = room1;
    //Inc. connection counts for next connection
    room1->connectionCount++;
    room2->connectionCount++;
}

// Adds a random, valid outbound connection from a Room to another Room
void AddRandomConnection(struct Room* roomStructs)  
{
    //Declare 2 Room struct pointers
    struct Room* room1; 
    struct Room* room2; 
    while(TRUE)
    {   
        //room1 is now a random initilized room struct
        room1 = getRandomRoom(roomStructs);
            //Check to see if we can add more connections
            if (room1->connectionCount <= MAX_OUTBOUND)
            break;
    }

    do
    {   
        //room2 is now a random initilized room struct
        room2 = getRandomRoom(roomStructs);
    }
    //Taken directly from the profs outline.
    while((room2->connectionCount >= MAX_OUTBOUND) || sameRoom(room1, room2) == TRUE || connectedAlready(room1, room2) == TRUE);
    ConnectRooms(room1, room2);  // TODO: Add this connection to the real variables, 
}



// Returns true if all rooms have 3 to 6 outbound connections, false otherwise
Boolean IsGraphFull(struct Room* roomStructs)  
{
    int i;
    int j=0; 
    for (i = 0; i < MAX_ROOMS; i++) {
        //Check to see that this room has between 3 and 6 connections, if it does proceed inc j.
        if(roomStructs[i].connectionCount >= MIN_OUTBOUND && roomStructs[i].connectionCount <= MAX_OUTBOUND)
            j++;
        }
    //Once all rooms have between 3 and 6 connections return TRUE.
    if(j == MAX_ROOMS)
        return TRUE;
    
    else
    {
        return FALSE;
    } 
}
// Helper function to randomize hard coded names. 
void shuffleNames()
{
    int size = ROOMS;
    if (size > 1)
    {
        int i;
        for (i = 0; i < size - 1; i++)
        {
        int j = rand() % ROOMS; 
        const char* temp = names[j];
        names[j] = names[i];
        names[i] = temp;
        }
    }
}

//Middleware function to sit between initilizing room structs and building the graph. 
struct Room* buildRooms(struct Room* roomStructs) {
    buildNames(roomStructs);
    buildTypes(roomStructs);
    allocateConnections(roomStructs);
  
    // Create all connections in graph 
    while (IsGraphFull(roomStructs) == FALSE)
    {
        AddRandomConnection(roomStructs);
    }
    
    return roomStructs;
}
//Copy the random names into the room structs.
void buildNames(struct Room* roomStructs)
{
    //How the names are actually randomized.
    shuffleNames();
    int i;
    for (i = 0; i < MAX_ROOMS; i++) {
        roomStructs[i].roomName = malloc(strlen(names[i] + 1));
        strcpy(roomStructs[i].roomName, names[i]);
        //printf("%s\n",roomStructs[i].roomName);
    }
}

//Initilize the room types
void buildTypes(struct Room *roomStructs)
{
    int i;
    //Here room indexes 1-5 get to be middle rooms
    for (i = 1; i < MAX_ROOMS-1; i++) {
        roomStructs[i].roomType = malloc(strlen(types[1] + 1));
        strcpy(roomStructs[i].roomType, types[1]);
    }
    //Index 0 is allways the start room and room index 6 is always the end room. 
    roomStructs[0].roomType = malloc(strlen(types[0] + 1));
    strcpy(roomStructs[0].roomType, types[0]);
    roomStructs[6].roomType = malloc(strlen(types[2] + 1)); 
    strcpy(roomStructs[6].roomType, types[2]);
}

//Initilize the room connection count and connection pointers. 
void allocateConnections(struct Room* roomStructs)
{
    int i;
    int j;
    for (i = 0; i < MAX_ROOMS; i++) {
        roomStructs[i].connectionCount = 0;
        roomStructs[i].roomConnections = malloc(sizeof(struct Room) * 6);
        //Int. to all point to NULL.
        for (j = 0; j < MAX_OUTBOUND; j++) {
            roomStructs[i].roomConnections[j] = NULL;
            //printf("%d   %d\n", i, j);
        }
    }
}

//This function creates the directory and then files within it.
void buildDirFi(struct Room* roomStructs) {
    int dirbuffer = 20; 
    char *directory = malloc(dirbuffer);
    char *prefix = "pfingstr.rooms.";
    int suffix = getpid();
    // Write pfingstr.rooms.PID
    snprintf(directory, dirbuffer, "%s%d", prefix, suffix);
    mkdir(directory, 0770);
    FILE *roomZ;
    int i;
    //For every room struct of 7.
	  for (i = 0; i < MAX_ROOMS; i++)
	  {
        //Overkill size
        int fibuffer = 100; 
        char *file = malloc(fibuffer);
        //Sets the room name to include _room at the end and prints in full name directory. 
        snprintf(file, fibuffer, "./%s/%s%s", directory, roomStructs[i].roomName, "_room");
        //Open file for writing.
        roomZ=fopen(file, "w");
        // Print first line based on formatting.
        fprintf(roomZ, "ROOM NAME: %s\n", roomStructs[i].roomName);
        int j;
        //Print each connection room name on its own line.
        for(j=0; j<roomStructs[i].connectionCount; j++) {
            fprintf(roomZ, "CONNECTION %d: %s\n", j+1, roomStructs[i].roomConnections[j]->roomName);
        }
        //On the last line print the room type.
        fprintf(roomZ, "ROOM TYPE: %s\n", roomStructs[i].roomType);
        //Close the file
        fclose(roomZ);
        //Free dynamic memory
        free(file);
    }
free(directory);
}

  
int main() 
{ 
    srand (time(NULL));
    struct Room *roomStructs = malloc(sizeof(struct Room) * MAX_ROOMS);
    buildRooms(roomStructs);
    buildDirFi(roomStructs);
    free(roomStructs);
    return 0;
} 
