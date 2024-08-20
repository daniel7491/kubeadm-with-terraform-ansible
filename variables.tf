variable "kubeadm_daniel_pj_key_name" {
  type        = string
  description = "name of key pair"
  default     = "daniel_pj_key"
}
variable "kubeadm_daniel_pj_ami" {
  type        = string
  description = "ami image"
  default     = "ami-048ddca51ab3229ab"
}
variable "kubeadm_instance_count" {
  type        = number
  description = "worker nodes in a cluster"
  default     = 2
}

variable "kubeadm_instance_type" {
  type        = string
  description = "instance type of the workers"
  default     = "t2.micro"

}