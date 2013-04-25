# Check if burnupi/plana
if !node[:hostname].match(/^(plana|burnupi|mira|vpm)/)
 raise "This recipe is only intended for plana/burnupi/mira/vpm hosts"
end

if node[:platform] == "ubuntu"
  # remove ceph packages (if any)
  #  FIXME: possibly remove this when teuthology starts using debs.
  execute "remove ceph packages" do
    command 'apt-get purge -f -y --force-yes ceph ceph-common libcephfs1 radosgw python-ceph librbd1 librados2|| true'
  end
  execute "remove /etc/ceph" do
    command 'rm -rf /etc/ceph'
  end
  execute "remove ceph sources" do
    command 'rm -f /etc/apt/sources.list.d/ceph.list'
  end
end

#Setup sources.list to use our apt mirror.
case node[:platform]
when "ubuntu"
  case node[:platform_version]
  when "12.04"
    cookbook_file '/etc/apt/sources.list' do
      source "sources.list.precise"
      mode 0644
      owner "root"
      group "root"
    end
  when "12.10"
    cookbook_file '/etc/apt/sources.list' do
      source "sources.list.quantal"
      mode 0644
      owner "root"
      group "root"
    end
  end
end

if node[:platform] == "ubuntu"
  # for rgw
  execute "add autobuild gpg key to apt" do
    command <<-EOH
  wget -q -O- 'http://ceph.com/git/?p=ceph.git;a=blob_plain;f=keys/autobuild.asc;hb=HEAD' \
  | sudo apt-key add -
    EOH
  end
end

if node[:platform] == "ubuntu"
  # do radosgw recipe first, because it updates the apt sources and runs
  # apt-get update for us too.
  if node[:platform] == "ubuntu" and (node[:platform_version] == "10.10" or node[:platform_version] == "11.10" or node[:platform_version] == "12.04")
    include_recipe "ceph-qa::radosgw"
  else
    Chef::Log.info("radosgw not supported on: #{node[:platform]} #{node[:platform_version]}")

    # der.. well, run update.
    execute "apt-get update" do
      command "apt-get update"
    end
  end
end


if node[:platform] == "ubuntu"
  package 'lsb-release'
  package 'build-essential'
  package 'sysstat'
  package 'gdb'
  package 'python-configobj'
  package 'python-gevent'

  # for running ceph
  package 'libedit2'
  package 'libssl0.9.8'

  if node[:platform_version] == "12.10"
    package 'libgoogle-perftools4'
  else
    package 'libgoogle-perftools0'
  end

  if node[:platform_version] == "12.10"
    package 'libboost-thread1.49.0'
  else
    package 'libboost-thread1.46.1'
  end

  package 'cryptsetup-bin'
  package 'xfsprogs'
  package 'gdisk'
  package 'parted'

  # for setting BIOS settings
  package 'smbios-utils'
end

if node[:platform] == "centos"
  package 'redhat-lsb'
  package 'sysstat'
  package 'gdb'
  package 'python-configobj'

  # for running ceph
  package 'libedit'
  package 'openssl098e'
  package 'google-perftools-devel'
  package 'boost-thread'
  package 'xfsprogs'
  package 'gdisk'
  package 'parted'
  package 'libgcrypt'
  package 'cryptopp-devel'
  package 'cryptopp'

  # for setting BIOS settings
  package 'smbios-utils'

end

case node[:platform]
when "ubuntu"
  case node[:platform_version]
  when "10.10"
    package 'libcrypto++8'
  when "11.10", "12.04", "12.10"
    package 'libcrypto++9'
  else
    Chef::Log.fatal("Unknown ubuntu release: #{node[:platform_version]}")
    exit 1
  end
when "centos"
  case node[:platform_version]
  when "6.3"
     package 'openssl'
  else
    Chef::Log.fatal("Unknown ubuntu release: #{node[:platform_version]}")
    exit 1
  end
else
  Chef::Log.fatal("Unknown platform: #{node[:platform]}")
  exit 1
end

