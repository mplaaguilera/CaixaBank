@isTest
public class CSBD_DisponibilidadGestores_Apex_Test {

    @isTest
    private static void init() {
        System.runAs(CSBD_TestDataFactory.usuarioGestor()) {
            Test.startTest();
            Map<String, Object> retorno = CSBD_DisponibilidadGestores_Apex.init();
            List<CalendarViewShare> calendarViewShares = (List<CalendarViewShare>)retorno.get('calendarViewShares');
            Test.stopTest();

            System.assert(retorno.containsKey('currentUserName'));
            System.assert(retorno.containsKey('calendarViewShares'));
        }
    }

    @isTest
    private static void getEventosGestores() {
        User gestor = CSBD_TestDataFactory.usuarioGestor();
        System.runAs(gestor) {
            Opportunity cmn = CSBD_Opportunity.crearOportunidad('CSBD_CMN');
            CSBD_Opportunity.programarCita(cmn.Id, false, gestor.Id, System.now());

            Test.startTest();
            Map<Id, List<Event>> eventosGestores = CSBD_DisponibilidadGestores_Apex.getEventosGestores(System.today(), new List<Id>{gestor.Id});
            Test.stopTest();

            System.debug('eventosGestores: ' + eventosGestores);
            System.assert(eventosGestores.containsKey(gestor.Id));
        }
    }
}