locals {
  subnets = {
    "public-1"  = { cidr = "10.0.1.0/24", az = "eu-north-1a", public = true  }
    "public-2"  = { cidr = "10.0.2.0/24", az = "eu-north-1b", public = true  }
    "private-1" = { cidr = "10.0.3.0/24", az = "eu-north-1a", public = false }
    "private-2" = { cidr = "10.0.4.0/24", az = "eu-north-1b", public = false }
    "private-3" = { cidr = "10.0.5.0/24", az = "eu-north-1c", public = false }
    "public-3" = { cidr = "10.0.6.0/24", az = "eu-north-1c", public = true }
  }
}

locals {
    name = "ECSv3"
}