public with sharing class CC_Agrupador_Fecha_Limite_Caso {

    @InvocableMethod
    public static void asignarFechaLimite(List<Id> idsCasos) {
        List<Case> listaCasos = [SELECT Id, Status, Origin, CC_Canal_Resolucion__c, CC_Tipo_Contacto__c, CreatedDate, CC_Fecha_Limite_Resolucion__c
                                FROM Case WHERE Id IN :idsCasos AND Status != 'Cerrado' AND CC_Fecha_Limite_Resolucion__c = null];        
        
        List<Case> listaCasosActualizar = new List<Case>();
        for (Case caso : listaCasos) {
            //Boolean auxiliar para evitar repetición
            Boolean resolucionEsAtencionOmicAsociacion = (caso.CC_Canal_Resolucion__c == 'Atención al Cliente'
            || caso.CC_Canal_Resolucion__c == 'Omic'
            || caso.CC_Canal_Resolucion__c == 'Asociación Consumidores');

            if (caso.Origin == 'Email' && caso.CC_Tipo_Contacto__c == 'Petición documentación' && resolucionEsAtencionOmicAsociacion) {
                caso.CC_Fecha_Limite_Resolucion_Verde__c   = CC_MetodosUtiles.fechaLimiteFinSemanaFestivos('5', caso.CreatedDate);
                caso.CC_Fecha_Limite_Resolucion_Naranja__c = CC_MetodosUtiles.fechaLimiteFinSemanaFestivos('10', caso.CreatedDate);
                caso.CC_Fecha_Limite_Resolucion__c         = CC_MetodosUtiles.fechaLimiteFinSemanaFestivos('20', caso.CreatedDate);
                listaCasosActualizar.add(caso);
            } else if (caso.Origin == 'Email' && caso.CC_Canal_Resolucion__c == 'Junta Andalucia') {
                caso.CC_Fecha_Limite_Resolucion_Verde__c   = CC_MetodosUtiles.fechaLimiteFinSemanaFestivos('4', caso.CreatedDate);
                caso.CC_Fecha_Limite_Resolucion_Naranja__c = CC_MetodosUtiles.fechaLimiteFinSemanaFestivos('8', caso.CreatedDate);
                caso.CC_Fecha_Limite_Resolucion__c         = CC_MetodosUtiles.fechaLimiteFinSemanaFestivos('10', caso.CreatedDate);
                listaCasosActualizar.add(caso);
            } else if (caso.Origin == 'Email' && (resolucionEsAtencionOmicAsociacion || caso.CC_Canal_Resolucion__c == 'Dirección')) {
                caso.CC_Fecha_Limite_Resolucion_Verde__c   = CC_MetodosUtiles.fechaLimiteFinSemanaFestivos('3', caso.CreatedDate);
                caso.CC_Fecha_Limite_Resolucion_Naranja__c = CC_MetodosUtiles.fechaLimiteFinSemanaFestivos('5', caso.CreatedDate);
                caso.CC_Fecha_Limite_Resolucion__c         = CC_MetodosUtiles.fechaLimiteFinSemanaFestivos('7', caso.CreatedDate);
                listaCasosActualizar.add(caso);
            } else if (caso.Origin == 'Email' && caso.CC_Canal_Resolucion__c == 'Oficina Preventiva') {
                caso.CC_Fecha_Limite_Resolucion_Verde__c   = CC_MetodosUtiles.fechaLimiteFinSemanaFestivos('3', caso.CreatedDate);
                caso.CC_Fecha_Limite_Resolucion_Naranja__c = CC_MetodosUtiles.fechaLimiteFinSemanaFestivos('5', caso.CreatedDate);
                caso.CC_Fecha_Limite_Resolucion__c         = CC_MetodosUtiles.fechaLimiteFinSemanaFestivos('7', caso.CreatedDate);
                listaCasosActualizar.add(caso);
            } else if (caso.Origin == 'Phone' && caso.CC_Canal_Resolucion__c == 'Atención al Cliente' ) {
                if (caso.CC_Tipo_Contacto__c == 'Petición documentación') {
                    caso.CC_Fecha_Limite_Resolucion_Verde__c   = CC_MetodosUtiles.fechaLimiteFinSemanaFestivos('5', caso.CreatedDate);
                    caso.CC_Fecha_Limite_Resolucion_Naranja__c = CC_MetodosUtiles.fechaLimiteFinSemanaFestivos('10', caso.CreatedDate);
                    caso.CC_Fecha_Limite_Resolucion__c         = CC_MetodosUtiles.fechaLimiteFinSemanaFestivos('20', caso.CreatedDate);
                    listaCasosActualizar.add(caso);
                } else {
                    caso.CC_Fecha_Limite_Resolucion_Verde__c   = CC_MetodosUtiles.fechaLimiteFinSemanaFestivos('3', caso.CreatedDate);
                    caso.CC_Fecha_Limite_Resolucion_Naranja__c = CC_MetodosUtiles.fechaLimiteFinSemanaFestivos('5', caso.CreatedDate);
                    caso.CC_Fecha_Limite_Resolucion__c         = CC_MetodosUtiles.fechaLimiteFinSemanaFestivos('7', caso.CreatedDate);
                    listaCasosActualizar.add(caso);
                }
            } else if (caso.CC_Canal_Resolucion__c == 'Atención al Cliente') {
                caso.CC_Fecha_Limite_Resolucion_Verde__c   = CC_MetodosUtiles.fechaLimiteFinSemanaFestivos('3', caso.CreatedDate);
                caso.CC_Fecha_Limite_Resolucion_Naranja__c = CC_MetodosUtiles.fechaLimiteFinSemanaFestivos('5', caso.CreatedDate);
                caso.CC_Fecha_Limite_Resolucion__c         = CC_MetodosUtiles.fechaLimiteFinSemanaFestivos('7', caso.CreatedDate);
                listaCasosActualizar.add(caso);
            }      
        } 
        
    	if (!listaCasosActualizar.isEmpty()) {
            Database.update(listaCasosActualizar, false);
        }
    }   	
}