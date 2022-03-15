# -------------------------------------------------------
# TECHNOGIX
# -------------------------------------------------------
# Copyright (c) [2022] Technogix SARL
# All rights reserved
# -------------------------------------------------------
# Robotframework test suite for module
# -------------------------------------------------------
# Nadège LEMPERIERE, @07 march 2022
# Latest revision: 07 march 2022
# -------------------------------------------------------


*** Settings ***
Documentation   A test case to check multiple repositories creation using module
Library         technogix_iac_keywords.terraform
Library         technogix_iac_keywords.keepass
Library         technogix_iac_keywords.ecr
Library         technogix_iac_keywords.kms
Library         ../keywords/data.py
Library         OperatingSystem

*** Variables ***
${KEEPASS_DATABASE}                 ${vaultdatabase}
${KEEPASS_KEY_ENV}                  ${vault_key_env}
${KEEPASS_PRINCIPAL_KEY_ENTRY}      /engineering-environment/aws/aws-principal-access-key
${KEEPASS_PRINCIPAL_USERNAME}       /engineering-environment/aws/aws-principal-credentials
${KEEPASS_ACCOUNT}                  /engineering-environment/aws/aws-account
${REGION}                           eu-west-1

*** Test Cases ***
Prepare Environment
    [Documentation]         Retrieve principal credential from database and initialize python tests keywords
    ${keepass_key}          Get Environment Variable          ${KEEPASS_KEY_ENV}
    ${principal_access}     Load Keepass Database Secret      ${KEEPASS_DATABASE}     ${keepass_key}  ${KEEPASS_PRINCIPAL_KEY_ENTRY}    username
    ${principal_secret}     Load Keepass Database Secret      ${KEEPASS_DATABASE}     ${keepass_key}  ${KEEPASS_PRINCIPAL_KEY_ENTRY}    password
    ${principal_name}       Load Keepass Database Secret      ${KEEPASS_DATABASE}     ${keepass_key}  ${KEEPASS_PRINCIPAL_USERNAME}     username
    ${account}              Load Keepass Database Secret      ${KEEPASS_DATABASE}     ${keepass_key}  ${KEEPASS_ACCOUNT}          password
    Initialize Terraform    ${REGION}   ${principal_access}   ${principal_secret}
    Initialize ECR          None        ${principal_access}   ${principal_secret}    ${REGION}
    Initialize KMS          None        ${principal_access}   ${principal_secret}    ${REGION}
    ${TF_PARAMETERS}=       Create Dictionary   account=${account}    service_principal=${principal_name}
    Set Global Variable     ${TF_PARAMETERS}

Create Multiple Repositories
    [Documentation]         Create Repositories And Check That The AWS Infrastructure Match Specifications
    Launch Terraform Deployment                 ${CURDIR}/../data/multiple    ${TF_PARAMETERS}
    ${states}   Load Terraform States           ${CURDIR}/../data/multiple
    ${specs}    Load Multiple Test Data         ${states['test']['outputs']['repositories']['value']}
    Repository Shall Exist And Match            ${specs['repositories']}
    Key Shall Exist And Match                   ${specs['keys']}
    [Teardown]  Destroy Terraform Deployment    ${CURDIR}/../data/multiple    ${TF_PARAMETERS}
