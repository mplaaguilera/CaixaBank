public with sharing class OS_Account_Campos_COPS_Controller {

    @AuraEnabled
    public static Map<String, Object> init(Id recordId) {

        Map<String, Object> retorno = new Map<String, Object>();

        //Opciones del desplegable de carteras
        List<OT_Picklist.Item> carteras = new List<OT_Picklist.Item>();
        List<OT_Picklist.Item> carterasCentroManipulador = new List<OT_Picklist.Item>();
        
        OT_Picklist.Item wrapNinguno = new OT_Picklist.Item('', 'Ninguno');
        carteras.add(wrapNinguno);
        carterasCentroManipulador.add(wrapNinguno);
        
        for (OS_Cartera__c cartera : [SELECT Name, Recordtype.developername, OS_Activo__c FROM OS_Cartera__c WHERE Recordtype.developername = 'OS_Cartera' ORDER BY Name ASC LIMIT 100]) {
            OT_Picklist.Item wrap = new OT_Picklist.Item(cartera.Id, cartera.Name);
            carteras.add(wrap);    
        }    

        for (OS_Cartera__c centroManipulador : [SELECT Name, Recordtype.developername, OS_Activo__c FROM OS_Cartera__c 
                                                WHERE Recordtype.developername = 'OS_Centro_Manipulador' 
                                                AND OS_Activo__c = TRUE 
                                                ORDER BY Name ASC LIMIT 100]) {

            OT_Picklist.Item wrap2 = new OT_Picklist.Item(centroManipulador.Id, centroManipulador.Name);
            carterasCentroManipulador.add(wrap2);
            
        }   
        retorno.put('carteras', carteras);
        retorno.put('carterasCentroManipulador', carterasCentroManipulador);
        

        String objectId = string.valueOf(recordId);
        if (objectId.subString(0,3)=='003'){ //Si Contact

            Contact contacto = [SELECT SEG_No_enviar_Acuse_Recibo__c, recordtype.developerName  FROM Contact WHERE Id = :recordId];
            retorno.put('SEG_No_enviar_Acuse_Recibo__c', contacto.SEG_No_enviar_Acuse_Recibo__c);
            retorno.put('objectContact', 'Yes');
        }

        // system.debug('+++retorno: ' + retorno);
        else { //Si Account
            //Valores del registro
            Account cuenta = [SELECT OS_Cartera__c, OS_Premium__c, CBK_HolaBank__c, OS_Centro_Manipulador__c, SEG_No_enviar_Acuse_Recibo__pc, recordtype.developerName  FROM Account WHERE Id = :recordId];
            retorno.put('OS_Cartera__c', cuenta.OS_Cartera__c);
            retorno.put('OS_Premium__c', cuenta.OS_Premium__c);
            retorno.put('CBK_HolaBank__c', cuenta.CBK_HolaBank__c);
            retorno.put('recordtype', cuenta.recordtype.developerName);
            retorno.put('OS_Centro_Manipulador__c', cuenta.OS_Centro_Manipulador__c);
            retorno.put('SEG_No_enviar_Acuse_Recibo__pc', cuenta.SEG_No_enviar_Acuse_Recibo__pc);
            retorno.put('objectAccount', 'Yes');
        }

        return retorno;
    }

    @AuraEnabled
    public static void guardar(Id recordId, string cartera, Boolean premium, Boolean holabank, String centroManipulador) {
        Account cuenta = new Account(Id = recordId);

        if (cartera == '') {
            cuenta.OS_Cartera__c = null;
        }
        else {
            cuenta.OS_Cartera__c = cartera;
        }
        if(centroManipulador == ''){
            cuenta.OS_Centro_Manipulador__c = null;
        }
        else {
            cuenta.OS_Centro_Manipulador__c = centroManipulador;
        }
        cuenta.OS_Modificacion_Campos_COPS__c = true;
        cuenta.OS_Premium__c = premium;
        cuenta.CBK_HolaBank__c = holabank;
        update cuenta;

        cuenta.OS_Modificacion_Campos_COPS__c = false;
        update cuenta;
    }

    @AuraEnabled
    public static void guardarPA(Id recordId, String cartera, Boolean premium, Boolean acuse) {
        Account cuenta = new Account(Id = recordId);

        if (cartera == '') {
            cuenta.OS_Cartera__c = null;
        }
        else {
            cuenta.OS_Cartera__c = cartera;
        }
        cuenta.OS_Modificacion_Campos_COPS__c = true;
        cuenta.OS_Premium__c = premium;
        cuenta.SEG_No_enviar_Acuse_Recibo__pc = acuse;
        update cuenta;

        cuenta.OS_Modificacion_Campos_COPS__c = false;
        update cuenta;
    }

    @AuraEnabled
    public static void guardarContact(Id recordId, Boolean acuse) {
        Contact contacto = new Contact(Id = recordId);

        contacto.OS_Modificacion_Campos_Contact_COPS__c = true;
        contacto.SEG_No_enviar_Acuse_Recibo__c = acuse;
        update contacto;

        contacto.OS_Modificacion_Campos_Contact_COPS__c = false;
        update contacto;
    }
}