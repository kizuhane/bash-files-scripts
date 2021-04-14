### sposób użycia

- odwieramy gitBash
- przechodzimy do ścieżki gdzie chcemy wykonać skrypt cd "skopiowana ścieżka" (cd "P:\Praca\przedłużacz x3")
  - wklejamy do konsoli za pomocą klawisza Insert albo prawy przycisk myszki -> Paste
- jesli kożystamy z dosu z plików .sh to kopujemy go tam
- odpalamy skrypt
  - jeśli pojedyńczy: to wklejamy go
  - jeśli skrypt z pliku: wykonujemy go za pomocą sh plik_skryptu (sh exportProductsByIndex.sh)

---

### aby znaleźć tylko pierwsze zdjęcia i skopiować je do folderu export plastrol

```bash
find . -regextype posix-extended -regex '.*\_00.jpg' -exec cp -n {} export_plastrol \;
```

- folder do exportu musi iuż istnień

---

### kopiuj całe foldery gotowe utrzymując drzewo folderów do folderu wcześniej

```bash
find . -type d -name 'gotowe' -exec cp -n -r --parent {} ../export_plastrol \;
```

- skrypt wymaga poprawy ścieżki docelowej zależnie gdzie został użyty

---

### szukanie i kopiowanie folderów gotowe z zmianą ich nazwy

```bash
find . -type d -name 'gotowe' | while IFS= read -r NAME; do item="${NAME%/*}"; cp -r -v "$NAME" "export/${item: -7}"; done
```

---

### przejście po foldereach i poprawa nazw zdjęć w gotowych

```bash
for dir in *; do
    if [ -d "$dir" ]; then
        # Will not run if no directories are available

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

```

plik:**rename.sh**

- startować skrypt z poziomu produktów a nie grup produktowych
- foldery muszą mieć poprawnie nazwany folder gotowe i index w nazwie głównego folderu

---

### przejście po foldereach i poprawa nazw zdjęć w gotowych i plikach originals

```bash
# przejście po foldereach i zmiana nazw plików w folderze 'gotowe' i 'originals'
# w gotowe na ${index}_${licznik}
# w originals na ${nazwa folderu}-${licznik}

doneFileFolderName="gotowe"
originalsFileFolderName="originals"

# check if in current directory any folders exist
countDir=`ls -d -1 */ 2>/dev/null | wc -l`
if [ $countDir != 0 ]; then

    for dir in *; do
        if [ -d "$dir" ]; then
            # Will not run if no directories are available

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


```

plik:**renameDoneAndOrginals.sh**

- startować skrypt z poziomu produktów a nie grup produktowych
- przed ruszeniem skryptu należy sprawdzić czy nazwa docelowego folderu oraz rozszerzenie plików się zgadza

---

### przeniesienie wyznaczonych plików do folderu originals

```bash
originalsfilesExtension="png" # target file extention
targetFolderName="originals" # target directory name to move files

# check if in current directory any folders exist
countDir=`ls -d -1 */ 2>/dev/null | wc -l`
if [ $countDir != 0 ]; then


    for dir in *; do
      if [ -d "$dir" ]; then
          # Will not run if no directories are available

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

```

plik:**moveOriginals.sh**

- startować skrypt z poziomu produktów a nie grup produktowych
- foldery muszą mieć poprawnie nazwany folder gotowe i originals i index w nazwie głównego folderu

---

### wystaw wszystkie zdjęcia do wspólnego folderu

```bash
ExportFolder="../ExportFolder"

find . -type d -name 'gotowe' |
  while IFS= read -r NAME; do
    itemName="${NAME%/*}"


    # regex to extract index
    [[ $itemName =~ ([W|T]-[0-9]+$) ]]
    itemIndex="${BASH_REMATCH[1]}"

    # copy to new folder
    cp -r -v "$NAME" "${ExportFolder}/${itemIndex}"
    # send info about complide
    echo "${NAME} -> ${ExportFolder}/${itemIndex}"

  done
```

plik:**exportProducts.sh**

---

### wystaw wszystkie zdjęcia do według listy z indexami

