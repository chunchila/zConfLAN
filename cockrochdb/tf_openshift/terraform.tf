# Configure the Microsoft Azure Provider
provider "azurerm" {
    subscription_id = "3abd0dd5-602a-4620-b1f8-d53bf2a6dbad"
    client_id       = "f481799b-ac0f-4765-a2a1-8f7035da8cbd"
    client_secret   = "3f1f48be-9406-4085-a8d1-14e07b8b73b8"
    tenant_id       = "d973bda2-a09e-44fe-9c85-c7ff5ea46be0"
}


variable "vms" {
    default = 7
  
}

# get az tenent id 
#az account show --query "{subscriptionId:id, tenantId:tenantId}"   

# create net application registration 
#az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/3abd0dd5-602a-4620-b1f8-d53bf2a6dbad"



## az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/3abd0dd5-602a-4620-b1f8-d53bf2a6dbad" 
#f481799b-ac0f-4765-a2a1-8f7035da8cbd	azure-cli-2018-12-08-18-31-57	http://azure-cli-2018-12-08-18-31-57	3f1f48be-9406-4085-a8d1-14e07b8b73b8	d973bda2-a09e-44fe-9c85-c7ff5ea46be0


# Create a resource group if it doesn’t exist
resource "azurerm_resource_group" "resource_group_deploy" {
    name     = "resource_group_deploy"
    location = "eastus"

 
}

# Create virtual network
resource "azurerm_virtual_network" "virtual_network_deploy" {
    name                = "virtual_network_deploy"
    address_space       = ["10.0.0.0/16"]
    location            = "eastus"
    resource_group_name = "${azurerm_resource_group.resource_group_deploy.name}"

    
}

# Create subnet
resource "azurerm_subnet" "subnet_deploy" {
    name                 = "subnet_deploy"
    resource_group_name  = "${azurerm_resource_group.resource_group_deploy.name}"
    virtual_network_name = "${azurerm_virtual_network.virtual_network_deploy.name}"
    address_prefix       = "10.0.1.0/24"
}

# Create public IPs
resource "azurerm_public_ip" "public_ip_deploy" {
    count                        = "${var.vms}"
    name                         = "public_ip_deploy-${count.index}"
    location                     = "eastus"
    resource_group_name          = "${azurerm_resource_group.resource_group_deploy.name}"
    allocation_method = "Static"

   
}


# resource "azurerm_public_ip" "public_ip_lb_deploy" {
#     name                         = "public_ip_lb_deploy"
#     location                     = "eastus"
#     resource_group_name          = "${azurerm_resource_group.resource_group_deploy.name}"
#     public_ip_address_allocation = "dynamic"

   
# }



# Create Network Security Group and rule
resource "azurerm_network_security_group" "network_security_group_deploy" {
    name                = "network_security_group_deploy"
    location            = "eastus"
    resource_group_name = "${azurerm_resource_group.resource_group_deploy.name}"

    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "8080"
        priority                   = 1002
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "8080"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "26257"
        priority                   = 1003
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "26257"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }


    
}

# Create Load Balancer 
# resource "azurerm_lb" "lb_deploy" {
#   resource_group_name = "${azurerm_resource_group.resource_group_deploy.name}"
#   name                = "lb_deploy"
#   location            = "eastus"

#   frontend_ip_configuration {
#     name                 = "LoadBalancerFrontEnd"
#     public_ip_address_id = "${azurerm_public_ip.public_ip_lb_deploy.id}"
#   }
# }

# resource "azurerm_lb_backend_address_pool" "lb_backend_address_pool_deploy" {
#   resource_group_name = "${azurerm_resource_group.resource_group_deploy.name}"
#   loadbalancer_id     = "${azurerm_lb.lb_deploy.id}"
#   name                = "lb_backend_address_pool_deploy"
# }

# resource "azurerm_lb_nat_rule" "lb_nat_rule-ssh-deploy" {
#   resource_group_name            = "${azurerm_resource_group.resource_group_deploy.name}"
#   loadbalancer_id                = "${azurerm_lb.lb_deploy.id}"
#   name                           = "lb_nat_rule-ssh-deploy-${count.index}"
#   protocol                       = "tcp"
#   frontend_port                  = "5000${count.index}"
#   backend_port                   = 22
#   frontend_ip_configuration_name = "LoadBalancerFrontEnd"
#   count                          = "${var.vms}"
# }

# resource "azurerm_lb_rule" "lb_rule" {
#   resource_group_name            = "${azurerm_resource_group.resource_group_deploy.name}"
#   loadbalancer_id                = "${azurerm_lb.lb_deploy.id}"
#   name                           = "LBRule"
#   protocol                       = "tcp"
#   frontend_port                  = 80
#   backend_port                   = 80
#   frontend_ip_configuration_name = "LoadBalancerFrontEnd"
#   enable_floating_ip             = false
#   backend_address_pool_id        = "${azurerm_lb_backend_address_pool.lb_backend_address_pool_deploy.id}"
#   idle_timeout_in_minutes        = 5
#   probe_id                       = "${azurerm_lb_probe.lb_probe.id}"
#   depends_on                     = ["azurerm_lb_probe.lb_probe"]
# }

