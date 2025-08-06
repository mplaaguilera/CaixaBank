public with sharing class CSBD_RunTestSuite_Schedulable implements Schedulable {

    private String modo; //Se asigna en el constructor que se pasa como parámetro al System.schedule()
    // 'run' --> ejecutar test suite, 'report' --> enviar los resultados, 'null' --> añadir clases + ejecutar test suite

    public CSBD_RunTestSuite_Schedulable() { //Constructor sin parámetros dummy necesario para implementar Schedulable
        this.modo = null;
    }

    public CSBD_RunTestSuite_Schedulable(String modo) {
        this.modo = modo;
    }

    public static void programar() {
        programar(null, 10);
    }

    public static void programar(String modo) {
        programar(modo, 10);
    }

    public static void programar(String modo, Integer segundos) {
        segundos = (segundos ?? 0) < 10 ? 10 : segundos;
        Datetime fechaEjecucion = Datetime.now().addSeconds(segundos);
		while (fechaEjecucion <= System.now()) {
			fechaEjecucion = fechaEjecucion.addMinutes(1);
		}
        System.schedule(
            'CSBD_RunTestSuite_Schedulable__' + modo + '__' + fechaEjecucion.format('yyyyMMdd_HHmmss'),
            fechaEjecucion.format('s m H d M ? yyyy'),
            new CSBD_RunTestSuite_Schedulable(modo));
    }

    public void execute(SchedulableContext sc) {
        CSBD_EjecucionProgramadaTests__mdt config = [SELECT CSBD_TestSuiteName__c, CSBD_AnyadirClases__c, CSBD_PrefijoClases__c,
                                                        CSBD_ClasesExcluidas__c, CSBD_DEV_ModoDesarrollo__c
                                                        FROM CSBD_EjecucionProgramadaTests__mdt WHERE DeveloperName = 'CSBD_Parametros'];
        if (this.modo == null && config.CSBD_AnyadirClases__c && !config.CSBD_DEV_ModoDesarrollo__c) {
            //Añadir clases a la test suite y ejecutarla
            System.enqueueJob(new CSBD_RunTestSuite_Queueable('add'));

        } else if (this.modo == 'report') {
            //Emvío de resultados
            System.enqueueJob(new CSBD_RunTestSuite_Queueable('report'));

        } else {
            //Ejecución de test suite
            Set<Id> idClasesEjecutar = getClasesTestEjecutar();
            if (!idClasesEjecutar.isEmpty()) {
                List<ApexTestQueueItem> apexTestQueueItems = new List<ApexTestQueueItem>();
                for (Id idClaseEjecutar : idClasesEjecutar) {
                    apexTestQueueItems.add(new ApexTestQueueItem(ApexClassId = idClaseEjecutar));
                }
                if (!Test.isRunningTest()) {
                    insert apexTestQueueItems;
                }
				programar('report', apexTestQueueItems.size() * 25); //25 segundos por clase de test
            }
        }
    }

	public static Set<Id> getClasesTestEjecutar() {
        CSBD_EjecucionProgramadaTests__mdt config = [SELECT CSBD_TestSuiteName__c, CSBD_PrefijoClases__c,
                                                        CSBD_DEV_ModoDesarrollo__c, CSBD_DEV_TestSuiteName__c
                                                        FROM CSBD_EjecucionProgramadaTests__mdt WHERE DeveloperName = 'CSBD_Parametros'];
        String testSuiteName = config.CSBD_DEV_ModoDesarrollo__c ? config.CSBD_DEV_TestSuiteName__c : config.CSBD_TestSuiteName__c;

        Set<Id> idClases = new Set<Id>();
        for (TestSuiteMembership testSuiteMembership : [SELECT ApexClassId FROM TestSuiteMembership
                                                        WHERE ApexTestSuite.TestSuiteName = :testSuiteName
                                                        AND ApexClass.Name LIKE :config.CSBD_PrefijoClases__c + '%'
                                                        AND ApexClass.Name NOT IN :getNombreClasesExcluidas()]) {
            idClases.add(testSuiteMembership.ApexClassId);
        }
        return idClases;
	}

	public static List<String> getNombreClasesExcluidas() {
        String configClasesExcluidas = [SELECT CSBD_ClasesExcluidas__c FROM CSBD_EjecucionProgramadaTests__mdt
                                        WHERE DeveloperName = 'CSBD_Parametros'].CSBD_ClasesExcluidas__c ?? '';
		List<String> nombreClasesExcluidas = new List<String>();
		for (String nombreClaseExcluida : configClasesExcluidas.split('\n')) {
			nombreClaseExcluida = nombreClaseExcluida.trim();
			if (!String.isBlank(nombreClaseExcluida)) {
				nombreClasesExcluidas.add(nombreClaseExcluida);
			}
		}
		return nombreClasesExcluidas;
	}
}