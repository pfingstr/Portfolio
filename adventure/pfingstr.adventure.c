#include <sys/types.h>
#include <sys/stat.h>
#include <stdio.h> 
#include <dirent.h>
#include <stdlib.h> 
#include <time.h> 
#include <string.h>
#include <locale.h>
#include<pthread.h>

#define ROOMS 10
#define MAX_ROOMS 7
#define MAX_OUTBOUND 6
#define MIN_OUTBOUND 3
#define LINES 128 
#define ROWS 8

 typedef enum {
  FALSE = 0,
  TRUE = 1,
} Boolean;

struct Room
{
    char* roomName;
    char* roomType;
    char* connectionNames[6];
    int connectionCount;
    
 };


char* mostRecentDir();
void fileTo2Darray(char*, FILE*, struct Room*, int);
void adventureRooms(char*, struct Room*);
void* makeTime();
void readTimeFile();
void postTimeHelper(struct Room*, int);
void startCheck(struct Room*);
void endCheck(struct Room*, int);
int inConnections(char*, struct Room*, int);
void playAdventure(struct Room*, int);
void errorFunc(struct Room*, int);
int endAdventure(struct Room*, int);

//Global variables:
char pathToVic[100][8];
int countToVic;
pthread_t tid;
pthread_mutex_t lock;


char* mostRecentDir()
{
  int max, count;
  max = 0;
  //count is used to keep track of the index in the char-strs array, and int-arr array.
  count = 0;
  DIR *d;
  struct dirent *dir;
  char *dirName;
  char *prefix = "pfingstr.rooms.";
  d = opendir("."); 
  struct stat current;
  //Could have probably figured out how do this with a 2D array but this was easy. 
  char *strs[50];
  int arr[50];
  if (d)
  {
    while ((dir = readdir(d)) != NULL)
    {
        // Compare the name read and skip directory traversal files dot & dotdot. 
        if( strcmp( dir->d_name, "." ) == 0 || 
        strcmp( dir->d_name, ".." ) == 0 ) 
        {
            continue;
        }
        //If the first 14 characters of a file match my name then:
        if ( strncmp(dir->d_name, prefix, 14) == 0)
        {   
            //Create stat struct for every hit.
            stat(dir->d_name, &current);
            //Allocate space in char array for directory names.
            strs[count]=malloc(sizeof(char)*30);
            //Copy the name into index of array.
            strcpy(strs[count], dir->d_name);
            //Put time (s) in indexed position of array.
            arr[count]=current.st_mtime;
            count++;
        }
    }
        
        
        int j;
        int location;
        location=0;
        //Set max to the first element of array
        max=arr[0];
        //For every element of the time array
        for(j=1; j<count; j++){
          //If the second element of array through the nth element is larger than previous max
          if(arr[j] > max)
          {
            //Make it new max
            max=arr[j];
            //Save index of this in 'loction variable'
            location=j;
          }  
        }
        
        dirName=malloc(sizeof(char)*30);
        char *front = "./";
        snprintf(dirName, 32, "%s%s", front, strs[location]);
        
        closedir(d);
        return dirName;
  }
}

//Function that reads each file into a 2D Array and then parses the input line by line.
void fileTo2Darray(char* fullFileName, FILE* fptr, struct Room* roomStructs, int roomCount) 
{
    char line[ROWS][LINES];
	  FILE *dfptr;
    int i = 0;
    int tot = 0;
    //While there is a string to get in a line from 1-n.
    while(fgets(line[i], LINES, fptr)) 
	  {
        //At the end of the line put a null terminator.
        line[i][strlen(line[i]) - 1] = '\0';
        i++;
    }
    //Stored this out of paranoia. 
    tot = i;
    //get connection count
    roomStructs[roomCount].connectionCount=tot-2;
    //Allocate then get room name using sprintf to select last section of characters, had to manually count.
    roomStructs[roomCount].roomName=malloc(sizeof(char)*8);
    sprintf(roomStructs[roomCount].roomName, "%s", line[0]+11);
    int j, k;
    //k is started from 2nd line of file.
    k=1;
    //For every connection 
    for (j=0; j<roomStructs[roomCount].connectionCount;j++)
    {
      //Allocate then get connection name using sprintf to select last section of characters.
      roomStructs[roomCount].connectionNames[j]=malloc(sizeof(char)*8);
      sprintf(roomStructs[roomCount].connectionNames[j], "%s", line[k]+14);
      k++;
    }
    //Get the room type from the file.
    roomStructs[roomCount].roomType=malloc(sizeof(char)*13);
    //Finally making use of the paranoid 'tot' variable to access last index.
    sprintf(roomStructs[roomCount].roomType, "%s", line[tot-1]+11);
}

