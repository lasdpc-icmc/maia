vpc_name                   = "vpc"
instance_type              = "m5.large"
max_size                   = "4"
min_size                   = "1"
desired_capacity           = "3"
max_size_on_demand         = "4"
min_size_on_demand         = "1"
desired_capacity_on_demand = "3"
spot_price                 = "0.30"
root_volume_size           = "32"
root_volume_type           = "standard"
cluster_version            = "1.19"
env                        = "prod"
region                     = "us-east-1"
key_pair                   = "prod"
resource_name              = "usp-icmc"
key                        = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCn9tj+F1+xIOpNaqnp9z/NHGIuMUMlwXcy6X0BMAJVP1Joovqqz8yeQ4oYRwcF7fFaQOrhaABZJcZgZkoYiBEqRZEiMXpnH/Fey0IKjM8Eq15GF1BDkN30VxwVwIBhNDZSUS1NtP/L20FFc1BfIdFPLhuHRu12yweD4BSiyUg7XgOqa++mgeIt5TSy9qMNO6sXa4KzuUBY5cRHBeFbifA7Th7rGC3zdj4nvcvGGySAtbHlsxWptGcGy9FzwD8jmfBTMUgk6CbOwmv6RboRwPWM2+9pMuE+oGnN35NaB5UV0uIizUW5KTg2Re3hQsiwPDAWTkSu0xTDA7/9YKuwEX8x"
users                     = ["julio.estrella", "lucas.pulcinelli", "giovanni.shibaki", "pedro.grando", "henrique.lecco", "luciana.marques", "franciscorocha"]  
