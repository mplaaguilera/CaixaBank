public with sharing class CC_Aviso_Agrupador {
    
	@InvocableMethod
    public static void publicarEventoDeAviso(List<CC_Agrupador__c> agrupadores) {
        List<String> nombresLOV = new List<String>();
        for (CC_Agrupador__c agrupador : agrupadores) {
            nombresLOV.add(agrupador.CC_Record_Type_Name__c + ' - Umbral primer aviso');
            nombresLOV.add(agrupador.CC_Record_Type_Name__c + ' - Umbral siguientes avisos');
        }
        //Comprobar si hay casos de clientes
        List <Id> idsAgrupadores = new List <Id>();
        for (CC_Agrupador__c agrupador : agrupadores){
            idsAgrupadores.add(agrupador.Id);
        }
        
        List <Case> casos = ([SELECT Status, CC_Agrupador_Id__c, RecordType.DeveloperName, CC_NotIncidencia__c FROM Case WHERE CC_Agrupador_Id__c IN :idsAgrupadores AND Status != 'Cerrado' AND Status != 'Pendiente Revisión']);
        Boolean isCliente = false;
        if (!casos.isEmpty()) {
            for (Case caso : casos) {
                if (caso.RecordType.DeveloperName == 'CC_Cliente' && isCliente == false){
                    isCliente = true;
                }
            }
        }
        
        List<CC_Lista_Valores__c> resultadosQuery = [SELECT Name, CC_Valor__c FROM CC_Lista_Valores__c WHERE CC_Lista__r.Name = 'Avisos sobre agrupadores' AND Name IN :nombresLOV];

        Map<String, Integer> listaValores = new Map<String, Integer>();
        if (!resultadosQuery.isEmpty()) {
            for (CC_Lista_Valores__c lov : resultadosQuery) {
                listaValores.put(lov.Name, Integer.valueof(lov.CC_Valor__c));
            }
        }
        
        List<CC_Aviso_Coordinador_Cases_Agrupador__e> eventosDeAviso = new List<CC_Aviso_Coordinador_Cases_Agrupador__e>();
        if (!listaValores.isEmpty()) {
            for (CC_Agrupador__c agrupador : agrupadores) {
                Integer umbralPrimerAviso      = listaValores.get(agrupador.CC_Record_Type_Name__c + ' - Umbral primer aviso');
                Integer umbralSiguientesAvisos = listaValores.get(agrupador.CC_Record_Type_Name__c + ' - Umbral siguientes avisos');

                Integer calculoResto = math.mod((agrupador.CC_Numero_Casos__c.intValue() - umbralPrimerAviso), umbralSiguientesAvisos);
                if ((agrupador.CC_Numero_Casos__c.intValue() == umbralPrimerAviso) || calculoResto == 0) {
                    String mensaje = '';
                    switch on agrupador.CC_Record_Type_Name__c {
                        when 'Comunicación Informativa' {
                            mensaje = 'Se han asociado ' + agrupador.CC_Numero_Casos__c.intValue() + ' casos a la Comunicación Informativa ' + agrupador.Name + '.';
                        }
                        when 'Comunicación Informativa de Campaña' {
                            mensaje = 'Se han asociado ' + agrupador.CC_Numero_Casos__c.intValue() + ' casos a la Comunicación Informativa de Campaña ' + agrupador.Name + '.';
                        }
                        when else { // Incidencia, Masiva de control, Seguimiento, etc.
                            mensaje = 'El agrupador ' + agrupador.Name + ' tiene ' + agrupador.CC_Numero_Casos__c.intValue() + ' casos asociados.';
                        }
                    }
                    eventosDeAviso.add(new CC_Aviso_Coordinador_Cases_Agrupador__e(Mensaje__c = mensaje, Agrupador_Id__c = String.valueOf(agrupador.Id), Agrupador_RecordType__c = agrupador.CC_Record_Type_Name__c, Tipo__c = 'warning'));
                }
            }
        }
        
        if (!eventosDeAviso.isEmpty() && isCliente) {
            EventBus.publish(eventosDeAviso);
        }
    }
}