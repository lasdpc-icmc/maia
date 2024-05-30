cidr_block = "172.20.0.0/16"
subnet = {
  private  = 8
  public   = 4
  internal = 4
}
newbits       = 4
zones         = 4
env           = "dev"
region        = "us-east-1"
key_pair      = "dev"
resource_name = "application-metrics"
