# Bash Scripts for working with files
Some bash scripts i wrote for finding, importing and editing filenames

## Console script

### find first image and copy it to folder named expert

```bash
find . -regextype posix-extended -regex '.*\_00.jpg' -exec cp -n {} export \;
```
> run in main folder 
> folder `export` need to exist

### Copy folder named "done" with current folder tree

```bash
```

### Find and copy folder "done" with name change using fist file from folder 

```bash
find . -type d -name 'done' | while IFS= read -r NAME; do item="${NAME%/*}"; cp -r -v "$NAME" "export/${item: -7}"; done
```

## File Script 

### Move through folders and update image name in done folder using directory name

File: [`rename.sh`](./scripts/rename.sh)

> run script in product root folder
> folder need to have correct names nad "done" folder

### Move through folders and update image name in done and original folder

File: [`renameDoneAndOriginals.sh`](./scripts/renameDoneAndOriginals.sh)

| options                 | default value |
| ----------------------- | ------------- |
| doneFileFolderName      | gotowe        |
| originalsFileFolderName | originals     |

> run script in product root folder
> folder need to have correct names nad "done" folder

### Move selected files to originals folder

| options                 | default value | description                         |
| ----------------------- | ------------- | ----------------------------------- |
| originalsFilesExtension | png           | target file extension               |
| targetFolderName        | originals     | target directory name to move files |


File: [`moveOriginals.sh`](./scripts/moveOriginals.sh)

> run script in product root folder
> folder need to have correct names nad "done" folder

### Export all images to one directory

File: [`exportProducts.sh`](./scripts/exportProducts.sh)

| options      | default value   |
| ------------ | --------------- |
| ExportFolder | ../ExportFolder |
| targetFolder | gotowe          |


### Export all images from list

File: [`exportProductsByIndex.sh`](./scripts/exportProductsByIndex.sh)

| options                 | default value       |
| ----------------------- | ------------------- |
| FileWithIndexToExport   | export.txt          |
| ExportFolder            | ExportFolder        |
| missingProductsListFile | missingProducts.txt |
| dupProductsListFile     | duplicateIndex.txt  |

> script have help flag `-h`
> file `export.txt` need to exist
>   - names in export file need to be new line separated 
> all folder are updated when script finished
>   - duplicated indexes are saved in *duplicateIndex.txt*
>   - indexes that are not found are save *missingProducts.txt*

### Export folders using list from given file
> improved and optimize version to export files

File: [`exportFoldersByIndex_v2.sh`](./scripts/exportFoldersByIndex_v2.sh)

| options                       | default value                        | flag |
| ----------------------------- | ------------------------------------ | ---- |
| FILE_WITH_INDEX_TO_EXPORT     | indexList.txt                        | -i   |
| EXPORT_FOLDER                 | !!ExportedFolder[$(date +%F)]        | -f   |
| EXPORT_FOLDER_PATH            |                                      | -p   |
| FOUND_ITEMS_LIST_FILE         | foundProducts.csv                    |      |
| MISSING_ITEMS_LIST_FILE       | missingProducts.txt                  |      |
| MISSING_REQUIRED_FOLDERS_FILE | emptyProducts.csv                    |      |
| FLAG_CREATE_LOG_FILE          | false                                | -l   |
| LOG_FILE_NAME                 | exportFoldersScript[$(date +%F)].log |      |
| FLAG_USE_MAX_DEPTH            | false                                | -d   |
| FLAG_EXPORT_ONLY_FIRST_IMAGE  | false                                | -s   |
| FLAG_PRESERVE_ORIGINAL_NAME   | false                                | -n   |
| REQUIRED_FOLDER_NAME          | gotowe                               |      |

> script have help flag `-h` 
> to know more use `-h `

### change directory name

File: [`renameFolders.sh`](./scripts/renameFolders.sh)

| options       | default value | description              |
| ------------- | ------------- | ------------------------ |
| inputDirName  | JPG           | directory name to change |
| outputDirName | newName       | new directory name       |

> run script in parent folder 
> before running script remember to change values for `inputDirName` and `outoutDirName`

### rename files in directory 

File: [`renameFile.sh`](./scripts/renameFile.sh)

| options            | default value | description                    |
| ------------------ | ------------- | ------------------------------ |
| inputFileName      | 9             | directory name to change       |
| inputFileExtension | jpg           | extension of the searched file |
| outputFileName     | 10009         | new directory name             |

> run script in parent folder 
> before running script remember to change values for `inputFileName`, `inputFileExtention` and `inputFileExtention`

### rename index name folders to a correct name from file

File: [renameFoldersUsingFile.sh`](./scripts/renameFoldersUsingFile.sh)

| options               | default value | description                     |
| --------------------- | ------------- | ------------------------------- |
| FileWithIndexToExport | fileNames.txt | file used to map names to index |

Example: 
```
PB-HEAVY-D-K-20M-3X1-5-H05RR-czarny-W-99245
PB-HEAVY-D-K-20M-3X2-5-H05RR-czarny-W-99249
```

> run script in root folder 
> *fileNames.txt* need to exist, not be empty and have correct values
> *fileNames.txt* need to have names separated with new line

### przeszukaj foldery i popraw nazwy dla gotowych z indexów
### search through directory's and change names for "done" folder

File: [`fixNameForDoneDirectory.sh`](./scripts/fixNameForDoneDirectory.sh)

| options            | default value | description                             |
| ------------------ | ------------- | --------------------------------------- |
| doneFileFolderName | gotowe        | final folder with files ready to export |

> run script in parent folder 
> script log only folders that have changed

### Move through folders and collecting names of the photos

File: [`exportPhotosName.sh`](./scripts/exportPhotosName.sh)

| options            | default value   |
| ------------------ | --------------- |
| doneFileFolderName | gotowe          |
| PhotosFileName     | PhotosNames.csv |

> run script in parent folder
> script output to csv file `;` separated
> script error if do ton find done folder

### Convert file from png to jpg using photoshop

Photoshop Script File: [`script.exe`](./scripts/convertPngUsingPhotoshop/script.exe)

> run script in parent folder
> script ignore others file then .png

#### Windows version:
File: [`convertPngUsingPhotoshop_WINDOWS`](./scripts/convertPngUsingPhotoshop/convertPngUsingPhotoshop_WINDOWS.sh)

> if you have error open script and change line when photoshop is run directly to version using cmd runtime

#### Server version
File: [`convertPngUsingPhotoshop_SERVER`](./scripts/convertPngUsingPhotoshop/convertPngUsingPhotoshop_SERVER.sh)


### additional regex

- `^.*-[W|T]\-\d+\-01\.jpg` - for photos
- `[W|T]-[0-9]+$` - dla indexów
