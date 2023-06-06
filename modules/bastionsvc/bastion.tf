# Copyright 2017, 2021 Oracle Corporation and/or affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

resource "oci_bastion_bastion" "bastion" {
  bastion_type                 = "STANDARD"
  compartment_id               = var.compartment_id
  target_subnet_id             = data.oci_core_subnets.bastion_svc_target_subnet.subnets[0].id
  client_cidr_block_allow_list = var.bastion_service_access
  name                         = var.bastion_service_name
}


resource "null_resource" "init" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "file" {
    source      = "userdata/"
    destination = "/tmp"
  }
  provisioner "remote-exec" {
    inline = [
      "/tmp/userdata/linux.sh",
    ]
  }
  connection {
    type        = "ssh"
    user        = "opc"
    host        = module.oke-cluster.output.bastion_public_ip
    private_key = file("~/.ssh/id_rsa")
  }
}
