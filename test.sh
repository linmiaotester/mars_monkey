#!/bin/sh
isCommandInPath() {
	which $1 &> /dev/null
	if [ $? -ne 0 ]
	then
		echo "false";
	else
		echo "true";
	fi
}


if [[ `isCommandInPath adb ` = "false" || `isCommandInPath aapt ` = "false" ]]
then
	echo "check android idk in ur PATH environment :$PATH"
	#exit 1
fi

for i in $@
do
	eval $i
	if [ $? -ne 0 ]
	then
		echo "bad arguments"	
		exit 1
	fi
done


if [ -z ${eventCount} ]
then 
	eventCount=100
fi


if [ -z ${deviceID} ]
then 
	echo "deviceID为空，使用默认"
	deviceArgs=""
else
	deviceArgs="-s $deviceID"
fi

if [ -z $apkFilePath ]
then
	echo "no apkFilePath"
	exit 1
fi

pkgName=` aapt d badging ${apkFilePath} | grep "package:.*name" | awk -F"'" '{ print $2 }'`

adb ${deviceArgs} uninstall $pkgName &> /dev/null
echo "adb ${deviceArgs} uninstall ${pkgName} "

if [ -f "$apkFilePath" ] && [ ${apkFilePath: -4} = ".apk" ]
then 
	adb $deviceArgs install $apkFilePath
	echo "start install apk=== "
else
	echo "$apkFile is not a apk"
	exit 1
fi

seedNo=$RANDOM
echo "start monkey"
adb $deviceArgs shell monkey -p $pkgName --throttle 100 -s $seedNo -v -v $eventCount &> monkey.log 
echo "after monkey"

#test.sh apkFilePath=xx eventCount=xx deviceID=xx

