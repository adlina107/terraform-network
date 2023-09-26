# Create the managementnet network
resource "google_compute_network" "managementnet" {
  name = "managementnet"
  #RESOURCE properties go here
  auto_create_subnetworks = "false"
}
# Create managementsubnet-us subnetwork
resource "google_compute_subnetwork" "managementsubnet-us" {
  name          = "managementsubnet-us"
  region        = "us-west1"
  network       = google_compute_network.managementnet.self_link
  ip_cidr_range = "10.130.0.0/20"
}
# Add a firewall rule to allow HTTP, SSH, RDP and ICMP traffic on managementnet
resource "google_compute_firewall" "managementnet-allow-http-ssh-rdp-icmp" {
  name = "managementnet-allow-http-ssh-rdp-icmp"
  source_ranges = [
    "0.0.0.0/0"
  ]
  #RESOURCE properties go here
  #instruct Terraform to resolve these resources in a dependent order. The network is created before the firewall rule
  network = google_compute_network.managementnet.self_link
  allow {
    protocol = "tcp"
    ports    = ["22", "80", "3389"]
  }
  allow {
    protocol = "icmp"
  }
}
# Add the managementnet-us-vm instance
#leveraging the module in the instance folder and provides the name, zone, and network as inputs. 
#because this instance depends on a VPC network, you are using the google_compute_subnetwork.managementsubnet-us.self_link reference
#to instruct Terraform to resolve these resources in a dependent order
module "managementnet-us-vm" {
  source              = "./instance"
  instance_name       = "managementnet-us-vm"
  instance_zone       = "us-west1-c"
  instance_subnetwork = google_compute_subnetwork.managementsubnet-us.self_link
}
