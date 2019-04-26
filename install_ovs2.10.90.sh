#!/bin/bash
################################################
#
# Mihai IDU (c) - 2019
#	
# This script is the automated way to install 
#and power the ovs-2.10.90 as a service on the
#host machine (Virtual Machine or Physical
#Machine)
#
################################################

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


function install_ovs {
  echo "Installing the OpenvSwitch-2.10.90"
  git clone https://github.com/openvswitch/ovs.git
  OVS_PATH=$PWD
  cd $OVS_PATH/ovs
  git checkout origin/branch-2.10
  ./boot.sh
  ./configure
  echo_info "Start the making process. Please have patience!"
  echo_info ""
  echo_info "The output information of the process it can be found on the make.log file!"
  sudo make > make.log 2>&1
  echo_info "################################################"
  echo_info "Checking all the previous work is done corect. Please have patience!"
  echo_info ""
  echo_info "The output information of the process it can be found on the make_check.log file!"
  sudo make check > make_check.log 2>&1
  echo_info "################################################"
  echo_info "Start the installation!"
  sudo make install
  cd -
}

#begin the installation process
echo_info "Install all the aditional repositories needed to prepare the host environment!"
sudo apt-get update -y 
sudo apt-get install git -y
sudo apt install build-essential libssl1.0.0 libcap-ng-utils -y
sudo apt-get install python2.7 libnuma-dev libtool autoconf automake wget python-six libvirt-bin -y
sudo apt-get install g++-4.9 gcc-multilib -y
sudo apt-get install libpcap-dev -y
sudo apt-get install iperf -y

echo_info "Start installing the ovs-2.10.90 on the host"
install_ovs
echo_info "################################################"
echo_success "The installation is done! The ovs-2.10.90 will start"
if [ "$(whoami)" != "root" ]; then
    exec sudo -- "$0" "$@"
fi
# Start the OVS server
modprobe udp_tunnel
modprobe ip6_udp_tunnel
modprobe gtp
ovsdb-server --remote=punix:/usr/local/var/run/openvswitch/db.sock \
             --remote=db:Open_vSwitch,Open_vSwitch,manager_options \
             --private-key=db:Open_vSwitch,SSL,private_key \
             --certificate=db:Open_vSwitch,SSL,certificate \
             --bootstrap-ca-cert=db:Open_vSwitch,SSL,ca_cert \
             --pidfile --detach
ovs-vsctl --no-wait init
ovs-vswitchd --pidfile --detach --log-file=/tmp/log


