provider "google" {
  project     = "poc-danamon-devsecops"
  region      = "asia-southeast2"
}

resource "google_compute_subnetwork" "custom" {
  name          = "test-subnetwork"
  ip_cidr_range = "10.2.0.0/16"
  region        = "asia-southeast2"
  network       = google_compute_network.custom.id
  secondary_ip_range {
    range_name    = "services-range"
    ip_cidr_range = "192.168.1.0/24"
  }

  secondary_ip_range {
    range_name    = "pod-ranges"
    ip_cidr_range = "192.168.64.0/22"
  }
}

resource "google_compute_network" "custom" {
  name                    = "test-network"
  auto_create_subnetworks = false
}

resource "google_container_cluster" "my_vpc_native_cluster" {
  name               = "my-vpc-native-cluster"
  location           = "asia-southeast2"
  initial_node_count = 1

  network    = google_compute_network.custom.id
  subnetwork = google_compute_subnetwork.custom.id

  ip_allocation_policy {
    cluster_secondary_range_name  = "services-range"
    services_secondary_range_name = google_compute_subnetwork.custom.secondary_ip_range.1.range_name
  }

  # other settings...
}