```bash
FileWithIndexToExport="export.txt"
ExportFolder="ExportFolder"
missingProductsListFile="missingProducts.txt"
duppProductsListFile="dupplicateIndex.txt"

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
  echo -e "\n----- UWAGA -----"
  echo "znaleziono duplikaty w pliku ${FileWithIndexToExport}"
  echo "--- liczba duplikatów: ${#duppFilesIndexArray[*]}"
  echo "duplikaty zapisano do: ${duppProductsListFile}"
  printf "%s\n" "${duppFilesIndexArray[@]}" > $duppProductsListFile
fi

uniqFilesIndexArray=($(printf "%s\n" "${filesIndexArray[@]}" | sort -u ))
echo -e "\nzaznaczonych elemętów - ${#uniqFilesIndexArray[*]} \n"

for item in ${uniqFilesIndexArray[@]}; do
    NAME=`find . -type d -regextype posix-extended -regex "^.*\-${item}"`

    # if product dont exist push to $missingIndex array
    if ! [[ $NAME ]]; then
        missingIndex+=($item)
        continue
      fi

    if ! [[ -d "${NAME}/gotowe" ]]; then
        missingIndex+=($item)
        echo -e "\033[0;31m------- [X] missing 'done' file for ${item} !!!"
        echo -e "\033[0;31m------- ------- ------- ------- -------"
        continue
      fi

    echo "------- [✓] find ${item}"
    itemName="${NAME##*/}"

    # regex to extract index
    [[ $itemName =~ ([W|T]-[0-9]+$) ]]
    itemIndex="${BASH_REMATCH[1]}"

    # copy to new folder
    cp -r -v "${NAME}/gotowe" "${ExportFolder}/${itemIndex}"

    # exporter produkts couter
    let "exportedIndexCounter+=1"
  done

echo -e "\n\nznaleziono ${exportedIndexCounter} produktów z ${#uniqFilesIndexArray[*]}"

if [[ ${#missingIndex[*]} > 0 ]]; then
  printf "%s\n" "${missingIndex[@]}" > $missingProductsListFile
  echo -e "\033[0;31m nie znaleziono ${#missingIndex[*]} produktów z listy, zapisano do folderu 'missingProducts.txt'"
fi

echo -e "\n"
read -n 1 -s -r -p "Wciśnij dowonly przycisk aby wyłączyć"

```

plik:**exportProductsByIndex.sh**

- plik w którym zapiszać trzeba indexy musi być txt (domyślny to export.txt)
- plik w którym zawarte są indexy muszą być podzielone jeden index w lini np:
  > W-99171
  > W-99162
  > W-99143
- skryp zaczyna szukanie od momętu w którym został otworzony
- automatycznie zmiania nazwe z gotowego na index produktu
- zapisuje elemęnty w folderze `ExportFolder` w miejsu gdzie skrypt został odpalony
- wskazuje czy indexy są zduplikowane i te zapisuje do `dupplicateIndex.txt`
- indexy nie znalezionych produktów zapisuje do `missingProducts.txt`

---

### zmień nazwy wszystkich folderów o podanej nazwie na inną

```bash
inputDirName="JPG"
outoutDirName="newName"

find . -maxdepth 2 -type d -name "${inputDirName}" |
  while IFS= read -r NAME; do
    filePath="${NAME%/*}"

    # rename to $outoutDirName
    mv "$NAME" "${filePath}/${outoutDirName}"
    # send info about completion
    echo "rename ${inputDirName} -> ${outoutDirName} in ${filePath}/"
  done

```

plik:**renameFolders.sh**

- skrypt odpalamy w grupie produktów
- przed odpaleniem skryptu należy zmienić nazwy dla `inputDirName` i `outoutDirName` w samym skrypcie
- `inputDirName` - nazwa folderów do wyszukiwania
- `outoutDirName` - nowa nazwa wyszukanego folderu

---

### zmień nazwy wszystkich plików o podanej nazwie na inną

