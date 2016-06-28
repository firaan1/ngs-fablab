#!/bin/bash
# Checking root

if [ -n "$1" ]; then
    ANS=$1;
    export ANSIBLE_LIBRARY=${ANS}/ansible-modules-core:${ANS}/ansible-modules-extras
fi

if [ ! "$(whoami)" == "root" ];
then
    echo -e "\nPlease run as root...\n"; exit 1
fi
 
# Checking the current working directory
if [ ! -f "${PWD}/site.yml" ];
then
    echo -e "\nFile playbooks.yml missing...Please check the working directory\n"
    exit 1
fi

if [ ! -f "${PWD}/inifile.yml" ] || [ ! -f "${PWD}/hosts" ];
then
    echo -e "\nplease create 'inifile.yml' and 'hosts' files from 'inifile.yml.sample' and 'hosts.sample' files and run ./install.sh ...\n"
    exit 1
fi


OPTIONS="galaxy-apache2-postgresql-nfs_server_client-slurm galaxy-apache2-postgresql-nfs_server_client galaxy-apache2-postgresql galaxy apache2 postgresql nfs_server_client slurm exit"

select OPT_VAR in ${OPTIONS};
do
    case ${OPT_VAR} in
        'galaxy-apache2-postgresql-nfs_server_client-slurm')
            addvars="galaxy=True apache2=True postgresql=True nfs_server_client=True slurm=True"
            break
         ;;
        'galaxy-apache2-postgresql-nfs_server_client')
            addvars="galaxy=True apache2=True postgresql=True nfs_server_client=True"
            break
         ;;
        'galaxy-apache2-postgresql')
            addvars="galaxy=True apache2=True postgresql=True"
            break
         ;;
        'slurm')
            addvars="slurm=True"
            break
         ;;
        'galaxy')
            addvars="galaxy=True"
            break
         ;;
        'apache2')
            addvars="apache2=True"
            break
         ;;
        'postgresql')
            addvars="postgresql=True"
            break
         ;;
        "nfs_server_client")
            addvars="nfs_server_client=True"
            break
         ;;
        'exit')
            echo "See you later...:-)"
            exit 0;;
        *)
            echo "The selected option is not valid..."
            exit 1;;
    esac
done

# finding os
if [ $(cat /etc/*-release | grep -i "Ubuntu" | wc -l) -ne 0 ]; then
    apt-get install -y python-dev python-jinja2 python-pkg-resources python-paramiko python-yaml python-crypto
elif [ $(cat /etc/*-release | grep -i "SuSE" | wc -l) -ne 0 ]; then
    zypper -n install python-devel python-Jinja2 python-paramiko python-yaml python-crypto
fi

echo $addvars

echo "Please enter the root password..."
ansible-playbook site.yml -i hosts -k -e "LOCAL_DIR=${PWD} ${addvars}"