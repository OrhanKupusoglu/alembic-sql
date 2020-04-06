#!/bin/bash

set -e

PATH_SCRIPT="$0"
HELP_ARG="$1"

DIR_PATH=$(cd "$(dirname "$PATH_SCRIPT")" && pwd)
CONTAINING_DIR=$(basename "$DIR_PATH")
SCRIPT_NAME=$(basename "$PATH_SCRIPT")
CONTAINING_DIR_PTH="${CONTAINING_DIR}.pth"
INST_REQ=0
VIRTUAL_ENV=.venv


if [[ $HELP_ARG == "help" ]]
then
    echo "usage: ./$SCRIPT_NAME"
    echo "       + if missing, creates a virtual environment '$VIRTUAL_ENV'."
    echo "       + activates the virtual environment"
    echo "       + installs all the requirements for PostgreSQL"
    echo "       + if missing, creates a Python path configuration file"
    echo "       + deactivates the virtual environment"
    echo
    exit 0
fi

# create a python 3 virtual environment
printf "+++ virtual environment"

if [[ -d "${VIRTUAL_ENV}" ]]
then
    echo " - exists: ${VIRTUAL_ENV}"
else
    echo
    virtualenv -p python3 $VIRTUAL_ENV
    INST_REQ=1
    printf " - created: ${VIRTUAL_ENV}\n\n"
fi

source "${VIRTUAL_ENV}/bin/activate"

if [[ $INST_REQ -eq 1 ]]
then
    pip install -r requirements.txt
    echo
fi

# https://docs.python.org/3/library/site.html
cd $(python -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())")

printf "+++ path configuration file"

if [[ -f "${CONTAINING_DIR_PTH}" ]]
then
    echo " - exists: ${CONTAINING_DIR_PTH}"
else
    echo "${DIR_PATH}" > "${CONTAINING_DIR_PTH}"
    echo " - created: ${CONTAINING_DIR_PTH}"
fi

echo

deactivate

exit 0
