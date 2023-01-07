package rabbitmq.externs.nodejs;

typedef ExchangeOptions = {
    var ?durable:Bool;              // if true, the exchange will survive broker restarts. Defaults to true.
    var ?internal:Bool;             // if true, messages cannot be published directly to the exchange (i.e., it can only be the target of bindings, or possibly create messages ex-nihilo). Defaults to false.
    var ?autoDelete:Bool;           // if true, the exchange will be destroyed once the number of bindings for which it is the source drop to zero. Defaults to false.
    var ?alternateExchange:String;  // an exchange to send messages to if this exchange can’t route them to any queues.
    var ?arguments:Dynamic;         // any additional arguments that may be needed by an exchange type.
}