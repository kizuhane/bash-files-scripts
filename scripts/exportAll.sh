EXPORT_FOLDER="!!ExportedFolder[$(date +%F)]" # -f
FOUND_ITEMS_LIST_FILE="foundProducts.csv"
MISSING_ITEMS_LIST_FILE="missingProducts.txt"
MISSING_REQUIRED_FOLDERS_FILE="emptyProducts.csv"

#--------- [ flags ] ---------
FLAG_USE_MAX_DEPTH=false # -d
FLAG_EXPORT_ONLY_FIRST_IMAGE=false # -s
FLAG_PRESERVE_ORIGINAL_NAME=false # -n

#--------- [ manual overwrite ] ---------
REQUIRED_FOLDER_NAME="gotowe"
#---------------------------
# other global string variabels
USR_SYSTEM=""

# EXAMPLE: sh moveFoldersToSpecificGroup.sh -i 'items.txt' -p 'C:\___TEST\export folders\move_here' -f 'export items' -l -d
function  displayHelp {
  echo "sctipt to export all folders passing name check to new directory"
  echo "CAUTION: Script don't check if folder have same index in them. if w folder will have same index script will export only first whats find and don't show any errors"
  echo
  echo "example: sh exportAll.sh -e 'exportet-items' -d"
  echo
  echo "to change option in script open it and edit variabels below:"
  echo "EXPORT_FOLDER                   folder name where files will be moved [default: 'Group_Name']"
  echo "FOUND_ITEMS_LIST_FILE           name of txt file where will be printed all items that was find [default: 'foundProducts.txt']"
  echo "MISSING_ITEMS_LIST_FILE         name of txt file where will be printed all items that wasn't find [default: 'missingProducts.txt']"
  echo "MISSING_REQUIRED_FOLDERS_FILE   name of txt file where will be printed all items wich missing or empty folder [default: 'emptyProducts.txt']"
  echo "REQUIRED_FOLDER_NAME            name of specify folder that is required and can't be empty [default: 'gotowe.txt']"
  echo
  echo "Syntax: scriptTemplate [-e|s|d|n|h]"
  echo "options:"
  echo "e     Specyfy folder name where items will be moved, if empty refer to default [EXPORT_FOLDER]"
  echo "s     export sigle file from searching directory, first image, false on default."
  echo "d     shift deapt of searching directory to 2, false on default."
  echo "n     leave orginal name for folder, false on default."
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
# "options: [-e|s|d|n|h]"
while getopts e:hdsn flag ;do
    case "${flag}" in
        e) if [[ $OPTARG ]]; then
              EXPORT_FOLDER="!${OPTARG}"
            fi;;
        d) FLAG_USE_MAX_DEPTH=true;;
        s) FLAG_EXPORT_ONLY_FIRST_IMAGE=true;;
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

# create folder to export
mkdir -p "${EXPORT_FOLDER}"

###################################
# DECLARE VARIABELS AND FUNCTIONS
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
  # array structure: name;parent_folder
  # array example: W-12021;P:__/old group/dir/item
  itemsWithMissingFolder+=("${value#*\/};${value%\/*}")
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

  # check if Item have folder $REQUIRED_FOLDER_NAME
  if [[ ! -d "${dir}/${REQUIRED_FOLDER_NAME}" ]] || [[ -z `ls -A "$dir/${REQUIRED_FOLDER_NAME}"` ]]; then
      echo -e "\033[0;31m[X] ── missing folder or empty for: ${dir}\033[0m"
      updateMissingItems "${dir}"
      return 1
    fi

  echo -e "[ ] ── find ${itemIndex} \033[1;30min ${dir} \033[0m"

  # create exportet directory path wich folder name to exported folder [-n]
  if [[ $FLAG_PRESERVE_ORIGINAL_NAME == true ]]; then
      exportedItemDirectoryName=$dirName
    else
      exportedItemDirectoryName=$itemIndex
    fi

  # copy folder depends on flag [-s]
  if [[ $FLAG_EXPORT_ONLY_FIRST_IMAGE == true ]]; then
        mkdir -p "${EXPORT_FOLDER}/${exportedItemDirectoryName}/"
        cp -r "${dir}/${REQUIRED_FOLDER_NAME}/${itemIndex}_00.jpg" "${EXPORT_FOLDER}/${exportedItemDirectoryName}"
        let "exportedFilesCounter++"
    else
      cp -r "${dir}/${REQUIRED_FOLDER_NAME}" "${EXPORT_FOLDER}/${exportedItemDirectoryName}"
      quantityOfFilesInExportedDirectory=$(ls "${dir}/${REQUIRED_FOLDER_NAME}" | wc -l)
      exportedFilesCounter=$((exportedFilesCounter+$quantityOfFilesInExportedDirectory))
    fi

  echo "    └─ exported ${exportedFilesCounter} Item to: \"`translatePath "${EXPORT_FOLDER}"`\""

  echo -e "\033[2A[\033[1;32m✓\033[0m] ── find ${itemIndex} \033[0;40min ${dir} \033[0m\033[1B"

  # add current index to $foundIndex array
  updateMovedItems "${exportedItemDirectoryName}" "${EXPORT_FOLDER}/${exportedItemDirectoryName}"

  # exporter produkts couter
  let "exportedItemCounter++"
}

###################################
# ACTUAL PROGRAM

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

echo -e "\n\nFound ${exportedItemCounter} products"

echo -e "\n"
read -n 1 -s -r -p "Press any button to exit"
