package rabbitmq.externs.nodejs;

typedef PublishOptions = {
    var ?expiration:String;         // if supplied, the message will be discarded from a queue once it’s been there longer than the given number of milliseconds. In the specification this is a string; numbers supplied here will be coerced to strings for transit.
    var ?userId:String;             // If supplied, RabbitMQ will compare it to the username supplied when opening the connection, and reject messages for which it does not match.
    var ?CC:Array<String>;          // an array of routing keys as strings; messages will be routed to these routing keys in addition to that given as the routingKey parameter. A string will be implicitly treated as an array containing just that string. This will override any value given for CC in the headers parameter. NB The property names CC and BCC are case-sensitive.
    var ?priority:Int;              // a priority for the message; ignored by versions of RabbitMQ older than 3.5.0, or if the queue is not a priority queue (see maxPriority above).
    var ?persistent:Bool;           // If truthy, the message will survive broker restarts provided it’s in a queue that also survives restarts. Corresponds to, and overrides, the property deliveryMode.
    //var ?deliveryMode:Int;        // Either 1 or falsey, meaning non-persistent; or, 2 or truthy, meaning persistent. That’s just obscure though. Use the option persistent instead.
    var ?mandatory:Bool;            // if true, the message will be returned if it is not routed to a queue (i.e., if there are no bindings that match its routing key).
    var ?BCC:Array<String>;         // like CC, except that the value will not be sent in the message headers to consumers.
    //var ?immediate:Bool;          // in the specification, this instructs the server to return the message if it is not able to be sent immediately to a consumer. No longer implemented in RabbitMQ, and if true, will provoke a channel error, so it’s best to leave it out.
    var ?contentType:String;        // a MIME type for the message content
    var ?contentEncoding:String;    // a MIME encoding for the message content
    var ?headers:Dynamic;           // application specific headers to be carried along with the message content. The value as sent may be augmented by extension-specific fields if they are given in the parameters, for example, ‘CC’, since these are encoded as message headers; the supplied value won’t be mutated.
    var ?correlationId:String;      // usually used to match replies to requests, or similar
    var ?replyTo:String;            // often used to name a queue to which the receiving application must send replies, in an RPC scenario (many libraries assume this pattern)
    var ?messageId:String;          // arbitrary application-specific identifier for the message
    var ?timestamp:Int;             // a timestamp for the message
    var ?type:String;               // an arbitrary application-specific type for the message
    var ?appId:String;              // an arbitrary identifier for the originating application
}