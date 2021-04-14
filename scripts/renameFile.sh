inputFileName="9"
inputFileExtention="jpg"
outoutDirName="10009"

# wait for user confirmation
echo "Czy chcesz wykonać program? wpisz 'Y' aby kontynuować"
    read userImput
      if [[ $userImput != "Y" ]] ; then
        echo -e "\n------ Zamykam program ------\n"
        exit 0
      break
  fi
echo -e "\n"

find . -type f -name "${inputFileName}.${inputFileExtention}" |
  while IFS= read -r NAME; do
    filePath="${NAME%/*}"

    # ignore files start wich "_" and "!"
    if [[ "${NAME}" =~ [_*|/!*] ]]; then
        continue
    fi

    oldName="${inputFileName}.${inputFileExtention}"
    newname="${outoutDirName}.${inputFileExtention}"

    # rename to $outoutDirName
    mv "$NAME" "${filePath}/${newname}"
    # send info about completion
    echo "rename ${oldName} -> ${newname} in ${filePath}/"
  done
