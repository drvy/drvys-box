# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

    # ( Drvy's Vagrant Box                    )
    # ( A Vagrant Machine for Web Development )
    #  ---------------------------------------
    #   o
    #    o   \
    #         \ /\
    #         ( )
    #       .( o ).

    config.vm.box = 'ubuntu/bionic64'
    config.vm.network 'private_network', ip: '192.168.30.10'
    config.vm.hostname = 'drvysBox'

    config.vm.synced_folder "./www", "/var/www", :mount_options => ["dmode=777", "fmode=666"]
    # Optional NFS. Make sure to remove the other synced_folder line.
    #config.vm.synced_folder "./www", "/var/www", :nfs => { :mount_options => ["dmode=777","fmode=666"] }

    config.vm.provision :shell, path: 'bootstrap.sh'
end