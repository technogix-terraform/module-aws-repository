# -------------------------------------------------------
# TECHNOGIX
# -------------------------------------------------------
# Copyright (c) [2022] Technogix.io
# All rights reserved
# -------------------------------------------------------
# Simple deployment for repository testing
# -------------------------------------------------------
# Nadège LEMPERIERE, @07 march 2022
# Latest revision: 07 march 2022
# -------------------------------------------------------

# -------------------------------------------------------
# Local test variables
# -------------------------------------------------------
locals {
	test_repositories = [
		{ 	name = "test-1"},
		{ 	name = "test-2", lifecycles = { max_tagged_images = 10, untagged_deletion_delay = 7 } },
		{ 	name = "test-3", lifecycles = { max_tagged_images = 20, untagged_deletion_delay = 10 } },
		{ 	name = "test-4", lifecycles = { max_tagged_images = 30, untagged_deletion_delay = 14 } },
		{	name = "test-5", lifecycles = { max_tagged_images = 35, untagged_deletion_delay = 30} , rights = [
				{ description = "AllowLoggingService", actions = ["ecr:PutImage"], principal = { aws = ["*"] } }
		] }
	]
}

# -------------------------------------------------------
# Create repositories using the current module
# -------------------------------------------------------
module "repositories" {

	count 		= length(local.test_repositories)

	source 					= "../../../"
	email 					= "moi.moi@moi.fr"
	name 					= lookup("${local.test_repositories[count.index]}", "name", null)
	project 				= "test"
	environment 			= "test"
	module 					= "test"
	git_version 			= "test"
	service_principal 		= var.service_principal
	account					= var.account
	rights					= lookup("${local.test_repositories[count.index]}", "rights", null)
	lifecycles				= lookup("${local.test_repositories[count.index]}", "lifecycles", null)
}

# -------------------------------------------------------
# Terraform configuration
# -------------------------------------------------------
provider "aws" {
	region		= var.region
	access_key 	= var.access_key
	secret_key	= var.secret_key
}

terraform {
	required_version = ">=1.0.8"
	backend "local"	{
		path="terraform.tfstate"
	}
}

# -------------------------------------------------------
# Region for this deployment
# -------------------------------------------------------
variable "region" {
	type    = string
}

# -------------------------------------------------------
# AWS credentials
# -------------------------------------------------------
variable "access_key" {
	type    	= string
	sensitive 	= true
}
variable "secret_key" {
	type    	= string
	sensitive 	= true
}

# -------------------------------------------------------
# Privilegied users that are allow full access to the repository
# -------------------------------------------------------
variable "account" {
	type 		= string
	sensitive 	= true
}
variable "service_principal" {
	type 		= string
	sensitive 	= true
}

output "repositories" {
	value = {
		id = module.repositories.*.registry
		arn = module.repositories.*.arn
		url = module.repositories.*.url
		key = module.repositories.*.key
	}
}
