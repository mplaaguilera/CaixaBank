@IsTest
public class CC_Trazabilidad_Methods_Test {
  
    @isTest
    static void altaPeticion() {
        Id recordTem = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id recordProd = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id recordMot = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
                
        CC_MCC__c mcc = new CC_MCC__c();
        mcc.RecordTypeId = recordTem;
        mcc.Name = 'App\'s';
        mcc.CC_Tipo_Cliente__c = 'Cliente';
        mcc.CC_Codigo_Externo__c = 'TE-000001';
        mcc.CC_Canal_Operativo__c = 'Sin canal';
        insert mcc;
        CC_MCC__c tem = [SELECT Id FROM CC_MCC__c WHERE Name='App\'s' LIMIT 1];
        CC_MCC__c mcc1 = new CC_MCC__c();
        mcc1.RecordTypeId = recordProd;
        mcc1.Name = 'APP CaixaBank';
        mcc1.CC_Detalle__c = 'CaixaBank';
        mcc1.CC_Tipo_Cliente__c = 'Cliente';
        mcc1.CC_Tematica__c = tem.Id;
        mcc1.CC_Codigo_Externo__c = 'PR-000001';
        insert mcc1;
    //'APP BrokerNow','APP CaixaBank','APP CaixaBank Pay','APP CaixaBank Sign','App imaginBank'
        CC_MCC__c prod = [SELECT Id FROM CC_MCC__c WHERE Name='APP CaixaBank' LIMIT 1];
        CC_MCC__c mcc2 = new CC_MCC__c();
        mcc2.RecordTypeId = recordMot;
        mcc2.Name = 'Valoración positiva';
        mcc2.CC_Tipo_Cliente__c = 'Cliente';
        mcc2.CC_Producto_Servicio__c = prod.Id;
        mcc2.CC_Codigo_Externo__c = 'MO-000001';
        insert mcc2;  
    CC_MCC__c motiv = [SELECT Id FROM CC_MCC__c WHERE Name='Valoración positiva' LIMIT 1];
             
        Case c1 = new Case();
        c1.Subject = 'Prueba';
        c1.CC_Idioma__c = 'es';
        c1.CC_NumPerso__c = '123456';
        c1.CC_Tipo_Cliente__c = 'Cliente';
        c1.Status = 'Activo';
        c1.Origin = 'Email';
    c1.CC_Tipo_Contacto__c = 'Consulta';
        c1.CC_Canal_Procedencia__c = 'Atención al Cliente';
        c1.CC_MCC_Motivo__c = motiv.Id;
    c1.CC_MCC_ProdServ__c = prod.Id;
        c1.CC_MCC_Tematica__c = tem.Id;
        insert c1;
                
        CC_Trazabilidad__c TRZ = new CC_Trazabilidad__c();
        TRZ.CC_Estado__c = 'Activo';
        TRZ.CC_Id_Peticion__c = c1.Id;
        TRZ.CC_Tipo_de_Registro__c = 'Alta';
        TRZ.CC_Control_Envio__c = 'Pdte. Envio';
        insert TRZ;
        
        List<Id> ListCaseId = new List<Id>();
    ListCaseId.add(c1.Id);
        CC_Trazabilidad_Methods.altaPeticion(ListCaseId);
    }
    
