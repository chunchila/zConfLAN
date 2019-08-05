# Configure the Microsoft Azure Provider
provider "azurerm" {
    subscription_id = "3abd0dd5-602a-4620-b1f8-d53bf2a6dbad"
    client_id       = "f481799b-ac0f-4765-a2a1-8f7035da8cbd"
    client_secret   = "3f1f48be-9406-4085-a8d1-14e07b8b73b8"
    tenant_id       = "d973bda2-a09e-44fe-9c85-c7ff5ea46be0"
}


variable "vms" {
    default = 3
  
}

resource "azurerm_resource_group" "resource_group_deploy" {
    name     = "resource_group_deploy"
    location = "eastus"

 
}

# Create public IPs
resource "azurerm_public_ip" "public_ip_deploy" {
    count                        = "${var.vms}"
    name                         = "public_ip_deploy-${count.index}"
    location                     = "eastus"
    resource_group_name          = "${azurerm_resource_group.resource_group_deploy.name}"
    allocation_method = "Dynamic"

   
}

# Create subnet
# resource "azurerm_subnet" "subnet_deploy" {
#     name                 = "subnet_deploy"
#     resource_group_name  = "${azurerm_resource_group.resource_group_deploy.name}"
#     virtual_network_name = "${azurerm_virtual_network.virtual_network_deploy.name}"
#     address_prefix       = "10.0.1.0/24"
# }




# get az tenent id 
#az account show --query "{subscriptionId:id, tenantId:tenantId}"   

# create net application registration 
#az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/3abd0dd5-602a-4620-b1f8-d53bf2a6dbad"



## az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/3abd0dd5-602a-4620-b1f8-d53bf2a6dbad" 
#f481799b-ac0f-4765-a2a1-8f7035da8cbd	azure-cli-2018-12-08-18-31-57	http://azure-cli-2018-12-08-18-31-57	3f1f48be-9406-4085-a8d1-14e07b8b73b8	d973bda2-a09e-44fe-9c85-c7ff5ea46be0

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



// Installing Cockroch Master
resource "null_resource" "install_cockroch_master" {
count                        = "${var.vms}"

# provisioner "file" {
#     source      = ".terraform"
#     destination = "~/"

#     connection {
#     user     = "azureuser"
#     host        = "${element(azurerm_public_ip.public_ip_deploy.*.ip_address,count.index)}"
#     # password     = "Roman-12345678!"
#     private_key = "${file("~/.ssh/id_rsa")}"
#     agent       = false
#     timeout     = "10s"

#     }

#   }

// Installing cockroch Master
provisioner "remote-exec" {
    inline = [
      "wget -qO- https://binaries.cockroachdb.com/cockroach-v19.1.3.linux-amd64.tgz | tar  xvz",
      "cp -i cockroach-v19.1.3.linux-amd64/cockroach /usr/local/bin",
      "cockroach start --insecure --listen-addr=0.0.0.0 --background",
    ]
    connection {
    user     = "azureuser"
    host        = "${element(azurerm_public_ip.public_ip_deploy.*.ip_address,count.index)}"
    # password     = "Roman-12345678!"
    private_key = "${file("~/.ssh/id_rsa")}"
    agent       = false
    timeout     = "10s"
    }    
}
}


// Installing Cockroch Nodes
resource "null_resource" "install_cockroch_Nodes" {
count                        = "${var.vms}"

// Installing cockroch Master
provisioner "remote-exec" {
    inline = [
      "wget -qO- https://binaries.cockroachdb.com/cockroach-v19.1.3.linux-amd64.tgz | tar  xvz",
      "cp -i cockroach-v19.1.3.linux-amd64/cockroach /usr/local/bin",
      "cockroach start --insecure --store=node-${var.vms+1} --listen-addr=0.0.0.0 --join=${element(azurerm_network_interface.network_interface_deploy.*.ip_address,0)}:26257 --background",
    ]
    connection {
    user     = "azureuser"
    host        = "${element(azurerm_public_ip.public_ip_deploy.*.ip_address,count.index + 1)}"
    # password     = "Roman-12345678!"
    private_key = "${file("~/.ssh/id_rsa")}"
    agent       = false
    timeout     = "10s"
    }    
}


provisioner "local-exec" {
    command =  "rm -f terraform.tfstate"
}

}
   
output "public_ip" {
  value = "${azurerm_public_ip.public_ip_deploy.*.ip_address}"
}

output "names" {
  value = "${azurerm_public_ip.public_ip_deploy.*.fqdn}"
}