:

SQLDIR=/home/jkstill/oracle/oracle-script-lib/sql
TARFILE=~/ftp/sql_scripts.tar
ZIPFILE=~/ftp/sql_scripts_windows.zip

rm -f ${TARFILE}.gz

FILES=$(grep ^@ INDEX*| cut -f2 -d@ | cut -f1 -d:)

cd $SQLDIR || {
	echo Could not chdir to $SQLDIR
	exit 3
}

# maintain symlinks as needed

for f in $(grep ^@ ../INDEX.ashmasters| cut -f2 -d@ | cut -f1 -d:)
do
	ln -s ../../ashmasters/$f . 2>/dev/null
done

# no longer getting snapper due to licensing - does not allow public distribution
# get current version of snapper from Tanel Poder
rm -f snapper.sql.[1-9] snapper.sql
wget https://raw.githubusercontent.com/tanelpoder/tpt-oracle/master/snapper.sql
#wget http://blog.tanelpoder.com/files/scripts/snapper4.sql
# remove old backup copies of snapper that were created by wget - keep one available
#rm -f snapper4.sql.[2-9]


# get current version of ashtop from Tanel Poder
#wget http://blog.tanelpoder.com/files/scripts/ashtop.sql
rm -f ashtop.sql.[1-9] ashtop.sql
wget https://raw.githubusercontent.com/tanelpoder/tpt-oracle/master/ash/ashtop.sql
# remove old backup copies of snapper that were created by wget - keep one available

# h dereferences symbolic links and gets the file instead of the link

CMD="tar chvf $TARFILE ../INDEX* $FILES"
#echo CMD:$CMD
$CMD
gzip $TARFILE

echo 
TARFILE=${TARFILE}.gz
echo created ${TARFILE}
echo 

TMPDIR=/tmp/sqldist.$$
mkdir $TMPDIR
cd $TMPDIR || {
	echo Could not chdir to $TMPDIR
	exit 1
}

tar xvfz $TARFILE

unix2dos *.sql
unix2dos INDEX
zip $ZIPFILE INDEX* *.sql

rm -f $TMPDIR/INDEX*
rm -f $TMPDIR/*.sql
rm -f $TMPDIR/distribution.sh
cd
rmdir $TMPDIR

: <<'JKS-DOC'

# skipping dropbox

dropboxDir=/home/jkstill/Dropbox/Public/oracle/SQL-Library

echo
echo Copying files to Dropbox - $dropboxDir
echo Make sure Dropbox is running
echo Start as jkstill with 'nohup ~/.dropbox-dist/dropboxd &'
echo 

[ -d "$dropboxDir" ] || {
	echo 
	echo Cannot copy to dropbox - please start the dropbox daemon
	echo
	echo eg. ~/.dropbox-dist/dropboxd
	echo
	exit 1
}

cp $TARFILE $dropboxDir
cp $ZIPFILE $dropboxDir

JKS-DOC

echo Files:
echo "  $TARFILE"
echo "  $ZIPFILE"


