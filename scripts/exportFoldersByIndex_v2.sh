FILE_WITH_INDEX_TO_EXPORT="indexList.txt" # -i
EXPORT_FOLDER="!!ExportedFolder[$(date +%F)]" # -f
EXPORT_FOLDER_PATH="" # -p
FOUND_ITEMS_LIST_FILE="foundProducts.csv"
MISSING_ITEMS_LIST_FILE="missingProducts.txt"
MISSING_REQUIRED_FOLDERS_FILE="emptyProducts.csv"

#--------- [ flags ] ---------
FLAG_CREATE_LOG_FILE=false # -l
LOG_FILE_NAME="exportFoldersScript[$(date +%F)].log"
FLAG_USE_MAX_DEPTH=false # -d
FLAG_EXPORT_ONLY_FIRST_IMAGE=false # -s
FLAG_PRESERVE_ORIGINAL_NAME=false # -n

#--------- [ manual overwrite ] ---------
REQUIRED_FOLDER_NAME="gotowe"
declare -a EXPORT_ALSO_LIST # -E
#---------------------------
# other global string variabels
EXPORT_FULL_DIRECTORY=""
USR_SYSTEM=""

# EXAMPLE: sh moveFoldersToSpecificGroup.sh -i 'items.txt' -p 'C:\___TEST\export folders\move_here' -f 'export items' -l -d
function  displayHelp {
  echo "sctipt to export folders to new directory serching by index from provaided txt file"
  echo "CAUTION: Script don't check if folder have same index in them. if w folder will have same index script will export only first whats find and don't show any errors"
  echo
  echo "example: sh moveFoldersToSpecificGroup.sh -i 'items.txt' -p 'C:\Produckts\Product list\export' -f 'export items'"
  echo
  echo "to change option in script open it and edit variabels below:"
  echo "FILE_WITH_INDEX_TO_EXPORT       name of txt file with list of index separate by new line [default: 'indexList.txt']"
  echo "EXPORT_FOLDER                   folder name where files will be moved [default: 'Group_Name']"
  echo "EXPORT_FOLDER_PATH              path where folder to export will be created, can be absolute or relative [default: '']"
  echo "FOUND_ITEMS_LIST_FILE           name of txt file where will be printed all items that was find [default: 'foundProducts.txt']"
  echo "MISSING_ITEMS_LIST_FILE         name of txt file where will be printed all items that wasn't find [default: 'missingProducts.txt']"
  echo "MISSING_REQUIRED_FOLDERS_FILE   name of txt file where will be printed all items wich missing or empty folder [default: 'emptyProducts.txt']"
  echo "REQUIRED_FOLDER_NAME            name of specify folder that is required and can't be empty [default: 'gotowe.txt']"
  echo
  echo "Syntax: scriptTemplate [-i|f|p|d|s|l|n|h]"
  echo "options:"
  echo "i     specify name of file wich item to move if empty refer to default [FILE_WITH_INDEX_TO_EXPORT]"
  echo "p     Add additional absolute or relative paht to directory where folders will be exported; default ./"
  echo "f     Specyfy folder name where items will be moved, if empty refer to default [EXPORT_FOLDER]"
  echo "s     export sigle file from searching directory, first image, false on default."
  echo "d     shift deapt of searching directory to 2, false on default."
  echo "l     save log file of done action, false on default.[exportFoldersScript.log]"
  echo "n     leave orginal name for folder, false on default."
  echo "E     add extra folders to export you can add multiple by reapiting flag"
  echo "h     Print this Help."
  echo
}

function getSystemName {
  local unameOut="$(uname -s)"
  local sysName=""
  case "${unameOut}" in
      Linux*)                         sysName=Linux;;
      Darwin*)                        sysName=Mac;;
      CYGWIN*|MINGW32*|MSYS*|MINGW**) sysName=Win;;
    esac
  echo $sysName
}

