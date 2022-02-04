#!/bin/bash

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
if [ $filePath = "$(readlink -f $0)" ]
then
        errorMessage="recycle: Attempting to delete recycle - operation aborted"
        return 1
fi

return 0
}

#executes the movement into recyclebin and appending .restore.info
execute(){
mv $filePath $binPath"/"$inodeValue"_"$fileName #move from folder to recyclebin
echo "$fileName"_"$inodeValue:$filePath" >> $HOME/.restore.info #append .restore.info file
}

############### M A I N #######################
#flags for options
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
emptyChecks $# #check if arguments are present
createBin #create recyclebin

#main function that processes the arguments
main(){
while [ $# -gt 0 ]
do
        settingVariable $1 #declare variables (filepath, filename etc that will be used)

       #for recursion/directories
        if [ -d $1 ] && $recursive
        then
                main $1/*
                if [ -z "$(ls -A $1)" ]
                then
                        rm -r $1
                fi
                shift
               continue
        else
                :
        fi

        #for normal files
        if runChecks $1
        then
                if  $interactive
                then
                        read -p "recycle file $1? " decision
                        if  echo "$decision" | grep -qv ^[Yy]
                        then
                                shift
                                continue #continue to next argument if anything other than Y or y is entered
                        fi
                fi

                if  $verbose
                then
                        echo "recycled '$fileName' to $HOME/recyclebin"
                fi
                execute
                shift
        else
                echo $errorMessage >&2
                shift
        fi
done
}

main $* #calling main
