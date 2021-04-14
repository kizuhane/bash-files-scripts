# przejście po foldereach i zmiana nazw plików w folderze 'gotowe' i 'originals'
# w gotowe na ${index}_${licznik}
# w originals na ${nazwa folderu}-${licznik}

doneFileFolderName="gotowe"
originalsFileFolderName="originals"

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

            # extract index
            index=${dir: -7}

            echo -e "\n ── ${dir} "
            # loop through files in $doneFileFolderName
            if [[ -d "$dir/$doneFileFolderName" ]]; then
                num=0 # add counter for files name
                echo " ├─ rename files in ${doneFileFolderName} "

                for photosPath in $dir/$doneFileFolderName/*; do
                    directories="${photosPath%/*}/"
                    oldFileName="${photosPath##*/}"

                    printf -v i "%02d" $((num++))
                    fileName="$index"_"$i"

                    # change name for files in $doneFileFolderName
                    mv "$photosPath" "$directories""$fileName".jpg
                    echo " │   ├─ ${oldFileName} -> ${fileName}.jpg" # send info about complide
                  done;

                  echo " │   └───────"

              else
                  echo " ├─ no filse to rename in ${doneFileFolderName}"

              fi

            # change names in folder $originalsFileFolderName
            if [[ -d "$dir/$originalsFileFolderName" ]]; then
                numOrginals=1 # add counter for files name
                echo " ├─ rename files in ${originalsFileFolderName} "

                for photosPathOrg in $dir/$originalsFileFolderName/*; do
                    directoriesOrg="${photosPathOrg%/*}/"
                    oldFileNameOrg="${photosPathOrg##*/}"
                    fileExtentionOrg="${photosPathOrg##*.}"

                    printf -v i "%02d" $((numOrginals++))
                    fileNameOrg="$dir"-"$i"

                    # change name for files in $originalsFileFolderName
                    mv "$photosPathOrg" "$directoriesOrg""$fileNameOrg".${fileExtentionOrg}
                    echo " │   ├─ ${oldFileNameOrg} -> ${fileNameOrg}.${fileExtentionOrg}" # send info about complide
                  done;

                  echo " │   └───────"

                else
                  echo " └─ no filse to rename in ${originalsFileFolderName}"

              fi

          fi
      done

  else
    echo "--- NIE ZNALEZIONO FOLDERÓW --- "

  fi