### list of allow flags
# "options: [-i|f|p|d|s|l|n|h]"
while getopts hp:f:i:dslnE: flag ;do
    case "${flag}" in
        i) if [[ $OPTARG ]]; then
              FILE_WITH_INDEX_TO_EXPORT="${OPTARG}"
            fi;;
        f) if [[ $OPTARG ]]; then
              EXPORT_FOLDER="${OPTARG}"
            fi;;
        p) if [[ $OPTARG ]]; then
              EXPORT_FOLDER_PATH=`cygpath -u "${OPTARG}"`
            fi;;
        E) if [[ $OPTARG ]]; then
              EXPORT_ALSO_LIST+=("${OPTARG[@]}")
            fi;;
        d) FLAG_USE_MAX_DEPTH=true;;
        s) FLAG_EXPORT_ONLY_FIRST_IMAGE=true;;
        l) FLAG_CREATE_LOG_FILE=true;;
        n) FLAG_PRESERVE_ORIGINAL_NAME=true;;
        h) displayHelp; exit 0;;
        \?) echo -e "\033[0;31mIllegal option or missing arguments for flag\033[0m";exit 0;;
    esac
  done

# wait for user confirmation
echo "Do you want to execute program? Enter 'Y' to continue"
    read userImput
      if [[ $userImput != "Y" ]] ; then
        echo -e "\n ------ Exiting program ------\n"
        exit 0
      break
  fi
echo -e "\n"

# confert files wich index clft to lf
if [[ ! -f $FILE_WITH_INDEX_TO_EXPORT ]];then
    echo -e "\033[0;31m[X] missing file with list of index, expected file: ${FILE_WITH_INDEX_TO_EXPORT}\033[0m"
    exit 0
  fi
dos2unix $FILE_WITH_INDEX_TO_EXPORT

# check if path was provided and create full path to export
if [[ $EXPORT_FOLDER_PATH ]];then
    EXPORT_FULL_DIRECTORY="${EXPORT_FOLDER_PATH}/${EXPORT_FOLDER}"
  else
    EXPORT_FULL_DIRECTORY="${EXPORT_FOLDER}"
  fi

# create folder to export
mkdir -p "${EXPORT_FULL_DIRECTORY}"

###################################
# DECLARE VARIABELS AND FUNCTIONS
declare -a filesIndexArray # array with items names from file
declare -a uniqItemsIndexArray # array with items name from file without duplicates
declare -a foundIndex # array with found item names
declare -a itemsWithMissingFolder # array of folders without or empty folder specified in $REQUIRED_FOLDER_NAME
declare -i exportedItemCounter=0 # counter how many item were found
declare -i initialItemCounter # counter how many item were found

USR_SYSTEM=$(getSystemName)

# translate path depends on system
function translatePath {
  local path=$1

  case $USR_SYSTEM in
    Win) echo `cygpath -w "${path}"`;;
    Mac|Linux) echo `cygpath -u "$path"`;;
  esac
}

# update $itemsWithMissingFolder array and $MISSING_REQUIRED_FOLDERS_FILE file
function updateMissingItems {
  local value=$1
  local path=$(translatePath "$2")

  # array structure: index;path
  # array example: W-12021;P:__/old group/dir/item
  itemsWithMissingFolder+=("${value};${path}")
  printf "%s\n" "${itemsWithMissingFolder[@]}" > $MISSING_REQUIRED_FOLDERS_FILE
}
# update $foundIndex array and $FOUND_ITEMS_LIST_FILE file
function updateMovedItems {
  local value=$1
  local path=$(translatePath "$2")

  # array structure: index;path
  # array example: W-12021;P:__/new group/dir/item
  foundIndex+=("${value};${path}")
  printf "%s\n" "${foundIndex[@]}" > $FOUND_ITEMS_LIST_FILE
}

# if $FLAG_CREATE_LOG_FILE [-l] flag is true update $LOG_FILE_NAME
function updateLogFile {
  local logText=$1

  # print info to log file
  if [[ $FLAG_CREATE_LOG_FILE == true ]]; then
    printf "%s\n" "${logText}" >> $LOG_FILE_NAME
    fi
}

