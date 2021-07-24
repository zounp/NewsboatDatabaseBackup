#! /bin/bash

# Because cache.db (bad name (which has been acknowledged)) can be excluded from a backup ( and with reason )
# a copy is made with a different name so it is incorporated in the backup.
#
# Two times because cache.db can be being updated while the copy is made. Mostly by user interaction (run this program when the user is asleep)
# or by auto update (I think every 360 minutes should be sufficient).
# I seems that cache.db can be copied even if it is locked.
#
# Proposed cronjob:
# 6 3 * * * /home/username/newsboat.backup.sh
#
# Manual
# Replace username with the acual username before use.

filename='newsboat.backup.sh'
newsboatdatabasedir='/home/username/.local/share/newsboat'
#newsboatdatabasefile='cache.db'
waittime='20m' # 20 minutes ( 20m )
exitcode=1

while [[ $exitcode -ne 0 ]]; do
  sleep $waittime # Initial wait and wait so newsboat can finish updating if applicable
  cp --update --no-dereference --preserve=all \
    $newsboatdatabasedir/cache.db $newsboatdatabasedir/newsboat.db
  sleep $waittime # Wait so newsboat can finsish updating if applicable
  cp --update --no-dereference --preserve=all \
    $newsboatdatabasedir/cache.db $newsboatdatabasedir/newsboat.2.db
	# Compare if the two newsboat??.db files are the same. If so it is presumed that the database copy is valid.
  diff $newsboatdatabasedir/newsboat.db $newsboatdatabasedir/newsboat.2.db &> /dev/null
  exitcode=$?
done
rm -f $newsboatdatabasedir/newsboat.2.db  # Clean up
printf "Successfully made a backup of newsboat's cache.db at %(%d-%b-%Y %H:%M)T\n"	# This goes to local email. Comment it if you do not need it.
