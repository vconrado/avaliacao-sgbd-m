#!/bin/bash
#
# Roda o rasql passando o arquivo $1 passado como paramentro
#

function usage() {
    echo "Usage: `basename $0` filename.rql"
}

if [ ! -f "$1" ]; then
	echo "File $1 not found!"
    usage
    exit
fi

rasql -q "$(cat $1)" --user rasadmin --passwd rasdamin
