# -------------------------------------------------------
# TECHNOGIX
# -------------------------------------------------------
# Copyright (c) [2022] Technogix SARL
# All rights reserved
# -------------------------------------------------------
# Module to deploy an ecr repository with all the secure 
# components required
# -------------------------------------------------------
# Nadège LEMPERIERE, @12 november 2021
# Latest revision: 12 november 2021
# -------------------------------------------------------

output "arn" {
    value = aws_ecr_repository.repository.arn
}

output "registry" {
    value = aws_ecr_repository.repository.registry_id
}

output "url" {
    value = aws_ecr_repository.repository.repository_url
}

output "key" {
    value = aws_kms_key.repository.arn
}