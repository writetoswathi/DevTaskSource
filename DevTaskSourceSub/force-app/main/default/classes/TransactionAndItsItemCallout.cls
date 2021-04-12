/*
 * Author   : Swathi
 * Purpose  : Handlerclass for TransactionItem__c to send out rest api call with Transactionitems details.
 * 
 * Revision  doc        Release              Modified By     Description
 * --------  -----      --------------       --------------  -------------
 * 1.0       xxxxxxx    12-Apr-2021          09-Apr-2021     Swathi--Send all the transaction items related to a transaction -API call
 
 * 
 * 
 */

public class TransactionAndItsItemCallout {


    //Class Variables
    public static final Integer TIMEOUT = 60000;
    public static final String METHOD = 'POST';
    public static boolean AUTHENTICATIONREQUIRED = false;
    public static String ENDPOINT;
    public static String USERNAME;
    public static String PASSWORD;

    //future callout method which is being fired from TransactionItemTrigger trigger.
    @future(callout = true)
    public static void doCalloutFromFuture(List < Id > setids) {
       

        system.debug('set ids' + setids);
        HttpResponse response = null;
        HTTPResponse discard = null;
        String requestBody = null;
        Map < string, Integer > mapTransactionitemsCount = new Map < string, Integer > ();



        //Aggregate result to capture count of transaction items based on its parent(Transaction).
        for (AggregateResult aggResult: [select Transaction__c transactionid, count(id) Transactionitemcount from
                TransactionItem__c where Transaction__c in: setids group by Transaction__c
            ]) {
            mapTransactionitemsCount.put((string) aggResult.get('transactionid'), (Integer) aggResult.get('Transactionitemcount'));
            system.debug('Transaction items count based on parent ' + mapTransactionitemsCount);
            system.debug('aggResult ' + aggResult);
        }

        //To get all transaction records based on transaction items and its counts
        List < Transaction__c > TransactionAll = new List < Transaction__c > ([select id, Total_Cost__c, 
                                                                            Total_Discount__c, CreatedDate, 
                                                                            Transaction_Count__c from Transaction__c 
                                                                            where id 
                                                                            in: mapTransactionitemsCount.keyset()]);
        Transaction__c[] Transactiontosendout = new List < Transaction__c > ();
        system.debug('All transactions...' + TransactionAll);



        //Verify and adding all transaction records into list based on count match with parent and childs 
        for (Transaction__c eachTransaction: TransactionAll) {
            system.debug('eachTransaction.Transaction_Count__c' + eachTransaction.Transaction_Count__c);
            system.debug('mapTransactionitemsCount.get(eachTransaction.id)' + mapTransactionitemsCount.get(eachTransaction.id));
            if (eachTransaction.Transaction_Count__c == mapTransactionitemsCount.get(eachTransaction.id)) {
                Transactiontosendout.add(eachTransaction);
                system.debug('Qualified transactions ' + Transactiontosendout);
            }
        }

        //all transaction items which need to send to clinet.
        list < TransactionItem__c > transactionitems = new List < TransactionItem__c > ([select id, name, item_cost__c, Transaction__c from TransactionItem__c where Transaction__c in: Transactiontosendout]);
        system.debug('transactionitems records.... ' + transactionitems);

        //system.debug('testing json ---- '+ JSON.serialize(transactionitems ));
        system.debug('testing json ---- 2---------- ' + JSON.serializePretty(transactionitems));

        // Http Callout to send Transanction items
        IF(transactionitems.size() != null) {
            // requestBody =  JSON.serializePretty(transactionitems);
            requestBody = JSON.serialize(transactionitems);
            system.debug('Request body for testing ' + requestBody);
            try {
                //commenting code here for testing purpose
                if (Test.IsRunningTest()) {
                    HttpRequest req = new HttpRequest();
                    req = createHttpRequestHeader();
                    MockCallOut mock = new mockCallout();
                    discard = mock.respond(req);
                } else {
                    response = sendHttpRequest(requestBody);
                }

            } catch (System.CalloutException e) {
                System.debug('Callout error: ' + e);

            }
        }


        // Http Callout to send Transanction when transaction item related response status = 200
        if (response != null && response.getStatusCode() == 200) {

            requestBody = JSON.serializePretty(TransactionAll);
            try {
                //commenting code here for testing purpose

                if (Test.IsRunningTest()) {
                    if (discard != null && discard.getstatusCode() == 200) {
                        HttpRequest req = new HttpRequest();
                        MockCallOut mock = new mockCallout();
                        discard = mock.respond(req);
                    }
                } else {
                    response = sendHttpRequest(requestBody);
                }
            } catch (System.CalloutException e) {
                System.debug('Callout error: ' + e);

            }
        }

    }
    
    //Method to send HTTPRequest
    public static HttpResponse sendHttpRequest(String requestBody) {
        //method call to create HttpRequest
        HttpRequest req = createHttpRequestHeader();
        //sets the request body
        req.setBody(requestBody);
        Http http = new Http();
        System.debug('## Authorization Header: ' + req.getHeader('Authorization'));
        //Sending the HTTP request
        HTTPResponse res = http.send(req);
        system.debug('Response..' + res);
        return res;
    }


    //Method to create HTTPRequest Header
    private static HttpRequest createHttpRequestHeader() {
        setAuthenticationInfo();
        HttpRequest req = new HttpRequest();
        //Set endpoint URL
        req.setEndpoint(ENDPOINT);
        //Set the method Type
        req.setMethod(METHOD);
        req.setHeader('Content-Type', 'application/json;charset=UTF-8');
        if (authenticationRequired) {
            // Specify the required user name and password to access the endpoint
            // As well as the header and header information
            Blob headerValue = Blob.valueOf(USERNAME + ':' + PASSWORD);
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            req.setHeader('Authorization', authorizationHeader);
        }
        //Set the timeout value for the Request
        req.setTimeout(TIMEOUT);
        return req;
    }


    //Methid to set parameters 
    private static void setAuthenticationInfo() {

        //Set header parameters - Here we can have sandbox and production credentials which can be captured under custom labels     

        // ENDPOINT = 'http://your-end-point.com/';
        ENDPOINT = 'http://example.com/example/test';
        USERNAME = 'usernamevalue'; //for PRODUCTION env
        PASSWORD = 'passwordvalues'; // to be filled in later
        authenticationRequired = true;
        System.debug('---Dev SANDBOX: ' + ENDPOINT + ': ' + USERNAME + ' -> ' + PASSWORD);
    }


}