@isTest
public class CBK_UtilsDate_Test {
    @isTest
    public static void testNowDT (){
        CBK_UtilsDate.nowDatetime = DateTime.newInstance(2023,1,1,23,55,0);
        Datetime dt = CBK_UtilsDate.nowDT();
        System.assertEquals(dt,CBK_UtilsDate.nowDatetime);
    }
    @isTest
    public static void testNowDT2 (){
        Datetime dt = CBK_UtilsDate.nowDT();
        System.assertNotEquals(dt,null);
    }
    @isTest
    public static void testTodayDT (){
        CBK_UtilsDate.todayDate = Date.newInstance(2023,1,22);
        Date dt = CBK_UtilsDate.todayDT();
        System.assertEquals(dt,CBK_UtilsDate.todayDate);
    }
    @isTest
    public static void testTodayDT2 (){
        Date dt = CBK_UtilsDate.todayDT();
        System.assertNotEquals(dt,null);
    }

    @isTest
    public static void testNowSYS (){
        CBK_UtilsDate.nowSystem = DateTime.newInstance(2023,1,1,23,55,0);
        Datetime dt = CBK_UtilsDate.nowSYS();
        System.assertEquals(dt,CBK_UtilsDate.nowSystem);
    }

    @isTest
    public static void testNowSYS2 (){
        Datetime dt = CBK_UtilsDate.nowSYS();
        System.assertNotEquals(dt,null);
    }

    @isTest
    public static void testTodaySYS (){
        CBK_UtilsDate.todaySystem = Date.newInstance(2023,1,22);
        Datetime dt = CBK_UtilsDate.todaySYS();
        System.assertEquals(dt,CBK_UtilsDate.todaySystem);
    }

    @isTest
    public static void testTodaySYS2 (){
        Datetime dt = CBK_UtilsDate.todaySYS();
        System.assertNotEquals(dt,null);
    }
}