#!/bin/bash
#############

# colorful echos
###################################

black='\E[30m'
red='\E[31m'
green='\E[32m'
yellow='\E[33m'
blue='\E[1;34m'
magenta='\E[35m'
cyan='\E[36m'
white='\E[37m'
reset_color='\E[00m'
COLORIZE=1

cecho()  {
    # Color-echo
    # arg1 = message
    # arg2 = color
    local default_msg="No Message."
    message=${1:-$default_msg}
    color=${2:-$green}
    [ "$COLORIZE" = "1" ] && message="$color$message$reset_color"
    echo -e "$message"
    return
}

echo_error()   { cecho "$*" $red          ;}
echo_fatal()   { cecho "$*" $red; exit -1 ;}
echo_warning() { cecho "$*" $yellow       ;}
echo_success() { cecho "$*" $green        ;}
echo_info()    { cecho "$*" $blue         ;}

check_supported_os_dist() {
    case "$os_dist" in
        "ubuntu17.10") return 0 ;;
        "ubuntu17.04") return 0 ;;
        "ubuntu16.04") return 0 ;;
        "ubuntu14.04") return 0 ;;
        "fedora24")    return 0 ;;
        "rhel7")       return 0 ;;
        "centos7")     return 0 ;;
    esac
    return 1
}

function install_ovs {
  echo "Installing the OpenvSwitch-2.10.90"
  git clone https://github.com/openvswitch/ovs.git
  OVS_PATH=$PWD
  cd $OVS_PATH/ovs
  
}


ORIGIN_PATH=$PWD
