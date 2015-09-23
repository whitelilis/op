#!/bin/bash
cwd=$(dirname $0)
cd  $cwd
source /etc/profile

aim_sh='install.sh'

function mkpackage(){
    pid=$$
    target_dir=$1
    follow_install_shell_command_file=$2

    base64_file=._base64_$pid

    tar cz $target_dir | base64 > $base64_file

    printf "test_base64=\"">$aim_sh
    while IFS='' read -r line || [[ -n "$line" ]]; do
        printf "$line\\" >>$aim_sh
        printf "n" >>$aim_sh
    done <./$base64_file
    rm $base64_file
    echo "\"" >>$aim_sh
    echo 'printf $test_base64|base64 -d >._temp.tar.gz;'>>$aim_sh
    echo 'tar zxf ._temp.tar.gz' >> $aim_sh
    echo 'rm ._temp.tar.gz' >>$aim_sh
    if [[ -e $follow_install_shell_command_file ]]; then
        cat $follow_install_shell_command_file >>$aim_sh
    fi
    chmod +x $aim_sh
}
function usage(){
   echo "usage:"
   echo "    $1 test_dir [the_command.sh]"
}

if [ -e $aim_sh ]
then
    echo "$aim_sh exist, exit"
else
    if [[ $# != 0 ]]
    then
        mkpackage $1 $2
    else
        usage $0
    fi
fi
