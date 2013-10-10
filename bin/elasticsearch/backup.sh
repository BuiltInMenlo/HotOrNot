SCRIPTS=/home/shane/dev/hotornot/bin/elasticsearch
TO_FOLDER=/home/shane/esbackups
FROM=/elasticsearch
 
DATE=`date +%Y-%m-%d_%H`
TO=$TO_FOLDER/$DATE/
echo "rsync from $FROM to $TO"
# the first times rsync can take a bit long - do not disable flusing
rsync -a $FROM $TO
 
# now disable flushing and do one manual flushing
$SCRIPTS/es-flush-disable.sh true
$SCRIPTS/es-flush.sh
# ... and sync again
rsync -a $FROM $TO
 
$SCRIPTS/es-flush-disable.sh false

