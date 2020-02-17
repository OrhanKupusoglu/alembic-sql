#!/bin/bash

set -e

PATH_SCRIPT="$0"
HELP_ARG="$1"
DATABASE_DIR="$1"
DATABASE_NAME="$2"

DIR_PATH=$(cd "$(dirname "$PATH_SCRIPT")" && pwd)
SCRIPT_NAME=$(basename "$PATH_SCRIPT")
DIR_CUSTOM=alembic_sql
SECTION_CUSTOM=alembic-sql
VIRTUAL_ENV=.venv
DB_URL="postgresql://postgres:123456@127.0.0.1:5432/$DATABASE_NAME"


if [[ $# -eq 0 ]] || [[ $HELP_ARG == "help" ]]
then
    echo "usage: ./$SCRIPT_NAME <database directory> <database name>"
    echo "                           --absolute path--"
    echo "       + activates the virtual environment '$VIRTUAL_ENV'"
    echo "       + creates at the absolute path to the <database directory> a directory named <database name>"
    echo "       + initializes in the <database name> directory a customized Alembic instance"
    echo "       + the configuration file's 'sqlalchemy.url' parameter must point to the actual database"
    echo "       + deactivates the virtual environment"
    echo
    exit 0
fi

if [[ -z "$DATABASE_DIR" ]]
then
    echo "ERROR: database directory is missing"
    exit 1
else
    echo "+++ database directory: ${DATABASE_DIR}"
fi

if [[ "${DATABASE_DIR:0:1}" == '/' ]]
then
    echo "+++ path to database directory is absolute"
else
    echo "ERROR: path to database directory is NOT absolute"
    exit 2
fi

if [[ -z "$DATABASE_NAME" ]]
then
    echo "ERROR: database name is missing"
    exit 3
else
    echo "+++ database name: ${DATABASE_NAME}"
fi

# 1. activate the virtual environment
printf "+++ virtual environment: ${VIRTUAL_ENV}"
if [[ -d "${VIRTUAL_ENV}" ]]
then
    echo " - activated"
    source "${VIRTUAL_ENV}/bin/activate"
else
    echo -e "\n\nERROR - virtual environment does NOT exist\n"
    exit 4
fi

# 2. create project for the database
mkdir -p "${DATABASE_DIR}/${DATABASE_NAME}"
cd "${DATABASE_DIR}/${DATABASE_NAME}"
alembic init "${DATABASE_NAME}"

# 3. customize the alembic.ini - sed
cp -a alembic.ini alembic.ini.orig
ORIG="sqlalchemy.url = driver://user:pass@localhost/dbname"
REP="sqlalchemy.url = $DB_URL\n \
\n\
[${SECTION_CUSTOM}]\n\
downgrade_enabled = False"

sed -i "s#$ORIG#$REP#" alembic.ini

# 4. customize the script.py.mako - symlink
cd "${DATABASE_NAME}"
mv script.py.mako script.py.mako.orig
ln -s "${DIR_PATH}/${DIR_CUSTOM}/script.py.mako" script.py.mako

cd ..
printf "\n!!! ATTENTION: the configuration file's 'sqlalchemy.url' parameter must point to the actual database with username & password\n\n"
printf "  $DB_URL\n\n"

deactivate

exit 0