    @isTest
    static void altaPeticionEnviado() {
        Id recordTem = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id recordProd = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id recordMot = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
                
        CC_MCC__c mcc = new CC_MCC__c();
        mcc.RecordTypeId = recordTem;
        mcc.Name = 'App\'s';
        mcc.CC_Tipo_Cliente__c = 'Cliente';
        mcc.CC_Codigo_Externo__c = 'TE-000001';
        mcc.CC_Canal_Operativo__c = 'Sin canal';
        insert mcc;
        CC_MCC__c tem = [SELECT Id FROM CC_MCC__c WHERE Name='App\'s' LIMIT 1];
        CC_MCC__c mcc1 = new CC_MCC__c();
        mcc1.RecordTypeId = recordProd;
        mcc1.Name = 'APP CaixaBank';
        mcc1.CC_Detalle__c = 'CaixaBank';
        mcc1.CC_Tipo_Cliente__c = 'Cliente';
        mcc1.CC_Tematica__c = tem.Id;
        mcc1.CC_Codigo_Externo__c = 'PR-000001';
        insert mcc1;
    //'APP BrokerNow','APP CaixaBank','APP CaixaBank Pay','APP CaixaBank Sign','App imaginBank'
        CC_MCC__c prod = [SELECT Id FROM CC_MCC__c WHERE Name='APP CaixaBank' LIMIT 1];
        CC_MCC__c mcc2 = new CC_MCC__c();
        mcc2.RecordTypeId = recordMot;
        mcc2.Name = 'Valoración positiva';
        mcc2.CC_Tipo_Cliente__c = 'Cliente';
        mcc2.CC_Producto_Servicio__c = prod.Id;
        mcc2.CC_Codigo_Externo__c = 'MO-000001';
        insert mcc2;  
    CC_MCC__c motiv = [SELECT Id FROM CC_MCC__c WHERE Name='Valoración positiva' LIMIT 1];
             
        Case c1 = new Case();
        c1.Subject = 'Prueba';
        c1.CC_Idioma__c = 'es';
        c1.CC_NumPerso__c = '123456';
        c1.CC_Tipo_Cliente__c = 'Cliente';
        c1.Status = 'Activo';
        c1.Origin = 'Email';
    c1.CC_Tipo_Contacto__c = 'Consulta';
        c1.CC_Canal_Procedencia__c = 'Atención al Cliente';
        c1.CC_MCC_Motivo__c = motiv.Id;
    c1.CC_MCC_ProdServ__c = prod.Id;
        c1.CC_MCC_Tematica__c = tem.Id;
        insert c1;
                
        CC_Trazabilidad__c TRZ = new CC_Trazabilidad__c();
        TRZ.CC_Estado__c = 'Activo';
        TRZ.CC_Id_Peticion__c = c1.Id;
        TRZ.CC_Tipo_de_Registro__c = 'Alta';
        TRZ.CC_Control_Envio__c = 'Enviado';
        insert TRZ;
        
        List<Id> ListCaseId = new List<Id>();
    ListCaseId.add(c1.Id);
        CC_Trazabilidad_Methods.altaPeticion(ListCaseId);
    }
    
    @isTest
    static void reapertura() {
        Id recordTem = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id recordProd = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id recordMot = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
                
        CC_MCC__c mcc = new CC_MCC__c();
        mcc.RecordTypeId = recordTem;
        mcc.Name = 'App\'s';
        mcc.CC_Tipo_Cliente__c = 'Cliente';
        mcc.CC_Codigo_Externo__c = 'TE-000001';
        mcc.CC_Canal_Operativo__c = 'Sin canal';
        insert mcc;
        CC_MCC__c tem = [SELECT Id FROM CC_MCC__c WHERE Name='App\'s' LIMIT 1];
        CC_MCC__c mcc1 = new CC_MCC__c();
        mcc1.RecordTypeId = recordProd;
        mcc1.Name = 'APP CaixaBank';
        mcc1.CC_Detalle__c = 'CaixaBank';
        mcc1.CC_Tipo_Cliente__c = 'Cliente';
        mcc1.CC_Tematica__c = tem.Id;
        mcc1.CC_Codigo_Externo__c = 'PR-000001';
        insert mcc1;
    //'APP BrokerNow','APP CaixaBank','APP CaixaBank Pay','APP CaixaBank Sign','App imaginBank'
        CC_MCC__c prod = [SELECT Id FROM CC_MCC__c WHERE Name='APP CaixaBank' LIMIT 1];
        CC_MCC__c mcc2 = new CC_MCC__c();
        mcc2.RecordTypeId = recordMot;
        mcc2.Name = 'Valoración positiva';
        mcc2.CC_Tipo_Cliente__c = 'Cliente';
        mcc2.CC_Producto_Servicio__c = prod.Id;
        mcc2.CC_Codigo_Externo__c = 'MO-000001';
        insert mcc2;  
    CC_MCC__c motiv = [SELECT Id FROM CC_MCC__c WHERE Name='Valoración positiva' LIMIT 1];
             
        Case c1 = new Case();
        c1.Subject = 'Prueba';
        c1.CC_Idioma__c = 'es';
        c1.CC_NumPerso__c = '123456';
        c1.CC_Tipo_Cliente__c = 'Cliente';
        c1.Status = 'Cerrado';
        c1.Origin = 'Email';
    c1.CC_Tipo_Contacto__c = 'Consulta';
        c1.CC_Canal_Procedencia__c = 'Atención al Cliente';
        c1.CC_MCC_Motivo__c = motiv.Id;
    c1.CC_MCC_ProdServ__c = prod.Id;
        c1.CC_MCC_Tematica__c = tem.Id;
        c1.CC_Detalles_Consulta__c = 'pruebas';
        c1.CC_Detalles_Solucion__c = 'pruebas';
        insert c1;
                
        CC_Trazabilidad__c TRZ = new CC_Trazabilidad__c();
        TRZ.CC_Estado__c = 'Activo';
        TRZ.CC_Id_Peticion__c = c1.Id;
        TRZ.CC_Tipo_de_Registro__c = 'Alta';
        TRZ.CC_Control_Envio__c = 'Enviado';
        insert TRZ;
        
        c1.Status = 'Activo';
        c1.CC_Fecha_Reapertura__c = Datetime.valueOf(System.now());
        c1.CC_Tramo_TRZ__c = 'Resuelta - En redaccion';
        update c1;
        
        //Trazabilidad en reapertura
        CC_Trazabilidad_Methods.reapretura('Resolucion', c1.Id);
        CC_Trazabilidad_Methods.reapretura('Asignacion', c1.Id);
    }    
        
