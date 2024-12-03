/**********************************************************************************************************************
 Name:	  CIBE_OpportunityTFButton
 Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
   VERSION		USER_STORY			AUTHOR				DATE				Description
   1.0			Data access		    Jose Maria Fernandez Rodero          2/12/2022		    Init version

***********************************************************************************************************************/

/**
 * @description: Clase que devuelve la url de la terminal financiera con el número de persona del contacto. En caso de no encontrarlo, devuelve la url sin redirección al contacto.
 * El método es @AuraEnabled para poder ser llamado desde un componente de Lightning y se le pasa como parámetro el Id del contacto.
 * 
 */

public with sharing class CIBE_OpportunityTFButton {



/**
 * @param: recordId
 * @return: linkTf
 * @throws: AuraHandledException
 * 
*/
@AuraEnabled (cacheable=true)
public static String getUrl(String recordId){
    //Inicializamos la variable
    CIBE_Link__mdt result = CIBE_Link__mdt.getInstance('CIBE_Boton_TF');
    String emptyUrl = result.CIBE_URL__c;
    String url = '';
    Account  accApoderado = new Account();
    // Creamos un try catch para capturar los errores
    
       try{
        accApoderado = [SELECT Id,Name,AV_NumPerso__c,CC_Numero_Documento__c FROM Account WHERE Id = :recordId];
        System.debug('URL a devolver: ' + result.CIBE_URL__C);
         System.debug('CIBE_Parameters__c a devolver: ' + result.CIBE_Parameters__c);

        if(String.isNotBlank(result.CIBE_Parameters__c)) { 
            String identificadorAccount = String.isNotBlank(accApoderado.CC_Numero_Documento__c) ? accApoderado.CC_Numero_Documento__c : '';
            String numperAccount = String.isNotBlank(accApoderado.AV_NumPerso__c) ? accApoderado.AV_NumPerso__c : '';
            url=  result.CIBE_URL__C.replace('{numperso}',numperAccount ).replace('{nif}',identificadorAccount );
            }
    
        }
         catch(Exception e){
            System.debug('Error al intentar obtener los datos para generar la url' + e.getMessage());
            url = emptyUrl;
         }
        

        System.debug('URL a devolver: ' + url);

        return url;
    }  

 


    
}