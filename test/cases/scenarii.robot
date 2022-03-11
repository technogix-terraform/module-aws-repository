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

*** Variables ***
${KEEPASS_DATABASE}                 ${vaultdatabase}
${KEEPASS_KEY}                      ${vaultkey}
${KEEPASS_GOD_KEY_ENTRY}            /engineering-environment/aws/aws-god-access-key
${KEEPASS_GOD_USERNAME}             /engineering-environment/aws/aws-god-credentials
${KEEPASS_ACCOUNT}                  /engineering-environment/aws/aws-account
${REGION}                           eu-west-1

*** Test Cases ***
Prepare Environment
    [Documentation]         Retrieve god credential from database and initialize python tests keywords
    ${god_access}           Load Keepass Database Secret            ${KEEPASS_DATABASE}     ${KEEPASS_KEY}  ${KEEPASS_GOD_KEY_ENTRY}    username
    ${god_secret}           Load Keepass Database Secret            ${KEEPASS_DATABASE}     ${KEEPASS_KEY}  ${KEEPASS_GOD_KEY_ENTRY}    password
    ${god_name}             Load Keepass Database Secret            ${KEEPASS_DATABASE}     ${KEEPASS_KEY}  ${KEEPASS_GOD_USERNAME}     username
    ${account}              Load Keepass Database Secret            ${KEEPASS_DATABASE}     ${KEEPASS_KEY}  ${KEEPASS_ACCOUNT}          password
    Initialize Terraform    ${REGION}   ${god_access}   ${god_secret}
    Initialize ECR          None        ${god_access}   ${god_secret}    ${REGION}
    Initialize KMS          None        ${god_access}   ${god_secret}    ${REGION}
    ${TF_PARAMETERS}=       Create Dictionary   account=${account}    service_principal=${god_name}
    Set Global Variable     ${TF_PARAMETERS}

Create Multiple Repositories
    [Documentation]         Create Repositories And Check That The AWS Infrastructure Match Specifications
    Launch Terraform Deployment                 ${CURDIR}/../data/multiple    ${TF_PARAMETERS}
    ${states}   Load Terraform States           ${CURDIR}/../data/multiple
    ${specs}    Load Multiple Test Data         ${states['test']['outputs']['repositories']['value']}
    Repository Shall Exist And Match            ${specs['repositories']}
    Key Shall Exist And Match                   ${specs['keys']}
    [Teardown]  Destroy Terraform Deployment    ${CURDIR}/../data/multiple    ${TF_PARAMETERS}
