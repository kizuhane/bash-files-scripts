# przejście po foldereach i zebranie nazw zdjęć w gotowych

doneFileFolderName="gotowe"
PhotosFileName="PhotosNames.csv"

# wait for user confirmation
echo "Czy chcesz wykonać program? wpisz 'Y' aby kontynuować"
    read userImput
      if [[ $userImput != "Y" ]] ; then
        echo -e "\n------ Zamykam program ------\n"
        exit 0
      break
  fi
echo -e "\n"

declare -a photosNamesArray

# check if in current directory any folders exist
countDir=`ls -d -1 */ 2>/dev/null | wc -l`
if [ $countDir != 0 ]; then

    # create header to csv file
    photosNamesArray+=("index;first_img;additional_img")

    for dir in *; do
        if [ -d "$dir" ]; then
            # Will not run if no directories are available

            # ignore files start wich "_" and "!"
            if [[ "${dir#\.\/}" =~ [_*|/!*] ]]; then
                continue
            fi

            declare -i photosQuantity=0
            declare -a photosNameList

            # regex to extract index
            [[ $dir =~ ([W|T]-[0-9]+$) ]]
            index="${BASH_REMATCH[1]}"

            # if directory $doneFileFolderName dont exist display error
            if ! [[ -d "${dir}/${doneFileFolderName}" ]]; then
                echo -e "\033[0;31m------- [X] missing 'done' file for ${dir} !!!\033[0m"
                continue
              fi
              #endregion if $doneFileFolderName is named wrong

            echo "------- [✓] find ${dir}"
            photosNameList=($(ls "${dir}/${doneFileFolderName}"))

            echo "             └─  find ${#photosNameList[*]} photos"

            # save photos name in csv format and push to $photosNamesArray array
            # output example: name;first_img;additional_img
            # output example: W-98526;W-98526_00.jpg;W-98526_00.jpg W-98526_01.jpg
            photosNamesArray+=("${index};${photosNameList[0]};$( IFS=$','; echo "${photosNameList[*]:1}")")

          fi
      done

      echo -e "\n\n\033[1;32m----------SAVE PHOTOS NAME TO: ${PhotosFileName} ----------\033[0m"
      # save array to file
      printf "%s\n" "${photosNamesArray[@]}" > $PhotosFileName

  else
    echo "--- NIE ZNALEZIONO FOLDERÓW --- "

  fi

echo -e "\n"
read -n 1 -s -r -p "Wciśnij dowonly przycisk aby wyłączyć"
