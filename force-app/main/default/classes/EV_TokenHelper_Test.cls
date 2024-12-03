/**********************************************************************************************************************
 Name:	  EV_TokenHelper_Test
 Copyright © 2024  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
* @description Clase de pruebas del EV_TokenHelper
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			        		Carolina Lopez    	08/02/2024			Init version
    1.1         FIX             Carolina Lopez      14/02/2024          add constants for credentials.
***********************************************************************************************************************/
@isTest
private class EV_TokenHelper_Test {
    private static final String EXTERNAL = 'EV_ExternalCredentials';
    private static final String CREDENTIAL_PRO = 'EV_AdobeCampaignCredentialPRO';
    private static final String CREDENTIAL_PRE = 'EV_AdobeCampaignCredentialPRE';
    private static final String ST_TOKEN = 'SFTokens';
    private static final String ST_EXPIRES = 'EXPIRES';
    private static final String ST_SESSION = 'SESSION'; 
    private static final String ST_SECURITY = 'SECURITY';
    private static final String DATE_EXPIRES = '2022-02-15 10:54:00';

    @isTest(SeeAllData=true)
    static void testCheckTokenValidity() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
        System.runAs(newUser){
            List<PermissionSetAssignment> existingAssignments = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :newUser.Id AND PermissionSet.Name =:EXTERNAL LIMIT 1];
            if(existingAssignments.isEmpty()){
                PermissionSet ps = [select id, name from PermissionSet where name =:EXTERNAL limit 1];
                PermissionSetAssignment newPermission = new PermissionSetAssignment();
                newPermission.PermissionSetId = ps.Id;
                newPermission.AssigneeId = newUser.Id;
                insert newPermission;
            }
        }
        Test.startTest();
        System.runAs(newUser){
            Test.setMock(HttpCalloutMock.class, new EV_AdobeCampaignInscripcion_Mock());
            EV_TokenHelper.getCredentialTestResults = new Map<String, Map<String, Map<ConnectApi.CredentialPrincipalType, ConnectApi.Credential>>>();
            ConnectApi.Credential cred = new ConnectApi.Credential();
            cred.externalCredential = (DomainParser.parse(DomainCreator.getOrgMyDomainHostname()).getSandboxName() == null) ? CREDENTIAL_PRO : CREDENTIAL_PRE;
            cred.principalName = ST_TOKEN;
            cred.principalType = ConnectApi.CredentialPrincipalType.NamedPrincipal;
            Map<String, ConnectApi.CredentialValue> credentialsMap = new Map<String, ConnectApi.CredentialValue>();
            ConnectApi.CredentialValue expiresValue = new ConnectApi.CredentialValue();
            expiresValue.value = DATE_EXPIRES;
            expiresValue.encrypted = false;
            credentialsMap.put(ST_EXPIRES, expiresValue);
            ConnectApi.CredentialValue sessionValue = new ConnectApi.CredentialValue();
            sessionValue.value = ST_SESSION;
            sessionValue.encrypted = false;
            credentialsMap.put(ST_SESSION, sessionValue);
            ConnectApi.CredentialValue securityValue = new ConnectApi.CredentialValue();
            securityValue.value = ST_SECURITY;
            securityValue.encrypted = false;
            credentialsMap.put(ST_SECURITY, securityValue);
            cred.credentials = credentialsMap;
            
            Map<ConnectApi.CredentialPrincipalType, ConnectApi.Credential> innerMap = new Map<ConnectApi.CredentialPrincipalType, ConnectApi.Credential>();
            innerMap.put(cred.principalType, cred);
            Map<String, Map<ConnectApi.CredentialPrincipalType, ConnectApi.Credential>> middleMap = new Map<String, Map<ConnectApi.CredentialPrincipalType, ConnectApi.Credential>>();
            middleMap.put(cred.principalName, innerMap);
            EV_TokenHelper.getCredentialTestResults.put(cred.externalCredential, middleMap);
            
            Boolean isValid = EV_TokenHelper.checkTokenValidity((DomainParser.parse(DomainCreator.getOrgMyDomainHostname()).getSandboxName() == null) ? CREDENTIAL_PRO : CREDENTIAL_PRE);
            System.assertEquals(true, isValid, 'Se esperaba que el token fuera válido');
        }
        Test.stopTest();
    }

    @isTest(SeeAllData=true)
    static void testUpdateToken() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
        System.runAs(newUser){
            List<PermissionSetAssignment> existingAssignments = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :newUser.Id AND PermissionSet.Name =:EXTERNAL LIMIT 1];
            if(existingAssignments.isEmpty()){
                PermissionSet ps = [select id, name from PermissionSet where name =:EXTERNAL limit 1];
                PermissionSetAssignment newPermission = new PermissionSetAssignment();
                newPermission.PermissionSetId = ps.Id;
                newPermission.AssigneeId = newUser.Id;
                insert newPermission;
            }
        }
        Test.startTest();
            System.runAs(newUser){
            Test.setMock(HttpCalloutMock.class, new EV_AdobeCampaignInscripcion_Mock());

            EV_TokenHelper.getCredentialTestResults = new Map<String, Map<String, Map<ConnectApi.CredentialPrincipalType, ConnectApi.Credential>>>();
            ConnectApi.Credential cred = new ConnectApi.Credential();
        	cred.externalCredential = (DomainParser.parse(DomainCreator.getOrgMyDomainHostname()).getSandboxName() == null) ? CREDENTIAL_PRO : CREDENTIAL_PRE;
            cred.principalName = ST_TOKEN;
        	cred.principalType = ConnectApi.CredentialPrincipalType.NamedPrincipal;
            cred.credentials = new Map<String, ConnectApi.CredentialValue>();

            Map<ConnectApi.CredentialPrincipalType, ConnectApi.Credential> innerMap = new Map<ConnectApi.CredentialPrincipalType, ConnectApi.Credential>();
			innerMap.put(cred.principalType, cred);
            Map<String, Map<ConnectApi.CredentialPrincipalType, ConnectApi.Credential>> middleMap = new Map<String, Map<ConnectApi.CredentialPrincipalType, ConnectApi.Credential>>();
			middleMap.put(cred.principalName, innerMap);
            EV_TokenHelper.getCredentialTestResults.put(cred.externalCredential, middleMap);
            EV_TokenHelper.updateToken((DomainParser.parse(DomainCreator.getOrgMyDomainHostname()).getSandboxName() == null) ? CREDENTIAL_PRO : CREDENTIAL_PRE, ST_SECURITY, ST_SESSION,Datetime.now().addHours(Integer.valueOF(23)));  
            ConnectApi.Credential updatedCredential = EV_TokenHelper.getCredentialTestResults.get((DomainParser.parse(DomainCreator.getOrgMyDomainHostname()).getSandboxName() == null) ? CREDENTIAL_PRO : CREDENTIAL_PRE).get(ST_TOKEN).get(ConnectApi.CredentialPrincipalType.NamedPrincipal);
            System.assertNotEquals(null, updatedCredential,'El ConnectApi.Credential no se ha actualizado correctamente');
            }
        Test.stopTest();
    }
}