originalsfilesExtension="png" # target file extention
targetFolderName="originals" # target directory name to move files

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
          if [[ "${dir#\.\/}" =~ [_*|/!*] ]]; then
              continue
          fi

          # check if in current directory exist files with extension pointed in $originalsfilesExtension without directory
          count=`ls -1 ${dir}/*.${originalsfilesExtension} 2>/dev/null | wc -l` # count $originalsfilesExtension
          if [ $count != 0 ]; then
              # run if $originalsfilesExtension files exist
              echo "── move folders for ${dir} "

              # create folder original if arredy don't exist
              folderOrginal="${dir}/${targetFolderName}"
              if [[ ! -e $folderOrginal ]]; then
                  mkdir $folderOrginal
                  echo "  ├─ create folder '${targetFolderName}' in ${dir}"
                fi

              # move $originalsfilesExtension filest to folder originals
              mv $dir/*.${originalsfilesExtension} "${folderOrginal}/"
              echo "  └─ move .${originalsfilesExtension} filest to folder original"
            fi

        fi
    done

  else
    echo "--- NIE ZNALEZIONO FOLDERÓW --- "

  fi
