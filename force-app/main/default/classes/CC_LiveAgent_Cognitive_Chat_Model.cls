public class CC_LiveAgent_Cognitive_Chat_Model {   
    
    //En los lightning components los textos de inicio y fin tienen una
    //parte sin estilo (Inicio/Fin) y otra parte en negrita (Inicio2/Fin2)
    
    @AuraEnabled
    public string inicio {get;set;}

    @AuraEnabled 
    public string inicio2 {get;set;}

    @AuraEnabled 
    public string fin {get;set;}
    
    @AuraEnabled 
    public string fin2 {get;set;}

    @AuraEnabled 
    public List<Mensaje> mensajes {get;set;}
    
    public class Mensaje {
        @AuraEnabled
        public string id {get;set;}
        
        @AuraEnabled 
        public boolean cliente {get;set;}
        
        @AuraEnabled 
        public boolean hidden {get;set;}
        
        @AuraEnabled 
        public String nombre {get;set;}
        
        @AuraEnabled 
        public String hora {get;set;}
    
        @AuraEnabled 
        public String texto {get;set;}
    }
}