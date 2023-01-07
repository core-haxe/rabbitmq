package rabbitmq.externs.nodejs;

typedef ConsumeOptions = {
    var ?consumerTag:String;    // a name which the server will use to distinguish message deliveries for the consumer; mustn’t be already in use on the channel. It’s usually easier to omit this, in which case the server will create a random name and supply it in the reply.
    var ?noLocal:Bool;          // in theory, if true then the broker won’t deliver messages to the consumer if they were also published on this connection; RabbitMQ doesn’t implement it though, and will ignore it. Defaults to false.
    var ?noAck:Bool;            // if true, the broker won’t expect an acknowledgement of messages delivered to this consumer; i.e., it will dequeue messages as soon as they’ve been sent down the wire. Defaults to false (i.e., you will be expected to acknowledge messages).
    var ?exclusive:Bool;        // if true, the broker won’t let anyone else consume from this queue; if there already is a consumer, there goes your channel (so usually only useful if you’ve made a ‘private’ queue by letting the server choose its name).
    var ?priority:Int;          //  gives a priority to the consumer; higher priority consumers get messages in preference to lower priority consumers.
    var ?arguments:Dynamic;     // arbitrary arguments. Go to town.
}