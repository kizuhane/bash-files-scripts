array=(T-96678 T-96679 T-96680 T-96681 T-97093 T-97094 T-97095 T-97096 T-97117 T-97118 T-97119 T-97120 T-97162 T-97163 T-97164 T-97165 T-97166 T-97167 T-97168 T-97315 T-97316 T-97318 T-97320 T-97322 T-97324 T-97336 T-97338 T-97340 T-97342 T-97344 T-97346 T-97348 T-97350 T-97377 T-97378 T-97379 T-97380 T-97390 T-97392 T-97394 T-97395 T-97398 T-97400 T-97413 T-97415 T-97417 T-97419 T-97421 T-97423 T-97425 T-97427 T-97449 T-97450 T-97451 T-97452 T-97461 T-97462 T-97463 T-97464 T-97489 T-97490 T-97491 T-97492 T-97493 T-97494 T-97495 T-97496 T-97553 W-98431 W-98432 W-98433 W-98434 W-98435 W-98436)

imgName="zastepcze-zdjecie-produktu.jpg"

# wait for user confirmation
echo "Czy chcesz wykonać program? wpisz 'Y' aby kontynuować"
    read userImput
      if [[ $userImput != "Y" ]] ; then
        echo -e "\n------ Zamykam program ------\n"
        exit 0
      break
  fi
echo -e "\n"

for el in "${array[@]}"; do

    mkdir $el
    cp "${imgName}" "${el}/${el}.jpg"
    echo "create ${imgName} -> ${el}/${el}.jpg"

  done
