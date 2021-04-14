# Bash Scripts for working with files

## sposób użycia

- odwieramy gitBash
- przechodzimy do ścieżki gdzie chcemy wykonać skrypt cd "skopiowana ścieżka" (cd "P:\Praca\przedłużacz x3")
  - wklejamy do konsoli za pomocą klawisza Insert albo prawy przycisk myszki -> Paste
- jesli kożystamy z dosu z plików .sh to kopujemy go tam
- odpalamy skrypt
  - jeśli pojedyńczy: to wklejamy go
  - jeśli skrypt z pliku: wykonujemy go za pomocą sh plik_skryptu (sh exportProductsByIndex.sh)

## Script list

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

plik:**rename.sh**

- startować skrypt z poziomu produktów a nie grup produktowych
- foldery muszą mieć poprawnie nazwany folder gotowe i index w nazwie głównego folderu

---

### przejście po foldereach i poprawa nazw zdjęć w gotowych i plikach originals

przejście po foldereach i zmiana nazw plików w folderze 'gotowe' i 'originals'
w gotowe na ${index}_${licznik}
w originals na ${nazwa folderu}-${licznik}

plik:**renameDoneAndOrginals.sh**

- startować skrypt z poziomu produktów a nie grup produktowych
- przed ruszeniem skryptu należy sprawdzić czy nazwa docelowego folderu oraz rozszerzenie plików się zgadza

---

### przeniesienie wyznaczonych plików do folderu originals

originalsfilesExtension = "png" # target file extention
targetFolderName = "originals" # target directory name to move files

plik:**moveOriginals.sh**

- startować skrypt z poziomu produktów a nie grup produktowych
- foldery muszą mieć poprawnie nazwany folder gotowe i originals i index w nazwie głównego folderu

---

### wystaw wszystkie zdjęcia do wspólnego folderu

ExportFolder="../ExportFolder"
targetFolder="done"

plik:**exportProducts.sh**

---

### wystaw wszystkie zdjęcia do według listy z indexami

FileWithIndexToExport="export.txt"
ExportFolder="ExportFolder"
missingProductsListFile="missingProducts.txt"
duppProductsListFile="dupplicateIndex.txt"

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

inputDirName="JPG"
outoutDirName="newName"

plik:**renameFolders.sh**

- skrypt odpalamy w grupie produktów
- przed odpaleniem skryptu należy zmienić nazwy dla `inputDirName` i `outoutDirName` w samym skrypcie
- `inputDirName` - nazwa folderów do wyszukiwania
- `outoutDirName` - nowa nazwa wyszukanego folderu

---

### zmień nazwy wszystkich plików o podanej nazwie na inną

inputFileName="9"
inputFileExtention="jpg"
outputFileName="10009"

plik:**renameFolders.sh**

- skrypt odpalamy w grupie produktów
- przed odpaleniem skryptu należy zmienić wartości dla `inputFileName`, `inputFileExtention` i `inputFileExtention`
- `inputDirName` - nazwa pliku do wyszukiwania
- `inputFileExtention` - rozszerenie wyszukiwanego pliku
- `outputFileName` - nowa nazwa wyszukanego folderu

---

### zmień nazwy folderów zawierających tylko index na poprawną nazwę

FileWithIndexToExport="fileNames.txt"

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

doneFileFolderName="gotowe"

plik:**fixNameForDoneDirectory.sh**

- skrypt odpalamy w grupie produktów tam gdzie są główne foldery produktu
- skrypt wyświetla tylko foldery wtóre ulegly zmianie

---

### przeszukaj foldery i wylistuj wszystkie zdjęcia po nazwach oraz zapisz do pliku

doneFileFolderName="gotowe"
PhotosFileName="PhotosNames.csv"

plik:**exportPhotosName.sh**

- skrypt odpalamy w grupie produktów tam gdzie są główne foldery produktu
- skrypt zapisuje wynik operacji w formacjie CSV odzielone `;` (średnik)
- skrypt wyświetli bląd jeśli nie znajdzie pliku gotowe

---

### konwersja pliku png na jpg kożystając z photohsopa

PhotoshopScriptName="script.exe"

#### 2 version:

- for server using bash sessions
- for windows caling cmd sessions

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

script for windows: **convertPngUsingPhotoshop_WINDOWS.sh**
script for server: **convertPngUsingPhotoshop_SERVER.sh**

- istotny jest dodatkowy plik skrypt `script.exe` musi znajdować się w tym samym miejscu co odpalany skrypt
- skrypt należy nadać do grupy produktowej
- skrypt nie bierze pod uwagę innych plików `.png` w folderach głębiej

---

### additional regex

`^.*-[W|T]\-\d+\-01\.jpg` - dla zdjęć

`[W|T]-[0-9]+$` - dla indexów
