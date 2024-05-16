#
# ORIGIN: https://gist.github.com/mwodz/ceba436e4590073db61930551cba9ec1
#
# Fix emails with bad timestamps in a Maildir
#
# which are usually resulting from moves in IMAP clients
# If the client then doesn't ask Dovecot for a specific sorting, they will be shown in the order of the filename
# based timestamp.
#
# This script reads the date from the email header and set its UNIX timestamp and renames it with the proper date
# e.g. this:
# dec.  05  2017 1512499812.M908995P21566.ip-111-11-11-11,S=16331,W=16746:2,S
# becomes that (the email Date header is "Date: Tue, 22 Oct 2013 10:07:21 +0100"):
# oct.  22  2013 1382432841.M908995P21566.ip-111-11-11-11,S=16331,W=16746:2,S
#
# Based off of https://mikegriffin.ie/blog/20130226-change-the-timestamp-of-maildir-files and
# https://gist.github.com/pimpreneil/7163cc8d3f4935cde54a669b00861be6
#
# Refs.
# https://cr.yp.to/proto/maildir.html
# https://wiki2.dovecot.org/MailboxFormat/Maildir
# https://serverfault.com/questions/588618/maintain-email-timestamp-when-transferring-between-email-servers-using-an-email
#
# Keywords
# fix_msg_dates.pl Maildir Dovecot timestamp date sort
#
# 20200905 mwodz: Added a few safeguards, and option for running in CWD or on specified path.
#

if [ -z "$1" ]
then
    echo "Will run in $PWD and rename files!"
    echo "run $0 --yes to confirm"
    echo "or run $0 <path-to-dir>"
    exit
fi

if [ "$1" = '--yes' ]
then
    DIR=$PWD
else
    DIR=$1
fi

if [ ! -d "$DIR" ]
then
    echo "Directory $DIR does not exist"
    exit
fi

if [ `basename -- "$DIR"` != 'cur' ]
then
    echo "$DIR is not a Maildir/cur folder!"
    read -p "Are you absolutely sure you want to rename files in $DIR? yes/[no]: " -r
    echo
    if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]
    then
        [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1 
        # handle exits from shell or function but don't exit interactive shell
    fi
fi

cd -- "$DIR"
for i in `ls`
do
    # Find the date field and then remove up to the first space (Date: )
    DATE=$(grep -i '^Date:' $i | head -1 | cut -d' ' -f1 --complement)
    
    # We compute a touch-compatible timestamp as well as the real timestamp
    TIMESTAMP=$(date --date="$DATE" +%s)
    DATE=$(date --date="$DATE" +%Y%m%d%H%M)
    
    if [ ${i%%.*} = $TIMESTAMP ]
    then
        continue
        # skip this file, already updated
    fi
    
    # touch the file with the correct timestamp
    touch -t $DATE $i
    
    # We rename the file with preprending timestamp
    newfilename="$TIMESTAMP.${i#*.}"
    mv -v "$i" "$newfilename"
done
