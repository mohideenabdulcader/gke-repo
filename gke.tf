# variable "gke_username" {
#   default     = "mohideen"
#   description = "gke username"
# }

# variable "gke_password" {
#   default     = "Passw0rd$@654321"
#   description = "gke password"
# }

# variable "gke_num_nodes" {
#   default     = 3
#   description = "number of gke nodes"
# }

# GKE cluster
# resource "google_container_cluster" "primary" {
#   name     = "ul-gke-cluster"
#   location = "us-east4-a"

#   # We can't create a cluster with no node pool defined, but we want to only use
#   # separately managed node pools. So we create the smallest possible default
#   # node pool and immediately delete it.
#   remove_default_node_pool = true
#   initial_node_count       = 1

#   master_auth {
#     username = "mohideen"
#     password = "P@$$w0rd65432100"

#     client_certificate_config {
#       issue_client_certificate = false
#     }
#   }
# }

# resource "google_container_node_pool" "primary_preemptible_nodes" {
#   name       = "my-node-pool"
#   location   = "us-east4-a"
#   cluster    = google_container_cluster.primary.name
#   node_count = 2

#   node_config {
#     preemptible  = true
#     machine_type = "n1-standard-1"

#     metadata = {
#       disable-legacy-endpoints = "true"
#     }

#     oauth_scopes = [
#       "https://www.googleapis.com/auth/cloud-platform",
#       "https://www.googleapis.com/auth/compute",
#       "https://www.googleapis.com/auth/datastore",
#       "https://www.googleapis.com/auth/devstorage.read_only",
#       "https://www.googleapis.com/auth/logging.write",
#       "https://www.googleapis.com/auth/monitoring",
#       "https://www.googleapis.com/auth/service.management.readonly",
#       "https://www.googleapis.com/auth/servicecontrol",
#       "https://www.googleapis.com/auth/trace.append",
#       "https://www.googleapis.com/auth/bigquery",
#       "https://www.googleapis.com/auth/source.read_only",
#       "https://www.googleapis.com/auth/logging.write",
#       "https://www.googleapis.com/auth/devstorage.full_control"
#     ]
#   }
# }

resource "google_container_cluster" "unilever_cluster" {
  project  = "unilever-poc" # Replace with your Project ID, https://cloud.google.com/resource-manager/docs/creating-managing-projects#identifying_projects
  name     = "ul-gke-cluster-02"
  location = "us-east4-a"

  min_master_version = "1.16"

  # Enable Alias IPs to allow Windows Server networking.
  ip_allocation_policy {
    cluster_ipv4_cidr_block  = "/14"
    services_ipv4_cidr_block = "/20"
  }

  # Removes the implicit default node pool, recommended when using
  # google_container_node_pool.
  remove_default_node_pool = true
  initial_node_count = 1
}

# Small Linux node pool to run some Linux-only Kubernetes Pods.
resource "google_container_node_pool" "linux_pool" {
  name               = "linux-pool"
  project            = google_container_cluster.unilever_cluster.project
  cluster            = google_container_cluster.unilever_cluster.name
  location           = google_container_cluster.unilever_cluster.location
  node_count = 2

  node_config {
    image_type   = "COS_CONTAINERD"
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/datastore",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/trace.append",
      "https://www.googleapis.com/auth/bigquery",
      "https://www.googleapis.com/auth/source.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/devstorage.full_control"
    ]
  }
}
# resource "google_container_node_pool" "linux_pool1" {
#   name               = "linux-pool-1"
#   project            = google_container_cluster.unilever_cluster.project
#   cluster            = google_container_cluster.unilever_cluster.name
#   location           = google_container_cluster.unilever_cluster.location

#   node_config {
#     image_type   = "COS_CONTAINERD"
#   }
# }
# Node pool of Windows Server machines.
resource "google_container_node_pool" "windows_pool" {
  name               = "windows-pool"
  project            = google_container_cluster.unilever_cluster.project
  cluster            = google_container_cluster.unilever_cluster.name
  location           = google_container_cluster.unilever_cluster.location
  node_count = 2

  node_config {
    machine_type = "e2-standard-4"
    image_type   = "WINDOWS_SAC" # Or WINDOWS_SAC for new features.
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/datastore",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/devstorage.full_control"
    ]
  }

  # The Linux node pool must be created before the Windows Server node pool.
  depends_on = [google_container_node_pool.linux_pool]
}

  # The Linux node pool must be created before the Windows Server node pool.
  depends_on = [google_container_node_pool.linux_pool]
}

resource "google_compute_instance" "unileverdemo" {
  name         = "unilever-demo"
  machine_type = "f1-micro"
  zone         = "us-east4-a"

  tags = ["env", "development"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }


  network_interface {
   subnetwork = "sbnt-ul-poc-01"

    access_config {
      // Ephemeral IP
    }
  }
}
