#!/bin/bash

# Parse arguments
SNAPSHOT=false

while [[ $# -gt 0 ]]; do
    case $1 in 
        -f|--file)
            FILE="$2"
            shift
            shift
            ;;
        --snapshot)
            SNAPSHOT=true
            shift
            ;;
        -*|--*)
            echo "Only '-f | --file' and '--snapshot' arguments expected"
            exit 1
            ;;
        *)
            shift
            ;;
    esac
done

read_version () {
    VERSION=$(xmlstarlet sel -t -m _:project -v _:version -n < $FILE)
    VERSION=$(echo $VERSION | grep -oE "\d(\.\d)*\.\d")
    echo $VERSION
}

VERSION=$(read_version)
# Split version increments dotwise
VERSION_ARR=($(echo $VERSION | tr "." "\n"))
# Iterate minor increment
VERSION_ARR[-1]=$((VERSION_ARR[-1] + 1))
# Rebuild version string
RESULT=${VERSION_ARR[0]}
for (( i=1; i < ${#VERSION_ARR[@]}; i++ ))
do
    RESULT="$RESULT"".""${VERSION_ARR[i]}"
done

# If SNAPSHOT, add it to version
if [[ $SNAPSHOT = true ]];
then
    RESULT="$RESULT""-SNAPSHOT"
fi

# Write version back to pom.xml
xmlstarlet edit --inplace --update "/_:project/_:version" --value ${RESULT} ${FILE}

echo $RESULT
