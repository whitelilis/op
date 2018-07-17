#!/bin/bash
cwd=$(cd $(dirname $0); pwd)
cd  $cwd
source /etc/profile

aim_sh='install.sh'

function mkpackage(){
    pid=$$
    target_dir=$*
    follow_install_shell_command_file='post.sh'

    if [ ! -e $follow_install_shell_command_file ]; then
        echo "no $follow_install_shell_command_file found. Exit!!!"
        exit 1
    fi

    base64_file=._base64_$pid

    tar cz $target_dir $follow_install_shell_command_file | base64 > $base64_file

    echo '#!/bin/bash' > $aim_sh
    echo 'cwd=$(cd $(dirname $0); pwd)' >> $aim_sh
    echo 'cd  $cwd' >> $aim_sh
    echo 'source /etc/profile' >> $aim_sh



    printf "test_base64=\"" >> $aim_sh
    while IFS='' read -r line || [[ -n "$line" ]]; do
        printf "$line\\" >>$aim_sh
        printf "n" >>$aim_sh
    done <./$base64_file
    rm $base64_file
    echo "\"" >>$aim_sh
    echo 'printf $test_base64|base64 -d >._temp.tar.gz;'>>$aim_sh
    echo 'tar zxf ._temp.tar.gz' >> $aim_sh
    echo 'rm ._temp.tar.gz' >> $aim_sh
    echo 'bash post.sh' >> $aim_sh

    chmod +x $aim_sh
}
function usage(){
   echo "usage: (ensuer $follow_install_shell_command_file exist.)"
   echo "    $1 dirs"
}

if [ -e $aim_sh ]
then
    echo "$aim_sh exist, exit"
else
    if [[ $# != 0 ]]
    then
        mkpackage $*
    else
        usage $0
    fi
fi
