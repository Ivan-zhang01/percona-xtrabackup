########################################################################
# Bug #711166: Partitioned tables are not correctly handled by the
#              --databases and --tables-file options of innobackupex,
#              and by the --tables option of xtrabackup.
#              Testcase covers using --databases option with InnoDB
#              database
########################################################################

. inc/common.sh
. inc/ib_part.sh

start_server

require_partitioning

# Create InnoDB partitioned table with some partitions in
# different location
ib_part_init $topdir InnoDB

# Saving the checksum of original table
checksum_a=`checksum_table test test`

# Take a backup
cat >$topdir/databases_file <<EOF
mysql
performance_schema
test.test
EOF
xtrabackup --backup --databases-file=$topdir/databases_file --target-dir=$topdir/backup
xtrabackup --prepare --target-dir=$topdir/backup
vlog "Backup taken"

stop_server

# Restore partial backup
ib_part_restore $topdir $mysql_datadir

start_server

# compare checksum
ib_part_assert_checksum $checksum_a
