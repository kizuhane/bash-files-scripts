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

        # if dont work call cmd.exe usinf code bellow
        # start $PhotoshopScriptName "\"${winPath}"\"
    fi
done
