public class CBK_UtilsDate {
      // Propiedad privada para no sobreescribir en clases normales que no son test.
    @TestVisible
    private static Datetime nowDatetime;

    // Propiedad privada para no sobreescribir en clases normales que no son test.
    @TestVisible
    private static Date todayDate;

    // Propiedad privada para no sobreescribir en clases normales que no son test.
    @TestVisible
    private static Datetime nowSystem;

    // Propiedad privada para no sobreescribir en clases normales que no son test.
    @TestVisible
    private static Date todaySystem;

    /**
     * @description Obtención de la fecha / hora actual mediante Datetime.now() usando el FWK para test
     * https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_methods_system_datetime.htm#apex_System_Datetime_now
     * @return Fecha / Hora actual en base a Datetime.now() o sobrescritura en la clase de test.
     */
    public static Datetime nowDT() {
        return nowDatetime == null ? Datetime.now() : nowDatetime;
    }

    /**
    * @description Obtención de la fecha actual mediante Datetime.today() usando el FWK para test
    * https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_methods_system_date.htm#apex_System_Date_today
    * @return Fecha actual en base a Date.today() o sobrescritura en la clase de test.
    */
    public static Date todayDT() {
        return todayDate == null ? Date.today() : todayDate;
    }

    /**
     * @description Obtención de la fecha / hora actual mediante Datetime.now() usando el FWK para test
     * https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_methods_system_system.htm#apex_System_System_now
     * @return Fecha / Hora actual en base a System.now() o sobrescritura en la clase de test.
     */
    public static Datetime nowSYS() {
        return nowSystem == null ? System.now() : nowSystem;
    }

    /**
    * @description Obtención de la fecha actual mediante Datetime.today() usando el FWK para test
    * https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_methods_system_system.htm#apex_System_System_today
    * @return Fecha actual en base a System.today() o sobrescritura en la clase de test.
    */
    public static Date todaySYS() {
        return todaySystem == null ? System.today() : todaySystem;
    }
}