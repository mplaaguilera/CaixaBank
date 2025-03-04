@isTest
public class CSBD_DatosEntrevistaHipoteca_Test {

    @isTest
    private static void test() {
        System.runAs(CSBD_TestDataFactory.usuarioGestor()) {

            Contact primerTitular = new Contact();
            primerTitular.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CSBD_TitularHipoteca').getRecordTypeId();
            primerTitular.LastName = 'Primer titular';
            Contact segundoTitular = new Contact();
            segundoTitular.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CSBD_TitularHipoteca').getRecordTypeId();
            segundoTitular.LastName = 'Segundo titular';
            insert new List<Contact>{primerTitular, segundoTitular};

            Test.startTest();
            //Con solo primer titular
            Map<String, Object> camposHipoteca = new Map<String, Object>{
                'Amount' => 100000,
                'CSBD_PrecioInmueble__c' => 100000,
                'CSBD_Now_Plazo__c' => 290,
                'CSBD_TIN_Inicial__c' => 3,
                'CSBD_AportacionInicial__c' => 20000,
                'CSBD_ContactoTitular1__c' => primerTitular.Id,
                'CSBD_Datos_Calculo_DTI__c' => '{"metadata":{"version":"3","fechaGuardado":"2024-12-21T17:20:16.081Z","usuario":"0053Y00000ALRTSQA5"},"porcentajeGastosConstitucion":32,"ahorro":"02000","primerTitular":{"nominasNetas":{"tipo":"Nóminas netas","ingresos":"01000","numPagosImpuestos":"014"},"ingresosNetosIrpf":{"tipo":"Ingresos netos IRPF","ingresos":"0100","numPagosImpuestos":"50"},"otrosIngresos":{"tipo":"Otros ingresos","ingresos":"090","numPagosImpuestos":"012"},"ingresosAlquiler":{"tipo":"Ingresos por alquiler","ingresos":"080","numPagosImpuestos":"012"}},"segundoTitular":{"nominasNetas":{"tipo":"Nóminas netas","ingresos":"1500","numPagosImpuestos":"012"},"ingresosNetosIrpf":{"tipo":"Ingresos netos IRPF","ingresos":"0150","numPagosImpuestos":0},"otrosIngresos":{"tipo":"Otros ingresos","ingresos":"095","numPagosImpuestos":"012"},"ingresosAlquiler":{"tipo":"Ingresos por alquiler","ingresos":"085","numPagosImpuestos":"012"}},"deuda":{"dosTitulares":true,"hipoteca":{"primerTitular":"01","segundoTitular":"02"},"prestamo":{"primerTitular":"03","segundoTitular":"04"},"tarjetas":{"primerTitular":"05","segundoTitular":"06"},"alquiler":{"primerTitular":"07","segundoTitular":"08"}}}'
            };
            Opportunity hipoteca = CSBD_Opportunity.crearOportunidad('CSBD_Hipoteca', camposHipoteca);
            CSBD_DatosEntrevistaHipoteca datosEntrevista1 = new CSBD_DatosEntrevistaHipoteca(hipoteca);
            Decimal interesBonificado = datosEntrevista1.interesBonificado;
            Decimal tasa = datosEntrevista1.tasa;
            Decimal tasaBonificada = datosEntrevista1.tasaBonificada;
            Decimal primerTitularNominasNetasNeto = datosEntrevista1.primerTitular.nominasNetas.neto;
            Decimal primerTitularTotalIngresosNomina = datosEntrevista1.primerTitular.totalIngresosNomina;
            Decimal primerTitularTotalIngresosNominaProrrateado = datosEntrevista1.primerTitular.totalIngresosNominaProrrateado;
            Decimal primerTitularTotalIngresosIrpf = datosEntrevista1.primerTitular.totalIngresosIrpf;
            Decimal primerTitularTotalIngresosIrpfProrrateado = datosEntrevista1.primerTitular.totalIngresosIrpfProrrateado;
            Decimal primerTitularSumaDeuda = datosEntrevista1.deuda.sumaDeudasPrimerTitular;
            Decimal primerTitularTotalDeuda = datosEntrevista1.deuda.totalDeudaPrimerTitular;
            Decimal cuota = datosEntrevista1.deuda.cuota;
            Decimal cuotaBonificada = datosEntrevista1.deuda.cuotaBonificada;

            CSBD_DatosEntrevistaHipoteca.Deuda deuda = new CSBD_DatosEntrevistaHipoteca.Deuda(datosEntrevista1);

            //Con dos titulares
            hipoteca.CSBD_ContactoTitular2__c = segundoTitular.Id;
            update hipoteca;
            CSBD_DatosEntrevistaHipoteca datosEntrevista2 = new CSBD_DatosEntrevistaHipoteca(hipoteca);
            interesBonificado = datosEntrevista2.interesBonificado;
            tasa = datosEntrevista2.tasa;
            tasaBonificada = datosEntrevista2.tasaBonificada;
            primerTitularTotalIngresosIrpf = datosEntrevista2.primerTitular.totalIngresosIrpf;
            Decimal segundoTitularTotalIngresosIrpf = datosEntrevista2.segundoTitular.totalIngresosIrpf;
            Decimal segundaTitularSumaDeuda = datosEntrevista1.deuda.sumaDeudasSegundoTitular;
            Decimal segundoTitularTotalDeuda = datosEntrevista1.deuda.totalDeudaSegundoTitular;
            cuota = datosEntrevista1.deuda.cuota;
            cuotaBonificada = datosEntrevista1.deuda.cuotaBonificada;
            Test.stopTest();

            System.assert(datosEntrevista1 != null, 'No se ha podido crear la instancia de CSBD_DatosEntrevistaHipoteca');
            System.assert(datosEntrevista2 != null, 'No se ha podido crear la instancia de CSBD_DatosEntrevistaHipoteca');
        }
    }
}