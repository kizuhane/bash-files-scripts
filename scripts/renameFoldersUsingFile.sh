FileWithIndexToExport="fileNames.txt"

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


declare -a filesIndexArray
declare -a missingIndex
declare -i exportedIndexCounter=0

# read $FileWithIndexToExport file and put index to array
mapfile -t filesIndexArray < $FileWithIndexToExport

# check for duplicates in file and if exe
duppFilesIndexArray=($(printf "%s\n" "${filesIndexArray[@]}"|awk '!($0 in seen){seen[$0];next} 1'))
if [[ ${#duppFilesIndexArray[@]} > 0 ]]; then
  echo -e "\n----- UWAGA -----"
  echo "znaleziono duplikaty w pliku ${FileWithIndexToExport}"
  echo "--- liczba duplikatów: ${#duppFilesIndexArray[*]}"
fi

uniqFilesIndexArray=($(printf "%s\n" "${filesIndexArray[@]}" | sort -u ))
echo -e "\nzaznaczonych elemętów - ${#uniqFilesIndexArray[*]} \n"

for item in ${uniqFilesIndexArray[@]}; do
    itemIndex="${item: -7}"
    NAME=`find . -type d -regextype posix-extended -regex "^.*\_${itemIndex}"`

    # ignore files start wich "_" and "!"
    if [[ "${NAME#\.\/}" =~ [_*|/!*] ]]; then
        continue
    fi

    # if product dont exist push to $missingIndex array
    if ! [[ $NAME ]]; then
        missingIndex+=($item)
        continue
      fi

      echo -e "\n------- find ${item}"
      # rename folder
      mv "$NAME" "${uniqFilesIndexArray[exportedIndexCounter]}"
      echo  "${NAME} => ${uniqFilesIndexArray[exportedIndexCounter]}"

      # exporter produkts couter
      let "exportedIndexCounter+=1"
  done

# ----------------------------------------------------


echo -e "\n zmiana nazwy ${exportedIndexCounter} folderów z ${#uniqFilesIndexArray[*]}"

echo -e "\n"
read -n 1 -s -r -p "Wciśnij dowonly przycisk aby wyłączyć"
