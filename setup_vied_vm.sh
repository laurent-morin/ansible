#!/bin/bash


vms=( 10.193.156.14 )
# 10.193.156.71 10.193.156.58 10.193.156.88 )
for ip in "${vms[@]}"
do
  echo "$ip"
  ssh root@$ip "/bin/bash -x" << EOF
    # Set the number of hugepages
    echo 256 > /sys/devices/system/node/node0/hugepages/hugepages-2048kB/nr_hugepages 
    # Unbind the device from the kernel
    echo 0000:02:00.0 > /sys/bus/pci/drivers/igbvf/unbind
    # Load the driver
    modprobe vfio-pci
    # Bypass security protection
    echo 1 > /sys/module/vfio/parameters/enable_unsafe_noiommu_mode
    # Bind dpdk to the pci slot of the device
    dpdk-devbind.py --bind=vfio-pci 02:00.0

EOF

done
