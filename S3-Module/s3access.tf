resource "aws_iam_group" "my_group" {
  name = "${var.project_name}-s3-group"
}

resource "aws_iam_user" "my_user" {
  name = "${var.project_name}-s3-user"
}

resource "aws_iam_group_membership" "my_membership" {
  name  = "group_membership"
  users = [aws_iam_user.my_user.name]
  group = aws_iam_group.my_group.name
}



resource "aws_iam_policy" "bucket_access_policy" {
  name        = "BucketAccessPolicy"
  description = "Policy for accessing the S3 bucket"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "VisualEditor0",
        "Effect" : "Allow",
        "Action" : [
          "s3:ListStorageLensConfigurations",
          "s3:ListAccessPointsForObjectLambda",
          "s3:GetAccessPoint",
          "s3:PutAccountPublicAccessBlock",
          "s3:GetAccountPublicAccessBlock",
          "s3:ListAllMyBuckets",
          "s3:ListAccessPoints",
          "s3:PutAccessPointPublicAccessBlock",
          "s3:ListJobs",
          "s3:PutStorageLensConfiguration",
          "s3:ListMultiRegionAccessPoints",
          "s3:CreateJob"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "VisualEditor1",
        "Effect" : "Allow",
        "Action" : "s3:*",
        "Resource" : [
          "${aws_s3_bucket.aws_s3_bucket.arn}",
          "${aws_s3_bucket.aws_s3_bucket.arn}/*",
        ]
      }
    ]
  })
}

resource "aws_iam_group_policy_attachment" "attach_bucket_policy" {
  group      = aws_iam_group.my_group.name
  policy_arn = aws_iam_policy.bucket_access_policy.arn
}