if node[:platform] == "ubuntu"
  package 'libuuid1'
  package 'libfcgi'
  package 'btrfs-tools'

  # for compiling helpers and such
  package 'libatomic-ops-dev'

  # used by workunits
  package 'git-core'
  package 'attr'
  package 'dbench'
  package 'bonnie++'
  package 'iozone3'
  package 'tiobench'

  # No ltp-kernel-test package on quantal
  if node[:platform_version] != "12.10"
    package 'ltp-kernel-test'
  end
  package 'valgrind'
  package 'python-nose'
  package 'mpich2'
  package 'libmpich2-3'
  package 'libmpich2-dev'
  package 'ant'

  # used by the xfstests tasks
  package 'libtool'
  package 'automake'
  package 'gettext'
  package 'uuid-dev'
  package 'libacl1-dev'
  package 'bc'
  package 'xfsdump'
  package 'dmapi'
  package 'xfslibs-dev'

  # for blktrace and seekwatcher
  package 'blktrace'
  package 'python-numpy'
  package 'python-matplotlib'
  package 'mencoder'

  # for qemu
  package 'kvm'
  package 'genisoimage'

  # for json_xs to investigate JSON by hand
  package 'libjson-xs-perl'
  # for pretty-printing xml
  package 'xml-twig-tools'

  # for java bindings, hadoop, etc.
  package 'default-jdk'
  package 'junit4'

  # for disk/etc monitoring
  package 'smartmontools'
  package 'nagios-nrpe-server'
end

if node[:platform] == "centos"
  package 'libuuid'
  package 'fcgi-devel'
  package 'btrfs-progs'

  # for copmiling helpers and such
  package 'libatomic_ops-devel'

  # used by workunits
  package 'git-all'
  package 'attr'
  package 'valgrind'
  package 'python-nose'
  package 'mpich2'
  package 'mpich2-devel'
  package 'ant'
  package 'dbench'
  package 'bonnie++'
  package 'tiobench'

  # used by the xfstests tasks
  package 'libtool'
  package 'automake'
  package 'gettext'
  package 'uuid-devel'
  package 'libacl-devel'
  package 'bc'
  package 'xfsdump'

  # for blktrace and seekwatcher
  package 'blktrace'
  package 'numpy'
  package 'python-matplotlib'

  # for qemu:
  package 'qemu-kvm'
  package 'qemu-kvm-tools'
  package 'genisoimage'

  # for json_xs to investigate JSON by hand
  package 'perl-JSON'

  # for pretty-printing xml
  package 'perl-XML-Twig'

  # for java bindings, hadoop, etc.
  package 'java-1.7.0-openjdk-devel'
  package 'junit4'

  # for disk/etc monitoring
  package 'smartmontools'
end

if node[:platform] == "ubuntu"
  file '/etc/grub.d/35_ceph_force_timeout' do
    owner 'root'
    group 'root'
    mode '0755'
    content <<-EOH
	cat <<-EOF
	set timeout=5
	EOF
    EOH
  end
end


package 'ntp'

if node[:platform] == "ubuntu"
  cookbook_file '/etc/ntp.conf' do
    source "ntp.conf"
    mode 0644
    owner "root"
    group "root"
    notifies :restart, "service[ntp]"
  end

  service "ntp" do
    action [:enable,:start]
  end
end

if node[:platform] == "centos"
  cookbook_file '/etc/ntp.conf' do
    source "ntp.conf"
    mode 0644
    owner "root"
    group "root"
    notifies :restart, "service[ntpd]"
  end

  service "ntpd" do
    action [:enable,:start]
  end
end

if node[:platform] == "centos"
  cookbook_file '/etc/security/limits.d/remote.conf' do
    source "remote.conf"
    mode 0644
    owner "root"
    group "root"
  end
end

if node[:platform] == "ubuntu"
  execute "add user_xattr to root mount options in fstab" do
    # fugly but works! which is more than i can say for the "mount"
    # resource, which doesn't seem to like a rootfs with an unknown UUID
    # at all.
    command <<-'EOH'
      perl -pe 'if (m{^([^#]\S*\s+/\s+\S+\s+)(\S+)(\s+.*)$}) { $_="$1$2,user_xattr$3\n" unless $2=~m{(^|,)user_xattr(,|$)}; }' -i.bak /etc/fstab
    EOH
  end
end

if node[:platform] == "ubuntu"
  execute "enable xattr for this boot" do
    command "mount -o remount,user_xattr /"
  end
end

if node[:platform] == "ubuntu"
  execute "allow fuse mounts to be used by non-owners" do
    command "grep -q ^user_allow_other /etc/fuse.conf || echo user_allow_other >> /etc/fuse.conf"
  end
end

if node[:platform] == "ubuntu"
  execute "add user ubuntu to group fuse" do
    command "adduser ubuntu fuse"
  end
end

file '/etc/fuse.conf' do
  mode "0644"
end
if node[:platform] == "ubuntu"
  execute "add user ubuntu to group kvm" do
    command "adduser ubuntu kvm"
  end
end

if node[:platform] == "centos"
  execute "add user ubuntu to group kvm" do
    command "gpasswd -a ubuntu kvm"
  end
end


