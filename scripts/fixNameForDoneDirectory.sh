# przejście po foldereach i zmiana nazwy folderu 'gotowe' jeśli takowy nosi nazwe indexu filderu

doneFileFolderName="gotowe"

# wait for user confirmation
echo "Czy chcesz wykonać program? wpisz 'Y' aby kontynuować"
    read userImput
      if [[ $userImput != "Y" ]] ; then
        echo -e "\n------ Zamykam program ------\n"
        exit 0
      break
  fi
echo -e "\n"

# check if in current directory any folders exist
countDir=`ls -d -1 */ 2>/dev/null | wc -l`
if [ $countDir != 0 ]; then

    for dir in *; do
        if [ -d "$dir" ]; then
            # Will not run if no directories are available

            # ignore files start wich "_" and "!"
            if [[ "${dir}" =~ [_*|/!*] ]]; then
                continue
            fi
            
            # regex to extract index
            [[ $dir =~ ([W|T]-[0-9]+$) ]]
            index="${BASH_REMATCH[1]}"

            # if directory $doneFileFolderName for done photos is named wron, rename to $doneFileFolderName
            if [[ -d "${dir}/${index}" ]]; then
                echo -e "\n ── ${dir} "
                echo "   ├── find folder '${dir}/${index}'"
                echo "   └── rename folder '${index}' -> '${doneFileFolderName}'"

                # change directory name from index to $doneFileFolderName
                mv "${dir}/${index}" "${dir}/${doneFileFolderName}"

                continue
              fi
              #endregion if $doneFileFolderName is named wrong

          fi
      done

  else
    echo "--- NIE ZNALEZIONO FOLDERÓW --- "

  fi

echo -e "\n"
read -n 1 -s -r -p "Wciśnij dowonly przycisk aby wyłączyć"
