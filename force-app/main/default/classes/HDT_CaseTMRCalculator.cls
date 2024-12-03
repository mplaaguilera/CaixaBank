public with sharing class HDT_CaseTMRCalculator {
    private static final String BUSINESS_HOURS_NAME = 'HDT_Empleados';

    // Método principal para calcular el tiempo en cada estado
    public static void calculateStateTimes(Case c) {

        // Obtener el ID de la Business Hour 'Empleados'
        BusinessHours bh = [SELECT Id FROM BusinessHours WHERE Name = :BUSINESS_HOURS_NAME LIMIT 1];

        Id businessHoursId = bh.Id;

        Decimal activeTime = 0;
        Decimal pendingClientTime = 0;
        Decimal pendingIncidentTime = 0;
        Decimal pendingReviewTime = 0;

        String previousState = null;
        DateTime previousTime = null;

        // Obtener los cambios de estado del historial del caso
        List<CaseHistory> historyList = [SELECT CreatedDate, Field, OldValue, NewValue 
                                         FROM CaseHistory 
                                         WHERE CaseId = :c.Id AND Field = 'Status'
                                         ORDER BY CreatedDate ASC];

        for (CaseHistory history : historyList) {
            String currentState = (String)history.NewValue;
            DateTime currentTime = history.CreatedDate;

            if (previousState != null && previousTime != null) {
                Decimal timeSpent = calculateWorkingHours(previousTime, currentTime, businessHoursId);

                if (previousState == 'Activo') {
                    activeTime += timeSpent;
                } else if (previousState == 'Pendiente Cliente') {
                    pendingClientTime += timeSpent;
                } else if (previousState == 'Pendiente Incidencia') {
                    pendingIncidentTime += timeSpent;
                } else if (previousState == 'Pendiente Revisión') {
                    pendingReviewTime += timeSpent;
                }
            }

            previousState = currentState;
            previousTime = currentTime;
        }

        // Si el caso está actualmente en uno de los estados activos, sumar el tiempo hasta el presente
        if (previousState != null && previousTime != null) {
            Decimal timeSpent = calculateWorkingHours(previousTime, DateTime.now(), businessHoursId);

            if (previousState == 'Activo') {
                activeTime += timeSpent;
            } else if (previousState == 'Pendiente Cliente') {
                pendingClientTime += timeSpent;
            } else if (previousState == 'Pendiente Incidencia') {
                pendingIncidentTime += timeSpent;
            } else if (previousState == 'Pendiente Revisión') {
                pendingReviewTime += timeSpent;
            }
        }

        /*
        // Actualizar los campos del caso con el tiempo acumulado en cada estado
        c.Active_Time__c = activeTime;
        c.Pending_Client_Time__c = pendingClientTime;
        c.Pending_Incident_Time__c = pendingIncidentTime;
        c.Pending_Review_Time__c = pendingReviewTime;*/
        system.debug('Tiempo que ha estado activo : = ' + activeTime);
        system.debug('Tiempo que ha estado Pendiente Cliente : = ' + pendingClientTime);
        system.debug('Tiempo que ha estado Incidente : = ' + pendingIncidentTime);
        system.debug('Tiempo que ha estado Review : = ' + pendingReviewTime);
    }

    // Método auxiliar para calcular las horas de trabajo entre dos DateTime usando BusinessHours
    private static Decimal calculateWorkingHours(DateTime pp1, DateTime pp2, Id businessHoursId) {
        Long milliseconds = BusinessHours.diff(businessHoursId, pp1, pp2);
        Decimal hours = milliseconds != null ? (Decimal) milliseconds / (1000 * 60 * 60) : 0;
        return hours;
    }
}