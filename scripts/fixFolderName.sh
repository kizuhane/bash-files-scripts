find . -maxdepth 1 -name '* *' \
    -execdir bash -c 'mv -- "$1" "${1// /-}"' echo {} \;

find . -maxdepth 1 -name '*,*' \
    -execdir bash -c 'mv -- "$1" "${1//,/-}"' echo {} \;

find . -maxdepth 1 -name '*_*' \
    -execdir bash -c 'mv -- "$1" "${1//_/-}"' echo {} \;

