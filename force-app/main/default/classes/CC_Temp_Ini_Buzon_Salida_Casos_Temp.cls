public with sharing class CC_Temp_Ini_Buzon_Salida_Casos_Temp {
    
    public static void inicializar(Integer numCasos) {

        List<Case> casos = [SELECT CC_Canal_Procedencia__c, CC_Idioma__c
                            FROM Case WHERE Status NOT IN ('Cerrado', 'Rechazado')
                            AND CC_Canal_Procedencia__c != NULL AND CC_Idioma__c IN ('es', 'ca', 'en')
                            AND CC_Buzon_Salida__c = NULL
                            LIMIT :numCasos];

        for (Case caso : casos) {
            caso.CC_Buzon_Salida__c = obtenerBuzon(caso.CC_Canal_Procedencia__c, caso.CC_Idioma__c);
        }

        update casos;
    }

    private static String obtenerBuzon(String canalProcedencia, String idioma) {

        if (idioma == 'ca') {
            idioma = 'Català';
        } else if (idioma == 'en') {
            idioma = 'Inglés';
        } else {
            idioma = 'Castellano';
        }

        List<CC_Buzones_Por_Defecto__mdt> buzones = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt
                                                    WHERE CC_Canal_Procedencia__c = :canalProcedencia
                                                    AND CC_Idioma__c = :idioma];
        
        //Si no se ha encontrado  ningún buzón se usa el por defecto en el idioma del caso
        if (buzones.isEmpty()) {
            buzones = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt
                        WHERE CC_Canal_Procedencia__c = 'Por defecto' AND CC_Idioma__c = :idioma
                        AND CC_Activo__c = true];
        }

        //Si no se ha encontrado  ningún buzón se usa el por defecto en castellano
        if (buzones.isEmpty()) {
            buzones = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt
                        WHERE CC_Canal_Procedencia__c = 'Por defecto' AND CC_Idioma__c = 'Castellano'
                        AND CC_Activo__c = true];
        }

        if (!buzones.isEmpty()) {
            return buzones[0].CC_Direccion_Correo__c;
        } else {
            return null;
        }
    }
}