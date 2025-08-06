public class CC_TransChatModel {
    @AuraEnabled 
    public string Inicio {get;set;}
    
    @AuraEnabled 
    public string Fin {get;set;}
    
    @AuraEnabled 
    public List<Mensaje> Mensajes {get;set;}
    
   
    public class Mensaje {
    	@AuraEnabled 
        public string Id {get;set;}
        
        @AuraEnabled 
        public boolean Cliente {get;set;} 
        
        @AuraEnabled 
        public String Nombre {get;set;}  
        
        @AuraEnabled 
        public String Hora {get;set;}  
    
        @AuraEnabled 
        public String Texto {get;set;}    

    }
}