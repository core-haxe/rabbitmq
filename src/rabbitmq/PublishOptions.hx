package rabbitmq;

typedef PublishOptions = {
    var ?userId:String;             // If supplied, RabbitMQ will compare it to the username supplied when opening the connection, and reject messages for which it does not match.
    var ?CC:Array<String>;          // an array of routing keys as strings; messages will be routed to these routing keys in addition to that given as the routingKey parameter. A string will be implicitly treated as an array containing just that string. This will override any value given for CC in the headers parameter. NB The property names CC and BCC are case-sensitive.
    var ?BCC:Array<String>;         // like CC, except that the value will not be sent in the message headers to consumers.
}