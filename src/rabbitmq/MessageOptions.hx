package rabbitmq;

typedef MessageOptions = {
    var ?expiration:String;         // if supplied, the message will be discarded from a queue once it’s been there longer than the given number of milliseconds. In the specification this is a string; numbers supplied here will be coerced to strings for transit.
    var ?priority:Int;              // a priority for the message; ignored by versions of RabbitMQ older than 3.5.0, or if the queue is not a priority queue (see maxPriority above).
    var ?persistent:Bool;           // If truthy, the message will survive broker restarts provided it’s in a queue that also survives restarts. Corresponds to, and overrides, the property deliveryMode.
    var ?mandatory:Bool;            // if true, the message will be returned if it is not routed to a queue (i.e., if there are no bindings that match its routing key).
    var ?contentType:String;        // a MIME type for the message content
    var ?contentEncoding:String;    // a MIME encoding for the message content
    var ?correlationId:String;      // usually used to match replies to requests, or similar
    var ?replyTo:String;            // often used to name a queue to which the receiving application must send replies, in an RPC scenario (many libraries assume this pattern)
    var ?messageId:String;          // arbitrary application-specific identifier for the message
    var ?timestamp:Int;             // a timestamp for the message
    var ?type:String;               // an arbitrary application-specific type for the message
    var ?appId:String;              // an arbitrary identifier for the originating application
}