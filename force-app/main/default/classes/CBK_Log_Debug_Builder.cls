public with sharing class CBK_Log_Debug_Builder {

    public class DebugProcessConfig  {
        // Atributos privados
        private String contextId;
        private Map<String, String> message = new Map<String, String>();
        private List<Object> values = new List<Object>();
        private LoggingLevel level;
        private Boolean force;
        private Exception err;
        private Messaging.InboundEmail email = new Messaging.InboundEmail();
        private String category;

        // Constructor privado
        private DebugProcessConfig (DebugProcessConfigBuilder builder) {
            this.contextId = builder.contextId;
            this.message = builder.message;
            this.values = builder.values;
            this.level = builder.level;
            this.force = builder.force;
            this.err = builder.err;
            this.email = builder.email;
            this.category = builder.category;
        }

        // Getters
        public String getcontextId() { return contextId; }
        public Map<String, String> getmessage() { return message; }
        public  List<Object> getvalues() { return values; }
        public LoggingLevel getlevel() { return level; }
        public Boolean getforce() { return force; }
        public Exception geterr() { return err; }
        public Messaging.InboundEmail getemail() { return email; }
        public String getCategory() { return category; } 
    }
     
    // Clase Builder
    public with sharing class DebugProcessConfigBuilder {

        String contextId;
        Map<String, String> message = new Map<String, String>();
        List<Object> values = new List<Object>();
        LoggingLevel level;
        Boolean force;
        Exception err;
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        String category;

        public DebugProcessConfigBuilder setemail(Messaging.InboundEmail email) {
            this.email = email;
            return this;
        }

        public DebugProcessConfigBuilder seterr(Exception err) {
            this.err = err;
            return this;
        }

        public DebugProcessConfigBuilder setforce(Boolean force) {
            this.force = force;
            return this;
        }

        public DebugProcessConfigBuilder setContextId(String contextId) {
            this.contextId = contextId;
            return this;
        }

        public DebugProcessConfigBuilder setMessage(Map<String, String> message) {
            this.message = message;
            return this;
        }
        
        public DebugProcessConfigBuilder setMessageEntry(String key, String value) {
            this.message.put(key, value);
            return this;
        }
        
        public DebugProcessConfigBuilder setValues(List<Object> values) {
            this.values = values;
            return this;
        }
        
        public DebugProcessConfigBuilder setValue(Object value) {
            this.values.add(value);
            return this;
        }
        
        public DebugProcessConfigBuilder setLevel(LoggingLevel level) {
            this.level = level;
            return this;
        }

        public DebugProcessConfigBuilder setCategory(String category) {
            //Se comprueba que el valor de 'category' sea válido solamente si viene informado
            //Si existe, se guarda en el campo 'CBK_Category' el valor guardado como Name en la entrada de CBK_PicklistValue para mantener consistencia
            if(String.isNotBlank(category)){
                String sRecordTypeIdPicklistValue = Schema.SObjectType.CBK_PicklistValues__c.getRecordTypeInfosByDeveloperName().get('CBK_PicklistValue').getRecordTypeId();
                List<CBK_PicklistValues__c> listPicklistValues = [SELECT Id, Name
                                                                  FROM CBK_PicklistValues__c
                                                                  WHERE CBK_Picklist__r.CBK_Object__c = 'CBK_Log'
                                                                  AND CBK_Picklist__r.Name = 'CBK_Category__c'
                                                                  AND Name = :category
                                                                  AND RecordTypeId = :sRecordTypeIdPicklistValue
                                                                  LIMIT 1];
                if(!listPicklistValues.isEmpty()){
                    if(!listPicklistValues.isEmpty()){
                        this.category = listPicklistValues[0].Name;
                    }else{
                        this.category = 'Default';
                    }
                }
            }

            return this;
        }

        // Método build para crear una instancia de MyClass
       public DebugProcessConfig  build() {
            return new DebugProcessConfig (this);
       }
    }
    
    // Método para construir y llamar al método debug
    public static void executeDebugBuilder(DebugProcessConfigBuilder builder) {
        DebugProcessConfig myInstance = builder.build();
    }
}