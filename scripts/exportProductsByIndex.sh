FileWithIndexToExport="export.txt"
ExportFolder="ExportFolder"
missingProductsListFile="missingProducts.txt"
duppProductsListFile="dupplicateIndex.txt"
#---------------------------

# export only first image flag indicator
exportOnlyFirstImg=false

function  displayHelp {
  echo
  echo "to change option in script open it and edit variabels below:"
  echo "FileWithIndexToExport     name of txt file with list of index separate by new line [default: 'export.txt']"
  echo "ExportFolder              folder name/path wher files will be exported, can be absolute or relative [default: 'ExportFolder']"
  echo "missingProductsListFile   name of txt file where will be printed all indexes that wasn't find [default: 'missingProducts.txt']"
  echo "duppProductsListFile      name of txt file where will be printed all indexes that repeated [default: 'dupplicateIndex.txt']"
  echo
  echo "Syntax: scriptTemplate [-f|h]"
  echo "options:"
  echo "f     export only first image"
  echo "h     Print this Help."
  echo
}

### list of allow flags
# "options: [-f|h]"
# "f     export only first image"
# "h     Print Help."
while getopts hf flag ;do
    case "${flag}" in
        f) exportOnlyFirstImg=true;;
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
  echo -e "\033[0;31m\n----- UWAGA -----\033[0m"
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
    if [[ "${NAME#\.\/}" =~ [_*|/!*] ]]; then
        continue
      fi

    # if product dont exist push to $missingIndex array
    if ! [[ $NAME ]]; then
        missingIndex+=($item)
        continue
      fi

    if ! [[ -d "${NAME}/gotowe" ]]; then
        missingIndex+=("${item};${NAME}")
        echo -e "\033[0;31m------- [X] missing 'done' file for ${item} !!!"
        echo -e "\033[0;31m------- ------- ------- ------- -------\033[0m"
        continue
      fi

    echo "------- [✓] find ${item}"
    itemName="${NAME##*/}"

    # regex to extract index
    [[ $itemName =~ ([W|T]-[0-9]+$) ]]
    itemIndex="${BASH_REMATCH[1]}"

    # copy to new folder
    if [[ $exportOnlyFirstImg == true ]]; then
        # export only first image
        mkdir "${ExportFolder}/${itemIndex}"
        cp -r -v "${NAME}/gotowe/${itemIndex}_00.jpg" "${ExportFolder}/${itemIndex}/${itemIndex}_00.jpg"
        echo "ex first"
      else
        # export all image in folder 'gotowe'
        cp -r -v "${NAME}/gotowe" "${ExportFolder}/${itemIndex}"
      fi

    # exporter produkts couter
    let "exportedIndexCounter+=1"
  done

echo -e "\n\nznaleziono ${exportedIndexCounter} produktów z ${#uniqFilesIndexArray[*]}"

if [[ ${#missingIndex[*]} > 0 ]]; then
  printf "%s\n" "${missingIndex[@]}" > $missingProductsListFile
  #TODO: popraw tak aby na bierząco zapisywało brakujące indexy (NOTE: gdy z jakiegoś powodu skrypt zostanie przerwany przed rozpoczęciem nie zapisuje brakujących indexów)
  echo -e "\033[0;31mnie znaleziono ${#missingIndex[*]} produktów z listy, zapisano do folderu 'missingProducts.txt'\033[0m"
fi

echo -e "\n"
read -n 1 -s -r -p "Wciśnij dowonly przycisk aby wyłączyć"
