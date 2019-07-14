
provider "google" {
  credentials = "${file("/home/alianinho/eco-tenure-238419-ad5a7923a5b3.json")}"
  project = "eco-tenure-238419"
  region = "europe-west3"
  zone = "europe-west3-c"
}


resource "google_compute_instance" "minion-solt-" {
  count = 3
  name         = "minion-solt-${count.index}"
  machine_type = "g1-small"

 metadata_startup_script = <<EOF
#!/bin/bash
apt update
sudo apt-get -y update
sudo add-apt-repository ppa:jonathonf/python-3.6
sudo apt-get -y update 
sudo apt-get -y install python 3.6
sudo apt-get -y install salt-minion
sudo mv /home/alianinho/minion /etc/salt
sudo systemctl restart salt-minion
"}
EOF

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-1804-lts"
    }
  }

provisioner "file" {
  source = "minion"
  destination = "/home/alianinho/minion"

  connection {
    type = "ssh"
    user = "alianinho"
    private_key = "${file("/home/alianinho/gcp-key")}"
    agent = "false"
  }
}
  network_interface {
    network       = "default"
    access_config {
    }
  }
}
resource "google_compute_project_metadata_item" "default" {
  key = "sshKeys"
  value = "${"alianinho"}:${file("/home/alianinho/gcp-key.pub")}"
}
