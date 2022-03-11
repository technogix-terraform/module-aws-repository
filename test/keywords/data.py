# -------------------------------------------------------
# TECHNOGIX 
# -------------------------------------------------------
# Copyright (c) [2022] Technogix SARL
# All rights reserved 
# -------------------------------------------------------
# Keywords to create data for module test
# -------------------------------------------------------
# Nadège LEMPERIERE, @13 november 2021
# Latest revision: 13 november 2021
# -------------------------------------------------------

# System includes
from json import load, dumps

# Robotframework includes
from robot.libraries.BuiltIn import BuiltIn, _Misc
from robot.api import logger as logger
from robot.api.deco import keyword
ROBOT = False

# ip address manipulation
from ipaddress import IPv4Network

@keyword('Load Multiple Test Data')
def load_multiple_test_data(repositories) :
    
    result = {}
    result['repositories'] = []
    result['keys'] = []

    if len(repositories['id']) != 5 : raise Exception(str(len(repositories['id'])) + ' repositories created instead of 5')
    
    for i in range(1,5) :
        repository = {}

        repository['repositoryArn']                 = repositories['arn'][i - 1]
        repository['registryId']                    = repositories['id'][i - 1]
        repository['repositoryName']                = 'test-' + str(i) + '.test.test'
        repository['repositoryUri']                 = repositories['url'][i - 1]
        repository['imageTagMutability']            = 'IMMUTABLE'
        repository['imageScanningConfiguration']    = {'scanOnPush': True}
        repository['encryptionConfiguration']       = {'encryptionType' : 'KMS', 'kmsKey' : repositories['key'][i - 1] }
        repository['Policy']                        = {'Version': '2012-10-17', 'Statement': [{'Sid': 'AllowRootAndServicePrincipal', 'Effect': 'Allow', 'Principal': {'AWS': ['arn:aws:iam::833168553325:user/god', 'arn:aws:iam::833168553325:root']}, 'Action': 'ecr:*'}]}
        
        rules = []
        rules.append({'rulePriority': 100, 'description': 'Keep tagged images', 'selection': {'tagStatus': 'tagged', 'tagPrefixList': ['v'], 'countType': 'imageCountMoreThan', 'countNumber': 0}, 'action': {'type': 'expire'}})
        rules.append({'rulePriority': 200, 'description': 'Delete other images older than untagged_deletion_delay number of days', 'selection': {'tagStatus': 'untagged', 'countType': 'sinceImagePushed', 'countUnit': 'days', 'countNumber': 0}, 'action': {'type': 'expire'}})
        if i == 1 : 
            rules[0]['selection']['countNumber'] = 30
            rules[1]['selection']['countNumber'] = 7
        elif i == 2 : 
            rules[0]['selection']['countNumber'] = 10
            rules[1]['selection']['countNumber'] = 7
        elif i == 3 : 
            rules[0]['selection']['countNumber'] = 20
            rules[1]['selection']['countNumber'] = 10
        elif i == 4 : 
            rules[0]['selection']['countNumber'] = 30
            rules[1]['selection']['countNumber'] = 14
        elif i == 5 : 
            rules[0]['selection']['countNumber'] = 35
            rules[1]['selection']['countNumber'] = 30
        repository['Lifecycle']                     = {'rules' : rules}

        repository['Tags'] = []
        repository['Tags'].append({'Key'        : 'Version'             , 'Value' : 'test'})
        repository['Tags'].append({'Key'        : 'Project'             , 'Value' : 'test'})
        repository['Tags'].append({'Key'        : 'Module'              , 'Value' : 'test'})
        repository['Tags'].append({'Key'        : 'Environment'         , 'Value' : 'test'})
        repository['Tags'].append({'Key'        : 'Owner'               , 'Value' : 'moi.moi@moi.fr'})
        repository['Tags'].append({'Key'        : 'Name'                , 'Value' : 'test.test.test.repository.test-' + str(i)})
        
        result['repositories'].append({'name' : 'test-' + str(i), 'data' : repository})

        key = {}

        key['AWSAccountId']             = repositories['id'][i - 1]
        key['KeyId']                    = repositories['key'][i - 1].split('/')[1]
        key['Arn']                      = repositories['key'][i - 1]
        key['Enabled']                  = True
        key['KeyUsage']                 = 'ENCRYPT_DECRYPT'
        key['KeyState']                 = 'Enabled'
        key['Origin']                   = 'AWS_KMS'
        key['KeyManager']               = 'CUSTOMER'
        key['CustomerMasterKeySpec']    = 'SYMMETRIC_DEFAULT'
        key['KeySpec']                  = 'SYMMETRIC_DEFAULT'
        key['EncryptionAlgorithms']     = ['SYMMETRIC_DEFAULT']
        key['MultiRegion']              = False
        key['Policy']                   = {'Version': '2012-10-17', 'Statement': [{'Sid': 'AllowRootAndServicePrincipal', 'Effect': 'Allow', 'Principal': {'AWS': ['arn:aws:iam::833168553325:root', 'arn:aws:iam::833168553325:user/god']}, 'Action': 'kms:*', 'Resource': '*'}]} 

        key['Tags'] = []
        key['Tags'].append({'TagKey'        : 'Version'             , 'TagValue' : 'test'})
        key['Tags'].append({'TagKey'        : 'Project'             , 'TagValue' : 'test'})
        key['Tags'].append({'TagKey'        : 'Module'              , 'TagValue' : 'test'})
        key['Tags'].append({'TagKey'        : 'Environment'         , 'TagValue' : 'test'})
        key['Tags'].append({'TagKey'        : 'Owner'               , 'TagValue' : 'moi.moi@moi.fr'})
        key['Tags'].append({'TagKey'        : 'Name'                , 'TagValue' : 'test.test.test.repository.test-' + str(i) + '.key'})
        
        result['keys'].append({'name' : 'test-' + str(i), 'data' : key})

    logger.debug(dumps(result))

    return result

    