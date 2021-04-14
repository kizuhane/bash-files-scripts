inputDirName="JPG"
outoutDirName="newName"

# wait for user confirmation
echo "Czy chcesz wykonać program? wpisz 'Y' aby kontynuować"
    read userImput
      if [[ $userImput != "Y" ]] ; then
        echo -e "\n------ Zamykam program ------\n"
        exit 0
      break
  fi
echo -e "\n"

find . -maxdepth 2 -type d -name "${inputDirName}" |
  while IFS= read -r NAME; do
    filePath="${NAME%/*}"

    # ignore files start wich "_" and "!"
    if [[ "${NAME}" =~ [_*|/!*] ]]; then
        continue
    fi

    # rename to $outoutDirName
    mv "$NAME" "${filePath}/${outoutDirName}"
    # send info about completion
    echo "rename ${inputDirName} -> ${outoutDirName} in ${filePath}/"
  done
