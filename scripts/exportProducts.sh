ExportFolder="ExportFolder"
targetFolder="gotowe"

# wait for user confirmation
echo "Do you want to run exportProducts.sh? Press 'Y' to continue"
    read userImput
      if [[ $userImput != "Y" ]] ; then
        echo -e "\n------ Zamykam program ------\n"
        exit 0
      break
  fi
echo -e "\n"

mkdir $ExportFolder

find . -type d -name $targetFolder |
  while IFS= read -r NAME; do
    itemName="${NAME%/*}"

    # ignore files start wich "_" and "!"
    if [[ "${NAME#\.\/}" =~ [_*|/!*] ]]; then
        continue
    fi

    # regex to extract index
    [[ $itemName =~ ([W|T]-[0-9]+$) ]]
    itemIndex="${BASH_REMATCH[1]}"

    # copy to new folder
    cp -r -v "$NAME" "${ExportFolder}/${itemIndex}"
    # send info about complide
    echo "${NAME} -> ${ExportFolder}/${itemIndex}"

  done
