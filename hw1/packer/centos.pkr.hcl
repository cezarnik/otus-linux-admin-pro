packer {
  required_plugins {
    vagrant = {
      source  = "github.com/hashicorp/vagrant"
      version = "~> 1"
    }
  }
}

variable "artifact_description" {
  type    = string
  default = "CentOS Stream 8 with kernel 6.x"
}

variable "artifact_version" {
  type    = string
  default = "8"
}

source "virtualbox-iso" "centos-8" {
  boot_command     = ["<tab> inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks.cfg<enter><wait>"]
  boot_wait        = "10s"
  disk_size        = "10240"
  export_opts      = ["--manifest", "--vsys", "0", "--description", "${var.artifact_description}", "--version", "${var.artifact_version}"]
  guest_os_type    = "RedHat_64"
  http_directory   = "http"
  iso_checksum     = "029ead89f720becd5ee2a8cf9935aad12fda7494d61674710174b4674b357530"
  iso_url          = "http://mirror.linux-ia64.org/centos/8-stream/isos/x86_64/CentOS-Stream-8-20230710.0-x86_64-boot.iso"
  output_directory = "builds"
  shutdown_command = "echo vagrant | sudo -S /sbin/halt -h -p"
  shutdown_timeout = "5m"
  ssh_password     = "vagrant"
  ssh_port         = 22
  ssh_pty          = true
  ssh_timeout      = "20m"
  ssh_username     = "vagrant"
  vboxmanage       = [["modifyvm", "{{.Name}}", "--memory", "1024"], ["modifyvm", "{{.Name}}", "--cpus", "2"]]
  vm_name          = "packer-centos-vm"
}

build {
  sources = ["source.virtualbox-iso.centos-8"]

  provisioner "shell" {
    execute_command = "echo vagrant | {{ .Vars }} sudo -S -E bash '{{ .Path }}'"
    expect_disconnect   = true
    pause_before        = "20s"
    start_retry_timeout = "1m"
    override = {
      centos-8 = {
        scripts = [
          "scripts/stage-1-kernel-update.sh",
          "scripts/stage-2-clean.sh"
        ]
      }
    }
  }


  post-processor "vagrant" {
    compression_level = "7"
    output            = "centos-${var.artifact_version}-kernel-6-x86_64-Minimal.box"
  }
}
