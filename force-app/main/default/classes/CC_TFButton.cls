public with sharing class CC_TFButton {


    @AuraEnabled (cacheable=true)
    public static String getUrl(String recordId){
        //Inicializamos la variable
        CIBE_Link__mdt result = CIBE_Link__mdt.getInstance('CC_Boton_TF');
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
                String nombre = String.isNotBlank(accApoderado.Name) ? accApoderado.Name : '';

                url=  result.CIBE_URL__C.replace('{numperso}',numperAccount ).replace('{nif}',identificadorAccount ).replace('{nombre}',nombre);
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