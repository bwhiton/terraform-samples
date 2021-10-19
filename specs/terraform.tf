variable "cloudUrl"       {default = "vcenter01.prod.dc2.den.morpheusdata.com"}
variable "cloudUsername"  {}
variable "cloudPassword"  {}
variable "datacenterName" {default = "labs-den-dc2-qa"}

terraform {
  required_version = ">= 0.12"
}

provider "vsphere" {
  user           = var.cloudUsername
  password       = var.cloudPassword
  vsphere_server = var.cloudUrl
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "dc" {
  name = var.datacenterName
}

data "vsphere_datastore" "datastore" {
  name          = "ESXi-DC2-QA-LUN01"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_resource_pool" "pool" {
  name          = "QA"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = "VLAN0002 - Internal Server"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
  name          = "qa-apache"
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_virtual_machine" "vm" {
  name             = "auto-vmw-terraspec1"
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id

  num_cpus = 1
  memory   = 1024
  guest_id = "ubuntu64Guest"

  network_interface {
    network_id = data.vsphere_network.network.id
  }

  disk {
    label            = "disk0"
    thin_provisioned = true
    size             = 15
  }

  disk {
    label       = "disk1"
    size        = 5
    unit_number = 1
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
  }

  connection {
    type     = "ssh"
    user     = "cloudinit"
    password = "P@55w0rd!!"
  }
}
