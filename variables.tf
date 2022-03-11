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

terraform {
	experiments = [ module_variable_optional_attrs ]
}

# -------------------------------------------------------
# Contact e-mail for this deployment
# -------------------------------------------------------
variable "email" {
	type 	= string
}

# -------------------------------------------------------
# Environment for this deployment (prod, preprod, ...)
# -------------------------------------------------------
variable "environment" {
	type 	= string
}

# -------------------------------------------------------
# Topic context for this deployment
# -------------------------------------------------------
variable "project" {
	type    = string
}
variable "module" {
	type 	= string
}

# -------------------------------------------------------
# Solution version
# -------------------------------------------------------
variable "git_version" {
	type    = string
	default = "unmanaged"
}

# -------------------------------------------------------
# Repository name
# -------------------------------------------------------
variable "name" {
	type    = string
	nullable = false 
}

# --------------------------------------------------------
# ECR repository access rights + Service principal and account
# to ensure root and service principal can access
# --------------------------------------------------------
variable "rights" {
	type = list(object({
		description = string,
		actions 	= list(string)
		principal 	= object({
			aws 		= optional(list(string))
			services 	= optional(list(string))
		})
	}))
	default = null
}
variable "service_principal" {
	type = string
	nullable = false 
}
variable "account" {
	type = string
	nullable = false 
}

# --------------------------------------------------------
# ECR lifecycle policy parameters
# --------------------------------------------------------
variable "lifecycles" {
	type = object({
		max_tagged_images = number,
		untagged_deletion_delay = number
	})
	default = {
		max_tagged_images = 30,
		untagged_deletion_delay = 7
	}
	nullable = false 
}