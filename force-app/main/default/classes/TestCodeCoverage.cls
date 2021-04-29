@isTest
private class TestCodeCoverage {

    static testMethod void myUnitTest() {
        system.assertEquals(5000, CodeCoverage.coverme());
    }
    
    static testMethod void myUnitTest2() {
        system.assertEquals(5000, CodeCoverage2.coverme());
    }
    
    static testMethod void myUnitTest3() {
        system.assertEquals(5000, CodeCoverage3.coverme());
    }      
}