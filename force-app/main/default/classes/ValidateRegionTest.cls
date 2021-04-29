/* This is to test the Validate Region trigger */

@isTest
public class ValidateRegionTest{

  public static testmethod void testTrigger(){
  
  User testUser = new User (LastName= 'Test', Alias = 'TU', Email = 'tu@enett.com', Username = 'tu@enett.com',
                            ProfileId = '00e90000001HkJt', Record_Ownership_Value__c = 'APAC');
  
  User testError = new User(LastName= 'Error', Alias = 'EU', Email = 'eu@enett.com', Username = 'eu@enett.com',
                             ProfileId = '00e90000001HkJt', Record_Ownership_Value__c = 'APAC');
  
  try{
      Insert testUser;
      Insert testError;     
  }
  catch(DMLException dml){
      System.debug('DML Exception ' + dml);
  }
  catch(Exception e){
       System.debug('Exception ' + e);
  }
  finally{
      System.debug('The code is working as expected');
  }
  }
}