//This function opens the directory that adventure.c is in and calls fileTo2DArray.
void adventureRooms(char* adventureDir, struct Room* roomStructs)
{
  FILE *fptr;
  DIR *d = opendir(adventureDir);
  struct dirent *dir;
  char* roomName;
  char* fullFileName;
  char chr;
  int count, roomCount;
  count=0;
  roomCount=0;
  //If d exists:
  if (d)
  {
    //While we are not at the end of files.
    while ((dir = readdir(d)) != NULL)
    {
        // Compare the name read and skip directory traversal files dot & dotdot. 
        if( strcmp( dir->d_name, "." ) == 0 || 
        strcmp( dir->d_name, ".." ) == 0 ) 
        {
            continue;
        }
        //Allocate space for the room name.
        roomName=malloc(sizeof(char)*20);
        //Allocate even more space for the directory/room_name.
        fullFileName=malloc(sizeof(char)*40);
        strcpy(roomName, dir->d_name);
        //Format the full file name with directory/room_name
        sprintf(fullFileName, "%s/%s", adventureDir, roomName);
        fptr = fopen(fullFileName, "r");
          if(!fptr)
          {
            printf("Error! opening file\n");
            exit(1);
          }
        //Use roomCount as a variable to pass is probably ugly but it works,
        // tried passing in roomStructs[roomCount] and got warnings. 
        fileTo2Darray(fullFileName, fptr, roomStructs, roomCount);
        fclose(fptr);
        //On to the next room.
        roomCount++;
        }
        
    }
  }
// SOURCE: https://fresh2refresh.com/c-programming/c-time-related-functions/ 
//Print the time to a file.
void* makeTime()
{
    // Am not super sure this was correct but it seems to work, 
    //  stopped currentTime.txt from being created from main. 
    pthread_mutex_lock(&lock);
    FILE *fptr;
    fptr = fopen("currentTime.txt", "w");
    if(fptr == NULL)
    {
        printf("Error opening file\n");
        exit(1);
    }
    //100 is probably overkill. 
    char buffer[100];
    time_t rawTime;
    //Not understanding why 'time(& rawTime)' is necessary but my code broke trying to refactor. 
    time(& rawTime);
    struct tm *time;
    time=localtime(&rawTime);
	  strftime (buffer, 100, "%I:%M%P, %A, %B %d, %Y", time);
	  fputs(buffer, fptr);
	  fclose(fptr); 
}
//Read the time file just created to the command line.
void readTimeFile()
{
    FILE *fptr;
    fptr = fopen("currentTime.txt", "r");
    char linechar;
    //As long as the file as something in it:
    if ( fptr != NULL )
    {
      //Start taking in characters
      linechar=fgetc(fptr);
      //Added a space based on formatting from assignment reqs.
      printf(" ");
      while(linechar != EOF)
      {
        //Print every character.
        printf("%c", linechar);
        linechar=fgetc(fptr); 
      }
    }
      //Print 2 lines then close file.
      printf("\n\n");
      fclose(fptr); 
    }

//Entrance to the game, prints the Start_Room to console. 
void startCheck(struct Room* roomStructs)
{
  int i;
  //Initilize global path counter
  countToVic=0;
  for (i=0;i<MAX_ROOMS;i++){
    //When the start room structure found use that index
    if(strcmp(roomStructs[i].roomType, "START_ROOM") == 0)
    {
      //NOT NEEDED but was useful for debugging and didnt hurt final output.
      strcpy(pathToVic[countToVic], roomStructs[i].roomName);
      //Print start room using found index.
      playAdventure(roomStructs, i);
    }
  }
}

//Check function to see if this room is the end room. 
void endCheck(struct Room* roomStructs, int index)
{
    //If end room:
    if(strcmp(roomStructs[index].roomType, "END_ROOM") == 0)
    {
      countToVic++;
      strcpy(pathToVic[countToVic], roomStructs[index].roomName);
      endAdventure(roomStructs, index);
    }
    //If mid room:
    else
    {
      countToVic++;
      strcpy(pathToVic[countToVic], roomStructs[index].roomName);
      playAdventure(roomStructs, index);
    } 
  }

//Determines if this room is connected to input, if it is return 0.
int inConnections(char *input, struct Room* roomStructs, int index)
{
        int i;
        for(i=0; i<roomStructs[index].connectionCount; i++){
        //if input == valid connection string
        if(strcmp(roomStructs[index].connectionNames[i], input) == 0)
          return 0;
        } 
          return 1;
}

