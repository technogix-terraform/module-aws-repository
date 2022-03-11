#!/bin/bash
# -------------------------------------------------------
# TECHNOGIX
# -------------------------------------------------------
# Copyright (c) [2022] Technogix SARL
# All rights reserved
# -------------------------------------------------------
# Module to deploy an aws repository with all the secure
# components required
# Bash script to launch robotframework tests
# -------------------------------------------------------
# Nadège LEMPERIERE, @07 march 2022
# Latest revision: 07 march 2022
# -------------------------------------------------------

# Retrieve absolute path to this script
script=$(readlink -f $0)
scriptpath=`dirname $script`

# Consider all additional arguments as a case to test (if none, all cases are tested)
args=''
for level in "$@"; do
    export args=$args" --loglevel $level"
done

# Install required python packages
pip install --quiet --no-warn-script-location -r $scriptpath/../requirements-test.txt --target /tmp/site-packages

# Launch python scripts to setup terraform environment
export PYTHONPATH=/tmp/site-packages
python3 -m robot --variable vaultdatabase:$scriptpath/../../vault/database.kdbx   \
                 --variable vaultkey:$scriptpath/../../vault/database.key         \
                 $args                                                            \
                 $scriptpath/../test/cases