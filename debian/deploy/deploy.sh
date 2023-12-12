#!/bin/bash
source cdt-final.sh
hostnames=("host02" "host03" "host04" "host05" "host06" "host07" "host08")
octet1=192
octet2=168
octet3=1
octet4=10 # Starting IP

# Function to create a VM
create_vm() {
    local vm_group=$1
    local vm_number=$2
    local ip_address="$octet1.$octet2.$octet3.$octet4"
    local hostname_index=$3
    local availability_zone=${hostnames[hostname_index]}
    # VM naming convention: n{group_number}kali{vm_number_within_group}
    local vm_name="n${vm_group}kali${vm_number}"
    openstack server create --flavor large --availability-zone $availability_zone --image Kali-2023.1 --boot-from-volume 256 --key-name cdt-final-scoring --nic net-id=f81a7f95-b0b3-4e97-870b-3f21c531e54f  --nic net-id=830afc36-11dd-4e5b-ac7b-d313793eb956,v4-fixed-ip=$ip_address --user-data user-datas/kali1.sh $vm_name

    echo "VM created: $vm_name with IP $ip_address"
}
# Main loop to create 50 VMs
group_number=1
vm_in_group=1
hostname_index=0
for (( i=1; i<=50; i++ )); do
    create_vm "$group_number" "$vm_in_group" "$hostname_index"

    # Increment IP
    let octet4++

    # Increment VM number in group
    let vm_in_group++

    # Increment hostname index, wrap around if it exceeds the length of hostnames array
    let hostname_index=(hostname_index+1)%${#hostnames[@]}

    # Every 5 VMs, increment the group number, reset VM number in group,
    # increment the third octet, and reset the fourth octet
    if (( i % 5 == 0 )); then
        let group_number++
        vm_in_group=1
        let octet3++
        octet4=10
    fi
done

echo "All VMs created successfully!"