//This is the main play function which outputs room choices, time, and error message.
void playAdventure(struct Room* roomStructs, int index)
{
  int i, conCount;
  char input[32];
  conCount=roomStructs[index].connectionCount;
  //Prints the name of the current room
  printf("CURRENT LOCATION: %s\nPOSSIBLE CONNECTIONS: ", roomStructs[index].roomName);
  // And prints commas between rooms with a period at the end.
  for(i=0; i<conCount; i++){
      printf("%s", roomStructs[index].connectionNames[i]);
      if(i==conCount-1)
        printf(".\n");
      else
      {
        printf(", ");
      }
  }
    
    printf("WHERE TO? >");
    memset(input, '\0', sizeof(input));
		scanf("%s", input);
    printf("\n");

    if(strcmp(input, "time") == 0)
    {
          pthread_mutex_unlock(&lock);
          makeTime();
          //Was repeatedly told to initite another thread upon terminating previous. 
          pthread_create(&tid, NULL, &makeTime, NULL);
          //Read time file function, reads 1st line. 
          readTimeFile();
          //Call helper to return user to a reduced version of play adventure. 
          postTimeHelper(roomStructs, index);

    }

    else if( inConnections(input, roomStructs, index) == 0)
		{ 
			for(i=0; i<MAX_ROOMS; i++){
              if(strcmp(roomStructs[i].roomName, input) == 0)
              {
                  int b;
                  b=i;
                  // Check to see if this is the end room.
                  endCheck(roomStructs, b);
              }
            } 
		}

    else
    {
      errorFunc(roomStructs, index);
    }
}

// This is a helper function that restores the flow of playAdventure 
// without needing to add further conditionals to playAdventure.
// LOTS OF DUPLICATE CODE HERE SO NO COMMENTS
void postTimeHelper(struct Room* roomStructs, int index)
{
          int i, conCount;
          char input[32];
          conCount=roomStructs[index].connectionCount;
          printf("WHERE TO? >");
          memset(input, '\0', sizeof(input));
		      scanf("%s", input);
          printf("\n");
          
          if(strcmp(input, "time") == 0)
          {
          pthread_mutex_unlock(&lock);
          makeTime();
          pthread_create(&tid, NULL, &makeTime, NULL);
          readTimeFile();
          postTimeHelper(roomStructs, index);
          }

    else if( inConnections(input, roomStructs, index) == 0)
		{ 
			      for(i=0; i<MAX_ROOMS; i++){
              if(strcmp(roomStructs[i].roomName, input) == 0)
              {
                  int b;
                  b=i;
                  // Check to see if this is the end room
                  endCheck(roomStructs, b);
              }
            } 
		}
    else
    {
      errorFunc(roomStructs, index);
    }
}



// This handles all error messages and resets user in playAdventure() with same room.
void errorFunc(struct Room* roomStructs, int index)
{
      printf("HUH? I DON’T UNDERSTAND THAT ROOM. TRY AGAIN.\n");
      printf("\n");
      playAdventure(roomStructs, index);
}

//Output the path taken and step count to the user upon reaching the ending room.
int endAdventure(struct Room* roomStructs, int index)
{
  //This is janky but it outputs the right info to the user.
  int i;
	printf("YOU HAVE FOUND THE END ROOM. CONGRATULATIONS!\n");
  printf("YOU TOOK %d STEPS. YOUR PATH TO VICTORY WAS:", countToVic);
  printf("\n");
  //Cant print the starting room in the path to victory.
  for(i=1;i<countToVic+1;i++){
    printf("%s\n", pathToVic+i);
  }
  return 0;
}

int main(int argc, char **argv)
{
    // Mutex stuff:
    // SOURCE: https://piazza.com/class/k0n1xcux3ah4r?cid=261
    // Init and lock mutex.
    int i = 0;
    int err;
    if (pthread_mutex_init(&lock, NULL) != 0)
    {
        printf("\n mutex init failed\n");
        return 1;
    }
  
  //Spawn time_thread with time function (lock mutex and unlock in time function)
  pthread_mutex_lock(&lock);
  pthread_create(&tid, NULL, &makeTime, NULL);
  
  //Get most recent directory name.
  char* adventureDir = mostRecentDir();
  //Allocate space for the structs to be filled. 
  struct Room *roomStructs = malloc(sizeof(struct Room) * MAX_ROOMS);
  
  //Bulild room structs from files in room directories.
  adventureRooms(adventureDir, roomStructs);
  
  //Start game
  startCheck(roomStructs);
  free(roomStructs);
  
  //Unlock and destroy mutex
  pthread_mutex_unlock(&lock);
  pthread_mutex_destroy(&lock);
  return 0; 
}

