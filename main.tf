resource "azurerm_resource_group" "k8sresourcegroup"{
    name = var.resource_group_name
    location = var.location
}

resource "azurerm_kubernetes_cluster" "k8cluster" {
    name                    = var.cluster_name
    location                = var.location
    resource_group_name     = azurerm_resource_group.k8sresourcegroup.name
    dns_prefix              = var.cluster_name

    default_node_pool {
        name                = "defaultk8s"
        node_count          = var.system_node_count
        vm_size             = "Standard_D2s_v3"   
    }
 
    identity {
        type = "SystemAssigned"
    }

    network_profile {
        load_balancer_sku   = "standard"
        network_plugin      = "kubenet"
    }

    tags = {
        Enviroment = "Despliegue Parcial"
    }
}

output "aks_id" {
  value = azurerm_kubernetes_cluster.k8cluster.id
}

output "aks_fqdn" {
  value = azurerm_kubernetes_cluster.k8cluster.fqdn
}

output "aks_node_rg" {
  value = azurerm_kubernetes_cluster.k8cluster.node_resource_group
}


resource "local_file" "kubeconfig" {
  depends_on   = [azurerm_kubernetes_cluster.k8cluster]
  filename     = "kubeconfig"
  content      = azurerm_kubernetes_cluster.k8cluster.kube_config_raw
}