# resource "azurerm_lb_probe" "lb_probe" {
#   resource_group_name = "${azurerm_resource_group.resource_group_deploy.name}"
#   loadbalancer_id     = "${azurerm_lb.lb_deploy.id}"
#   name                = "tcpProbe"
#   protocol            = "tcp"
#   port                = 22
#   interval_in_seconds = 5
#   number_of_probes    = 2
# }

# Create network interface
resource "azurerm_network_interface" "network_interface_deploy" {
    count                     = "${var.vms}"
    name                      = "network_interface_deploy-${count.index}"
    location                  = "eastus"
    resource_group_name       = "${azurerm_resource_group.resource_group_deploy.name}"
    network_security_group_id = "${azurerm_network_security_group.network_security_group_deploy.id}"

   
   
    ip_configuration {
        name                          = "network_interface_deploy_ip_configuration"
        subnet_id                     = "${azurerm_subnet.subnet_deploy.id}"
        private_ip_address_allocation = "dynamic"
        public_ip_address_id          = "${element(azurerm_public_ip.public_ip_deploy.*.id,count.index)}"
        # load_balancer_backend_address_pools_ids = ["${azurerm_lb_backend_address_pool.lb_backend_address_pool_deploy.id}"]
        # load_balancer_inbound_nat_rules_ids     = ["${element(azurerm_lb_nat_rule.lb_nat_rule-ssh-deploy.*.id, count.index)}"]

    }
    

  
}



# Generate random text for a unique storage account name
resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = "${azurerm_resource_group.resource_group_deploy.name}"
    }

    byte_length = 8
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "storage_account_deploy" {
    name                        = "diag${random_id.randomId.hex}"
    resource_group_name         = "${azurerm_resource_group.resource_group_deploy.name}"
    location                    = "eastus"
    account_tier                = "Standard"
    account_replication_type    = "LRS"

    
}


# resource "azurerm_availability_set" "availability_set_deploy" {
#   name                         = "availability_set_deploy"
#   location                     = "eastus"
#   resource_group_name          = "${azurerm_resource_group.resource_group_deploy.name}"
#   platform_fault_domain_count  = 2
#   platform_update_domain_count = 2
#   managed                      = true
# }



# Create virtual machine
resource "azurerm_virtual_machine" "virtual_machine_deploy" {
    count                 = "${var.vms}" 
    name                  = "vm-deploy-${count.index}"
    location              = "eastus"
    resource_group_name   = "${azurerm_resource_group.resource_group_deploy.name}"
    network_interface_ids = ["${element(azurerm_network_interface.network_interface_deploy.*.id,count.index)}"]
    vm_size               = "Standard_DS3_v2"
    delete_data_disks_on_termination = true
    delete_os_disk_on_termination  =true
    # availability_set_id   = "${azurerm_availability_set.availability_set_deploy.id}"
    

    storage_os_disk {
        name              = "vm-deploy-${count.index}"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Premium_LRS"
    }
    

    storage_image_reference {
        publisher = "openlogic"
        offer     = "CentOS"
        sku       = "7.6"
        version   = "latest"
    }

    # storage_image_reference {
    #     publisher = "Canonical"
    #     offer     = "UbuntuServer"
    #     sku       = "16.04.0-LTS"
    #     version   = "latest"
    # }

    os_profile {
        computer_name  = "vm-deploy${count.index}"
        admin_username = "azureuser"
        admin_password = "Roman-12345678!"
        ## connect via ssh -p 50001 azureuser@ipaddress

    }

    os_profile_linux_config {
        disable_password_authentication = false
        
        ssh_keys {
            path     = "/home/azureuser/.ssh/authorized_keys"
            key_data = "${file("~/.ssh/id_rsa.pub")}"
        }
    }

    boot_diagnostics {
        enabled = "true"
        storage_uri = "${azurerm_storage_account.storage_account_deploy.primary_blob_endpoint}"
    }



#   provisioner "remote-exec" {
    
#     inline = [
#       "sudo apt-get install tmux htop -y",
#       "ls /etc",
#       "echo roman ",
#     ]

#         connection {
#         user     = "azureuser"
#         host        = "${element(azurerm_public_ip.public_ip_deploy.*.ip_address,count.index)}"
#         //password     = "Roman-12345678!"
#         private_key = "${file("~/.ssh/id_rsa")}"
#         agent       = true
#         timeout     = "10m"

#         } 
#     }
#    provisioner "local-exec" {
#     command = "sleep 30"
#     #interpreter = ["perl", "-e"]
#   }

}


// Installing Cockroch Cluster
resource "null_resource" "install_cockroch_Cluster" {

depends_on = ["azurerm_virtual_machine.virtual_machine_deploy"]


triggers ={
        build_number = "${timestamp()}"
    }

// Install Master
provisioner "remote-exec" {
    inline = [
    #   "sudo wget -qO- https://binaries.cockroachdb.com/cockroach-v19.1.3.linux-amd64.tgz | tar  xvz",
      "sudo yum update -y",
      
    ]
    connection {
    user     = "azureuser"
    host        = "${element(azurerm_public_ip.public_ip_deploy.*.ip_address,count.index)}"
    # password     = "Roman-12345678!"
    private_key = "${file("~/.ssh/id_rsa")}"
    agent       = true
    timeout     = "10m"
    }    
}




}




   
output "public_ip" {
  value = "${azurerm_public_ip.public_ip_deploy.*.ip_address}"
}

output "names" {
  value = "${azurerm_public_ip.public_ip_deploy.*.fqdn}"
}
