# terraform {
  

# region = "us-west-2"
# #profile = "nonprod"

# }



resource "aws_iam_role" "db-proxy-role" {
  name = var.role-name

  assume_role_policy = jsonencode({
     Version = "2012-10-17",
     Statement = [
        {
            Sid = "",
            Effect = "Allow",
            Principal = {
                "Service": "rds.amazonaws.com"
            },
            Action = "sts:AssumeRole"
        }
    ]


  })

  
}


data "aws_secretsmanager_secret" "test-secret" {
  arn = "arn:aws:secretsmanager:us-west-2:366751107728:secret:test-secret-qykHJo"
}


resource "aws_secretsmanager_secret_version" "rds_credentials" {
  secret_id     = data.aws_secretsmanager_secret.test-secret.id
  secret_string = <<EOF
{
  "username": "test",
  "password": "test",
  "engine": "mysql",
  "host": "hotel-non-prod-rds-cluster.cluster-cvvwqxxa3xvq.us-west-2.rds.amazonaws.com",
  "port": 3306,
  "dbClusterIdentifier": "hotel-non-prod-rds-cluster"
}
EOF
}

resource "aws_iam_policy" "db-proxy-policy" {
  name        = var.policy-name
  path        = "/"
  description = "My test policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
        {
            Sid = "VisualEditor0",
            Effect = "Allow",
            Action = [
                "secretsmanager:GetResourcePolicy",
                "secretsmanager:GetSecretValue",
                "secretsmanager:DescribeSecret",
                "secretsmanager:ListSecretVersionIds"
            ],
            Resource = [
                data.aws_secretsmanager_secret.test-secret.arn
            ]
        },
        {
            Sid = "VisualEditor1",
            Effect = "Allow",
            Action = [
                "secretsmanager:GetRandomPassword",
                "secretsmanager:ListSecrets"
            ],
            Resource = "*"
        }
      
    ]
  })
}


resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.db-proxy-role.name
  policy_arn = aws_iam_policy.db-proxy-policy.arn
}


data "aws_security_group" "rds-sg" {
  id = "sg-0fa6202eca731f28d"
}

# variable "security_group_id" {
#   type = list(string)
#   default = ["sg-0fa6202eca731f28d"]
# }

data "aws_vpc" "NON-PROD-HOTEL-VPC2" {
  # filter {
  #   name = "tag:name"
  #   values = ["NON-PROD-HOTEL-VPC2"]
  # }
  id  = "vpc-03768100a9e2831b0"
  
}
data "aws_subnet" "rds-subnet1" {
  filter {
    name   = "tag:Name"
    values = ["NON-PROD-HOTEL-VPC2-PRIVATE1-us-west-2a"]
  }
  vpc_id = data.aws_vpc.NON-PROD-HOTEL-VPC2.id
  #id = "subnet-0d91362be07517717" 
  # = "subnet-0279e594bbebdfc9a"
  
}

data "aws_subnet" "rds-subnet2" {
  filter {
    name = "tag:Name"
    values = ["NON-PROD-HOTEL-VPC2-PRIVATE2-us-west-2b"]
  }
  vpc_id = data.aws_vpc.NON-PROD-HOTEL-VPC2.id
}


resource "aws_db_proxy" "example-db-proxy" {
  name                   = var.proxy-name
  debug_logging          = false
  engine_family          = "MYSQL"
  idle_client_timeout    = 1800
  require_tls            = true
  role_arn               = aws_iam_role.db-proxy-role.arn
  vpc_security_group_ids = [data.aws_security_group.rds-sg.id]
  vpc_subnet_ids         = [data.aws_subnet.rds-subnet1.id, data.aws_subnet.rds-subnet2.id]
  # vpc_subnet_ids         = ["subnet-0d91362be07517717", "subnet-0279e594bbebdfc9a"] 
  auth {
    auth_scheme = "SECRETS"
    description = "example"
    iam_auth    = "DISABLED"
    secret_arn  = data.aws_secretsmanager_secret.test-secret.arn
  }

  tags = {
    Name = "example"
    Key  = "value"
  }
}



resource "aws_db_proxy_default_target_group" "example-2" {
  db_proxy_name = aws_db_proxy.example-db-proxy.name

  connection_pool_config {
    connection_borrow_timeout    = 120
    #init_query                   = "SET x=1, y=2"
    max_connections_percent      = 100
    max_idle_connections_percent = 50
    #session_pinning_filters      = ["None"]
  }
}


data "aws_rds_cluster" "clusterName" {
  cluster_identifier = "hotel-non-prod-rds-cluster"

}

 data "aws_db_instance" "database" {
#   #db_name = "hotel-non-prod-rds"
#   #db_ClusterIdentifier = "hotel-non-prod-rds-cluster"
  
db_instance_identifier = "hotel-non-prod-rds"
 }


resource "aws_db_proxy_target" "example-3" {
  db_cluster_identifier = data.aws_rds_cluster.clusterName.cluster_identifier
  db_proxy_name          = aws_db_proxy.example-db-proxy.name
  target_group_name      = aws_db_proxy_default_target_group.example-2.name
}