# check if curent folder shuld be skiped (if start wich _ or !)
function checkWhetherToIgnore {
  local dir=$1
  if [[ "${dir#\.\/}" =~ [_*|/!*] ]]; then
      return 1
    fi
}

function GetIndexFromFolderName {
  local dir=$1
  [[ $dir =~ ([W|T]-[0-9]+$) ]]
  itemIndex="${BASH_REMATCH[1]}"
  echo $itemIndex
}

# export folder function
function ExportFolder {
  local itemIndex=$1
  local dir=$2
  local dirName="${dir#*\/}"
  local exportedItemDirectoryName=""
  local exportedFilesCounter=0

  # loop thru array with Items to move
  # when find move new place and remove from array
  # if finded item is empty to array with missing items
  for item in "${!uniqItemsIndexArray[@]}"; do
    if [[ "${uniqItemsIndexArray[$item]}" == "${itemIndex}" ]]; then

        # check if Item have folder $REQUIRED_FOLDER_NAME
        if [[ ! -d "${dir}/${REQUIRED_FOLDER_NAME}" ]] || [[ -z `ls -A "$dir/${REQUIRED_FOLDER_NAME}"` ]]; then
            echo -e "\033[0;31m[X] ── missing folder or empty for: ${dir}\033[0m"
            updateLogFile "[X] ── missing folder or empty for: ${dir}"
            updateMissingItems $dir "${EXPORT_FULL_DIRECTORY}"
            continue
          fi

        echo -e "[ ] ── find ${itemIndex} \033[1;30min ${dir} \033[0m"
        updateLogFile "[✓] ── find ${itemIndex} in ${dir}"

        # create exportet directory path wich folder name to exported folder [-n]
        if [[ $FLAG_PRESERVE_ORIGINAL_NAME == true ]]; then
            exportedItemDirectoryName=$dirName
          else
            exportedItemDirectoryName=$itemIndex
          fi

        # copy folder depends on flag [-s]
        if [[ $FLAG_EXPORT_ONLY_FIRST_IMAGE == true ]]; then
              mkdir -p "${EXPORT_FULL_DIRECTORY}/${exportedItemDirectoryName}/"
              cp -r "${dir}/${REQUIRED_FOLDER_NAME}/${itemIndex}_00.jpg" "${EXPORT_FULL_DIRECTORY}/${exportedItemDirectoryName}"
              let "exportedFilesCounter++"
          else
            cp -r "${dir}/${REQUIRED_FOLDER_NAME}" "${EXPORT_FULL_DIRECTORY}/${exportedItemDirectoryName}"
            quantityOfFilesInExportedDirectory=$(ls "${dir}/${REQUIRED_FOLDER_NAME}" | wc -l)
            exportedFilesCounter=$((exportedFilesCounter+$quantityOfFilesInExportedDirectory))
          fi

        echo "    └─ exported ${exportedFilesCounter} Item to: \"`translatePath "${EXPORT_FULL_DIRECTORY}"`\""
        updateLogFile "    └─ exported ${exportedFilesCounter} Item to: \"`translatePath "${EXPORT_FULL_DIRECTORY}"`\""

        # copy extra folders [-E] flag
        if [[ "${#EXPORT_ALSO_LIST[*]}" > 0 ]]; then
            for extraDir in "${EXPORT_ALSO_LIST[@]}";do
                # check directory exist
                if [[ ! -d "${dir}/${extraDir}" ]] || [[ -z `ls -A "$dir/${extraDir}"` ]]; then
                    echo -e "    └─ \033[0;31m[X] missing folder or empty for: ${dir}/${extraDir}\033[0m"
                    updateLogFile "    └─ missing folder or empty for: ${dir}/${extraDir}"
                  else
                    cp -r "${dir}/${extraDir}" "${EXPORT_FULL_DIRECTORY}/${exportedItemDirectoryName}"
                    echo "    └─ exported '${extraDir}' folder to: \"`translatePath "${EXPORT_FULL_DIRECTORY}/${extraDir}"`\""
                    updateLogFile "    └─ exported '${extraDir}' folder to: \"`translatePath "${EXPORT_FULL_DIRECTORY}/${extraDir}"`\""
                  fi
              done
          fi

        echo -e "\033[$((${#EXPORT_ALSO_LIST[*]} + 2))A[\033[1;32m✓\033[0m] ── find ${itemIndex} \033[0;40min ${dir} \033[0m\033[$((${#EXPORT_ALSO_LIST[*]} + 1))B"

        # remove element from array
        uniqItemsIndexArray[$item]=${uniqItemsIndexArray[-1]} # replace current item wich last item in array
        uniqItemsIndexArray=("${uniqItemsIndexArray[@]::${#uniqItemsIndexArray[@]}-1}") # reassign array wichout last element

        # add current index to $foundIndex array
        updateMovedItems $exportedItemDirectoryName "${EXPORT_FULL_DIRECTORY}/${dir}"

        # exporter produkts couter
        let "exportedItemCounter++"

        break
      fi
  done
}

