/*****************************************************************
 Name:  SIRE_LCMP_AsignarAnalista_Test
 Copyright © 2023  CaixaBank

Proposito:   Clase Test de la clase controladora externa del LWC SIRE_LCMP_HomeGestorPreventivo                                                                                                          

    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0                             Atmira         18/07/2023     	  Created    

*****************************************************************/
@istest
public class SIRE_LCMP_AsignarAnalista_Test {
    
    /*****************************************************************
        Proposito:  Metodo clase test                                                      
        Parameters: No
        Returns: No
        Throws [Exceptions]: No                                                          
        
        Historial
        -------- 
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                     		Atmira         18/07/2023     	  Created    
        
	*****************************************************************/    
    @Istest static void asignarAnalistaTest(){
        SIR_Constantes constantes = new SIR_Constantes();
        
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('usuarioTest',rol,'System Administrator', 'U0111111', '001-09999'); 
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SIR_PS_SSMM'];
        System.debug(ps);
        insert new PermissionSetAssignment(AssigneeId = usuario.id, PermissionSetId = ps.Id);  
        System.runAs(usuario) {  
            Account cuenta = SIR_TestDataFactory.crearCuenta();
            SIREC__SIREC_obj_proceso__c proceso = SIR_TestDataFactory.crearProceso(cuenta);  
            ID recordTypeCentro = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
            Account centro2 = new Account();
            centro2.RecordTypeId = recordTypeCentro;
            centro2.Name = 'Centro INTOUCH';
            centro2.CC_Numero_Empresa__c = '001';
            centro2.CC_Numero_Oficina__c = '09999';
            centro2.CC_Numero_Oficina_Empresa__c = '001-09999';            
            insert centro2;
            
            Account centro1 = new Account();
            centro1.RecordTypeId = recordTypeCentro;
            centro1.Name = 'D.A.N. Centro';
            centro1.CC_Numero_Empresa__c = '001';
            centro1.CC_Numero_Oficina__c = '09991';
            centro1.CC_Numero_Oficina_Empresa__c = '001-09991';
            centro1.CC_SubTipo_Centro__c = 'EM';
            centro1.AV_CentroSuperior__c = centro2.id;
            insert centro1;
            
            FinServ__ReciprocalRole__c rolCentro = new FinServ__ReciprocalRole__c();
            rolCentro.Name = 'CAR-CTO';
            rolCentro.FinServ__InverseRole__c = 'CTO-CAR';
            insert rolCentro;
            
            FinServ__AccountAccountRelation__c centroCentroRelacion = new FinServ__AccountAccountRelation__c();
            ID rtCentroCentroRelacion = Schema.SObjectType.FinServ__AccountAccountRelation__c.getRecordTypeInfosByDeveloperName().get('SIRE_Relacion_CAR_CTO').getRecordTypeId();
            centroCentroRelacion.RecordtypeId = rtCentroCentroRelacion;
            centroCentroRelacion.FinServ__Role__c = rolCentro.Id;
            centroCentroRelacion.FinServ__Account__c = centro2.Id;
            centroCentroRelacion.FinServ__RelatedAccount__c = centro1.Id;
            insert centroCentroRelacion;
            
            Contact contacto = new Contact(LastName='Test01',CC_NumPerso__c = '99999991', CC_Matricula__c='U0111111', AccountId= centro2.Id, AV_UsuarioAsociado__c= usuario.Id);
            insert contacto;
            test.startTest();
            SIRE_LCMP_AsignarAnalista.getQueryRecordTypeProceso();
            SIRE_LCMP_AsignarAnalista.getOficinaGestorActual();
            SIRE_LCMP_AsignarAnalista.getOficinas(centro2.Id);
            SIRE_LCMP_AsignarAnalista.getEmployees(centro2.Id); 
            String valueIdOwner = [SELECT OwnerId from SIREC__SIREC_obj_proceso__c where Id = :proceso.Id].OwnerId;       
            
            SIRE_LCMP_AsignarAnalista.buscarProcesos('1', '12', valueIdOwner, null, cuenta.Id, proceso.RecordTypeId);
            SIRE_LCMP_AsignarAnalista.buscarProcesos('1', '12', 'UserIntegracion', '2', cuenta.Id, proceso.RecordTypeId);
            SIRE_LCMP_AsignarAnalista.buscarProcesos('1', '12', 'Todos', '3', cuenta.Id, proceso.RecordTypeId);
        
            List<String> listaIds = new List<String>();
            listaIds.add(proceso.Id);
            String response;
            
            response = SIRE_LCMP_AsignarAnalista.changeAnalista(valueIdOwner, listaIds);  
            test.stopTest();
            System.assertEquals('OK', response, 'SIRE_LCMP_AsignarAnalista_Test.test1 No se ha obtenido la respuesta OK');
        }
    }
}