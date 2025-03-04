@isTest
public class CBK_Case_Extension_TRDisp_Test {
@TestSetup
    static void setup(){
        User thisUser;

         System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Profile perfil = [SELECT Id FROM Profile WHERE Name='SEG_Usuario_CaixaBank'];
            UserRole rol = [SELECT Id FROM UserRole WHERE Name='Segmentos + FFEE'];
            thisUser = new User(alias = 'tsegmen', email='testSEGBI@acme.com',
                emailencodingkey='UTF-8', lastname='Smith',
                languagelocalekey='en_US',
                localesidkey='en_US', profileid = perfil.Id, userroleid = rol.Id,
                timezonesidkey='America/Los_Angeles',
                username='testSEGBI@acme.com');
            insert thisUser;
            List<PermissionSetAssignment> listPermissionSetAssignment = new List<PermissionSetAssignment>();
            for (PermissionSetGroupComponent permisoUnitario : [SELECT Id, PermissionSetGroupId, PermissionSetId, PermissionSet.Name FROM PermissionSetGroupComponent WHERE PermissionSetGroup.DeveloperName IN ('SEG_Operativo','SEG_Supervisor')]){
                PermissionSetAssignment nuevoPermiso = new PermissionSetAssignment();
                nuevoPermiso.PermissionSetId = permisoUnitario.PermissionSetId;
                nuevoPermiso.AssigneeId = thisUser.id;
                listPermissionSetAssignment.add(nuevoPermiso);
            }
            if (listPermissionSetAssignment.isEmpty()){
                insert listPermissionSetAssignment;
            }
        }
        
        System.runAs ( thisUser ) {
            //Preparación de los datos
            Case caso = new Case();
            caso.Subject = 'Caso Test';
            insert caso;
        }
        
        
    }
    
    @isTest
    public static void updateTest() {
        User testUser = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];

        System.runAs (testUser) {
            String sExceptionMessage = '';

            Test.startTest();
            try{
                CBK_Case_Extension__c oCaseExtension = new CBK_Case_Extension__c();
                oCaseExtension.Name = 'Test1';
                insert oCaseExtension;
                oCaseExtension.Name = 'Test2';
                update oCaseExtension;
            }catch(Exception e){
                sExceptionMessage = e.getMessage();
                System.debug(sExceptionMessage);
            }
            Test.stopTest();
            
            System.AssertEquals(true, String.isBlank(sExceptionMessage), 'Debería no haber saltado la excepción');
        }
    }
}