    @isTest
    static void cierre() {
        Id recordTem = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id recordProd = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id recordMot = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
                
        CC_MCC__c mcc = new CC_MCC__c();
        mcc.RecordTypeId = recordTem;
        mcc.Name = 'App\'s';
        mcc.CC_Tipo_Cliente__c = 'Cliente';
        mcc.CC_Codigo_Externo__c = 'TE-000001';
        mcc.CC_Canal_Operativo__c = 'Sin canal';
        insert mcc;
        CC_MCC__c tem = [SELECT Id FROM CC_MCC__c WHERE Name='App\'s' LIMIT 1];
        CC_MCC__c mcc1 = new CC_MCC__c();
        mcc1.RecordTypeId = recordProd;
        mcc1.Name = 'APP CaixaBank';
        mcc1.CC_Detalle__c = 'CaixaBank';
        mcc1.CC_Tipo_Cliente__c = 'Cliente';
        mcc1.CC_Tematica__c = tem.Id;
        mcc1.CC_Codigo_Externo__c = 'PR-000001';
        insert mcc1;
    //'APP BrokerNow','APP CaixaBank','APP CaixaBank Pay','APP CaixaBank Sign','App imaginBank'
        CC_MCC__c prod = [SELECT Id FROM CC_MCC__c WHERE Name='APP CaixaBank' LIMIT 1];
        CC_MCC__c mcc2 = new CC_MCC__c();
        mcc2.RecordTypeId = recordMot;
        mcc2.Name = 'Valoración positiva';
        mcc2.CC_Tipo_Cliente__c = 'Cliente';
        mcc2.CC_Producto_Servicio__c = prod.Id;
        mcc2.CC_Codigo_Externo__c = 'MO-000001';
        insert mcc2;  
    CC_MCC__c motiv = [SELECT Id FROM CC_MCC__c WHERE Name='Valoración positiva' LIMIT 1];
             
        Case c1 = new Case();
        c1.Subject = 'Prueba';
        c1.CC_Idioma__c = 'es';
        c1.CC_NumPerso__c = '123456';
        c1.CC_Tipo_Cliente__c = 'Cliente';
        c1.Status = 'Cerrado';
        c1.Origin = 'Email';
    c1.CC_Tipo_Contacto__c = 'Consulta';
        c1.CC_Canal_Procedencia__c = 'Atención al Cliente';
        c1.CC_MCC_Motivo__c = motiv.Id;
    c1.CC_MCC_ProdServ__c = prod.Id;
        c1.CC_MCC_Tematica__c = tem.Id;
        c1.CC_Detalles_Consulta__c = 'pruebas';
        c1.CC_Detalles_Solucion__c = 'pruebas';
        c1.CC_Tramo_TRZ__c = 'Resuelta - En redaccion';
        insert c1;
                
        CC_Trazabilidad__c TRZ = new CC_Trazabilidad__c();
        TRZ.CC_Estado__c = 'Activo';
        TRZ.CC_Id_Peticion__c = c1.Id;
        TRZ.CC_Tipo_de_Registro__c = 'Alta';
        TRZ.CC_Control_Envio__c = 'Enviado';
        insert TRZ;
        
        List<Id> LCasos = new List<Id>();
        LCasos.add(c1.Id);
        
        //Trazabilidad
        CC_Trazabilidad_Methods.altaPaso('Resolucion', '', LCasos);
        CC_Trazabilidad_Methods.altaPaso('Cierre',     '', LCasos);
        CC_Trazabilidad_Methods.bajaAviso('I', 'CC_AVISREAPERTURA', c1.Id);
        
    }
    
    
    private void asignacionTRZ(Map<Id, Case> mapOldObj, List<Case> listNewObj) {
        List<Id> casosAsignacion = new List<Id>();
        List<Id> casosResolucion = new List<Id>();
        List<Id> casosCierre = new List<Id>();

        for (Case caso : listNewObj) {
            //Asignacion del caso
            if (caso.OwnerId != mapOldObj.get(caso.Id).OwnerId && caso.CC_Fecha_Reapertura__c == null && caso.CC_Fecha_Limite_Resolucion__c != null) {
                caso.CC_Tramo_TRZ__c = 'Asignada - En gestion';
                casosAsignacion.add(caso.Id);
            }
            //Resolucion y Cierre
            if (caso.Status == 'Cerrado' && mapOldObj.get(caso.Id).Status != 'Cerrado' && caso.CC_Fecha_Limite_Resolucion__c != null) {
                caso.CC_Tramo_TRZ__c = 'Cerrada';
                casosResolucion.add(caso.Id);
                casosCierre.add(caso.Id);
            } else if (caso.Status == 'Rechazado' && mapOldObj.get(caso.Id).Status != 'Rechazado' && caso.CC_Fecha_Limite_Resolucion__c != null) { //Rechazo
                caso.CC_Tramo_TRZ__c = 'Cerrada';
                casosCierre.add(caso.Id);
            }
        }
        if (casosAsignacion.size() > 0) {
            CC_Trazabilidad_Methods.altaPaso('Asignacion', '', casosAsignacion);
        }
        if (casosResolucion.size() > 0) {
            CC_Trazabilidad_Methods.altaPaso('Resolucion', '', casosResolucion);
        }
        if (casosCierre.size() > 0) {
            CC_Trazabilidad_Methods.altaPaso('Cierre',     '', casosCierre);
        }
        
    }
    
    
    
    @isTest
    static void bajaPeticionTest() {             
        Case c1 = new Case();
        c1.Subject = 'Prueba';
        c1.CC_Idioma__c = 'es';
        c1.CC_NumPerso__c = '123456';
        c1.CC_Tipo_Cliente__c = 'Cliente';
        c1.Status = 'Cerrado';
        c1.Origin = 'Email';
    c1.CC_Tipo_Contacto__c = 'Consulta';
        c1.CC_Canal_Procedencia__c = 'Atención al Cliente';
        c1.CC_Detalles_Consulta__c = 'pruebas';
        c1.CC_Detalles_Solucion__c = 'pruebas';
        c1.CC_Tramo_TRZ__c = 'Resuelta - En redaccion';
        insert c1;
                
        CC_Trazabilidad__c TRZ = new CC_Trazabilidad__c();
        TRZ.CC_Estado__c = 'Activo';
        TRZ.CC_Id_Peticion__c = c1.Id;
        TRZ.CC_Tipo_de_Registro__c = 'Alta';
        TRZ.CC_Control_Envio__c = 'Enviado';
        insert TRZ;
    CC_Trazabilidad_Methods.bajaPeticion(c1.Id);
       
    }
    
    
}