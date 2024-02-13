#!/bin/bash

#VIED_HOST
vms=( 10.193.156.14 )
# 10.193.156.71 ) 
# 10.193.156.58 10.193.156.88 )
VIED_PATH="/root/VIED/install"
VIED_CONFIG_FILE=etc/config/sea-dpdk01/vied1-dpdk-64.config

vm_sender="10.193.156.25"
PCAP_HOST_INTERFACE="enp5s0"
PCAP_PATH="/root/VIED/install"
PCAP_CONFIG_FILE=etc/config/sea-dpdk01/pcap_sender_cluster-1-4.config
PCAP_REPORT_PATH="/dev/shm"
# 5 min = 300 s
TEST_DURATION=300

#Date
echo "Launch date:  $(date)"

#Packet recorder
echo "root${vm_sender}"
ssh "root@${vm_sender}"  "/bin/bash -x " << EOF
cd /dev/shm
cd "$PCAP_PATH"
/bin/rm  -f "$PCAP_REPORT_PATH"/packet_record;
PCI_RT_TIMEOUT="$TEST_DURATION" taskset 0x4 nohup bin/packet_recorder "$PCAP_HOST_INTERFACE" "$PCAP_REPORT_PATH"/packet_record LIE01 1000000000 > "$PCAP_REPORT_PATH"/packet_record.log 2>&1 &
EOF


#PCAP SENDER
echo "root@$vm_sender"
ssh "root@${vm_sender}" "/bin/bash -x"  << EOF
cd "$PCAP_PATH"   
PCI_RT_TIMEOUT="$TEST_DURATION" taskset 0x2 nohup bin/pcap_sender_cluster "$PCAP_CONFIG_FILE" > "$PCAP_REPORT_PATH"/pcap_sender.log 2>&1 &
EOF


#Run VIED
#for ip in "${vms[@]}"
#do
#  echo "$ip"
#  ssh root@$ip "/bin/bash -x" << EOF
#    cd "$VIED_PATH" > /dev/shm/vied.log 2>&1 
#    PCI_RT_TIMEOUT="$TEST_DURATION" taskset 0x2 nohup  bin/vied "$VIED_CONFIG_FILE" >> /dev/shm/vied1.log 2>&1 &
#
#EOF
#
#done

#Strees machine
#ssh root@10.193.156.132 "/bin/bash -x" << EOF
#sleep 30
#nohup /root/stress-me.sh > /dev/null 2>&1 &
#stress-ng --all 2 -t "$TEST_DURATION"
#EOF
