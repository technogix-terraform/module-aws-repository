# -------------------------------------------------------
# TECHNOGIX
# -------------------------------------------------------
# Copyright (c) [2022] Technogix.io
# All rights reserved
# -------------------------------------------------------
# Module to deploy an ecr repository with all the secure 
# components required
# -------------------------------------------------------
# Nadège LEMPERIERE, @07 march 2022
# Latest revision: 07 march 2022
# -------------------------------------------------------

# -------------------------------------------------------
# Create the aws repository
# -------------------------------------------------------
resource "aws_ecr_repository" "repository" {
	
	name                 	= "${var.name}.${var.project}.${var.environment}"
  	
	image_tag_mutability 	= "IMMUTABLE"

	encryption_configuration {
		encryption_type 	= "KMS"
		kms_key 			= aws_kms_key.repository.arn
	}

  	image_scanning_configuration {
    	scan_on_push 		= true
  	}

	tags = {
		Name           		= "${var.project}.${var.environment}.${var.module}.repository.${var.name}"
		Environment     	= var.environment
		Owner   			= var.email
		Project   			= var.project
		Version 			= var.git_version
		Module  			= var.module
	}
}

# -------------------------------------------------------
# Set permission policy for ecr repository access
# -------------------------------------------------------
locals {
	cycle_statements = {
		rules = [
			{
				rulePriority 	= 100
				description		= "Keep tagged images",
				selection		= {
					"tagStatus"		: "tagged",
					"tagPrefixList"	: ["v"],
					"countType"		: "imageCountMoreThan",
					"countNumber"	: "${var.lifecycles.max_tagged_images}"
				}
				action 			= {
					"type": "expire"
				}
			},
			{
				rulePriority 	= 200
				description		= "Delete other images older than untagged_deletion_delay number of days",
				selection		= {
					"tagStatus"		: "untagged",
                	"countType"		: "sinceImagePushed",
                	"countUnit"		: "days",
                	"countNumber"	: "${var.lifecycles.untagged_deletion_delay}"
				}
				action 			= {
					"type": "expire"
				}
			}
		]
	}
}

# -------------------------------------------------------
# Create the aws repository lifecycle
# -------------------------------------------------------
resource "aws_ecr_lifecycle_policy" "lifecycle" {

  	repository = aws_ecr_repository.repository.name

  	policy = jsonencode("${local.cycle_statements}")
}


# -------------------------------------------------------
# Set permission policy for ecr repository access
# -------------------------------------------------------
locals {
	kms_statements = [
		{
			Sid 		= "AllowRootAndServicePrincipal"
			Effect 		= "Allow"
			Principal 	= { 
				"AWS" 		: ["arn:aws:iam::${var.account}:root", "arn:aws:iam::${var.account}:user/${var.service_principal}"]
			}
			Action 		= "kms:*",
			Resource	= ["*"]
		}
	]
}

# -------------------------------------------------------
# Repository encryption key
# -------------------------------------------------------
resource "aws_kms_key" "repository" {
  	
	description             	= "Repository ${var.name} encryption key"
	key_usage					= "ENCRYPT_DECRYPT"
	customer_master_key_spec	= "SYMMETRIC_DEFAULT"
	deletion_window_in_days		= 7
	enable_key_rotation			= true
  	policy						= jsonencode({
  		Version = "2012-10-17",
  		Statement = "${local.kms_statements}"
	})
  	
	tags = {
		Name           	= "${var.project}.${var.environment}.${var.module}.repository.${var.name}.key"
		Environment     = var.environment
		Owner   		= var.email
		Project   		= var.project
		Version 		= var.git_version
		Module  		= var.module
	}
}


# -------------------------------------------------------
# Set permission policy for ecr repository access
# -------------------------------------------------------
locals {
	ecr_statements = concat([
		for i,right in (("${var.rights}" != null) ? "${var.rights}" : []) :
		{
			Sid 		= right.description
			Effect 		= "Allow"
			Principal 	= { 
				"AWS" 		: (("${right.principal.aws}" != null) ? "${right.principal.aws}" : [])
				"Service" 	: (("${right.principal.services}" != null) ? "${right.principal.services}" : [])
			}
			Action 		= right.actions
		}
	],
	[
		{
			Sid 		= "AllowRootAndServicePrincipal"
			Effect 		= "Allow"
			Principal 	= { 
				"AWS" 		: ["arn:aws:iam::${var.account}:root", "arn:aws:iam::${var.account}:user/${var.service_principal}"]
			}
			Action 		= "ecr:*"
		}
	])
}

# -------------------------------------------------------
# Allow writing in ecr repository for dedicated users and/or 
# services
# -------------------------------------------------------
resource "aws_ecr_repository_policy" "repository" {
	
	repository = aws_ecr_repository.repository.name
  	policy = jsonencode({
    	Version = "2012-10-17"
		Statement = "${local.ecr_statements}"
	})
}
