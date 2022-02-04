#variables#
filenameExist=true;
isRegularFile=true;
filenameIsRecycle=false;

filePath=$(readlink -f $1)
fileDepthLessOne=$(echo $filePath | tr '/' ' ' | wc -w)
fileDepth=$[$fileDepthLessOne + 1]                      #to cut out name of file
fileName=$(echo $filePath | cut -d'/' -f$fileDepth)

parentDirectory=$(echo $filePath | cut -d'/' --complement -f$fileDepth-)
inodeValue=$(ls -i $parentDirectory | grep -w $fileName | cut -d" " -f1)
binPath="$HOME/recyclebin"

#creates recycle bin in home directory if it does not exists
if ! ls ~ | grep -qw recyclebin
        then
                mkdir ~/recyclebin
fi

#checking if filename provided
if [ $# -eq 0 ]
        then
                echo "recycle: missing operand"
                exit 1
fi

#checking if file exists
if  [ -e $1 ]
then
        :
else
        echo "recycle: cannot remove '$1': No such file or directory"
        exit 1
fi

#checking if file is directory
if [ -d $1 ]
then
        echo "recycle: cannot remove 'test': Is a directory"
        exit 1
fi

#checking if filename provided is recycle
if [ $fileName = "recycle" ]
then
        echo "Attempting to delete recycle - operation aborted"
        exit 1
fi

##moving the files from folder to recyclebin
mv $filePath $binPath"/"$inodeValue"_"$fileName

##creating hidden .restore.info file in $HOME
echo "$fileName"_"$inodeValue:$filePath" >> $HOME/.restore.info
