global class mockCallout implements HttpCalloutMock
{
    global HttpResponse respond(HttpRequest request)
    {
        HttpResponse res = new HttpResponse();
        res.setBody( '{"text":"value"}');
        res.setStatusCode(200);
        return res;
    }   
}