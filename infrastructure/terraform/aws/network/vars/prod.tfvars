cidr_block = "172.20.0.0/16"
subnet = {
  private  = 16
  public   = 8
  internal = 8
}
newbits       = 4
zones         = 4
env           = "prod"
region        = "us-east-1"
key_pair      = "prod"
resource_name = "application-metrics"
