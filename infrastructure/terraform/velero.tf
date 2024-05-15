module "s3_bucket" {
  source                   = "terraform-aws-modules/s3-bucket/aws"
  version                  = "4.0.1"
  bucket                   = "${var.resource_name}-velero"
  acl                      = "private"
  control_object_ownership = true
  object_ownership         = "ObjectWriter"
}


module "velero" {
  source                      = "terraform-module/velero/kubernetes"
  version                     = "1.2.0"
  namespace_deploy            = true
  app_deploy                  = true
  cluster_name                = "${var.resource_name}"
  openid_connect_provider_uri = replace(module.eks.oidc_provider, "https://", "")
  bucket                      = module.s3_bucket.s3_bucket_id

  values = [<<EOF
          initContainers:
            - name: velero-plugin-for-aws
              image: velero/velero-plugin-for-aws:v1.7.1
              imagePullPolicy: IfNotPresent
              volumeMounts:
                - mountPath: /target
                  name: plugins
          securityContext:
              fsGroup: 1337
          configuration:
            provider: aws
            backupStorageLocation:
              name: "aws"
              provider: "velero.io/aws"
              bucket: "${module.s3_bucket.s3_bucket_id}" 
              default: true
              config:
                region: ${var.region}
            volumeSnapshotLocation:
              name: aws
              provider: velero.io/aws
              config:
                region: ${var.region}
          serviceAccount: 
            server:
              name: velero-server
              annotations: 
                eks.amazonaws.com/role-arn: arn:aws:iam::${var.aws_account_id}:role/lasdpc-icmc-${var.environment}-velero
          resources:
            requests:
              cpu: 100m
              memory: 32Mi
            limits:
              cpu: 100m
              memory: 128Mi 
 
    EOF
  ]
}

resource "aws_iam_policy" "velero_server_policy" {
  name        = "velero-server-policy"
  description = "Policy for velero-server to access S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:*",
          "ec2:DescribeVolumes",
          "ec2:DescribeSnapshots",
          "ec2:CreateTags",
          "ec2:CreateVolume",
          "ec2:CreateSnapshot",
          "ec2:DeleteSnapshot"
        ],
        Resource = [
          module.s3_bucket.s3_bucket_arn,
        ],
      },
      {
        Effect = "Allow",
        Action = [
          "s3:*",
          "ec2:DescribeVolumes",
          "ec2:DescribeSnapshots",
          "ec2:CreateTags",
          "ec2:CreateVolume",
          "ec2:CreateSnapshot",
          "ec2:DeleteSnapshot"
        ],
        Resource = [
          "${module.s3_bucket.s3_bucket_arn}/*",
        ],
      },
    ],
  })
}