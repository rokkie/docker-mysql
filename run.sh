#! /bin/bash

# exit immediately on error
set -e

# initialize variables
CMD="/usr/bin/mysqld_safe"
PROC_USR="mysql"
DATA_DIR="/var/lib/mysql"
INIT_FILE="/tmp/init-mysql.sql"

# parse cli options
while :; do
    case $1 in
        --user=?*)
            PROC_USR=${1#*=}
            ;;
        --datadir=?*)
            DATA_DIR=${1#*=}
            ;;
        --init-file=?*)
            INIT_FILE=${1#*=}
            ;;
        --)
            shift
            break
            ;;
        -?*)
            printf 'Unknown option (ignored): %s\n' "$1" >&2
            ;;
        *)
            break
    esac

    shift
done

# assemble command
CMD+=" --user=$PROC_USR --datadir=$DATA_DIR"

# check if mysql database directory exists
if [[ ! -d $DATA_DIR/mysql ]]; then

    # install mysql database
    echo "No MySQL data found in $DATA_DIR"
    echo "Installing MySQL db..."
    mysql_install_db --user=$PROC_USR --datadir=$DATA_DIR
    echo "Done!"

    # check if root password is provided, exit if not
    if [ -z "$MYSQL_ROOT_PASSWORD" ]; then
	    echo 'error: root password is not set' >&2
	    echo '  Did you forget to add -e MYSQL_ROOT_PASSWORD=... ?' >&2
	    exit 1
    fi

    # set root password in DDL
    sed -ri "s/\{MYSQL_ROOT_PASSWORD\}/$MYSQL_ROOT_PASSWORD/" $INIT_FILE
    unset MYSQL_ROOT_PASSWORD

    # check if database name to create is provided, uncomment DDL if so
    if [ "$MYSQL_DATABASE" ]; then
        sed -ri "s/-- CREATE DATABASE/CREATE DATABASE/" $INIT_FILE
        sed -ri "s/\{MYSQL_DATABASE\}/$MYSQL_DATABASE/" $INIT_FILE
    fi

    # check if username and password is provided for database, uncomment DDL if so
    if [ "$MYSQL_USER" -a "$MYSQL_PASSWORD" ]; then
        sed -ri "s/-- CREATE USER/CREATE USER/" $INIT_FILE
        sed -ri "s/\{MYSQL_USER\}/$MYSQL_USER/" $INIT_FILE
        sed -ri "s/\{MYSQL_PASSWORD\}/$MYSQL_PASSWORD/" $INIT_FILE
        unset MYSQL_USER
        unset MYSQL_PASSWORD

        # check again if database is provided, uncomment DDL if so
	    if [ "$MYSQL_DATABASE" ]; then
	        sed --ri "s/-- GRANT ALL/GRANT ALL/" $INIT_FILE
	    fi
    fi

    # add init file to command
    CMD+=" --init-file=$INIT_FILE"
else
    echo "Using existing MySQL installation"
fi

# execute command, starting the server
echo "Starting server..."
exec ${CMD# }
