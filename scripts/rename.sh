# wait for user confirmation
echo "Czy chcesz wykonać program? wpisz 'Y' aby kontynuować"
    read userImput
      if [[ $userImput != "Y" ]] ; then
        echo -e "\n------ Zamykam program ------\n"
        exit 0
      break
  fi
echo -e "\n"

for dir in *; do
    if [ -d $dir ]; then
        # Will not run if no directories are available

        # ignore files start wich "_" and "!"
        if [[ "${dir#\.\/}" =~ [_*|/!*] ]]; then
            continue
        fi

        # extract index
        index=${dir: -7}

        # loop through files in 'gotowe'
        num=0 # dodanie licznika dla plików
        echo "--------------- zmieniono nazwy dla === ${index} === ---------------"
        for photosPath in "$dir"/gotowe/*; do
            directories="${photosPath%/*}/"

            printf -v i "%02d" $((num++))
            fileName="$index"_"$i"

            mv "$photosPath" "$directories""$fileName".jpg
            echo "${photosPath} -> ${directories}${fileName}.jpg"
        done;
      else
        echo "NIE ZNALEZIONO FOLDERÓW"
    fi
done
