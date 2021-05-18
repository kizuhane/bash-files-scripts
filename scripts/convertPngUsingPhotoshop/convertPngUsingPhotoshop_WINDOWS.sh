PhotoshopScriptName="script.exe"

# loop through all folders in this directory
for dir in *; do
    if [ -d "$dir" ]; then
      # Will not run if no directories are available
      
      # ignore files start wich "_" and "!"
      if [[ "${dir#\.\/}" =~ [_*|/!*] ]]; then
          continue
        fi

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
