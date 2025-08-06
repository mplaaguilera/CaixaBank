public with sharing class CC_Disponibilidad_Cita_Setting {

    public static final String DISPONIBILIDAD_CALENDAR_SETT = 'CC_Configuracion_Citas_Calendario';
    public static final String CITA_OPCIONES_SETT = 'CC_Configuracion_Cita_Rapida_Opciones';

    @AuraEnabled(cacheable=true)
    public static Map<String, Integer> getDaysDiff(){
        Map<String, Integer> result = new Map<String, Integer>();
        result.put('citaRapida', 0);
        result.put('default', 0);
        CC_Settings__c dispSett = CC_Settings__c.getValues(DISPONIBILIDAD_CALENDAR_SETT);
        if(dispSett != null && dispSett.CC_Activa__c){
            //Configuracion para cita rapida
            if(dispSett.CC_Configuracion_1__c != null){
                try{
                    Integer value = Integer.valueOf(dispSett.CC_Configuracion_1__c) > 0 ? 
                        Integer.valueOf(dispSett.CC_Configuracion_1__c) : 
                        0;
                    result.put('citaRapida', value);
                }catch(Exception ex){
                    CBK_Log.error('CC_Disponibilidad_Cita_Setting', ex.getMessage());
                }             
            }

            //Configuracion para cita normal
            if(dispSett.CC_Configuracion_2__c != null){
                try{
                    Integer value = Integer.valueOf(dispSett.CC_Configuracion_2__c) > 0 ? 
                        Integer.valueOf(dispSett.CC_Configuracion_2__c) : 
                        0;
                    result.put('default', value);
                }catch(Exception ex){
                    CBK_Log.error('CC_Disponibilidad_Cita_Setting', ex.getMessage());
                }      
            }           
        }
        return result;
    }

    public static Map<String, String> getOptionsCitaRapida(){
        Map<String, String> result = new Map<String, String>();
      
        CC_Settings__c citaOptSett = CC_Settings__c.getValues(CITA_OPCIONES_SETT);
        if(citaOptSett != null && citaOptSett.CC_Activa__c){
            Boolean citaPresencialActiva = false;
            Boolean citaTelefonicaActiva = false;
            //Opcion Cita presencial
            try{
                if(citaOptSett.CC_Configuracion_1__c != null || citaOptSett.CC_Configuracion_2__c != null){
                    citaPresencialActiva = Boolean.valueOf(citaOptSett.CC_Configuracion_1__c);
                    citaTelefonicaActiva = Boolean.valueOf(citaOptSett.CC_Configuracion_2__c); 
                }
               
                if(citaPresencialActiva){
                    result.put('Cita presencial', citaOptSett.CC_Configuracion_3__c != null ? citaOptSett.CC_Configuracion_3__c : '42');
                }
                if(citaTelefonicaActiva){
                    result.put('Cita telefónica', citaOptSett.CC_Configuracion_4__c != null ? citaOptSett.CC_Configuracion_4__c : '43');
                }

            } catch(Exception ex){
                CBK_Log.error('CC_Disponibilidad_Cita_Setting', ex.getMessage());
            }           
        }
        return result;
    }

   
}