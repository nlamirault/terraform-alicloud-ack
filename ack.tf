# Copyright (C) 2020 Nicolas Lamirault <nicolas.lamirault@gmail.com>

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#resource "alicloud_resource_manager_resource_group" "ack" {
#  name         = format("ack-%s", var.cluster_name)
#  display_name = "ACK"
#}

resource "alicloud_cs_managed_kubernetes" "ack" {
  name    = var.cluster_name
  version = var.kubernetes_version
  # resource_group_id = alicloud_resource_manager_resource_group.ack.id

  new_nat_gateway       = false
  
  enable_ssh            = var.enable_ssh

  # install_cloud_monitor = var.install_cloud_monitor
  # cpu_policy            = var.cpu_policy
  # proxy_mode            = var.proxy_mode
  # password              = var.password
  service_cidr          = var.service_cidr
  node_cidr_mask        = var.node_cidr_mask
  pod_vswitch_ids       = data.alicloud_vswitches.pod_vswitch.ids

  worker_number         = var.worker_number
  worker_instance_types = var.worker_instance_types
  worker_vswitch_ids    = data.alicloud_vswitches.vswitch.ids
  worker_disk_category  = var.worker_disk_category
  worker_disk_size      = var.worker_disk_size
  key_name              = alicloud_key_pair.ack.key_name

  dynamic "addons" {
    for_each = var.cluster_addons
    content {
      name   = lookup(addons.value, "name", var.cluster_addons)
      config = lookup(addons.value, "config", var.cluster_addons)
    }
  }

  runtime = {
    name    = "docker"
    version = "19.03.5"
  }

  maintenance_window {
    enable            = true
    maintenance_time  = "01:00:00Z"
    duration          = "3h"
    weekly_period     = "Monday,Friday"
  }

  tags = var.tags
}

resource "alicloud_ess_scaling_group" "ack" {
  scaling_group_name   = var.cluster_name
  min_size             = var.min_size
  max_size             = var.max_size
  vswitch_ids          = data.alicloud_vswitches.vswitch.ids 
  removal_policies     = ["OldestInstance", "NewestInstance"]
}

#resource "alicloud_ess_scaling_configuration" "default" {
#  image_id             = data.alicloud_images.default.images.0.id
#  security_group_id    = alicloud_security_group.default.id
#  scaling_group_id     = alicloud_ess_scaling_group.default.id
#  instance_type        = data.alicloud_instance_types.default.instance_types.0.id
#  internet_charge_type = "PayByTraffic"
#  force_delete         = true
#  enable               = true
#  active               = true

#  lifecycle {
#    ignore_changes = [tags,user_data]
#  }
#}

#resource "alicloud_cs_kubernetes_autoscaler" "default" {
#  cluster_id              = data.alicloud_cs_managed_kubernetes_clusters.default.clusters.0.id
#  nodepools {
#    id                    = alicloud_ess_scaling_group.default.id
#    labels                = "a=b"
#  }

#  utilization             = var.utilization
#  cool_down_duration      = var.cool_down_duration
#  defer_scale_in_duration = var.defer_scale_in_duration

#  depends_on = [alicloud_ess_scaling_group.defalut, alicloud_ess_scaling_configuration.default]
#}