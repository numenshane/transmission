#!/bin/sh

# the folder to move completed downloads to

# port, username, password
SERVER="9091 --auth username:password"

# use transmission-remote to get torrent list from transmission-remote list
# use sed to delete first / last line of output, and remove leading spaces
# use cut to get first field from each line
TORRENTLIST=`transmission-remote $SERVER --list | sed -e '1d;$d;s/^ *//' | cut --only-delimited --delimiter=" " --fields=1`

transmission-remote $SERVER --list 

# for each torrent in the list
for TORRENTID in $TORRENTLIST
do
    echo Processing : $TORRENTID 

    # check if torrent download is completed
    DL_COMPLETED=`transmission-remote $SERVER --torrent $TORRENTID --info | grep "Percent Done: nan%"`
    ret1=$?

    # check torrents current state is
    STATE_STOPPED=`transmission-remote $SERVER --torrent $TORRENTID --info | grep "State: Seeding\|Stopped\|Finished\|Idle"`
    ret2=$?
    echo $STATE_STOPPED
    
    echo ret1=$ret1 ret2=$ret2
    # if the torrent is "Stopped", "Finished", or "Idle after downloading 100%"
    #if ["$DL_COMPLETED"] && ["$STATE_STOPPED"]; then
    if [[ "$ret1" == 0 ]] && [[ "$ret2" == 0 ]]; then
        echo "Now Removing torrent and data files from list"
        dir=$(transmission-remote $SERVER  --torrent $TORRENTID --info | sed -n 's/ \+Location: \+//gp')
        fileName=$(transmission-remote $SERVER  --torrent $TORRENTID --info | sed -n 's/ \+Name: \+//gp')
        if [ $? -eq 0 ]; then
            echo "rm ${dir}/${fileName}"
            rm "${dir}/${fileName}"
        fi

        transmission-remote $SERVER --torrent $TORRENTID --remove-and-delete
    else
        echo "Torrent #$TORRENTID is up & down. just Ignore."
    fi
done
