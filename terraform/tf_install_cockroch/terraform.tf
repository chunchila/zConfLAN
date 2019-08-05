# Configure the Microsoft Azure Provider
provider "azurerm" {
    subscription_id = "3abd0dd5-602a-4620-b1f8-d53bf2a6dbad"
    client_id       = "f481799b-ac0f-4765-a2a1-8f7035da8cbd"
    client_secret   = "3f1f48be-9406-4085-a8d1-14e07b8b73b8"
    tenant_id       = "d973bda2-a09e-44fe-9c85-c7ff5ea46be0"
}


variable "vms" {
    default = 4
  
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



# get az tenent id 
#az account show --query "{subscriptionId:id, tenantId:tenantId}"   

# create net application registration 
#az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/3abd0dd5-602a-4620-b1f8-d53bf2a6dbad"



## az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/3abd0dd5-602a-4620-b1f8-d53bf2a6dbad" 
#f481799b-ac0f-4765-a2a1-8f7035da8cbd	azure-cli-2018-12-08-18-31-57	http://azure-cli-2018-12-08-18-31-57	3f1f48be-9406-4085-a8d1-14e07b8b73b8	d973bda2-a09e-44fe-9c85-c7ff5ea46be0



resource "null_resource" "after_install" {
count                        = "${var.vms}"


connection {
    user     = "azureuser"
    host        = "${element(azurerm_public_ip.public_ip_deploy.*.ip_address,count.index)}"
    # password     = "Roman-12345678!"
    private_key = "${file("~/.ssh/id_rsa")}"
    agent       = false
    timeout     = "10s"

    }

provisioner "file" {
    source      = ".terraform"
    destination = "~/"
  }


provisioner "remote-exec" {
    
    inline = [
      "wget -qO- https://binaries.cockroachdb.com/cockroach-v19.1.3.linux-amd64.tgz | tar  xvz",
      "cp -i cockroach-v19.1.3.linux-amd64/cockroach /usr/local/bin",
      "echo roman ",
    ]

    
}

provisioner "local-exec" {
    command =  "rm -f terraform.tfstate"
}

}
   
output "public_ip" {
  value = "${azurerm_public_ip.public_ip_deploy.*.ip_address}"
}