# Create the mynetwork network
resource "google_compute_network" "mynetwork" {
  name = "mynetwork"
  #RESOURCE properties go here
  auto_create_subnetworks = "true"
}
# Create a firewall rule to allow HTTP, SSH, RDP and ICMP traffic on mynetwork
resource "google_compute_firewall" "mynetwork-allow-http-ssh-rdp-icmp" {
  name = "mynetwork-allow-http-ssh-rdp-icmp"
  source_ranges = [
    "0.0.0.0/0"
  ]
  network = google_compute_network.mynetwork.self_link
  allow {
    protocol = "tcp"
    ports    = ["22", "80", "3389"]
  }
  allow {
    protocol = "icmp"
  }
}
# Create the mynet-us-vm instance
module "mynet-us-vm" {
  source              = "./instance"
  instance_name       = "mynet-us-vm"
  instance_zone       = "us-west1-c"
  instance_subnetwork = google_compute_network.mynetwork.self_link
}
# Create the mynet-second-vm" instance
module "mynet-second-vm" {
  source              = "./instance"
  instance_name       = "mynet-second-vm"
  instance_zone       = "us-east4-b"
  instance_subnetwork = google_compute_network.mynetwork.self_link
}
