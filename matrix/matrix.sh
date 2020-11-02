#!/bin/bash
TMP="tempfile$$"
TMP2="tempfile2$$"
trap "rm -f $TMP $TMP2; exit" INT HUP TERM EXIT

#########################################################################################
# Function: dims
# Description: This function takes two matrices and multiplies them,
# Pre-Condition: None
# Post-Condition: Dims fed to standard out as row column with a space in between.
function dims() 
{
    rowcount=0
    while read
    do
        ((rowcount++))
    done < "$1"

    echo "$rowcount" "$(head -1 $1 |head -1 $1 |tr '\t' '\n' |wc -l)"
}
#########################################################################################
# Function: mean
# Description: This function takes one matrix and computes the means of column 1..n,
# Pre-Condition: None
# Post-Condition: Mean values fed to standard out in a single row.
function mean()
{
    # Assuming the matrix passed to mean is valid this works better than the above row count. 
    rowcount="$(cat $1|wc -l)"

    fields="$(head -1 $1 |head -1 $1 |tr '\t' '\n' |wc -l)"
    for ((i=1 ; i <= fields ; i++)); do 
        sum=0
        myvar="$(cat $1 | cut -f $i)"
        while read num
        do
            sum=$(($sum + $num))
        done <<< "$myvar"
        # (a + (b/2)*( (a>0)*2-1 )) / b
        avg=$((($sum + ($rowcount/2)*( ($sum>0)*2-1 )) / $rowcount))
        # Convert the column of means into a row of means.
        echo "$avg" | tr '\n' '\t' >> "$TMP2"
    
done 

echo "" >> "$TMP2"
# Getting rid of the trailing tabs -inspired by the profs hint, and another student alerting me to it in slack.
while read line
do
    line="$line"
    line=${line%}
    echo "$line"
done < $TMP2

}
#########################################################################################
# Function: transpose
# Description: This function takes one matrix and transposes it aka row 1..n becomes column 1..n.
# Pre-Condition: None
# Post-Condition: The transposed values fed to standard out.
function transpose()
{
    # Added as a backup conditional because I kept failing this test on grading script without.
    if [ ! -r $1 ]
    then
        echo "ERROR: Unreadable" >&2
        exit 7
    fi

    fields="$(head -1 $1 |head -1 $1 |tr '\t' '\n' |wc -l)"
    # For each column in the matrix from 1-n.
    for ((i=1 ; i <= fields ; i++)); do
        # Cut that whole column and convert it to a row.
        trans=$(cat $1 | cut -f $i | tr '\n' '\t')
        echo "$trans" >> "$TMP2"
    done 
    # Getting rid of the trailing tabs -inspired by the profs hint, and another student alerting me to it in slack.
    while read line
    do
        line="$line"
        line=${line%}
        echo "$line"
    done < "$TMP2"

}
#########################################################################################
# Function: add
# Description: This function fills a 1D array with the first matrix, 
# it then loops through the second matrix and adds the array value to the second matrix.
# Pre-Condition: Requires that rows and columns of first matrix equal to rows and columns of second matrix.
# Post-Condition: Added values fed to standard out.
function add()
{
    # Column count calculation
    COLS1="$(head -1 $1 |head -1 $1 |tr '\t' '\n' |wc -l)"
    COLS2="$(head -1 $2 |head -1 $2 |tr '\t' '\n' |wc -l)"
    # Row count 1 calculation.
    rowcount=0
    while read; do
        ((rowcount++))
    done < $1
    ROWS1="$rowcount"
    # Row count 2 calculation.
    rowcount=0
    while read; do
        ((rowcount++))
    done < $2
    ROWS2="$rowcount"
    # Check to see that the matrices are of the same dimensions, 
    # this could have been better done using dims but the above was easier for me to copy-paste.
    if [ $COLS1 -ne $COLS2 ] || [ $ROWS1 -ne $ROWS2 ]
    then 
        echo "ERROR: The dimensions of the input matrices do not allow them to be added together following the rules of matrix addition." >&2
        exit 7
    fi
    # This is where I started using arrays contrary to what the prof indicated this was easier than anything else I tried. 
    array=()
    j=0
    fields="$(head -1 $1 |head -1 $1 |tr '\t' '\n' |wc -l)"
    # Input the first matrix into an array by reading then cutting each line.
    while read line
    do
        for ((i=1 ; i <= fields ; i++)); do 
            array[j]=$(echo "$line" | cut -f $i)
            j=$((j+1))
        done

    done < $1
    # Input the first matrix into an array by reading then cutting each line.
    j=0
    while read line
    do
        for ((k=1 ; k <= fields ; k++)); do 
            # At each line and at each valueof m1 add the corresponding array value of m2.
            val=`expr $(echo "$line" | cut -f $k) + ${array[j]}`
            #For the line convert this column of values into a line with tab delim and store then append in tempfile.
            echo "$val" | tr '\n' '\t'>> "$TMP"
            # Update to next element in array for next pass.
            j=$((j+1))
        done
    echo "" >> "$TMP"
    done < $2
    # Getting rid of the trailing tabs inspired by the profs hint.
    while read line
    do
        line="$line"
        line=${line%}
        echo "$line"
    done < $TMP
    
}
#########################################################################################
# Function: multiply
# Description: This function takes two matrices and multiplies them,
# https://www.programmingsimplified.com/c-program-multiply-matrices was used for inspiration.
# Pre-Condition: Requires that rows of first matrix equal to columns of second matrix.
# Post-Condition: Multiplied values fed to standard out.
function multiply()
{
    # Declare 3 associative arrays to be used in multiply.
    declare -A array1
    declare -A array2
    declare -A array3
    # Column count calculation.
    COLS1="$(head -1 $1 |head -1 $1 |tr '\t' '\n' |wc -l)"
    COLS2="$(head -1 $2 |head -1 $2 |tr '\t' '\n' |wc -l)"

    # Row count calculation.
    rowcount=0
    while read; do
        ((rowcount++))
    done < $1
    ROWS1="$rowcount"

    
    rowcount=0
    while read; do
        ((rowcount++))
    done < $2
    ROWS2="$rowcount"
     # If column count of matrix 1 does not equal the row count of matrix 2 then exit with error.
    if [[ $COLS1 -ne $ROWS2 ]]
    then 
        echo "ERROR: The dimensions of the input matrices do not allow them to be multiplied together following the rules of matrix multiplication." >&2
        exit 6
    fi

    k=0
    while read line
    do
    j=0
        # Load associative array1 with each index, and a paired key in format [row, column].
        for ((i=1 ; i <= $COLS1 ; i++)); do 
            array1[$k, $j]=$(echo "$line" | cut -f $i)
            j=$((j+1))
        done
        k=$((k+1))
    done < $1

    k=0
    while read line
    do
    j=0
        # Load associative array2 with each index, and a paired key in format [row, column].
        for ((i=1 ; i <= $COLS2 ; i++)); do 
            array2[$k, $j]=$(echo "$line" | cut -f $i)
            j=$((j+1))
        done
        k=$((k+1))
    done < $2
    # Calculate the multiplication of array1 * array2 using a triple for loop.
    sum=0
    for ((i = 0; i < $ROWS1; i++)); do 
        for ((j = 0; j < $COLS2; j++)); do
            for ((k = 0; k < $ROWS2 ; k++)); do
            array1=${array1[$i, $k]}
            array2=${array2[$k, $j]}
            sum=$(($sum+($array1*$array2)))
            done
            # Update the multiplied value at this location in the matrix. 
            array3[$i, $j]=$sum
            # Reset the sum variable for next calculation.  
            sum=0
        done
    done
    # Print the multiplied matrix using a nested for loop.
    for ((i = 0; i < $ROWS1; i++)); do 
        for ((j = 0; j < $COLS2; j++)); do
        echo "${array3[$i, $j]}" | tr '\n' '\t' >> "$TMP"
        done
        echo "" >> "$TMP"
        done

    # Getting rid of the trailing tabs -inspired by the profs hint, and another student alerting me to it in slack.
    while read line
    do
        line="$line"
        line=${line%}
        echo "$line"
    done < $TMP
    
}
#########################################################################################
# Conditonal branches
# If argument number is 1 and dims is called assume data to be read from stdin
if [ $1 = "dims" ] && [ $# -eq 1 ]
then
        # Read data into temp file
        while read line
        do	
        echo "$line" >> "$TMP"
        done < "${2:-/dev/stdin}" 
        # If the temp file is readable then call dims         
        if [ $1 = "dims" ] && [ -r $TMP ] 
        then
            dims $TMP
            exit 0
        else
            echo "ERROR: File named by argument 1 is not readable." >&2
            exit 3 
        fi
# Else if argument number is 2 and dims is called, assume data to be read from file
elif [ $1 = "dims" ] && [ $# -eq 2 ]
then
                
        if [ $1 = "dims" ] && [ -r $2 ] 
        then
            dims $2
            exit 0
        else
            echo "ERROR: Argument count is 1 but the file named by argument 1 is not readable." >&2
            exit 3 
        fi

elif [ $1 = "transpose" ] && [ $# -eq 1 ]
then
        while read line
        do	
        echo "$line" >> "$TMP"
        done < "${2:-/dev/stdin}" 
                
        if [ $1 = "transpose" ] && [ -r $TMP ] 
        then
            transpose $TMP
            exit 0
        else
            echo "ERROR: File named by argument 1 is not readable." >&2
            exit 2 
        fi

elif [ $1 = "transpose" ] && [ $# -eq 2 ]
then
        
        if [ -r $2 ] && [ -f $2 ]
        then
            transpose $2
            exit 0
        else
            echo "ERROR: Argument count is 1 but the file named by argument 1 is not readable." >&2
            exit 2 
        fi        

elif [ $1 = "mean" ] && [ $# -eq 1 ]
then
        while read line
        do	
        echo "$line" >> "$TMP"
        done < "${2:-/dev/stdin}" 
                
        if [ $1 = "mean" ] && [ -r $TMP ] 
        then
            mean $TMP
            exit 0
        else
            echo "ERROR: File named by argument 1 is not readable." >&2
            exit 2 
        fi

elif [ $1 = "mean" ] && [ $# -eq 2 ]
then
               
        if [ $1 = "mean" ] && [ -r $2 ] 
        then
            mean $2
            exit 0
        else
            echo "ERROR: Argument count is 1 but the file named by argument 1 is not readable." >&2
            exit 2 
        fi 
# Else if add is called and if the two files indicated are readable.
elif [ $1 = "add" ] && [ -r $2 ] && [ -r $3 ]
then
        # Check to make sure too many/too few arguments arent used.
        if [ ! $# -eq 3 ]
        then
            echo "ERROR: Argument count does not equal 2." >&2
            exit 3
        else
            add $2 $3
            exit 0
        fi

# Else if multiply is called and if the two files indicated are readable.
elif [ $1 = "multiply" ] && [ -r $2 ] && [ -r $3 ] 
then
        # Check to make sure too many/too few arguments arent used.
        if [ ! $# -eq 3 ]
        then
            echo "ERROR: Argument count does not equal 2." >&2
            exit 3
        else
            multiply $2 $3
            exit 0
        fi

    else 
        echo "Argument count is incorrect." >&2
        exit 5
fi
########################################################################################

