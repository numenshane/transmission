#!/bin/bash
#set -x

# the folder to move completed downloads to
# port, username, password
SERVER="9091 --auth username:password" #never give you passwd in text
destDir="$1"

logDir="/Data/transmission"
pidFile=${logDir}/pid
mkdir -p ${logDir}

echo "this round started at `date`"
# check if last period running not completed
if [ -e ${pidFile} ]; then 
    echo "$0 not started, $pidFile exist"
    exit 0
fi

echo $$ > ${pidFile}

rename_and_compress="/usr/bin/rename_and_compress"

# use transmission-remote to get torrent list from transmission-remote list
# use sed to delete first / last line of output, and remove leading spaces
# use cut to get first field from each line
#TORRENTLIST=`transmission-remote $SERVER --list | sed -e '1d;$d;s/^ *//' | cut --only-delimited --delimiter=" " --fields=1`
TORRENTLIST=`transmission-remote $SERVER --list | grep -Eo '^ *([0-9]+)'`

# transmission-remote $SERVER --list 

# for each torrent in the list

for TORRENTID in $TORRENTLIST
do
    echo Processing : $TORRENTID 

    # check if torrent download is completed
    DL_COMPLETED=`transmission-remote $SERVER --torrent $TORRENTID --info | grep "Percent Done: 100%"`
    ret1=$?

    # check torrents current state is
    STATE_STOPPED=`transmission-remote $SERVER --torrent $TORRENTID --info | grep "State: Seeding\|Stopped\|Finished\|Idle\|Unknown"`
    ret2=$?
    
    echo for torrent id:$TORRENTID download_100percent=$ret1 current_status=$ret2
    # if the torrent is "Stopped", "Finished", or "Idle after downloading 100%"
    # if ["$DL_COMPLETED"] && ["$STATE_STOPPED"]; then
    if [ $ret1 -eq 0 ] && [ $ret2 -eq 0 ]; then
        # move the files and remove the torrent from Transmission
        echo "first rename_and_compress id:$TORRENTID, then move torrent id:$TORRENTID data file to $destDir"

        # transmission-remote $SERVER --torrent $TORRENTID --move $destDir
	# echo "since --move may not work as expected, so manually move to $destDir"

	dir=$(transmission-remote $SERVER  --torrent $TORRENTID --info | sed -n 's/ \+Location: \+//gp')	
	fileName=$(transmission-remote $SERVER  --torrent $TORRENTID --info | sed -n 's/ \+Name: \+//gp')
	
	if [ $? -eq 0 ]; then  
 	    $rename_and_compress "${dir}/${fileName}"
	    echo "mv $dir/$fileName to $destDir" 
	    mv "${dir}/${fileName}" ${destDir}
            echo "Torrent $TORRENTID data file moved succ"
	fi

        echo "Now Removing torrent from list"
        transmission-remote $SERVER --torrent $TORRENTID --remove
   else
        echo "Torrent $TORRENTID is not completed. Ignoring"
   fi
done

rm $pidFile

echo "this round ended at `date`"