###################################
# ACTUAL PROGRAM

# read $FILE_WITH_INDEX_TO_EXPORT file and put index to array
mapfile -t filesIndexArray < $FILE_WITH_INDEX_TO_EXPORT

# check for duplicates in file and if exe
duppFilesIndexArray=($(printf "%s\n" "${filesIndexArray[@]}"|awk '!($0 in seen){seen[$0];next} 1'))
if [[ ${#duppFilesIndexArray[@]} > 0 ]]; then
  echo -e "\033[0;31m \n----- WARNING -----\033[0m"
  echo "found duplicates in the file ${FILE_WITH_INDEX_TO_EXPORT}"
  echo "--- number of duplicates : ${#duppFilesIndexArray[*]}"
  echo "list of duplicates have been saved to : ${duppProductsListFile}"
  printf "%s\n" "${duppFilesIndexArray[@]}" > $duppProductsListFile
fi

uniqItemsIndexArray=($(printf "%s\n" "${filesIndexArray[@]}" | sort -u ))
echo -e "\nselected items - ${#uniqItemsIndexArray[*]} \n"
initialItemCounter="${#uniqItemsIndexArray[@]}" # get quantity of all indexes in files to compere layter
unset filesIndexArray # clear unused array from memory

for dir in *; do
  if [ -d "$dir" ]; then

      # if max depth flag [-d] is active search in subfolders
      if [[ $FLAG_USE_MAX_DEPTH == true ]]; then

          # ignore files start wich "_" and "!"
          checkWhetherToIgnore $dir || continue

          for subdir in "${dir}"/*; do
            if [ -d "$subdir" ]; then

                subdirName="${subdir#*\/}"

                # ignore files start wich "_" and "!"
                checkWhetherToIgnore $subdirName || continue

                #get item Index from folder name
                itemIndex=$(GetIndexFromFolderName $subdirName)

                # export curent directory function
                ExportFolder $itemIndex "${subdir}" || continue

              fi
          done

        else
          # ignore files start wich "_" and "!"
          checkWhetherToIgnore $dir || continue

          #get item Index from folder name
          itemIndex=$(GetIndexFromFolderName $dir)

          # export curent directory function
          ExportFolder $itemIndex "${dir}" || continue
        fi

    fi
done

###########################
# Summary of program opperation

echo -e "\n\nFound ${exportedItemCounter} products, of ${initialItemCounter}"

# save not found items to the file $MISSING_ITEMS_LIST_FILE
if [[ ${#uniqItemsIndexArray[*]} > 0 ]]; then
  printf "%s\n" "${uniqItemsIndexArray[@]}" > $MISSING_ITEMS_LIST_FILE
  echo -e "\033[0;31m not found ${#uniqItemsIndexArray[*]} folders from list, saved to file 'missingProducts.txt'\033[0m"
fi

echo -e "\n"
read -n 1 -s -r -p "Press any button to exit"
