DELETE FROM mysql.user ;
CREATE USER 'root'@'%' IDENTIFIED BY '{MYSQL_ROOT_PASSWORD}' ;
GRANT ALL ON *.* TO 'root'@'%' WITH GRANT OPTION ;
DROP DATABASE IF EXISTS test ;

-- CREATE DATABASE IF NOT EXISTS {MYSQL_DATABASE} ;
-- CREATE USER '{MYSQL_USER}'@'%' IDENTIFIED BY '{MYSQL_PASSWORD}' ;
-- GRANT ALL ON {MYSQL_DATABASE}.* TO '{MYSQL_USER}'@'%' ;

FLUSH PRIVILEGES ;
