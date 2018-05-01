# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure('2') do |config|

    config.vm.box = 'ubuntu/xenial64'
    config.vm.hostname = 'drvysbox'

    config.vm.network 'private_network', ip: '192.168.30.10'
    config.vm.synced_folder './www', '/var/www', :mount_options => ['dmode=777', 'fmode=666']

    config.vm.provider 'virtualbox' do |vb|
        vb.customize ['modifyvm', :id, '--memory',               '1024']
        vb.customize ['modifyvm', :id, '--cpuexecutioncap',      '95']
    end


    config.vm.provision :shell, path: 'bootstrap.sh'
end
