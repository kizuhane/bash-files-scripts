FILE_WITH_INDEX_TO_EXPORT="indexList.txt"
EXPORT_FOLDER="Group_Name"
EXPORT_FOLDER_PATH=""
FOUND_ITEMS_LIST_FILE="foundProducts.csv"
MISSING_ITEMS_LIST_FILE="missingProducts.txt"
MISSING_REQUIRED_FOLDERS_FILE="emptyProducts.csv"
#---------------------------
REQUIRED_FOLDER_NAME="gotowe"
#---------------------------

# export only first image flag indicator ▼
EXPORT_FULL_DIRECTORY=""
USR_SYSTEM=""

# EXAMPLE: sh moveFoldersToSpecificGroup.sh -i 'items.txt' -p 'C:\___TEST\export folders\move_here' -f 'export items'
function  displayHelp {
  echo "sctipt to relocate folders to new directory serching by index from provaided txt file"
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
  echo "Syntax: scriptTemplate [-f|h]"
  echo "options:"
  echo "i     specify name of file wich item to move if empty refer to default [FILE_WITH_INDEX_TO_EXPORT]"
  echo "n     Directory name where folders will be exported if empty refer to default [EXPORT_FOLDER]"
  echo "p     Add additional absolute or relative paht to directory where folders will be exported; default ./"
  echo "f     Specyfy folder name where items will be moved"
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
# "options: [-n|p|h]"
while getopts hp:f:i: flag ;do
    case "${flag}" in
        i) if [[ $OPTARG ]]; then
              FILE_WITH_INDEX_TO_EXPORT="${OPTARG}"
            fi;;
        f) if [[ $OPTARG ]]; then
              EXPORT_FOLDER="${OPTARG}"
            fi;;
        p) if [[ $OPTARG ]]; then
              EXPORT_FOLDER_PATH=`cygpath -u $OPTARG`
            fi;;
        h) displayHelp; exit 0;;
    esac
  done

# wait for user confirmation
echo "Czy chcesz wykonać program? wpisz 'Y' aby kontynuować"
    read userImput
      if [[ $userImput != "Y" ]] ; then
        echo -e "\n ------ Zamykam program ------\n"
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
declare -i exportedItemCounter # counter how many item were found
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

###################################
# ACTUAL PROGRAM

# read $FILE_WITH_INDEX_TO_EXPORT file and put index to array
mapfile -t filesIndexArray < $FILE_WITH_INDEX_TO_EXPORT

# check for duplicates in file and if exe
duppFilesIndexArray=($(printf "%s\n" "${filesIndexArray[@]}"|awk '!($0 in seen){seen[$0];next} 1'))
if [[ ${#duppFilesIndexArray[@]} > 0 ]]; then
  echo -e "\033[0;31m \n----- UWAGA -----\033[0m"
  echo "znaleziono duplikaty w pliku ${FILE_WITH_INDEX_TO_EXPORT}"
  echo "--- liczba duplikatów: ${#duppFilesIndexArray[*]}"
  echo "duplikaty zapisano do: ${duppProductsListFile}"
  printf "%s\n" "${duppFilesIndexArray[@]}" > $duppProductsListFile
fi

uniqItemsIndexArray=($(printf "%s\n" "${filesIndexArray[@]}" | sort -u ))
echo -e "\nzaznaczonych elemętów - ${#uniqItemsIndexArray[*]} \n"
initialItemCounter="${#uniqItemsIndexArray[@]}" # get quantity of all indexes in files to compere layter 
unset filesIndexArray # clear unused array from memory

for dir in *; do
  if [ -d "$dir" ]; then
      # ignore files start wich "_" and "!"
      if [[ "${dir#\.\/}" =~ [_*|/!*] ]]; then
          continue
        fi
      
      # get item Index from folder name
      [[ $dir =~ ([W|T]-[0-9]+$) ]]
      itemIndex="${BASH_REMATCH[1]}"

      # loop thru array with Items to move 
      # when find move new place and remove from array
      # if finded item is empty to array with missing items
      for item in "${!uniqItemsIndexArray[@]}"; do
        if [[ "${uniqItemsIndexArray[$item]}" == "${itemIndex}" ]]; then
            
            # check if Item have folder $REQUIRED_FOLDER_NAME
            if [[ ! -d "${dir}/${REQUIRED_FOLDER_NAME}" ]] || [[ -z `ls -A "$dir/${REQUIRED_FOLDER_NAME}"` ]]; then
                echo -e "\033[0;31m[X] ── missing folder or empty for: ${dir}\033[0m"
                updateMissingItems $dir "${EXPORT_FULL_DIRECTORY}"
                continue
              fi

            echo -e "[ ] ── find ${itemIndex} \033[1;30mas ${dir} \033[0m"

            # move logic remmovve 
            mv ${dir} "${EXPORT_FULL_DIRECTORY}"
            echo -e "\033[1A[\033[1;32m✓\033[0m] ── find ${itemIndex} \033[0;40mas ${dir} \033[0m"
            echo "    └─ move Item to: \"`translatePath "${EXPORT_FULL_DIRECTORY}"`\""
            
            # remove element from array
            uniqItemsIndexArray[$item]=${uniqItemsIndexArray[-1]} # replace current item wich last item in array
            uniqItemsIndexArray=("${uniqItemsIndexArray[@]::${#uniqItemsIndexArray[@]}-1}") # reassign array wichout last element

            # add current index to $foundIndex array
            updateMovedItems $itemIndex "${EXPORT_FULL_DIRECTORY}/${dir}"

            # exporter produkts couter
            let "exportedItemCounter+=1"

            break
          fi
      done
    fi
done

###########################
# Summary of program opperation

echo -e "\n\nznaleziono ${exportedItemCounter} produktów z ${initialItemCounter}"

# save not found items to the file $MISSING_ITEMS_LIST_FILE
if [[ ${#uniqItemsIndexArray[*]} > 0 ]]; then
  printf "%s\n" "${uniqItemsIndexArray[@]}" > $MISSING_ITEMS_LIST_FILE
  echo -e "\033[0;31mnie znaleziono ${#uniqItemsIndexArray[*]} produktów z listy, zapisano do folderu 'missingProducts.txt'\033[0m"
fi

echo -e "\n"
read -n 1 -s -r -p "Wciśnij dowonly przycisk aby wyłączyć"