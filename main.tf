# google_client_config and kubernetes provider must be explicitly specified like the following.
data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}

module "gke" {
  source                     = "terraform-google-modules/kubernetes-engine/google"
  project_id                 = "poc-danamon-devsecops"
  name                       = "gke-prd-cluster"
  region                     = "asia-southeast2"
  zones                      = ["asia-southeast2-a", "asia-southeast2-b", "asia-southeast2-c"]
  network                    = "vpc-danamonprod"
  subnetwork                 = "vpc-subnetwork-danamonprod"
  http_load_balancing        = false
  horizontal_pod_autoscaling = true
  network_policy             = false
  ip_range_services          = "10.30.0.0/16"
  ip_range_pods              = "10.20.0.0/16"

  node_pools = [
    {
      name                      = "default-node-pool"
      machine_type              = "e2-medium"
      node_locations            = "asia-southeast2-a,asia-southeast2-b,asia-southeast2-c"
      min_count                 = 1
      max_count                 = 3
      local_ssd_count           = 0
      disk_size_gb              = 100
      disk_type                 = "pd-standard"
      image_type                = "COS"
      auto_repair               = true
      auto_upgrade              = true
      service_account           = "ridwansulaiman@poc-danamon-devsecops.iam.gserviceaccount.com"
      preemptible               = false
      initial_node_count        = 80
    },
  ]
  }
