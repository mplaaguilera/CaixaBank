public with sharing class HDT_Task_BI_TRHan extends CC_TriggerHandlerBase {

    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<Task>)tp.newList, (Map<Id, Task>)tp.newMap);
    }

    private void process(List<Task> listNewObj, Map<Id, Task> mapNewObj) {
        Id idRtHdt = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('HDT_Task').getRecordTypeId();
        List<Task> listNewObjHdt = new List<Task>();
        for (Task tarea : listNewObj) {
            if (tarea.RecordTypeId == idRtHdt) {
                listNewObjHdt.add(tarea);
            }
        }
        if (!listNewObjHdt.isEmpty()) {
            enmascararPANs(listNewObjHdt);
        }
    }

    private void enmascararPANs(List<Task> listNewObjHdt) {
        for (Task tarea : listNewObjHdt) {
            if (tarea.Type == 'Automática') {
                // Se establece un patrón para el PAN
                String panRegex = '[0-9]{4}[ -./\\,_]?[0-9]{4}[ -./\\,_]?[0-9]{4}[ -./\\,_]?[0-9]{4}';
                Pattern myPattern = Pattern.compile(panRegex);

                // Campo "Descripcion"
                if (!String.isEmpty(tarea.Description)) {
                    Matcher asuntoMatcher = myPattern.matcher(tarea.Description);
                    while (asuntoMatcher.find()) {
                        String encryptedPan = asuntoMatcher.group().replaceAll('[^0-9]', '').replaceAll('(?<=\\d{4})\\d(?=\\d{4})', 'X');
                        tarea.Description = tarea.Description.replaceFirst(panRegex, encryptedPan);
                    }
                }

                // Campo "Subject"
                if (!String.isEmpty(tarea.Subject)) {
                    Matcher asuntoMatcher = myPattern.matcher(tarea.Subject);
                    while (asuntoMatcher.find()) {
                        String encryptedPan = asuntoMatcher.group().replaceAll('[^0-9]', '').replaceAll('(?<=\\d{4})\\d(?=\\d{4})', 'X');
                        tarea.Subject = tarea.Subject.replaceFirst(panRegex, encryptedPan);
                    }
                }
            }
        }
    }
}