env                = "prod"
region             = "us-east-1"
key_pair           = "prod"
resource_name      = "application-metrics"
username           = ["julio.estrella", "lucas.pulcinelli", "giovanni.shibaki", "pedro.grando", "henrique.lecco", "luciana.marques", "franciscorocha"] # for all users
username_dev       = ["julio.estrella", "lucas.pulcinelli", "giovanni.shibaki", "pedro.grando", "henrique.lecco", "franciscorocha"]
username_read_only = []

bucket_states_name  = "lasdpc-terraform-states"
bucket_gatling_name = "lasdpc-gatling-results"
bucket_locust_name  = "lasdpc-locust-results"
oidc_provider       = "oidc.eks.us-east-1.amazonaws.com/id/D24C5025164533C85B138C68071B5515"
