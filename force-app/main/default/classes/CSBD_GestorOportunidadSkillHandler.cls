public with sharing class CSBD_GestorOportunidadSkillHandler {
    
    // Instancia estática privada para el patrón Singleton
    private static CSBD_GestorOportunidadSkillHandler instance;
    
    // Atributo principal: lista de String
    private List<String> listaPrincipal;
    
    // Constructor privado para evitar instanciación directa
    private CSBD_GestorOportunidadSkillHandler() {
        // Inicialización del singleton
        listaPrincipal = new List<String>();
        // Cargar las habilidades al inicializar la instancia
        cargarHabilidades();
    }
    
    /**
     * Método público para obtener la instancia única del Singleton
     * @return CSBD_GestorOportunidadSkillHandler La instancia única
     */
    public static CSBD_GestorOportunidadSkillHandler getInstance() {
        if (instance == null) {
            instance = new CSBD_GestorOportunidadSkillHandler();
        }
        return instance;
    }
    
    /**
     * Método para cargar las habilidades desde la base de datos
     */
    public void cargarHabilidades() {
        try {
            List<CC_Lista_Valores__c> habilidades = [
                SELECT Name, CC_Valor__c 
                FROM CC_Lista_Valores__c 
                WHERE RecordType.DeveloperName = 'CC_Valor' 
                AND CC_Lista__r.Name = 'CSBD - Habilidades independientes a enrutar' 
                AND CC_Activa__c = TRUE
            ];            
           
            for (CC_Lista_Valores__c habilidad : habilidades) {
                if (String.isNotBlank(habilidad.CC_Valor__c)) {
                    listaPrincipal.add(habilidad.CC_Valor__c);
                }
            }
        } catch (Exception e) {
            System.debug('Error al cargar habilidades: ' + e.getMessage());
            listaPrincipal = new List<String>();
        }
    }
      
    /**
     * Método para verificar si la lista contiene un valor específico
     * @param valor El valor a buscar en la lista
     * @return Boolean True si el valor existe en la lista, false en caso contrario
     */
    public Boolean contieneValor(String valor) {
        if (listaPrincipal == null || listaPrincipal.isEmpty()) {
            return false;
        }
        return listaPrincipal.contains(valor);
    }
    
}