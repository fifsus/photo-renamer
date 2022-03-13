#! /bin/sh

# This script will be placed in the gallery root
# 1. Read current directory, list directories names
# 2. Ask user for directory which to process
# 3. User inputs directory name, if incorrect, must retry
# 4. Script reads directory and lists file names ordered by modified timestamp with example how the renamed file will look like
#       DCIM_PIC_265161321.jsg -> 2021-02-12 Dovolená
# 5. User is asked for confirmation if the rename should start.
# 6. On confirmation, files will be renamed -> exit, else exit

echo 'Starting...'

# Override default directory "C:/merim/rb3"
scriptLocation=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
# echo $SCRIPT_DIR
cd "$scriptLocation"
# echo "Script is located at '$SCRIPT_DIR'"

echo ""
currentDirectory=$(pwd)
echo "Your current directory is '$currentDirectory'"
echo ""

logToFile(){
    # Log rename result to file in case of soome issue, so it could be renamed back
    # logFileName="$scriptLocation/rename_log.txt"
    logFileName="rename_log.txt"    

    date=$(date)
    echo "$date | Directory: /$1/ | $2 -> $3" >> $logFileName
}

getNewName(){    
    # The program must be "cd" to required directory
    # First param is the directory name which will be used as image name
    # Second param is simple path to image from current directory, which will be used to retrieve timestamp
    # Third param is the counter for images with the same date
    # Fourth param is boolean if the numbers should be starting from (1)

    # The expected result is "2021-02-15 Dovolená (2).jpg"

    # imageName=${1#* }

    # Get date from properties
    timestamp=$(getDateOnly "$2")
    
    # Extract file extension without .
    fileExtension=$(getFileExtension "$2")

    if [ ! $3 = 1 ] || [ $4 = true ]; then
        counter=" ($3)"
    else 
        counter=""
    fi

    newName="$timestamp $1$counter.$fileExtension"
    echo $newName
}

