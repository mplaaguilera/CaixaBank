@isTest
public class SEG_Grupo_Colaborador_TRHan_Test{
    //User operativo = SEG_Usuarios.usuarioOperativo();
    //User supervisor = SEG_Usuarios.usuarioSupervisor();

    /**
     * @description   Preparación de los datos.
     */
    @testSetup
    public static void testSetup() 
    {
        User userA = SEG_TestHelper.createUser('UsA');
        User userB = SEG_TestHelper.createUser('UsB');
        CC_Grupo_Colaborador__c grupoColaboradorA = SEG_TestHelper.createGrupoColaborador('BO_TESTApex1', 'SEGMENTOS', 'BO');
        CC_Grupo_Colaborador__c grupoColaboradorB = SEG_TestHelper.createGrupoColaborador('BO_TESTApex2', 'SEGMENTOS', 'BO');
        CC_Grupo_Colaborador__c grupoColaboradorC = SEG_TestHelper.createGrupoColaborador('BO_TESTApex3', 'SEGMENTOS', 'BO');
        CC_Grupo_Colaborador_Contact__c colaboradorA = SEG_TestHelper.createColaborador(grupoColaboradorA, 'Escritura', userA);
        CC_Grupo_Colaborador_Contact__c colaboradorB = SEG_TestHelper.createColaborador(grupoColaboradorA, 'Escritura', userB);
        SEG_TestHelper.createCaseTeamTemplate(grupoColaboradorC.Name,grupoColaboradorC.Id);
        
                System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Profile perfil = [SELECT Id FROM Profile WHERE Name='SEG_Usuario_CaixaBank'];
            UserRole rol = [SELECT Id FROM UserRole WHERE Name='Sistemática Comercial'];
            String orgId = UserInfo.getOrganizationId();
            String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
            Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
            String uniqueName = orgId + dateString + randomInt;
            User thisUser = new User(alias = 'user2', email='testSEGBI2@acme.com',
                emailencodingkey='UTF-8', lastname='Smith',
                languagelocalekey='en_US',
                localesidkey='en_US', profileid = perfil.Id, userroleid = rol.Id,
                timezonesidkey='America/Los_Angeles',
                Username = uniqueName + '@test' + orgId + '.org');
            insert thisUser;
            List<PermissionSetAssignment> listPermissionSetAssignment = new List<PermissionSetAssignment>();
            for (PermissionSetGroupComponent permisoUnitario : [SELECT Id, PermissionSetGroupId, PermissionSetId, PermissionSet.Name FROM PermissionSetGroupComponent WHERE PermissionSetGroup.DeveloperName IN ('CBK_Framework_Login','CBK_Framework_Admin')]){
                PermissionSetAssignment nuevoPermiso = new PermissionSetAssignment();
                nuevoPermiso.PermissionSetId = permisoUnitario.PermissionSetId;
                nuevoPermiso.AssigneeId = thisUser.id;
                listPermissionSetAssignment.add(nuevoPermiso);
            }
            if (listPermissionSetAssignment.isEmpty()){
                insert listPermissionSetAssignment;
            }
            Profile perfil2 = [SELECT Id FROM Profile WHERE Name='SEG_Usuario_CaixaBank'];
            UserRole rol2 = [SELECT Id FROM UserRole WHERE Name='Segmentos + FFEE'];
            User thisUser2 = new User(alias = 'tsegmen', email='testSEGBI@acme.com',
                emailencodingkey='UTF-8', lastname='Smith',
                languagelocalekey='en_US',
                localesidkey='en_US', profileid = perfil2.Id, userroleid = rol2.Id,
                timezonesidkey='America/Los_Angeles',
                username='testSEGBI@acme.com');
            insert thisUser2;
            List<PermissionSetAssignment> listPermissionSetAssignment2 = new List<PermissionSetAssignment>();
            for (PermissionSetGroupComponent permisoUnitario : [SELECT Id, PermissionSetGroupId, PermissionSetId, PermissionSet.Name FROM PermissionSetGroupComponent WHERE PermissionSetGroup.DeveloperName IN ('SEG_Operativo','SEG_Supervisor')]){
                PermissionSetAssignment nuevoPermiso = new PermissionSetAssignment();
                nuevoPermiso.PermissionSetId = permisoUnitario.PermissionSetId;
                nuevoPermiso.AssigneeId = thisUser.id;
                listPermissionSetAssignment2.add(nuevoPermiso);
            }
            if (listPermissionSetAssignment2.isEmpty()){
                insert listPermissionSetAssignment2;
            }
        }

    }
    
    /* No existe este desarrollo en prod
    @isTest
    private static void testInserts() {
        List<CC_Grupo_Colaborador__c> lstGrupos = new List<CC_Grupo_Colaborador__c>();

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {

        Test.startTest();
        CC_Grupo_Colaborador__c grupoTratamiento2 = new CC_Grupo_Colaborador__c();
        grupoTratamiento2.SEG_Organizacion__c = 'Banca Corporativa';
        grupoTratamiento2.SEG_Zona__c = 'Corporativa';
        lstGrupos.add(grupoTratamiento2);
        
        CC_Grupo_Colaborador__c grupoTratamiento3 = new CC_Grupo_Colaborador__c();
        grupoTratamiento3.SEG_Organizacion__c = 'Centro Empresas';
        grupoTratamiento3.SEG_Zona__c = 'Corporativa';
        lstGrupos.add(grupoTratamiento3);
        
        CC_Grupo_Colaborador__c grupoTratamiento4 = new CC_Grupo_Colaborador__c();
        grupoTratamiento4.SEG_Organizacion__c = 'Instituciones';
        grupoTratamiento4.SEG_Zona__c = 'Corporativa';
        lstGrupos.add(grupoTratamiento4);
        
        CC_Grupo_Colaborador__c grupoTratamiento5 = new CC_Grupo_Colaborador__c();
        grupoTratamiento5.SEG_Organizacion__c = 'Centro Soporte Especialistas';
        grupoTratamiento5.SEG_Zona__c = 'Corporativa';
        lstGrupos.add(grupoTratamiento5);
        
        CC_Grupo_Colaborador__c grupoTratamiento6 = new CC_Grupo_Colaborador__c();
        grupoTratamiento6.SEG_Organizacion__c = 'Financiación Estructurada';
        grupoTratamiento6.SEG_Zona__c = 'Corporativa';
        lstGrupos.add(grupoTratamiento6);
        
        CC_Grupo_Colaborador__c grupoTratamiento7 = new CC_Grupo_Colaborador__c();
        grupoTratamiento7.SEG_Organizacion__c = null;
        grupoTratamiento7.SEG_Zona__c = null;
        lstGrupos.add(grupoTratamiento7);
        
        CC_Grupo_Colaborador__c grupoTratamiento8 = new CC_Grupo_Colaborador__c();
        grupoTratamiento8.SEG_Organizacion__c = 'Instituciones';
        grupoTratamiento8.SEG_Zona__c = 'Empresas Barcelona';
        lstGrupos.add(grupoTratamiento8);
        
        CC_Grupo_Colaborador__c grupoTratamiento9 = new CC_Grupo_Colaborador__c();
        grupoTratamiento9.SEG_Organizacion__c = 'Instituciones';
        grupoTratamiento9.SEG_Zona__c = 'Empresas Castilla La Mancha';
        lstGrupos.add(grupoTratamiento9);
        
        CC_Grupo_Colaborador__c grupoTratamiento10 = new CC_Grupo_Colaborador__c();
        grupoTratamiento10.SEG_Organizacion__c = 'Instituciones';
        grupoTratamiento10.SEG_Zona__c = 'Empresas Cataluña';
        lstGrupos.add(grupoTratamiento10);
        
        CC_Grupo_Colaborador__c grupoTratamiento11 = new CC_Grupo_Colaborador__c();
        grupoTratamiento11.SEG_Organizacion__c = 'Instituciones';
        grupoTratamiento11.SEG_Zona__c = 'Empresas Madrid';
        lstGrupos.add(grupoTratamiento11);
        
        CC_Grupo_Colaborador__c grupoTratamiento12 = new CC_Grupo_Colaborador__c();
        grupoTratamiento12.SEG_Organizacion__c = 'Instituciones';
        grupoTratamiento12.SEG_Zona__c = 'Empresas Valencia';
        lstGrupos.add(grupoTratamiento12);
        
        CC_Grupo_Colaborador__c grupoTratamiento13 = new CC_Grupo_Colaborador__c();
        grupoTratamiento13.SEG_Organizacion__c = 'Instituciones';
        grupoTratamiento13.SEG_Zona__c = 'Empresas Canarias';
        lstGrupos.add(grupoTratamiento13);
        
        CC_Grupo_Colaborador__c grupoTratamiento14 = new CC_Grupo_Colaborador__c();
        grupoTratamiento14.SEG_Organizacion__c = 'Instituciones';
        grupoTratamiento14.SEG_Zona__c = 'Instituciones Centro';
        lstGrupos.add(grupoTratamiento14);
        
        CC_Grupo_Colaborador__c grupoTratamiento15 = new CC_Grupo_Colaborador__c();
        grupoTratamiento15.SEG_Organizacion__c = 'Instituciones';
        grupoTratamiento15.SEG_Zona__c = 'Instituciones Este';
        lstGrupos.add(grupoTratamiento15);
        
        CC_Grupo_Colaborador__c grupoTratamiento16 = new CC_Grupo_Colaborador__c();
        grupoTratamiento16.SEG_Organizacion__c = 'Instituciones';
        grupoTratamiento16.SEG_Zona__c = 'Instituciones Norte';
        lstGrupos.add(grupoTratamiento16);
        
        CC_Grupo_Colaborador__c grupoTratamiento17 = new CC_Grupo_Colaborador__c();
        grupoTratamiento17.SEG_Organizacion__c = 'Instituciones';
        grupoTratamiento17.SEG_Zona__c = 'Instituciones Sur';
        lstGrupos.add(grupoTratamiento17);
        
        CC_Grupo_Colaborador__c grupoTratamiento18 = new CC_Grupo_Colaborador__c();
        grupoTratamiento18.SEG_Organizacion__c = 'Instituciones';
        grupoTratamiento18.SEG_Zona__c = 'CSE';
        lstGrupos.add(grupoTratamiento18);
        
        CC_Grupo_Colaborador__c grupoTratamiento19 = new CC_Grupo_Colaborador__c();
        grupoTratamiento19.SEG_Organizacion__c = 'Instituciones';
        grupoTratamiento19.SEG_Zona__c = 'Créditos Sindicados';
        lstGrupos.add(grupoTratamiento19);
        
        insert lstGrupos;
        
        Map<ID, CC_Grupo_Colaborador__c> mapGrupos = new Map<ID, CC_Grupo_Colaborador__c>();
        for(CC_Grupo_Colaborador__c grupo : lstGrupos){
            mapGrupos.put(grupo.Id,grupo);
        }
        
        SEG_Grupo_Colaborador_BI_TRHan.asignarOrgZona(mapGrupos);
        Test.stopTest();

        System.assertNotEquals(null , lstGrupos,'lstGrupos viene vacío');
        }
    }*/
    
    @isTest
    private static void test1() {
        User supervisor = SEG_Usuarios.usuarioSupervisor();

        CC_Grupo_Colaborador__c grupoTratamiento = [SELECT Id, Name, SEG_Inactivo__c, SEG_EquipoCaso__c FROM CC_Grupo_Colaborador__c where name='BO_TESTApex1'];
        
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Test.startTest();
            grupoTratamiento.SEG_Organizacion__c = 'Banca Corporativa;Centro Empresas;Instituciones;Centro Soporte Especialistas;Financiación Estructurada';
            grupoTratamiento.SEG_Zona__c = 'Corporativa';
            update grupoTratamiento;
            Test.stopTest();

            System.assertNotEquals(null , grupoTratamiento,'GrupoTratamiento viene vacío');
        }
    }
    
    @isTest
    private static void test6() {
        User supervisor = SEG_Usuarios.usuarioSupervisor();

        CC_Grupo_Colaborador__c grupoTratamiento = [SELECT Id, Name, SEG_Inactivo__c, SEG_EquipoCaso__c FROM CC_Grupo_Colaborador__c where name='BO_TESTApex1'];
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {      
            Test.startTest();
            grupoTratamiento.SEG_Organizacion__c = null;
            grupoTratamiento.SEG_Zona__c = 'Corporativa';
            update grupoTratamiento;
            Test.stopTest();

            System.assertNotEquals(null , grupoTratamiento,'GrupoTratamiento viene vacío');
        }
    }
    
    @isTest
    private static void test2() {
        User supervisor = SEG_Usuarios.usuarioSupervisor();

        CC_Grupo_Colaborador__c grupoTratamiento = [SELECT Id, Name, SEG_Inactivo__c, SEG_EquipoCaso__c FROM CC_Grupo_Colaborador__c where name='BO_TESTApex1'];
        
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Test.startTest();
            grupoTratamiento.SEG_Organizacion__c = 'Instituciones';
            grupoTratamiento.SEG_Zona__c = 'Empresas Barcelona;Empresas Castilla La Mancha;Empresas Cataluña;Empresas Madrid;Empresas Valencia;Instituciones Canarias;Instituciones Centro';
            update grupoTratamiento;
            Test.stopTest();

            System.assertNotEquals(null , grupoTratamiento,'GrupoTratamiento viene vacío');
        }
    }
    
    @isTest
    private static void test3() {
        User supervisor = SEG_Usuarios.usuarioSupervisor();

        CC_Grupo_Colaborador__c grupoTratamiento = [SELECT Id, Name, SEG_Inactivo__c, SEG_EquipoCaso__c FROM CC_Grupo_Colaborador__c where name='BO_TESTApex1'];
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Test.startTest();
            grupoTratamiento.SEG_Organizacion__c = 'Instituciones';
            grupoTratamiento.SEG_Zona__c = 'Instituciones Este;Instituciones Norte;Instituciones Sur;CSE;Créditos Sindicados';
            update grupoTratamiento;
            Test.stopTest();

            System.assertNotEquals(null , grupoTratamiento,'GrupoTratamiento viene vacío');
        }
    }
    
    @isTest
    private static void test26() {
        User supervisor = SEG_Usuarios.usuarioSupervisor();

        CC_Grupo_Colaborador__c grupoTratamiento = [SELECT Id, Name, SEG_Inactivo__c, SEG_EquipoCaso__c FROM CC_Grupo_Colaborador__c where name='BO_TESTApex1'];
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Test.startTest();
            grupoTratamiento.SEG_Organizacion__c = 'Instituciones';
            grupoTratamiento.SEG_Zona__c = null;
            update grupoTratamiento;
            Test.stopTest();

            System.assertNotEquals(null , grupoTratamiento,'GrupoTratamiento viene vacío');
        }
    }
    
    @isTest
    public static void insertTest(){
 
        
        User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Email = 'testSEGBI2@acme.com' LIMIT 1];
        Test.startTest();
        System.runAs (usuarioTest){ 
            CC_Grupo_Colaborador__c car = new CC_Grupo_Colaborador__c();
            car.Name = 'TEST';
            insert car;
        }
        Test.stopTest();
        CC_Grupo_Colaborador__c carTrasInsert = [SELECT Id, OS_Negocio__c,SEG_GrupoSegmentos__c FROM CC_Grupo_Colaborador__c LIMIT 1];
        System.assertEquals('SEGMENTOS' , carTrasInsert.OS_Negocio__c,'El caso no se ha insertado correctamente');
    }
    
       @isTest
    public static void updateTest() {
        // Obtener un usuario con permisos adecuados
        User usuarioTest = [SELECT Id FROM User WHERE Email = 'testSEGBI2@acme.com' LIMIT 1];

        // Verificar acceso al registro antes de modificarlo
        CC_Grupo_Colaborador__c grupoTratamiento = [SELECT Id, Name FROM CC_Grupo_Colaborador__c WHERE Name='BO_TESTApex1' LIMIT 1];

        // Compartir el registro con el usuario de prueba
        CC_Grupo_Colaborador__Share shareRecord = new CC_Grupo_Colaborador__Share();
        shareRecord.ParentId = grupoTratamiento.Id;
        shareRecord.UserOrGroupId = usuarioTest.Id;
        shareRecord.AccessLevel = 'Edit';
        insert shareRecord;

        Test.startTest();
        System.runAs(usuarioTest) { 
            grupoTratamiento.Name = 'TEST';
            update grupoTratamiento;
        }
        Test.stopTest();
        CC_Grupo_Colaborador__c carTrasInsert = [SELECT Id, OS_Negocio__c,SEG_GrupoSegmentos__c FROM CC_Grupo_Colaborador__c LIMIT 1];
        System.assertEquals('SEGMENTOS' , carTrasInsert.OS_Negocio__c,'El caso no se ha insertado correctamente');
    }
}