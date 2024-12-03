/**********************************************************************************************************************
Name:	  CIBE_TestInitialSetup
Copyright © 2019  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase que crea los datos minimos para realizar un test:
    Genera:
        - Usuario gestor para poder utilizar System.runAs().
        - Centro de nuestro gestor de test.
        - Contacto empleado asignado al centro y cuyo usuario asociado es nuestro gestor de test.
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
VERSION		USER_STORY				    AUTHOR				DATE				Description
1.0			CIBE_TestInitialSetup		Alex	   		    17/02/2023		  	Init version
1.1			CIBE_TestInitialSetup		Alex	   		    17/02/2023		  	Factory Settings
***********************************************************************************************************************/
@IsTest
public class CIBE_TestInitialSetup {

    private static Boolean createEmployeeDataSet = true;
    
    /**
     *  Genera el set de datos por defecto con los permisos de un gestor de EMP
     */
    public static TestData setupInitialDataEMP() {
        return CIBE_TestInitialSetup.setupInitialData(
            null,
            CIBE_AppConstants.CIBE_ROLEMP,
            null,
            null,
            null,
            new List<String>{
                CIBE_AppConstants.CIBE_OPERATIVAEMP,
                CIBE_AppConstants.CIBE_CUSTOMMETADATA
            }
        );
    }

    /**
     *  Genera el set de datos por defecto con los permisos de un gestor de CIB
     */
    public static TestData setupInitialDataCIB() {
        return CIBE_TestInitialSetup.setupInitialData(
            null,
            CIBE_AppConstants.CIBE_ROLECIB,
            null,
            null,
            null,
            new List<String>{
                CIBE_AppConstants.CIBE_OPERATIVACIB,
                CIBE_AppConstants.CIBE_CUSTOMMETADATA
            }
        );
    }

    /**
     *  Genera el set de datos con los permisos indicados en el usuario gestor
     */
    public static TestData setupInitialData(List<String> listPermissionSets) {
        return CIBE_TestInitialSetup.setupInitialData(
            null,
            null,
            null,
            null,
            null,
            listPermissionSets
        );
    }

    /**
     *  Activa/Desactiva la creación del set de datos relativo al centro del usuario
     */
    public static void setCenterCreation(Boolean value) {
        createEmployeeDataSet = value;
    }

    /**
     *  Genera el set de datos con los parametros indicados
     * 
     *  @param profile    - default 'CIBE_Gestor' - DeveloperName del profile para el gestor
     *  @param role       - default 'CIBE_CIBEmpresas' - DeveloperName del role para el gestor
     *  @param externalId - default 'U0000001' - Matricula para el gestor
     *  @param centerName - default '00001 - CENTER' - DeveloperName del profile para el gestor
     *  @param numOficina - default '00001' - DeveloperName del profile para el gestor
     *  @param listPermissionSets - DeveloperNames de los permission sets para el gestor
     */
    public static TestData setupInitialData(String profile, String role, String externalId, String centerName, String numOficina, List<String> listPermissionSets) {
        profile = String.isNotBlank(profile) ? profile : CIBE_AppConstants.CIBE_GESTOR;
        role = String.isNotBlank(role) ? role : CIBE_AppConstants.CIBE_CIBEMPRESAS;
        externalId = String.isNotBlank(externalId) ? externalId : 'U0000001';
        centerName = String.isNotBlank(centerName) ? centerName : '00001 - CENTER';
        numOficina = String.isNotBlank(numOficina) ? numOficina : '00001';
        listPermissionSets = listPermissionSets != null ? listPermissionSets : new List<String>();
        
        TestData dataSet = new TestData();
        System.runAs(new User(Id = UserInfo.getUserId())) {
            System.debug('QUERY LIMITS start: ' + Limits.getQueries() + ' / ' + Limits.getLimitQueries());

            Profile p = [SELECT Id FROM Profile WHERE Name = :profile LIMIT 1];
            UserRole ur = [SELECT Id FROM UserRole WHERE DeveloperName = :role LIMIT 1];

            User user = new User(
                ProfileId = p.Id,
                UserRoleId = ur.Id,
                UserName = externalId + '@test.dev',
                LastName = externalId + '_LastName',
                Alias = externalId.abbreviate(8),
                Email = externalId + '@test.dev',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'es',
                LocaleSidKey = 'es',
                TimeZoneSidKey = 'Europe/Berlin',
                AV_NumeroOficinaEmpresa__c = '001-' + numOficina,
                AV_ExternalID__c = externalId
            );
            insert user;
            dataSet.gestor = user;

            System.debug('QUERY LIMITS user inserted: ' + Limits.getQueries() + ' / ' + Limits.getLimitQueries());
        
            if(createEmployeeDataSet) {
                RecordType rtCenter = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_ACCOUNT, CIBE_AppConstants.ACCOUNT_CENTROCAIXABANK_RT);
                Account center = new Account();
                center.Name = centerName;
                center.RecordTypeId = rtCenter.Id;
                center.CC_Numero_Oficina_Empresa__c = numOficina;
                center.CC_Numero_Oficina__c = numOficina;
                center.BillingStreet = 'Calle Centro de test';
                center.BillingPostalCode = '24210';
                insert center;
                dataSet.centro = center;

                System.debug('QUERY LIMITS center inserted: ' + Limits.getQueries() + ' / ' + Limits.getLimitQueries());

                RecordType rtEmployee = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_CONTACT, CIBE_AppConstants.EMPLOYEE_RT);
                Contact employee = new Contact();
                employee.RecordTypeId = rtEmployee.Id;
                employee.AccountId = center.Id;
                employee.AV_UsuarioAsociado__c = user.Id;
                employee.FirstName = 'Employee';
                employee.LastName = externalId;
                employee.Email = externalId + '@test.dev';
                employee.CC_Idioma__c = 'es';
                employee.CC_Matricula__c = externalId;
                employee.OwnerId = user.Id;
                insert employee;
                dataSet.empleado = employee;

                System.debug('QUERY LIMITS employee inserted: ' + Limits.getQueries() + ' / ' + Limits.getLimitQueries());
            }

            List<PermissionSetAssignment> permissionSetList = new List<PermissionSetAssignment>();
            List<PermissionSet> perSet = [SELECT Id FROM PermissionSet WHERE Name IN :listPermissionSets];
            for(PermissionSet ps : perSet) {
                permissionSetList.add(
                    new PermissionSetAssignment(
                        AssigneeId = user.Id, 
                        PermissionSetId = ps.Id
                ));
            }

            if(!permissionSetList.isEmpty()) {
                insert permissionSetList;
            }

            System.debug('QUERY LIMITS permission sets inserted: ' + Limits.getQueries() + ' / ' + Limits.getLimitQueries());
        }
        return dataSet;
    }

    public class TestData {
        public User gestor {get; set;}
        public Account centro {get; set;}
        public Contact empleado {get; set;}
    }

}