if node[:platform] == "centos"
  execute "Make raid/smart scripts work on centos" do
    command "if [ ! -e /usr/bin/lspci ]; then ln -s /sbin/lspci /usr/bin/lspci; fi"
  end
end

directory '/home/ubuntu/.ssh' do
  owner "ubuntu"
  group "ubuntu"
  mode "0755"
end

if node[:platform] == "ubuntu"
  execute "set up ssh keys" do
    command <<-'EOH'
      URL=https://raw.github.com/ceph/keys/autogenerated/ssh/%s.pub
      export URL
      ssh-import-id -o /home/ubuntu/.ssh/authorized_keys @all
      sort -u </home/ubuntu/.ssh/authorized_keys >/home/ubuntu/.ssh/authorized_keys.sort
      mv /home/ubuntu/.ssh/authorized_keys.sort /home/ubuntu/.ssh/authorized_keys
      chown ubuntu.ubuntu /home/ubuntu/.ssh/authorized_keys
    EOH
  end
end

#Unfortunately no megacli/arecacli package for ubuntu -- Needed for raid monitoring and smart.
cookbook_file '/usr/sbin/megacli' do
  source "megacli"
  mode 0755
  owner "root"
  group "root"
end
cookbook_file '/usr/sbin/cli64' do
  source "cli64"
  mode 0755
  owner "root"
  group "root"
end


#Custom netsaint scripts for raid/disk/smart monitoring:
directory "/usr/libexec/" do
  owner "root"
  group "root"
  mode "0755"
  action :create
end
cookbook_file '/usr/libexec/raid.pl' do
  source "raid.pl"
  mode 0755
  owner "root"
  group "root"
end
cookbook_file '/usr/libexec/smart.pl' do
  source "smart.pl"
  mode 0755
  owner "root"
  group "root"
end
cookbook_file '/usr/libexec/diskusage.pl' do
  source "diskusage.pl"
  mode 0755
  owner "root"
  group "root"
end


if node[:platform] == "ubuntu"
  execute "add ubuntu to disk group" do
    command <<-'EOH'
      usermod -a -G disk ubuntu
    EOH
  end
end

if node[:platform] == "ubuntu"
  serial_port = 1
  if node[:hostname].match(/^mira/)
    serial_port = 2
  end
  directory '/etc/default/grub.d' do
    owner "root"
    group "root"
    mode "0755"
    action :create
  end
  # if we ever decide to use /etc/default/grub.d, change the
  # template destination to /etc/default/grub.d/ceph-qa.cfg
  # and the mode to 0644, and see comments in ceph-qa.erb
  template "/etc/grub.d/01_ceph_qa_fixup" do
    source "ceph-qa.erb"
    mode "0755"
    owner "root"
    group "root"
     variables({:serial_port => serial_port})
  end
  # bump up kernel debug.  There must be a better place than /etc/rc.local
  execute "set verbose kernel output via dmesg" do
    command <<-'EOH'
      #set verbose kernel output via dmesg:
      if ! grep -q dmesg /etc/rc.local; then
        sed -i 's/^exit 0/dmesg -n 7\nexit 0/g' /etc/rc.local
      fi
    EOH
  end
end

execute 'update-grub' do
end

if node[:platform] == "ubuntu"
  cookbook_file '/etc/init/ttyS1.conf' do
     source 'ttyS1.conf'
     mode 0644
     owner "root"
     group "root"
     notifies :start, "service[ttyS1]"
  end

  if node[:hostname].match(/^(mira)/)
    cookbook_file '/etc/init/ttyS2.conf' do
       source 'ttyS2.conf'
       mode 0644
       owner "root"
       group "root"
       notifies :start, "service[ttyS2]"
    end
  end

  service "ttyS1" do
    # Default provider for Ubuntu is Debian, and :enable doesn't work
    # for Upstart services unless we change provider.  Assume Upstart
    provider Chef::Provider::Service::Upstart
    action [:enable,:start]
  end

  if node[:hostname].match(/^(mira)/)
    service "ttyS2" do
      # Default provider for Ubuntu is Debian, and :enable doesn't work
      # for Upstart services unless we change provider.  Assume Upstart
      provider Chef::Provider::Service::Upstart
      action [:enable,:start]
    end
  end
end

if node[:platform] == "ubuntu"
  #NFS servers uport per David Z.
  package 'nfs-kernel-server'

  #Static IP
  package 'ipcalc'
end

if node[:platform] == "centos"
  #NFS servers uport per David Z.
  package 'nfs-utils'
end

