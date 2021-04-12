/***********************************************************
* Name          : TransactionAndItsItemCalloutTest 
* Description   : Test Class for TransactionAndItsItemCalloutTest 
 * 
 * Revision  doc        Release              Modified By     Description
 * --------  -----      --------------       --------------  -------------
 * 1.0       xxxxxxx    12-Apr-2021          09-Apr-2021     Swathi--Send all the transaction items related to a transaction -API call
 
 * 
 * 
 */
@isTest
private class TransactionAndItsItemCalloutTest {

        
       static  List<Id> TransactionSetIds = new List<Id>();


       private static void CreateTestData(){

        List<Transaction__c > testTransaction_list= new List<Transaction__c >();
        
        Transaction__c testTransaction = new Transaction__c(Total_Cost__c = 22.20,Total_Discount__c =1,Transaction_Count__c =1);        
        testTransaction_list.add(testTransaction );
        insert testTransaction;
        
        TransactionItem__c testTransactionitem = new TransactionItem__c(name = 'Test_TI',item_cost__c= 23,Transaction__c =testTransaction.id );
        insert testTransactionitem; 
           
        TransactionSetIds.add(testTransactionitem.Transaction__c );
     }
    
     static testMethod void doCalloutFromFutureTest(){
         
         CreateTestData();
      
         test.startTest();
         TransactionAndItsItemCallout.doCalloutFromFuture(TransactionSetIds); 
         Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());        
         test.stopTest();     
     }
     
    @isTest static void testCallout() {
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        string s = '{"example":"test"}';
        // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        HttpResponse res = TransactionAndItsItemCallout.sendHttpRequest(s);
        
        // Verify response received contains fake values
        String contentType = res.getHeader('Content-Type');
        System.assert(contentType == 'application/json');
        String actualValue = res.getBody();
        String expectedValue = '{"example":"test"}';
        
        System.assertEquals(actualValue, expectedValue);
        System.assertEquals(200, res.getStatusCode());
    }
}