env                 = "prod"
region              = "us-east-1"
key_pair            = "prod"
resource_name       = "application-metrics"
username            = ["julio.estrella", "lucas.pulcinelli", "giovanni.shibaki", "pedro.grando", "henrique.lecco", "luciana.marques","franciscorocha"] # for all users
username_dev        = ["julio.estrella", "lucas.pulcinelli", "giovanni.shibaki", "pedro.grando", "henrique.lecco", "franciscorocha"]
username_read_only  = []

bucket_states_name  = "terraform-lasdpc-states"
bucket_gatling_name = "lasdpc-gatling-results"
