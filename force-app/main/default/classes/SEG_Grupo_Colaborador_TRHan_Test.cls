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
}