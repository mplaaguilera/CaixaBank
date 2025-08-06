/**********************************************************************************************************************
Name:	  CIBE_TranslationUtilities
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Implementación para la obtencion de traducciones del custom metadata CIBE_TranslateConfiguration__mdt.
-----------------------------------------------------------------------------------------------------------------------
Historial
-----------------------------------------------------------------------------------------------------------------------
VERSION		USER_STORY		AUTHOR			DATE			Description
1.0			Init    		Alex Campos 	28/12/2022		Init version.
***********************************************************************************************************************/
public with sharing class CIBE_TranslationUtilities {
    
    private String language = UserInfo.getLanguage();
    private Map<String, String> translations = new Map<String, String>();

    public static CIBE_TranslationUtilities getInstance() {
        return new CIBE_TranslationUtilities();
    }

    /**
     *  Cambia el idioma en el que se obtendran las traducciones con el metodo queryTranslations() por el idioma por defecto del usuario loggeado
     */
    public CIBE_TranslationUtilities setLanguage() {
        this.language = UserInfo.getLanguage();
        return this;
    }

    /**
     *  Cambia el idioma en el que se obtendran las traducciones con el metodo queryTranslations()
     *  @param language Idioma en el que queremos obtener las traducciones
     */
    public CIBE_TranslationUtilities setLanguage(String language) {
        if(String.isNotBlank(language)) {
            this.language = language;
            return this;
        }

        throw new IllegalArgumentException('CIBE_TranslationUtilities - setLanguage(String language): language must not be empty!');
    }

    /**
     *  Añade el nombre de la traduccion que queremos obtener al mapa de traducciones pero no la obtiene.
     *  @param translationNames Lista de translations que queremos obtener
     */
    public CIBE_TranslationUtilities addTranslationName(String translationName) {
        if(String.isNotBlank(translationName)) {
            this.translations.put(translationName, '');
            return this;
        }

        throw new IllegalArgumentException('CIBE_TranslationUtilities - addTranslationName(String translationName): translationName must not be empty!');
    }

    /**
     *  Añade los nombres de las traducciones que queremos obtener al mapa de traducciones pero no las obtiene.
     *  @param translationNames Lista de translations que queremos obtener
     */
    public CIBE_TranslationUtilities addTranslationNames(List<String> translationNames) {
        if(translationNames != null) {
            for(String translationName : translationNames) {
                if(String.isNotBlank(translationName)) {
                    this.translations.put(translationName, '');
                }
            }
            return this;
        }

        throw new IllegalArgumentException('CIBE_TranslationUtilities - addTranslationNames(List<String> translationNames): translationNames must not be null!');
    }

    /**
     * Limpia los traducciones a obtener en el metodo 
     */
    public CIBE_TranslationUtilities clearTranslationNames() {
        this.translations = new Map<String, String>();
        return this;
    }

    /**
     * Obtiene las traducciones del custom metadata en caso de que existan y las añade al mapa
     */
    public CIBE_TranslationUtilities queryTranslations() {
        List<CIBE_TranslateConfiguration__mdt> translations = CIBE_TranslateConfiguration__mdt.getAll().values(); 
        
        for(CIBE_TranslateConfiguration__mdt translation : translations) {
            if(String.isNotBlank(translation.CIBE_TranslationName__c) && String.isNotBlank(translation.CIBE_Value__c) && this.translations.containsKey(translation.CIBE_TranslationName__c) && translation.CIBE_Language__c == this.language) {
                this.translations.put(translation.CIBE_TranslationName__c, translation.CIBE_Value__c);
            }
        }

        return this;
    }

    /**
     * Devuelve el idioma elegido para aplicar la traducción.
     */
    public String getLanguage() {
        return this.language;
    }

    /**
     * Devuelve el mapa de traducciones.
     */
    public Map<String, String> getTranslations() {
        return this.translations.clone();
    }

}