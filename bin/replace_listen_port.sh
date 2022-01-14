#!/bin/sh

function __readKey() {

    ConfigFILE=$1; KEY=$2

    _readIni=`awk -F ':' '/'$KEY'/{print $2}' $ConfigFILE`

    echo ${_readIni}
}

_listen_port=$( __readKey config/config.yaml listen_port )

sed -i "s/{{listen_port}}/${_listen_port=80}/g" conf/nginx.conf
