# Amazon AWS Access Key
# aws_access_key = "your-aws-access-key"
# Amazon AWS Secret Key
# ws_secret_key = "your-aws-secret-key"
# Amazon AWS Key Pair Name
ssh_key_name = "cloudops"

# Region where resources should be created
region = "us-west-2"

# Resources will be prefixed with this to avoid clashing names
prefix = "quickstart"

# Admin password to access Rancher
admin_password = "admin"

# Name of custom cluster that will be created
cluster_name = "shipdrop"

# rancher/rancher image tag to use
rancher_version = "latest"

# Count of agent nodes with role all
count_agent_all_nodes = "1"

# Count of agent nodes with role etcd
count_agent_etcd_nodes = "0"

# Count of agent nodes with role controlplane
count_agent_controlplane_nodes = "0"

# Count of agent nodes with role worker
count_agent_worker_nodes = "2"

# Docker version of host running `rancher/rancher`
docker_version_server = "18.09"

# Docker version of host being added to a cluster (running `rancher/rancher-agent`)
docker_version_agent = "18.09"

# AWS Instance Type for workers
server_instance_type = "t3.medium"

# AWS Instance Type for workers
worker_instance_type = "m4.large"

#CIDR Block for Entire VPC
vpc-CIDR = "10.1.0.0/16"

#CIDR Block for Public subnet
Publicsubnet-CIDR = "10.1.1.0/24"

#CIDR block for Private subnet
Privatesubnet-CIDR = "10.1.2.0/24"
