# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  slurm_conf = %q(
    # vim:ft=bash
    ClusterName=tester
    SlurmUser=slurm
    SlurmctldHost=localhost
    SlurmctldPidFile=/var/run/slurmctld.pid
    SlurmctldDebug=3
    SlurmctldLogFile=/var/log/slurmctld.log
    StateSaveLocation=/var/spool/slurm/ctld
    ReturnToService=1
    SlurmdPidFile=/var/run/slurmd.pid
    SlurmdSpoolDir=/var/spool/slurm/d
    SlurmdDebug=3
    SlurmdLogFile=/var/log/slurmd.log
    AuthType=auth/munge
    MpiDefault=none
    ProctrackType=proctrack/pgid
    SwitchType=switch/none
    TaskPlugin=task/affinity
    FastSchedule=2 # version prior to 20.04
    SchedulerType=sched/builtin
    SelectType=select/cons_res
    SelectTypeParameters=CR_CPU
    JobAcctGatherType=jobacct_gather/none
    JobCompType=jobcomp/none
    AccountingStorageType=accounting_storage/none
    NodeName=localhost Sockets=1 CoresPerSocket=8 ThreadsPerCore=2 State=UNKNOWN
    PartitionName=debug Nodes=localhost Default=YES MaxTime=INFINITE State=UP
  ).gsub(/^ */,'')

  plugin = '/etc/slurm/spank/singularity-exec.so'
  wrapper = '/etc/slurm/spank/slurm-singularity-wrapper.sh'
  bind = '/etc/slurm,/var/run/munge,/var/spool/slurm'

  singularity_conf = %Q(required #{plugin} default= script=#{wrapper} bind=#{bind} args="")
  
  # Copy test container into the box
  #
  %w(
    /tmp/debian10.sif
    /tmp/centos7.sif
    /tmp/centos_stream8.sif
   ).each do |file|
     name = File.basename file
     config.vm.provision "file", source: "#{file}", destination: "/tmp/#{name}"
  end

  config.vm.box_check_update = false
  config.vm.synced_folder ".", "/vagrant", type: "rsync"
  config.vm.network "private_network", ip: "192.168.50.10"

  ##
  # CentOS 7 with GCC 8
  #
  config.vm.define "el7gcc8" do |config|

    config.vm.hostname = "el7gcc8"
    config.vm.box = "centos/7"

    config.vm.provision "shell" do |s|
      s.privileged = true,
      s.inline = %q(
        yum install -y epel-release centos-release-scl
        rpm -i https://github.com/openhpc/ohpc/releases/download/v1.3.GA/ohpc-release-1.3-1.el7.x86_64.rpm
        yum install -y slurm-slurmctld-ohpc slurm-slurmd-ohpc slurm-example-configs-ohpc \
                       singularity git devtoolset-8
      )
    end

    config.vm.provision "shell" do |s|
      s.privileged = true,
      s.inline = %Q(
        source scl_source enable devtoolset-8
        mkdir /etc/slurm/spank
        cd /vagrant
        make libdir=/etc/slurm/spank install
        echo "#{singularity_conf}" > /etc/slurm/plugstack.conf.d/singularity-exec.conf
        echo "#{slurm_conf}" > /etc/slurm/slurm.conf
        systemctl enable --now munge slurmctld slurmd
      )
    end

  end

  ##
  # CentOS Stream 8
  #
  config.vm.define "els8" do |config|

    config.vm.hostname = "els8"
    config.vm.box = "centos/stream8"

    config.vm.provision "shell" do |s|
      s.privileged = true,
      s.inline = %q(
        dnf install -y epel-release
        dnf config-manager --set-enabled powertools
        dnf install -y munge slurm-slurmctld slurm-slurmd singularity make gcc gcc-c++ libstdc++-static
        echo 123456789123456781234567812345678 > /etc/munge/munge.key
        chown munge:munge /etc/munge/munge.key
        chmod 600 /etc/munge/munge.key
      )
    end
    
    # Configure Slurm and the Singularity SPANK plugin
    #
    config.vm.provision "shell" do |s|
      s.privileged = true,
      s.inline = %Q(
        mkdir /etc/slurm/spank
        cd /vagrant
        make libdir=/etc/slurm/spank install
        echo "#{singularity_conf}" > /etc/slurm/plugstack.conf.d/singularity-exec.conf
        systemctl enable --now munge slurmctld slurmd
      )
    end

  end

end
