# terraform-alicloud-ack

Terraform module which configure a Kubernetes cluster (ACK) on Alibaba Cloud.

## Versions

Use Terraform `0.13` and Terraform Alicloud provider `1.111.0+`.

## Usage

```hcl
module "ack" {
  source  = "nlamirault/ack/alicloud"
  version = "X.Y.Z"

  cluster_name = var.cluster_name
  kubernetes_version = var.kubernetes_version

  tags = var.tags

  node_pools = var.node_pools
}


}
```

```hcl


tags = {
    "project" = "foo"
    "env"     = "staging"
    "service" = "kubernetes"
    "made-by" = "terraform"
}
```

This module creates :

* a Kubernetes cluster

## Documentation

