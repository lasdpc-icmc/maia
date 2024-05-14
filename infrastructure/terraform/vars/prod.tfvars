region                   = "us-east-1"
resource_name            = "application-metrics"
environment              = "prod"
addon_version            = "v1.18.0-eksbuild.1"
instance_types_on_demand = ["c5.large", "c5.xlarge"]
instance_types_spot      = ["t3.small", "t3.large", "t3.xlarge", "c5.large", "c5.xlarge", "c5.2xlarge"]
volume_size              = "100"
iops                     = "3000"
throughput               = "150"
volume_type              = "gp3"
cluster_version          = "1.29"
min_size_spot            = "1"
max_size_spot            = "5"
desired_size_spot        = "2"
min_size_ondemand        = "1"
max_size_ondemand        = "5"
desired_size_ondemand    = "2"
aws_account_id           = "326123346670"
client_id                = "foo"
client_secret            = "bar"

map_roles = [
  {
    rolearn  = "arn:aws:iam::326123346670:role/AWSAdministratorAccess"
    username = "system:admins"
    groups   = ["system:masters"]
  },
  {
    rolearn  = "arn:aws:iam::326123346670:role/AWSReadOnlyAccess"
    username = "system:read-only"
    groups   = ["reader"]
  },
  {
    rolearn  = "arn:aws:iam::326123346670:role/vault"
    username = "vault"
    groups   = ["system:masters"]
  }
]