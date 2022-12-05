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


data "aws_secretsmanager_secret" "secret-manager" {
  arn = var.secret-arn
}


resource "aws_secretsmanager_secret_version" "rds_credentials" {
  secret_id     = data.aws_secretsmanager_secret.secret-manager.id
  secret_string = <<EOF
{
  "username": var.db_username,
  "password": var.password,
  "engine": var.engine,
  "host": var.host,
  "port": var.port,
  "dbClusterIdentifier": var.db_cluster_identifier
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
                data.aws_secretsmanager_secret.secret-manager.arn
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
  id = var.sg-id
}

# # variable "security_group_id" {
# #   type = list(string)
# #   default = ["sg-0fa6202eca731f28d"]
# # }

# data "aws_vpc" "NON-PROD-HOTEL-VPC2" {
#   # filter {
#   #   name = "tag:name"
#   #   values = ["NON-PROD-HOTEL-VPC2"]
#   # }
#   id  = var.vpc-id
  
# }
# data "aws_subnet" "rds-subnet1" {
#   filter {
#     name   = "tag:Name"
#     values = ["NON-PROD-HOTEL-VPC2-PRIVATE1-us-west-2a"]
#   }
#   vpc_id = data.aws_vpc.NON-PROD-HOTEL-VPC2.id
#   #id = "subnet-0d91362be07517717" 
#   # = "subnet-0279e594bbebdfc9a"
  
# }

# data "aws_subnet" "rds-subnet2" {
#   filter {
#     name = "tag:Name"
#     values = ["NON-PROD-HOTEL-VPC2-PRIVATE2-us-west-2b"]
#   }
#   vpc_id = data.aws_vpc.NON-PROD-HOTEL-VPC2.id
# }


resource "aws_db_proxy" "example-db-proxy" {
  name                   = var.db_proxy-name
  debug_logging          = var.debug_logging
  engine_family          = var.engine_family
  idle_client_timeout    = var.idle_client_timeout
  require_tls            = var.require_tls
  role_arn               = aws_iam_role.db-proxy-role.arn
  vpc_security_group_ids = [data.aws_security_group.rds-sg.id]
  vpc_subnet_ids         = var.vpc_subnet_ids
   
  auth {
    auth_scheme = "SECRETS"
    description = var.db_proxy_name
    iam_auth    = "DISABLED"
    secret_arn  = data.aws_secretsmanager_secret.secret-manager.arn
  }

  tags = {
    Name = var.db_proxy_name
    
  }
}



resource "aws_db_proxy_default_target_group" "example-2" {
  db_proxy_name = aws_db_proxy.example-db-proxy.name

  connection_pool_config {
    connection_borrow_timeout    = var.connection_borrow_timeout
    #init_query                   = "SET x=1, y=2"
    max_connections_percent      = var.max_connections_percent
    max_idle_connections_percent = var.max_idle_connections_percent
    #session_pinning_filters      = ["None"]
  }
}


data "aws_rds_cluster" "clusterName" {
  cluster_identifier = var.rds_cluster_identifier

}

#  data "aws_db_instance" "database" {
# #   #db_name = "hotel-non-prod-rds"
# #   #db_ClusterIdentifier = "hotel-non-prod-rds-cluster"
  
# db_instance_identifier = "hotel-non-prod-rds"
#  }


resource "aws_db_proxy_target" "example-3" {
  db_cluster_identifier = data.aws_rds_cluster.clusterName.cluster_identifier
  db_proxy_name          = aws_db_proxy.example-db-proxy.name
  target_group_name      = aws_db_proxy_default_target_group.example-2.name
}