```bash
inputFileName="9"
inputFileExtention="jpg"
outputFileName="10009"

find . -type f -name "${inputFileName}.${inputFileExtention}" |
  while IFS= read -r NAME; do
    filePath="${NAME%/*}"

    oldName="${inputFileName}.${inputFileExtention}"
    newname="${outputFileName}.${inputFileExtention}"

    # rename to $outputFileName
    mv "$NAME" "${filePath}/${newname}"
    # send info about completion
    echo "rename ${oldName} -> ${newname} in ${filePath}/"
  done
```

plik:**renameFolders.sh**

- skrypt odpalamy w grupie produktów
- przed odpaleniem skryptu należy zmienić wartości dla `inputFileName`, `inputFileExtention` i `inputFileExtention`
- `inputDirName` - nazwa pliku do wyszukiwania
- `inputFileExtention` - rozszerenie wyszukiwanego pliku
- `outputFileName` - nowa nazwa wyszukanego folderu

---

### zmień nazwy folderów zawierających tylko index na poprawną nazwę

```bash
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

```

plik:**renameFoldersUsingFile.sh**

- skrypt odpalamy w grupie produktów tam gdzie są główne foldery produktu
- plik w którym zapisać trzeba porpawne nazwy trzeba indexy musi być txt (domyślny to fileNames.txt)
- plik w którym zawarte są indexy muszą być podzielone jeden index w lini np:
  > PB-HEAVY-D-K-20M-3X1-5-H05RR-czarny-W-99245
  > PB-HEAVY-D-K-20M-3X2-5-H05RR-czarny-W-99249
  > PB-HEAVY-D-K-25M-3X1-5-H05RR-czarny-W-99253
  > PB-HEAVY-D-K-25M-3X2-5-H05RR-czarny-W-99257
- skryp zaczyna szukanie od momętu w którym został otworzony

---

### przeszukaj foldery i popraw nazwy dla gotowych z indexów

```bash
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

```

plik:**fixNameForDoneDirectory.sh**

- skrypt odpalamy w grupie produktów tam gdzie są główne foldery produktu
- skrypt wyświetla tylko foldery wtóre ulegly zmianie

---

### przeszukaj foldery i wylistuj wszystkie zdjęcia po nazwach oraz zapisz do pliku

```bash
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

```

plik:**exportPhotosName.sh**

- skrypt odpalamy w grupie produktów tam gdzie są główne foldery produktu
- skrypt zapisuje wynik operacji w formacjie CSV odzielone `;` (średnik)
- skrypt wyświetli bląd jeśli nie znajdzie pliku gotowe

---

### konwersja pliku png na jpg kożystając z photohsopa

dla serwera

```bash
PhotoshopScriptName="script.exe"

# loop through all folders in this directory
for dir in *; do
    if [ -d "$dir" ]; then
        # Will not run if no directories are available

        # get current paht and convert to windows path
        dirPath="${PWD}/${dir}"
        echo "converting ${dirPath}"

        # run photoshop script directly
        echo ./${PhotoshopScriptName} ${dirPath}
        ./${PhotoshopScriptName} "${dirPath}"
    fi
done

```

dla Windows

```bash
PhotoshopScriptName="script.exe"

# loop through all folders in this directory
for dir in *; do
    if [ -d "$dir" ]; then
        # Will not run if no directories are available

        # get current paht and convert to windows path
        dirPath="${PWD}/${dir}"
        winPath=`cygpath -w $dirPath`

        echo "converting ${winPath}"

        # run photoshop script directly
        ./$PhotoshopScriptName "\"${winPath}"\"

        # if dont work call cmd.exe usinf code bellow
        # start $PhotoshopScriptName "\"${winPath}"\"
    fi
done
```

plik dla windows: **convertPngUsingPhotoshop_WINDOWS.sh**

plik dla serwera: **convertPngUsingPhotoshop_SERVER.sh**

- istotny jest dodatkowy plik skrypt `script.exe` musi znajdować się w tym samym miejscu co odpalany skrypt
- skrypt należy nadać do grupy produktowej
- skrypt nie bierze pod uwagę innych plików `.png` w folderach głębiej

---

### dokładny regex

`^.*-[W|T]\-\d+\-01\.jpg` - dla zdjęć

`(W-[0-9]+)` - dla indexów