if !node[:hostname].match(/^(vpm)/)
  if node[:platform] == "ubuntu"
    execute "set up static IP in /etc/hosts" do
      command <<-'EOH'
        cidr=$(ip addr show dev eth0 | grep -iw inet | awk '{print $2}')
        ip=$(echo $cidr | cut -d'/' -f1)
        hostname=$(uname -n)
        sed -i "s/^127.0.1.1[\t]$hostname.front.sepia.ceph.com/$ip\t$hostname.front.sepia.ceph.com/g" /etc/hosts
      EOH
    end
    execute "set up static IP and 10gig interface" do
      command <<-'EOH'
        dontrun=$(grep -ic inet\ static /etc/network/interfaces)
        if [ $dontrun -eq 0 ]
        then
        cidr=$(ip addr show dev eth0 | grep -iw inet | awk '{print $2}')
        ip=$(echo $cidr | cut -d'/' -f1)
        miracheck=$(uname -n | grep -ic mira)
        netmask=$(ipcalc $cidr | grep -i netmask | awk '{print $2}')
        gateway=$(ipcalc $cidr | grep -i hostmin | awk '{print $2}')
        broadcast=$(ipcalc $cidr | grep -i hostmax | awk '{print $2}')
        octet1=$(echo $ip | cut -d'.' -f1)
        octet2=$(echo $ip | cut -d'.' -f2)
        octet3=$(echo $ip | cut -d'.' -f3)
        octet4=$(echo $ip | cut -d'.' -f4)
        octet3=$(($octet3 + 13))
      
        if [ $miracheck -gt 0 ]
        then
        cat interfaces | sed -i "s/iface eth0 inet dhcp/\
        iface eth0 inet static\n\
              address $ip\n\
              netmask $netmask\n\
              gateway $gateway\n\
              broadcast $broadcast\n\
        \n\
        /g" /etc/network/interfaces
        else
        cat interfaces | sed -i "s/iface eth0 inet dhcp/\
        iface eth0 inet static\n\
              address $ip\n
              netmask $netmask\n\
              gateway $gateway\n\
              broadcast $broadcast\n\
        \n\
        auto eth2\n\
        iface eth2 inet static\n\
              address $octet1.$octet2.$octet3.$octet4\n\
              netmask $netmask\
        /g" /etc/network/interfaces
        fi
        fi
      EOH
    end
  end
end

# Remove requiretty, not visiblepw and set unlimited security/limits.conf soft core value
if node[:platform] == "centos"
  execute "Sudoers and security/lmits.conf changes" do
    command <<-'EOH'
      sed -i 's/ requiretty/ !requiretty/g' /etc/sudoers
      sed -i 's/ !visiblepw/ visiblepw/g' /etc/sudoers
      sed -i 's/^#\*.*soft.*core.*0/\*                soft    core            unlimited/g' /etc/security/limits.conf
    EOH
  end
end



#Static DNS
if node[:platform] == "ubuntu"
  file '/etc/resolvconf/resolv.conf.d/base' do
    owner 'root'
    group 'root'
    mode '0755'
    content <<-EOH
      nameserver 10.214.128.4
      nameserver 10.214.128.5
      search front.sepia.ceph.com sepia.ceph.com
    EOH
  end

  #Nagios sudo (for raid utilities)
  file '/etc/sudoers.d/90-nagios' do
    owner 'root'
    group 'root'
    mode '0440'
    content <<-EOH
      nagios ALL=NOPASSWD: /usr/sbin/megacli, /usr/sbin/cli64, /usr/sbin/smartctl, /usr/sbin/smartctl
    EOH
  end
end

if node[:platform] == "ubuntu"
  #Nagios nrpe config
  cookbook_file '/etc/nagios/nrpe.cfg' do
    source "nrpe.cfg"
    owner 'root'
    group 'root'
    mode '0644'
    notifies :restart, "service[nagios-nrpe-server]"
  end

  service "nagios-nrpe-server" do
    action [:enable,:start]
  end

  #nagios nrpe settings
  file '/etc/default/nagios-nrpe-server' do
    owner 'root'
    group 'root'
    mode '0644'
    content <<-EOH
      DAEMON_OPTS="--no-ssl"
    EOH
  end
end

if node[:platform] == "ubuntu"
  execute "Restarting resolvdns" do
    command <<-'EOH'
      sudo service resolvconf restart
    EOH
  end

  bash "ssh_max_sessions" do
    user "root"
    cwd "/etc/ssh"
    code <<-EOT
      echo "MaxSessions 1000" >> sshd_config
    EOT
    not_if {File.read("/etc/ssh/sshd_config") =~ /MaxSessions/}
  end

  service "ssh" do
    action [:restart]
  end
end

file '/ceph-qa-ready' do
  content "ok\n"
end