getFullTimestamp(){
    timestamp=$(stat "$1" | grep Modify:)
    timestamp=${timestamp#"Modify: "}
    timestampWithoutSpaces=${timestamp//[[:blank:]]/}
    echo $timestampWithoutSpaces
}

getDateOnly(){
    # date=$(stat "$2")
    # File: test.jpg Size: 989366 Blocks: 968 IO Block: 65536 regular file Device: 9159dc44h/2438585412d Inode: 12666373952246117 Links: 1 Access: (0644/-rw-r--r--) Uid: (197609/ filip) Gid: (197609/ UNKNOWN) Access: 2022-03-02 18:15:44.651022300 +0100 Modify: 2018-08-31 20:22:27.000000000 +0200 Change: 2022-03-02 17:56:01.966701900 +0100 Birth: 2022-03-02 17:55:57.191266400 +0100 2018-08-31 20:22:27.000000000 +0200

    date=$(stat "$1" | grep Modify:)
    # Modify: 2018-08-31 20:22:27.000000000 +0200
    date=${date#"Modify: "}
    # 2018-08-31 20:22:27.000000000 +0200
    date=${date% *}
    # 2018-08-31 20:22:27.000000000
    date=${date% *}
    # 2018-08-31
    echo $date
}

getFileExtension(){
    fileExtension=${1##*.}
    echo $fileExtension
}

# List folders
echo "Found these folders:"
echo ""
for path in *
do
    if [[ -d $path ]]; then
        echo "  $path"
    elif [[ -f $path ]]; then
        # It is a file
        
        # echo $path
        continue 1
    else
        echo "$path is not valid"
        exit 1
    fi
done
echo ""
echo ""

echo "Which folder you want to rename files in?"
echo ""
read dirName
echo ""

while [[ ! -d "$dirName" ]]; do
    echo "Unknown directory '$dirName'. Retry..."
    read dirName
    echo ""
done

echo "Changing directory to '$dirName' and listing files..."
echo ""
cd "$dirName"

# Declare dictionary for unsorted images
declare -A unsortedImages

# Loop through the files in directory and populate the dictionary 
# where key is timestamp without spaces and value is file name
fileCount=0
imageCount=0
dirCount=0

# for PATH in ./"$DIR_NAME"/*
for path in *
do
    if [[ -d $path ]]; then
        ((dirCount++))
    elif [[ -f $path ]]; then
        ((fileCount++))
        # Get file extension
        fileExtension=$(getFileExtension "$path")
        # Process only *.jpg / *.jpeg images
        if [ $fileExtension = "jpg" ] || [ $fileExtension = "jpeg" ] || [ $fileExtension = "JPG" ] || [ $fileExtension = "JPEG" ]; then
            ((imageCount++))
            imageTimestamp=$(getFullTimestamp "$path")
            unsortedImages["$imageTimestamp"]=$path
        fi
    else
        echo "$path is not valid"
        exit 1
    fi
done

echo "In directory '$dirName' there are $dirCount directories and $fileCount files (of which $imageCount JPG/JPEG images which can be renamed). What name should be used for the files? (default: $dirName)"
echo ""

if [ $imageCount = 0 ]; then
    echo "No JPG/JPEG images found in folder '$dirName'. Exiting..."
    exit 1
fi

read newName

if [ -z "$newName" ] ; then
    newName="$dirName"
fi

echo ""

echo "Should I add number also to first photo with the same date? [e.g. 2021-05-04 Vacation (1).jpg] [Y/N] (default: N)"
echo ""

read numbersFromOne

echo ""

if [ -z "$numbersFromOne" ] ; then
    numbersFromOne=false
elif [ "$numbersFromOne" = "y" ] || [ "$numbersFromOne" = "Y" ] ; then
    numbersFromOne=true
else
    numbersFromOne=false
fi

# Now the dictionary is populated but unsorted

# Sort the dictionary

# Extract the keys (timestamps without spaces)
keyArray=${!unsortedImages[@]}

# Sort the keys
sortedArray=($(for l in ${keyArray[@]}; do echo $l; done | sort))
# printf "[%s]\n" "${sortedArray[@]}"

# Declare dictionary for sorted images
declare -A sortedImages

# Counter just to display in logs
imageCounter=0
# Date of previous image to compare for counter
previousImageDate=0
# Previous image counter value
sameDateCounter=0

echo "# | MODIFIED TIMESTAMP                | ORGINAL NAME -> NEW NAME"

# Loop through sorted image timestamps
for indexTimestamp in ${sortedArray[@]}; do 
    ((imageCounter++))

    # Get path to old image
    oldImageName=${unsortedImages[$indexTimestamp]}
    
    # Get and store date of old image
    newImageDate=$(getDateOnly "$oldImageName")
    # If the image has the same date as previous one, increment count, else, reset to 0
    if [ $newImageDate = $previousImageDate ] || [ $previousImageDate = 0 ]; then 
        ((sameDateCounter++))
    else
        sameDateCounter=1
    fi
    previousImageDate=$newImageDate

    # Get new name based on date, user custom name, photos count with the same date
    newImageName=$(getNewName "$newName" "$oldImageName" "$sameDateCounter" "$numbersFromOne")
    echo "$imageCounter | $indexTimestamp | $oldImageName -> $newImageName"
    
    # Store old and new name to dictionary
    sortedImages[$oldImageName]=$newImageName    
done

echo ""
echo "These images will be renamed as displayed above. Proceed? [Y/N] (default: N)"
echo ""
read confirmation
echo ""

if [ -z "$confirmation" ] ; then
    confirmed=false
elif [ "$confirmation" = "y" ] || [ "$confirmation" = "Y" ] ; then
    confirmed=true
else
    confirmed=false
fi

if [ $confirmed = true ] ; then
    echo "Processing..."
    echo ""

    for oldImageName in "${!sortedImages[@]}"; do
        if [[ -f "${sortedImages[$oldImageName]}" ]]; then
            # If file with new name exists, do not rename it, because this would replace the file
            echo "Cannot rename '$oldImageName' to '${sortedImages[$oldImageName]}'. File '${sortedImages[$oldImageName]}' already exists. Skipping..."
        else
            mv "$oldImageName" "${sortedImages[$oldImageName]}"
            logToFile "$dirName" "$oldImageName" "${sortedImages[$oldImageName]}"
            echo "Renaming '$oldImageName' to '${sortedImages[$oldImageName]}' completed"
        fi
    done

    echo ""
    echo "All done!"
    echo ""
fi

echo "Exiting."
exit 1