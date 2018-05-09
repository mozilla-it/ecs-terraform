# codebuild

# Load configuration files from template

data "template_file" "codebuild_policy" {
  template = "${file("./iam/codebuild-policy.tmpl")}"

  vars {
    codepipeline_bucket = "${aws_s3_bucket.codepipeline_bucket.id}"
  }
}

resource "aws_iam_role" "codebuild_role" {
  name               = "codebuild-role-${var.service_name}"
  assume_role_policy = "${file("./iam/codebuild-role.txt")}"
}

# IAM configuration

resource "aws_iam_policy" "codebuild_policy" {
  name        = "codebuild-policy-${var.service_name}"
  path        = "/service-role/"
  description = "Policy used in trust relationship with CodeBuild"
  policy      = "${data.template_file.codebuild_policy.rendered}"
}

resource "aws_iam_policy_attachment" "codebuild_policy_attachment" {
  name       = "codebuild-policy-attachment-${var.service_name}"
  policy_arn = "${aws_iam_policy.codebuild_policy.arn}"
  roles      = ["${aws_iam_role.codebuild_role.id}"]
}

# Create CodeBuild job

resource "aws_codebuild_project" "codebuild_project" {
  name          = "${var.service_name}"
  description   = "${var.description}"
  build_timeout = "15"
  service_role  = "${aws_iam_role.codebuild_role.arn}"

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/docker:17.09.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = "true"
  }

  source {
    type     = "GITHUB"
    location = "${var.source_repository["https_url"]}"

    buildspec = <<EOF
    version: 0.2

    phases:
      pre_build:
        commands:
          - echo Logging in to Amazon ECR...
          - aws --version
          - $(aws ecr get-login --region us-east-1 --no-include-email)
          - REPOSITORY_URI=${aws_ecr_repository.webops-redirect-server.repository_url}
          - IMAGE_TAG=$(echo $CODEBUILD_RESOLVED_SOURCE_VERSION | cut -c 1-7)
      build:
        commands:
          - echo Build started on `date`
          - echo Building the Docker image...
          - docker build -t $REPOSITORY_URI:latest .
          - docker tag $REPOSITORY_URI:latest $REPOSITORY_URI:$IMAGE_TAG
      post_build:
        commands:
          - echo Build completed on `date`
          - echo Pushing the Docker images...
          - docker push $REPOSITORY_URI:latest
          - docker push $REPOSITORY_URI:$IMAGE_TAG
          - echo Writing image definitions file...
          - printf '[{"name":"webops-redirect-server","imageUri":"%s"}]' $REPOSITORY_URI:$IMAGE_TAG > imagedefinitions.json
    artifacts:
        files: imagedefinitions.json
  EOF
  }

  tags = "${var.webops_tags}"
}
