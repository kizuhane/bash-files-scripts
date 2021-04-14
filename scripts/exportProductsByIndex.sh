FileWithIndexToExport="export.txt"
ExportFolder="ExportFolder"
missingProductsListFile="missingProducts.txt"
duppProductsListFile="dupplicateIndex.txt"

# wait for user confirmation
echo "Czy chcesz wykonać program? wpisz 'Y' aby kontynuować"
    read userImput
      if [[ $userImput != "Y" ]] ; then
        echo -e "\n------ Zamykam program ------\n"
        exit 0
      break
  fi
echo -e "\n"

# confert clft to lf
dos2unix $FileWithIndexToExport

# create folder to export
mkdir -p $ExportFolder

declare -a filesIndexArray
declare -a missingIndex
declare -i exportedIndexCounter

# read $FileWithIndexToExport file and put index to array
mapfile -t filesIndexArray < $FileWithIndexToExport

# check for duplicates in file and if exe
duppFilesIndexArray=($(printf "%s\n" "${filesIndexArray[@]}"|awk '!($0 in seen){seen[$0];next} 1'))
if [[ ${#duppFilesIndexArray[@]} > 0 ]]; then
  echo -e "\n----- UWAGA -----"
  echo "znaleziono duplikaty w pliku ${FileWithIndexToExport}"
  echo "--- liczba duplikatów: ${#duppFilesIndexArray[*]}"
  echo "duplikaty zapisano do: ${duppProductsListFile}"
  printf "%s\n" "${duppFilesIndexArray[@]}" > $duppProductsListFile
fi

uniqFilesIndexArray=($(printf "%s\n" "${filesIndexArray[@]}" | sort -u ))
echo -e "\nzaznaczonych elemętów - ${#uniqFilesIndexArray[*]} \n"

for item in ${uniqFilesIndexArray[@]}; do
    NAME=`find . -type d -regextype posix-extended -regex "^.*\-${item}"`

    # ignore files start wich "_" and "!"
      if [[ "${NAME}" =~ [_*|/!*] ]]; then
          continue
      fi
    
    # if product dont exist push to $missingIndex array
    if ! [[ $NAME ]]; then
        missingIndex+=($item)
        continue
      fi

    if ! [[ -d "${NAME}/gotowe" ]]; then
        missingIndex+=($item)
        echo -e "\033[0;31m------- [X] missing 'done' file for ${item} !!!"
        echo -e "\033[0;31m------- ------- ------- ------- -------"
        continue
      fi

    echo "------- [✓] find ${item}"
    itemName="${NAME##*/}"

    # regex to extract index
    [[ $itemName =~ ([W|T]-[0-9]+$) ]]
    itemIndex="${BASH_REMATCH[1]}"

    # copy to new folder
    cp -r -v "${NAME}/gotowe" "${ExportFolder}/${itemIndex}"

    # exporter produkts couter
    let "exportedIndexCounter+=1"
  done

echo -e "\n\nznaleziono ${exportedIndexCounter} produktów z ${#uniqFilesIndexArray[*]}"

if [[ ${#missingIndex[*]} > 0 ]]; then
  printf "%s\n" "${missingIndex[@]}" > $missingProductsListFile
  echo -e "\033[0;31m nie znaleziono ${#missingIndex[*]} produktów z listy, zapisano do folderu 'missingProducts.txt'"
fi

echo -e "\n"
read -n 1 -s -r -p "Wciśnij dowonly przycisk aby wyłączyć"
