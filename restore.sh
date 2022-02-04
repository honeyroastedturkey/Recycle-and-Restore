#!/bin/bash


errorChecks(){
if [ $# -eq 0 ]
then
        errorMessage="retore: no file provided as arugment"
        return 1
fi

if [ -e $HOME/recyclebin ]
then
        :
else
        errorMessage="restore: recyclebin does not exist"
        return 1
fi


fileName=$1
if [ $( grep -w "$fileName[:]" ~/.restore.info) ]
then
        :
else
        errorMessage="restore: file does not exist in .restore.info"
        return 1
fi

if [ $(find $HOME/recyclebin -name "$fileName") ] 2>/dev/null
then
        :
else
        errorMessage="restore: file does not exist in recyclebin"
        return 1
fi
return 0
}

#executes the making of new directories, restoring files from recyclebin to original path,
#deleting entry from .restore.info
execute(){
mkdir $parentDirectory 2>/dev/null
echo "parent directory is $parentDirectory"
mv $fileInBinPath $filePath
lineNumber=$(grep -wn "$fileName[:]" ~/.restore.info | cut -c1)
sed "${lineNumber}d" $HOME/.restore.info > temp
mv temp  .restore.info
}

#MAIN#
if  errorChecks $1
then
        filePath=$(grep -w "$fileName[:]" ~/.restore.info | cut -d":" -f2)
        fileInBinPath=$(find $HOME/recyclebin -name "$fileName")
        echo "bin path is $fileInBinPath"
        parentDirectory=$(dirname $filePath)
        echo "file path is $filePath"
        echo "successs"
        if [ -e $filePath ]
        then
                read -p "$filePath already exsists. Overwrite?" decision
                if echo "$decision" | grep -qv ^[Yy]
                then
                        echo "entered"
                        exit 0
                fi
        fi
        echo "retreat"
        execute

else
        echo $errorMessage >&2

fi

