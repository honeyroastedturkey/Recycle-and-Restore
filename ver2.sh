#!/bin/bash

################
#recycle script#
################



#creates recycle bin in home directory if it does not exists
createBin(){
if ! ls ~ | grep -qw recyclebin
        then
                mkdir ~/recyclebin
fi
}

##to initiate variables for the current file in use
settingVariable(){

filePath=$(readlink -f $1)
fileDepthLessOne=$(echo $filePath | tr '/' ' ' | wc -w)
fileDepth=$[$fileDepthLessOne + 1]                      #to cut out name of file
fileName=$(echo $filePath | cut -d'/' -f$fileDepth)

parentDirectory=$(echo $filePath | cut -d'/' --complement -f$fileDepth-)
inodeValue=$(ls -i $parentDirectory | grep -w $fileName | cut -d" " -f1)
binPath="$HOME/recyclebin"
errorMessage=""
}



runChecks(){
#checking if filename provided
if [ $# -eq 0 ]
        then
                errorMessage="recycle: missing operand"
                return 1
fi

#checking if file exists
if  [ -e $1 ]
then
        :
else
        errorMessage="recycle: cannot remove '$1': No such file or directory"
        return 1
fi

#checking if file is directory
if [ -d $1 ]
then
        errorMessage="recycle: cannot remove '$1': Is a directory"
        return 1
fi

#checking if filename provided is recycle
if [ $fileName = "recycle" ]
then
        errorMessage="Attempting to delete recycle - operation aborted"
        return 1
fi

return 0
}

execute(){
##moving the files from folder to recyclebin
mv $filePath $binPath"/"$inodeValue"_"$fileName

##adding file information into .restore.info file
echo "$fileName"_"$inodeValue:$filePath" >> $HOME/.restore.info
}

############### M A I N #######################

#options
while getopts :iv opt
do
        case $opt in
                i) echo "Interactive";;
                v) echo "Verbose";;
                /?) echo "$OPTARG is an invalid option"
                exit 1;;
        esac
done

shift $(($OPTIND - 1))


while [ $# -gt 0 ]
do
        settingVariable $1

        if runChecks $1
        then
                createBin
                execute
        else
                echo $errorMessage
                shift
                continue
        fi
        shift
done

