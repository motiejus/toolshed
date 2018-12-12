Vagrant.configure("2") do |config|
  config.vm.box = "debian/jessie64"

  # vagrant plugin install vagrant-disksize
  config.disksize.size = '100GB'

  config.vm.provider "virtualbox" do |vb|
    vb.memory = "2048"
  end

  config.vm.provision "shell", inline: <<~HEREDOC
    set -ex

    cat <<EOF > /etc/apt/sources.list.d/backports.list
      deb http://ftp.lt.debian.org/debian jessie-backports main
      deb-src http://ftp.lt.debian.org/debian jessie-backports main
    EOF

    apt-get update
    apt-get install -y --no-install-recommends cloud-guest-utils parted

    if [[ $(blkid | wc -l) != 1 ]]; then
      swapoff -a
      echo -e "d\n5\nd\n2\nw" | fdisk /dev/sda || :
      partprobe /dev/sda
      growpart /dev/sda 1
      resize2fs /dev/sda1
    fi

    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        pbuilder/jessie-backports tmux gdebi kernel-package vim libelf-dev \
        git-buildpackage htop graphviz

    sed -i -e 's/^"\([^ ]\)/\1/' -e 's/^"\(  \+\)/\1/' /etc/vim/vimrc
  HEREDOC

end
