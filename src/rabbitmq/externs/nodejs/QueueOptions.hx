package rabbitmq.externs.nodejs;

typedef QueueOptions = {
    var ?exclusive:Bool;        // if true, scopes the queue to the connection (defaults to false)
    var ?durable:Bool;          // if true, the queue will survive broker restarts, modulo the effects of exclusive and autoDelete; this defaults to true if not supplied, unlike the others
    var ?autoDelete:Bool;       // if true, the queue will be deleted when the number of consumers drops to zero (defaults to false)
    var ?arguments:Dynamic;     // additional arguments, usually parameters for some kind of broker-specific extension e.g., high availability, TTL.
                                // RabbitMQ extensions can also be supplied as options. These typically require non-standard x-* keys and values, sent in the arguments table; e.g., 'x-expires'. When supplied in options, the x- prefix for the key is removed; e.g., 'expires'. Values supplied in options will overwrite any analogous field you put in options.arguments.
}