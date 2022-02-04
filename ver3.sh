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
fileName=$(basename $1)

parentDirectory=$(dirname $1)
inodeValue=$(ls -i $parentDirectory | grep -w $fileName | cut -d" " -f1)
binPath="$HOME/recyclebin"
errorMessage=""
}

emptyChecks(){
#checking if filename provided
if [ $1 -eq 0 ]
        then
                echo "recycle: missing operand"
                exit 1
fi
}

runChecks(){
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
        errorMessage="recycle: Attempting to delete recycle - operation aborted"
        return 1
fi

return 0
}

execute(){
mv $filePath $binPath"/"$inodeValue"_"$fileName #move from folder to recyclebin
echo "$fileName"_"$inodeValue:$filePath" >> $HOME/.restore.info #append .restore.info file
}

############### M A I N #######################
#flags
verbose=false;
interactive=false;
recursive=false;

#options
while getopts :ivr opt
do
        case $opt in
                i) interactive=true;;
                v) verbose=true;;
                r) recursive=true;;
                \?) echo "recycle: $OPTARG is an invalid option"
                exit 1;;
        esac
done

shift $(($OPTIND - 1))
emptyChecks $#

#main function that loops through the arguments
while [ $# -gt 0 ]
do
        settingVariable $1
        echo "$filePath"
        if runChecks $1
        then
                createBin
                if  $interactive
                then
                        read -p "remove file $fileName? " decision
                        if  echo "$decision" | grep -qv ^[Yy]
                        then
                                shift
                                continue
                        fi
                fi
                if  $verbose
                then
                        echo "recycled '$fileName' to $HOME/recyclebin"
                fi
                echo "removed $fileName"
                #execute
        else
                echo $errorMessage
                shift
                continue
        fi
        shift
done
