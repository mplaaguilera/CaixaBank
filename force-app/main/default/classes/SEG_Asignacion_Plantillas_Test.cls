@isTest
public with sharing class SEG_Asignacion_Plantillas_Test {

    @isTest
    static void getPlantillas()
    { 
        SEG_Plantilla__c plantillaSeg = new SEG_Plantilla__c(); 
        insert plantillaSeg;

        Test.startTest();
        SEG_Asignacion_Plantillas.GetPlantillasRetorno retornoPlantilla = SEG_Asignacion_Plantillas.getPlantillas(plantillaSeg.Id);
        Test.stopTest();

        System.assertNotEquals(retornoPlantilla ,null,'La plantilla ha fallado');
    }
    
    @isTest
    static void asociarPlantillas()
    {
        SEG_Plantilla__c plantillaSeg = new SEG_Plantilla__c(); 
        insert plantillaSeg;
        
        Test.startTest();
        SEG_Asignacion_Plantillas.asociarPlantillas(plantillaSeg.id, new Map<String, String>{
            'SEG_PlantillaCastellanoID__c' => '',
            'SEG_PlantillaCastellano__c' => 'castellano',
            'SEG_PlantillaCatalanID__c' => '',
            'SEG_PlantillaCatalan__c' => 'catalan',
            'SEG_PlantillaInglesID__c' => '',
            'SEG_PlantillaIngles__c' => 'ingles',
            'SEG_PlantillaEuskeraID__c' => '',
            'SEG_PlantillaEuskera__c' => 'eusquera',
            'SEG_PlantillaGalegoID__c' => '',
            'SEG_PlantillaGalego__c' => 'gallego'
        });
        Test.stopTest();

        SEG_Plantilla__c resultado = [SELECT SEG_PlantillaCastellano__c FROM SEG_Plantilla__c];
        SEG_Plantilla__c resultado1 = [SELECT SEG_PlantillaCatalan__c FROM SEG_Plantilla__c ];
        SEG_Plantilla__c resultado2 = [SELECT SEG_PlantillaIngles__c FROM SEG_Plantilla__c ];
        SEG_Plantilla__c resultado3 = [SELECT SEG_PlantillaEuskera__c FROM SEG_Plantilla__c ];
        SEG_Plantilla__c resultado4 = [SELECT SEG_PlantillaGalego__c FROM SEG_Plantilla__c ];

        System.assertEquals(resultado.SEG_PlantillaCastellano__c,'castellano', 'Casetellano no coincide');
        System.assertEquals(resultado1.SEG_PlantillaCatalan__c, 'catalan', 'catalan no coincide');
        System.assertEquals(resultado2.SEG_PlantillaIngles__c, 'ingles', 'ingles no coincide');
        System.assertEquals(resultado3.SEG_PlantillaEuskera__c, 'eusquera', 'eusquera no coincide');
        System.assertEquals(resultado4.SEG_PlantillaGalego__c, 'gallego', 'gallego no coincide');
    }    
}